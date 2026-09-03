# Personal tasks → Obsidian

Bailey sometimes uses Claude Code for personal (non-work) things. When a personal
task produces documentation or notes worth keeping, store them in his Obsidian
vault (`~/workspace/obsidian`), inside the `claude/` folder. Source documents
(PDFs, statements, exports) go under `claude/raw/<area>/` via the vault's
`/ingest` skill; see the vault's `AGENTS.md` for the wiki rules. Write them as normal
Obsidian markdown (wikilinks/frontmatter fine), or use the `obsidian` CLI if the
app is running.

## Daily TODOs → `TODO.md`

`~/workspace/obsidian/personal/TODO.md` is Bailey's **canonical** todo
list — use it for anything like "add X to my todos" or "what's on my plate
today". (An older, retired `TODO.md` sits in `Archive/`. The finance action
list that used to live at `claude/finance/Action list - now.md` was merged
into TODO.md / TODO eventually.md on 2026-08-05 and deleted.) Rules:

- Sections: **Today**, **This Week**, **Done**.
- New items get the date added: `- [ ] (2026-08-04) call the bank`.
- Finished items get checked and moved to Done with the completion date:
  `- [x] (added 2026-08-04, done 2026-08-05) call the bank`.
- Always modify/append — never overwrite, clear, or delete items.
- If Today has stale items from previous days, ask Bailey whether to move them
  to This Week or Done — don't reshuffle his priorities silently.

Someday/no-deadline items go in `~/workspace/obsidian/personal/TODO eventually.md`
(sections: **Eventually**, **Done**; same dating and append-only rules). When
an item there becomes timely, move it into `TODO.md`.

# Git commit signing → 1Password

Bailey signs commits (and authenticates git pushes) with 1Password, which needs
his fingerprint. If a commit or push fails on it — `1Password: failed to fill
whole buffer`, a signing timeout, or `correct access rights` on push — that just
means the prompt went unanswered: tell him, stop, and retry the same command
when he replies. Never work around it with `--no-gpg-sign`, and never disable
`commit.gpgsign`.

