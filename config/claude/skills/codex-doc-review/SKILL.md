---
name: codex-doc-review
description: Get a second-model review from OpenAI Codex (gpt-5.6-sol) of a doc, note, spec, plan, or research write-up Claude just produced. Fact-checks, finds contradictions, unsupported claims, stale numbers, gaps. Use after writing a substantive document, or when Bailey says "have codex review", "codex check", "second opinion". For code diffs use the plugin's /codex:review or /codex:adversarial-review instead.
---

# codex-doc-review

Runs Codex as a read-only reviewer subagent over one or more files, then folds the
findings back into the document. Lives in `personal_packages/config/claude/skills/`,
symlinked into `~/.claude/skills/` and `~/.codex/skills/`. Built on OpenAI's official Claude Code plugin
(`codex@openai-codex`, repo `openai/codex-plugin-cc`), which is installed at user
scope. The plugin's `task` runtime does the work; this skill supplies the doc-review
prompt and the fold-back workflow. Read-only sandbox: Codex can read the whole
working root (and the web) but cannot edit anything.

## When to run it

- After writing or substantially rewriting a doc that makes checkable claims: vault
  notes with numbers, tax/finance notes, specs, plans, READMEs, research summaries.
- Not for trivial edits, todo items, or notes that are pure transcription of what
  Bailey said.
- Always before telling Bailey a high-stakes doc (money, taxes, legal, medical) is
  done.

## Procedure

1. **Locate the runtime** (path changes with plugin version):
   ```bash
   COMPANION=$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs | sort -V | tail -1)
   ```
   If that finds nothing, tell Bailey to run `/plugin install codex@openai-codex` and
   stop. If Codex reports "unauthenticated", tell him to run `/codex:setup`.

2. **Write the prompt** to the scratchpad from `prompt-template.md` in this skill's
   folder. Fill in:
   - `{{FILES}}`: one `- /absolute/path` line per file.
   - `{{ROOT}}`: the git root of the files (the vault root for vault notes).
   - `{{FOCUS}}`: `Extra focus from the requester: ...` with anything specific worth
     weighting (which claims matter most, which raw sources to check against, what the
     doc assumes), or leave blank.

3. **Run it.** Foreground for one or two short files, background otherwise:
   ```bash
   node "$COMPANION" task --wait --model gpt-5.6-sol --effort high --cwd "$ROOT" --prompt-file "$PROMPT" </dev/null
   ```
   ```bash
   node "$COMPANION" task --background --model gpt-5.6-sol --effort high --cwd "$ROOT" --prompt-file "$PROMPT" </dev/null
   ```
   - `</dev/null` matters: without it Codex waits on stdin and hangs.
   - Do **not** pass `--write`. Reviews are read-only.
   - Defaults are **`--model gpt-5.6-sol --effort high`**: sol is the newest flagship
     and Bailey wants it by default. When a newer GPT appears (check
     `~/.codex/models_cache.json`), move the default to it. Measured on a one-page
     note: medium ~35 s, high 1-7 min depending on how much Codex goes and checks.
   - Background jobs: `/codex:status` lists them, `/codex:result <job-id>` prints the
     output. Use a Bash `run_in_background` call and wait for the notification rather
     than polling.
   - stdout is progress lines prefixed `[codex]` followed by the review markdown.

4. **Triage the findings yourself.** Codex is a reviewer, not an authority:
   - For each Error or Risk, check it against the source (the raw file, the repo, the
     command output). Accept, reject with a reason, or mark "needs Bailey".
   - Apply accepted fixes to the document in place.
   - Keep the document's cite discipline: a fix that adds a fact adds its wikilink or
     source.

5. **Report back** in chat: what Codex flagged, what was fixed, what was rejected and
   why, and what needs Bailey's answer. Short table or bullets, not the raw review.

6. **Saving the review.** Default is not to. Only create a `<note> - Codex review.md`
   sibling (precedent: `claude/finance/Console sale tax plan 2026 - Codex review.md`,
   frontmatter `reviewer: "OpenAI Codex CLI (gpt-5.6-sol, read-only sandbox)"`) when
   Bailey asks or the findings are a checklist for a third party (a CPA, a lawyer).
   If a note is created, add it to `claude/index.md` in the same edit.

## Code, not docs

For reviewing code changes use the plugin directly: `/codex:review` (built-in reviewer
over the working tree or `--base <ref>`) or `/codex:adversarial-review <focus>` (steerable,
returns structured findings with line numbers). `/codex:rescue` delegates a task to Codex
with write access. Those are code-shaped prompts and do badly on prose, which is why this
skill exists.

## Gotchas

- `~/.codex/config.toml` sets gpt-5.5 at xhigh for interactive Codex; the skill
  overrides model and effort per call and leaves that file alone. Plain `gpt-5.6` is
  rejected on a ChatGPT account; the sol/terra/luna names work. A `notify` hook there launches the Codex Computer Use client on turn end; the
  plugin runtime handles this, but if running raw `codex exec` add `-c 'notify=[]'`.
- The sandbox blocks `crontab -l`, network writes, and builds. Codex will say so in its
  findings ("could not verify"); that is fine, do not re-run to chase it.
- Codex sometimes checks live machine state (installed versions, `claude mcp get`) and
  flags a note as stale when it was accurate on its date. Fix by dating the claim, not
  by deleting it.
