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

- Sections: **Open** (one list) and **Done**.
- New items get the date added: `- [ ] call the bank ➕ 2026-08-04` (optional
  `📅 2026-09-15` due date, `🔁 every week` repeat).
- Finished items get checked and moved to Done with the completion date:
  `- [x] call the bank ➕ 2026-08-04 ✅ 2026-08-05`; dropped ones become
  `- [-] … ❌ 2026-08-05`.
- Always modify/append — never overwrite, clear, or delete items.
- One short line per item: verb first, ~120 characters max, no status updates or
  evidence inside the line (rewrite it instead). Don't create a note to hold a
  TODO's context; link an existing note only if one already covers it.
- Don't reshuffle his priorities silently: ask before moving an open item to
  TODO eventually or Done.

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

