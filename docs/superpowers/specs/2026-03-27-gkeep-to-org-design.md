# Google Keep to Org Importer — Design Spec

## Overview

Pure elisp package (`gkeep-to-org.el`) that fetches Google Keep notes via the unofficial Keep API and inserts them as org headings. Follows the same pattern as `slack-saved-to-org.el`. One-way importer with optional auto-archive of imported notes in Keep.

## Authentication

Google Keep uses Google Play Services auth. The flow has two parts:

1. **Master token** (one-time, external): Obtained once via a helper Python script using `gpsoauth`. Stored in `auth-source` (e.g., `.authinfo.gpg`) under host `google-keep`, user `master-token`.

2. **OAuth token refresh** (per-session, in elisp): POST form-encoded data to `https://android.clients.google.com/auth` with:
   - `Email` — Google account email (from auth-source, user `email`)
   - `EncryptedPasswd` — the master token (sent directly, no re-encryption needed)
   - `app` — `com.google.android.keep`
   - `client_sig` — `38918a453d07199354f8b19af05ec6562ced5788`
   - `service` — `oauth2:https://www.googleapis.com/auth/memento https://www.googleapis.com/auth/reminders`

   Returns key=value pairs; extract `Auth=<token>`. Cache in a session variable (~1 hour lifetime).

**Auth-source entries:**

```
machine google-keep login email password user@gmail.com
machine google-keep login master-token password oauth2rt_1/xxx...
```

**Helper script** for one-time master token generation is provided but not a runtime dependency.

## Data Fetching

Single endpoint: `POST https://www.googleapis.com/notes/v1/changes`

Request body:
```json
{
  "nodes": [],
  "clientTimestamp": "<ISO-8601>",
  "requestHeader": {
    "clientSessionId": "s--<uuid>",
    "clientPlatform": "ANDROID",
    "clientVersion": {"major": "9", "minor": "9", "build": "9", "revision": "9"},
    "capabilities": [
      {"type": "NC"}, {"type": "PI"}, {"type": "LB"}, {"type": "AN"},
      {"type": "SH"}, {"type": "DR"}, {"type": "TR"}, {"type": "IN"},
      {"type": "SNB"}, {"type": "MI"}, {"type": "CO"}
    ]
  }
}
```

- First call: no `targetVersion` — returns all notes
- If `truncated` is true, loop with returned `toVersion` as `targetVersion`
- Parse response: `nodes` array + `userInfo.labels` for label lookup

### Filtering

- Only `type: "NOTE"` nodes (not LIST)
- Skip archived (`isArchived` is true)
- Skip trashed (non-nil `timestamps.trashed`)
- Skip pinned by default (`gkeep-exclude-pinned`, default `t`)
- Optional label filter (`gkeep-label-filter`)
- Dedup: skip notes whose `serverId` already exists as `GKEEP_ID` property in `org-agenda-files`

### Note structure

- Title lives on the top-level NOTE node
- Text content lives in the first child node (LIST_ITEM type)
- Labels are referenced by `labelIds` on the note; resolved via the label lookup table

## Auto-Archive

After successfully inserting a note as an org heading, push an archive update back to Keep via the same `/changes` endpoint:

```json
{
  "nodes": [{"id": "<note-id>", "baseVersion": "<note-version>", "isArchived": true}],
  ...same requestHeader...
  "targetVersion": "<current-version>"
}
```

Controlled by `gkeep-archive-after-import` (default `t`).

## Org Output Format

Each note inserted at point:

```org
* Note Title :keep:label1:label2:
:PROPERTIES:
:GKEEP_ID: <server-id>
:END:
[2026-03-15 Sun]

Note body text here.
```

- Heading: note title, or first ~60 chars of body if untitled
- Tags: `:keep:` plus Keep labels (sanitized to valid org tag chars)
- `GKEEP_ID` property for deduplication
- Inactive timestamp from `userEdited` or `created`
- Body text as-is (plain text)
- No TODO keyword

## Customization

| Variable | Default | Purpose |
|----------|---------|---------|
| `gkeep-auth-host` | `"google-keep"` | auth-source `:host` |
| `gkeep-email-user` | `"email"` | auth-source `:user` for Google email |
| `gkeep-master-token-user` | `"master-token"` | auth-source `:user` for master token |
| `gkeep-exclude-pinned` | `t` | Skip pinned notes |
| `gkeep-max-items` | `nil` | Max notes to fetch (nil = all) |
| `gkeep-skip-existing` | `t` | Dedup via GKEEP_ID in org-agenda-files |
| `gkeep-label-filter` | `nil` | Only import notes with these labels (list of strings) |
| `gkeep-archive-after-import` | `t` | Archive notes in Keep after importing |

## Interactive Commands

- `M-x gkeep-to-org` — fetch and insert notes at point (requires org buffer)
- `C-u N M-x gkeep-to-org` — fetch at most N notes

## File Location

`srijan-lisp/gkeep-to-org.el` — alongside `slack-saved-to-org.el` and `koreader-json-to-org.el`.

## Out of Scope

- List/checklist import (only plain notes)
- Bidirectional sync
- Media/blob attachments
- Reminders
