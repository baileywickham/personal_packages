---
name: insert-secret
description: "Use instead of asking Bailey to paste or set a secret (API key, token, client secret), edit .env himself, or run put-secret-value: opens a new Chrome window with a localhost form, he types the value, it lands in a local env file (dev) or AWS Secrets Manager (staging, production), and you only learn the key names. Also when he types /insert-secret."
---

# /insert-secret

Whenever a task is blocked on a secret Bailey has to supply (a dev API key, an OAuth client
secret, a token for `.env` or for a staging or production secret), don't ask him in chat and don't
tell him to go edit the file or run a CLI command. Run the form and keep working once it reports
back. Lives in `personal_packages/config/claude/skills/insert-secret`, symlinked into
`~/.claude/skills/`.

Dev secrets, into an env file:

```bash
python3 ~/.claude/skills/insert-secret/insert_secret.py \
  --env-file <path to .env> --key SOME_API_KEY [--key OTHER_KEY] [--note "where to find it"]
```

Staging and production secrets, into AWS Secrets Manager. Never an env file:

```bash
python3 ~/.claude/skills/insert-secret/insert_secret.py \
  --aws-profile AWSAdministratorAccess-<account> \
  --aws-secret LABEL=<secret id> [--aws-secret OTHER=<secret id>] [--note "where to find it"]
```

- Run it with `run_in_background: true`; it blocks until he hits Save (15 min timeout), and you
  get notified when it exits. Tell him in one line that a Chrome window is open and which keys
  or secrets it wants.
- `--note`: one line on where the value comes from (1Password item, vendor dashboard), if you know.
- Never `cat`, `grep`, read back or print a value afterwards to check; trust the exit line.

Env file mode:
- `--env-file`: the env file the code actually reads, usually the checkout or worktree root
  `.env`. In a worktree, use that worktree's `.env`, not `~/workspace/hone/.env`.
- `--key`: prefill each key name you need, exactly as the code reads it. He can add rows.
- Existing keys are replaced in place, others are appended, file mode is kept.
- Exit 0 prints only `Saved to <file>: KEY1, KEY2`; restart whatever process needs the new env.

Secrets Manager mode:
- The secret must already exist (created by Terraform or the owning stack); this sets its value,
  it never creates or deletes a secret.
- Before the form opens it runs `describe-secret` on each id with `--aws-profile`, so an expired
  SSO session or a wrong id fails right away (exit 2) instead of after he pasted. If SSO expired,
  ask him to run `aws sso login --profile <profile>`, then rerun.
- The page shows each secret's full ARN, the account in it, and the profile, so he can see where
  it writes. Rows are fixed to the `--aws-secret` list; he can't add or rename one, and every row
  must be filled.
- The value goes to `aws secretsmanager put-secret-value --secret-string file:///dev/stdin`: never
  in a process argument list, a shell history or a file. Any AWS error is printed with the value
  scrubbed.
- Exit 0 prints `Stored in Secrets Manager: LABEL → <secret id> (version <id>)` per secret. Exit 3
  names the secret that failed and the ones stored before it.
- Production access: only for a secret the task needs and Bailey asked for, with the profile he
  uses for that account. Never the hone-dev account (351389404199).

Exit 1 in either mode means it timed out with nothing saved: say so and offer to reopen it.
