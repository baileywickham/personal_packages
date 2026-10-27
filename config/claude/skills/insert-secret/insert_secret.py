#!/usr/bin/env python3
"""Open a one-shot localhost form in a new Chrome window; store what Bailey types.

Two destinations: a local env file (dev secrets) or AWS Secrets Manager (staging and production).
The values never pass through stdout, so the agent that runs this only learns which keys were set.
"""

import argparse
import html
import json
import os
import re
import secrets
import subprocess
import sys
import tempfile
import threading
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs

KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
# Secrets Manager's own name alphabet, so a typo fails here rather than as an AWS error.
SECRET_ID_RE = re.compile(r"^[A-Za-z0-9/_+=.@-]+$")
# Long enough to go find a key in 1Password, short enough that a forgotten window doesn't leave a
# listener up all afternoon.
TIMEOUT_SECONDS = 15 * 60

PAGE = """<!doctype html><meta charset="utf-8"><title>Insert secret</title>
<style>
body{{font:15px -apple-system,system-ui,sans-serif;max-width:680px;margin:48px auto;padding:0 16px;color:#222}}
code{{background:#f2f2f2;padding:1px 4px;border-radius:3px}}
.row{{display:flex;gap:8px;margin:8px 0}} .row input{{flex:1;padding:8px;font:14px ui-monospace,monospace}}
.row input.k{{flex:0 0 38%}} button{{padding:8px 14px;font-size:14px;cursor:pointer}}
p.note{{color:#666}} p.warn{{background:#fff4e5;border:1px solid #f0b36b;padding:8px 10px;border-radius:4px}}
</style>
<h2>Insert secret</h2>
{target}
{note}
<form method="post">
<div id="rows">{rows}</div>
{add_row}
<button type="submit">Save</button>
</form>
<script>
function addRow(){{const d=document.createElement('div');d.className='row';
d.innerHTML='<input class="k" name="key" placeholder="KEY_NAME"><input name="value" type="password" placeholder="value" autocomplete="off">';
document.getElementById('rows').appendChild(d);}}
document.querySelector('input[name=value]')?.focus();
</script>
"""

ROW = (
    '<div class="row"><input class="k" name="key" value="{key}" placeholder="KEY_NAME">'
    '<input name="value" type="password" placeholder="value" autocomplete="off"></div>'
)
# AWS rows name their secret and cannot be edited: the form may only write the secrets the
# command line named, and only after their preflight passed.
AWS_ROW = (
    '<div class="row"><input class="k" name="key" value="{key}" readonly>'
    '<input name="value" type="password" placeholder="value" autocomplete="new-password"></div>'
)


@dataclass(frozen=True)
class AwsTarget:
    key: str
    secret_id: str
    arn: str


def format_value(value: str) -> str:
    if re.fullmatch(r"[A-Za-z0-9_./:@+=,-]*", value):
        return value
    # Single quotes turn off interpolation in both python-dotenv and docker compose.
    if "'" not in value:
        return f"'{value}'"
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def write_env(env_file: Path, updates: dict[str, str]) -> None:
    lines = env_file.read_text().splitlines() if env_file.exists() else []
    remaining = dict(updates)
    out = []
    for line in lines:
        match = re.match(r"^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=", line)
        if match and match.group(1) in remaining:
            key = match.group(1)
            out.append(f"{key}={format_value(remaining.pop(key))}")
        else:
            out.append(line)
    out.extend(f"{key}={format_value(value)}" for key, value in remaining.items())
    # Write beside the target and rename so a crash never leaves a half-written .env.
    fd, tmp = tempfile.mkstemp(dir=env_file.parent, prefix=".env.insert-secret.")
    with os.fdopen(fd, "w") as f:
        f.write("\n".join(out) + "\n")
    if env_file.exists():
        os.chmod(tmp, env_file.stat().st_mode & 0o777)
    os.replace(tmp, env_file)


def aws(profile: str, region: str, *args: str, stdin: str | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["aws", "--profile", profile, "--region", region, *args],
        input=stdin,
        capture_output=True,
        text=True,
    )


def preflight_aws(profile: str, region: str, mapping: list[tuple[str, str]]) -> list[AwsTarget] | str:
    """Resolve each secret before the form opens, so an expired session or a missing secret fails
    while Bailey still holds the value, not after he pasted it."""
    targets = []
    for key, secret_id in mapping:
        proc = aws(profile, region, "secretsmanager", "describe-secret", "--secret-id", secret_id, "--output", "json")
        if proc.returncode != 0:
            return f"cannot reach secret {secret_id} with profile {profile}: {proc.stderr.strip()}"
        targets.append(AwsTarget(key=key, secret_id=secret_id, arn=json.loads(proc.stdout)["ARN"]))
    return targets


def put_secret(profile: str, region: str, target: AwsTarget, value: str) -> str:
    """Store one value as the secret's new current version; returns the version id.

    The value goes to the CLI on stdin (file:///dev/stdin), so it is never in a process argument
    list, a shell history or a file. AWS errors do not echo the value, but stderr is scrubbed of it
    before anything prints, in case one ever does.
    """
    proc = aws(
        profile,
        region,
        "secretsmanager",
        "put-secret-value",
        "--secret-id",
        target.arn,
        "--secret-string",
        "file:///dev/stdin",
        "--query",
        "VersionId",
        "--output",
        "text",
        stdin=value,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.replace(value, "<value>").strip())
    return proc.stdout.strip()


def parse_aws_secret(spec: str) -> tuple[str, str]:
    key, sep, secret_id = spec.partition("=")
    if not sep or not KEY_RE.match(key) or not SECRET_ID_RE.match(secret_id):
        raise argparse.ArgumentTypeError(f"expected LABEL=SECRET_ID, got {spec!r}")
    return key, secret_id


def main() -> int:
    parser = argparse.ArgumentParser()
    dest = parser.add_mutually_exclusive_group(required=True)
    dest.add_argument("--env-file", type=Path, help="dev secrets: the env file to write")
    dest.add_argument(
        "--aws-secret",
        action="append",
        type=parse_aws_secret,
        metavar="LABEL=SECRET_ID",
        help="staging/production: a Secrets Manager secret to set (repeatable)",
    )
    parser.add_argument("--aws-profile", help="AWS profile that may PutSecretValue (with --aws-secret)")
    parser.add_argument("--aws-region", default="us-east-1")
    parser.add_argument("--key", action="append", default=[], help="prefill a key name (repeatable, --env-file)")
    parser.add_argument("--note", default="", help="one line shown above the form, e.g. where to find it")
    parser.add_argument("--no-open", action="store_true", help="print the URL instead of opening Chrome")
    args = parser.parse_args()

    env_file: Path | None = None
    targets: list[AwsTarget] = []
    if args.env_file is not None:
        env_file = args.env_file.expanduser().resolve()
        if not env_file.parent.is_dir():
            print(f"error: {env_file.parent} does not exist", file=sys.stderr)
            return 2
        for key in args.key:
            if not KEY_RE.match(key):
                print(f"error: invalid key name {key!r}", file=sys.stderr)
                return 2
        target_html = f"<p>Writes to <code>{html.escape(str(env_file))}</code>. Existing keys are replaced; blank rows are skipped.</p>"
        rows = "".join(ROW.format(key=html.escape(k)) for k in (args.key or [""]))
        add_row = '<button type="button" onclick="addRow()">+ row</button>'
    else:
        if not args.aws_profile:
            print("error: --aws-secret needs --aws-profile", file=sys.stderr)
            return 2
        if args.key:
            print("error: --key is for --env-file; label AWS rows in --aws-secret", file=sys.stderr)
            return 2
        resolved = preflight_aws(args.aws_profile, args.aws_region, args.aws_secret)
        if isinstance(resolved, str):
            print(f"error: {resolved}", file=sys.stderr)
            return 2
        targets = resolved
        listed = "".join(
            f"<li><code>{html.escape(t.key)}</code> → <code>{html.escape(t.arn)}</code></li>" for t in targets
        )
        target_html = (
            f'<p class="warn">Sets a new current version of these AWS Secrets Manager secrets, as '
            f"<code>{html.escape(args.aws_profile)}</code>. Nothing is written to disk. Every row must be filled.</p>"
            f"<ul>{listed}</ul>"
        )
        rows = "".join(AWS_ROW.format(key=html.escape(t.key)) for t in targets)
        add_row = ""

    # The token keeps other local processes and web pages from posting into the target.
    token = secrets.token_urlsafe(24)
    result: dict[str, list[str]] = {}

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_: object) -> None:
            pass

        def _send(self, status: int, body: str) -> None:
            data = body.encode()
            self.send_response(status)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(data)

        def _ours(self) -> bool:
            # A page that rebinds its own hostname to 127.0.0.1 still sends that hostname as Host,
            # so only the exact address this server printed may reach the form.
            if self.headers.get("Host") != f"127.0.0.1:{server.server_port}" or self.path != f"/{token}":
                self._send(404, "not found")
                return False
            return True

        def do_GET(self) -> None:
            if not self._ours():
                return
            note = f'<p class="note">{html.escape(args.note)}</p>' if args.note else ""
            self._send(200, PAGE.format(target=target_html, rows=rows, add_row=add_row, note=note))

        def do_POST(self) -> None:
            if not self._ours():
                return
            length = int(self.headers.get("Content-Length", "0"))
            form = parse_qs(self.rfile.read(length).decode(), keep_blank_values=True)
            pairs = list(zip(form.get("key", []), form.get("value", [])))
            if targets:
                self._save_aws(dict(pairs))
            else:
                self._save_env(pairs)

        def _save_env(self, pairs: list[tuple[str, str]]) -> None:
            updates: dict[str, str] = {}
            for key, value in pairs:
                key = key.strip()
                if not key and not value:
                    continue
                if not KEY_RE.match(key):
                    self._send(400, f"Invalid key name {html.escape(key)!r}. Go back and fix it.")
                    return
                if "\n" in value or "\r" in value:
                    self._send(400, f"{html.escape(key)} has a newline. Go back and fix it.")
                    return
                updates[key] = value
            if not updates:
                self._send(400, "Nothing to save. Go back and fill a row.")
                return
            assert env_file is not None
            write_env(env_file, updates)
            result["saved"] = list(updates)
            self._done("Saved. You can close this window.")

        def _save_aws(self, submitted: dict[str, str]) -> None:
            # Only the preflighted secrets, each exactly once; a row the page did not render is
            # refused rather than mapped anywhere.
            if set(submitted) != {t.key for t in targets}:
                self._send(400, "The form does not match the secrets this run was started for.")
                return
            for t in targets:
                value = submitted[t.key]
                if not value or value != value.strip():
                    self._send(400, f"{html.escape(t.key)} is empty or has leading or trailing whitespace. Go back and fix it.")
                    return
            saved = []
            for t in targets:
                try:
                    version = put_secret(args.aws_profile, args.aws_region, t, submitted[t.key])
                except RuntimeError as err:
                    done = ", ".join(saved) or "none"
                    self._send(500, f"<p>Storing {html.escape(t.key)} failed: <code>{html.escape(str(err))}</code></p><p>Already stored: {html.escape(done)}.</p>")
                    result["saved"] = saved
                    result["failed"] = [f"{t.key}: {err}"]
                    threading.Thread(target=server.shutdown, daemon=True).start()
                    return
                saved.append(f"{t.key} → {t.secret_id} (version {version})")
            result["saved"] = saved
            self._done("Stored in Secrets Manager. You can close this window.")

        def _done(self, message: str) -> None:
            self._send(200, f"<p style='font:15px system-ui;margin:48px'>{html.escape(message)}</p>")
            threading.Thread(target=server.shutdown, daemon=True).start()

    server = HTTPServer(("127.0.0.1", 0), Handler)
    url = f"http://127.0.0.1:{server.server_port}/{token}"
    where = str(env_file) if env_file else ", ".join(t.secret_id for t in targets)
    if args.no_open:
        print(url, flush=True)
    else:
        subprocess.run(["open", "-na", "Google Chrome", "--args", "--new-window", url], check=True)
        print(f"Opened a Chrome window for {where}; waiting for Bailey to save.", flush=True)

    timer = threading.Timer(TIMEOUT_SECONDS, server.shutdown)
    timer.daemon = True
    timer.start()
    server.serve_forever()
    timer.cancel()

    if "failed" in result:
        print(f"Failed: {result['failed'][0]}. Stored before it: {', '.join(result['saved']) or 'none'}", file=sys.stderr)
        return 3
    if "saved" not in result:
        print(f"Timed out after {TIMEOUT_SECONDS // 60} min with nothing saved.", file=sys.stderr)
        return 1
    if env_file:
        print(f"Saved to {env_file}: {', '.join(result['saved'])}")
    else:
        print("Stored in Secrets Manager: " + "; ".join(result["saved"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
