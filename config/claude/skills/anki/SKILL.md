---
name: anki
description: Use when asked to create, add, edit, remove, or reorganize Anki flashcards or decks — "make me cards about X", "add this to my Anki", "merge/rename my decks", or any spaced-repetition/memorization request.
---

# Anki Cards

Bailey's Anki cards live as YAML in the public repo at `~/workspace/anki-decks`
(github.com/baileywickham/anki-decks). The YAML is the source of truth;
`push.py` upserts it into live desktop Anki via AnkiConnect and syncs to his
phone via AnkiWeb. Always go through the repo — never add or edit notes
directly via AnkiConnect, AppleScript, or the Anki UI.

## Workflow — a card change is these four steps, in order

1. `cd ~/workspace/anki-decks && git pull`
   (if the directory is missing: `git clone git@github.com:baileywickham/anki-decks.git ~/workspace/anki-decks`)
2. Add or edit YAML under `decks/` (format below).
3. `uv run push.py` — launches Anki if needed, upserts changed cards, moves
   notes whose `deck:` changed, triggers AnkiWeb sync. Read its output:
   report the added/updated/moved counts and relay any orphan warnings to
   Bailey verbatim.
4. `git add -A && git commit && git push` — git history is the audit trail of
   every card change across sessions. A push into Anki without a git commit is
   an unfinished job, whether or not Bailey asked for a commit.

## Card format

One YAML file per topic. Several files may share one `deck:` name — files are
repo organization, decks are Anki organization.

```yaml
deck: ML                # `::` creates subdecks; prefer ONE deck + tags
cards:
  - id: kv-cache-01     # permanent kebab-case slug — never change once pushed
    type: basic         # basic | cloze | code
    front: What dominates GPU memory in LLM serving?
    back: The KV cache.
    tags: [llm-serving]
```

Types: `basic` (front/back) · `cloze` (`text` with `{{c1::…}}`, optional
`extra`) · `code` (`front` prompt, `back` verbatim code, rendered monospace).

## Invariants

- Never change a card's `id` once pushed — it is the note's permanent
  identity (the hidden AD-ID field); a changed id reads as a new note and
  duplicates it. Ids must be unique across the whole repo.
- Renaming or merging decks IS safe: edit the `deck:` line and push — notes
  move with review history intact (push.py reports them as "moved"). Deck
  names are organization, not identity.
- Prefer one deck plus tags over deck hierarchies: filtered decks can study
  any tag subset, and tags are free to change at any time.
- Deleting cards: removing them from YAML only orphans the notes — push.py
  warns and never auto-deletes. When Bailey explicitly asks for removal, run
  `uv run push.py --prune` and confirm at its prompt (append `--yes` only in
  non-interactive shells, and only after his approval in chat). Never prune
  unprompted; orphan warnings go to Bailey first.
- Only touch decks defined in this repo. Decks Bailey made by hand in Anki are
  off limits.
- Never import `dist/*.apkg` into his main collection — push.py manages it and
  GUIDs won't match, so an import duplicates every note. `.apkg` (via
  `uv run build.py`) is only for bootstrapping a brand-new collection.

## Authoring good cards

- One fact per card. Prefer `cloze` for dense factual sentences, `code` for
  Python idioms, `basic` for definitions and "why" questions.
- Grep existing YAML for the topic first; edit near-duplicates instead of
  adding parallel cards.
- ids: topic slug + counter (`prefill-decode-01`), unique across the repo.
