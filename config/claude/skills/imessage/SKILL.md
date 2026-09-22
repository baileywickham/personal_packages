---
name: imessage
description: Use when asked to read, search, summarize, or watch Bailey's iMessages / SMS / texts — "what did X text me", "any messages about Saturday", "summarize the group chat", "who texted me today". Reads the local Messages database with the `imsg` CLI. Read-only unless Bailey explicitly asks to send.
---

# imessage

Reads Messages.app history on this Mac with [imsg](https://github.com/openclaw/imsg)
(Swift CLI over `~/Library/Messages/chat.db`; resolves contact names, decodes the
`attributedBody` text newer macOS versions hide from the `text` column).

## Prerequisites

- `imsg` on PATH. If missing: `brew install steipete/tap/imsg`.
- The terminal needs Full Disk Access (it has it on Bailey's Mac). An
  `authorization denied` / `unable to open database` error means it was revoked:
  tell Bailey to re-grant it in System Settings → Privacy & Security → Full Disk Access.

## Reading

```sh
imsg chats --limit 20                 # recent threads: [chat_id] name (handle) last=…
imsg chats --unread-only              # threads with unread inbound messages
imsg history --chat-id 13 --limit 50  # newest first
imsg history --chat-id 13 --start 2026-09-01T00:00:00Z --end 2026-09-08T00:00:00Z
imsg history --chat-id 13 --limit 20 --attachments   # include attachment paths
imsg group --chat-id 840              # participants of a group chat
imsg watch --chat-id 13               # stream new messages (long-running; use a background task)
```

Add `--json` for NDJSON (`is_from_me`, `text`, `sender`, `created_at`, `attachments`, `reactions`).

**Direction:** in text output `[sent]` = Bailey wrote it, `[recv]` = the other person.
In a 1:1 chat the handle printed after the tag is always the *other* person, even
on `[sent]` lines — go by the tag (or `is_from_me` in JSON), not the handle.

Timestamps are UTC (`Z`); Bailey is in Pacific time — convert before saying "this morning".

To find a person's thread: `imsg chats --limit 200 | grep -i name`. Unnamed group
chats show as `chatNNN…` or a hex id; use `imsg group` to see who is in them.

## Searching text across all chats

`imsg` has no search command. Query the database read-only:

```sh
sqlite3 -readonly ~/Library/Messages/chat.db "
select datetime(m.date/1000000000 + 978307200,'unixepoch','localtime') as at,
       c.chat_identifier, c.display_name, m.is_from_me, m.text
from message m
join chat_message_join cmj on cmj.message_id = m.ROWID
join chat c on c.ROWID = cmj.chat_id
where m.text like '%saturday%'
order by m.date desc limit 30;"
```

A few percent of messages have `text` NULL (body only in `attributedBody`), so SQL
search can miss some; confirm in the thread with `imsg history`. Never open the db
without `-readonly`.

## Rules

- **Read-only by default.** `send`, `react`, `tapback`, `edit`, `unsend`, `read`,
  `typing`, `poll`, `send-*` act on real conversations. Run them only when Bailey
  explicitly asks to send that specific thing, and show him the exact text and
  recipient first.
- Don't use `launch`, the IMCore bridge, or anything needing SIP disabled.
- Texts are private: quote only what answers the question. Don't copy message
  content into the vault, notes, or anything that leaves the machine unless he asks.
