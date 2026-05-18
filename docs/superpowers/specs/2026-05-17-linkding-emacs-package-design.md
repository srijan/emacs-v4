# linkding.el — Design Spec

**Date:** 2026-05-17
**Status:** Approved

## Overview

A single-file Emacs package providing a full CRUD client for [Linkding](https://linkding.link), a self-hosted bookmark manager. Published to MELPA. No external dependencies beyond Emacs built-ins (`url.el`, `json.el`). Minimum Emacs version: 28.1.

## Configuration

```elisp
(defgroup linkding nil "Linkding bookmark client." :group 'web)

(defcustom linkding-url nil "Base URL of your Linkding instance.")
(defcustom linkding-token nil "Linkding REST API token.")
(defcustom linkding-open-fn #'browse-url "Function to open bookmark URLs.")
(defcustom linkding-default-filter "" "Default filter string for linkding-list.")
(defcustom linkding-saved-searches nil
  "Alist of (NAME . FILTER-STRING) saved searches.")
```

Example saved searches:
```elisp
(setq linkding-saved-searches
  '(("Unread"       . "+unread")
    ("Emacs"        . "+emacs")
    ("Unread Emacs" . "+unread +emacs")))
```

## Internal API Layer

### `linkding--request METHOD ENDPOINT &optional PAYLOAD CALLBACK`

Generic async HTTP helper. Builds `Authorization: Token …` header. Calls `url-retrieve` async. On completion, parses the response body as JSON and passes the result alist to CALLBACK. Non-2xx responses show an error `message` in the echo area; CALLBACK receives nil.

### API wrappers

| Function | Method | Endpoint |
|---|---|---|
| `linkding--fetch-bookmarks CALLBACK &optional PARAMS` | GET | `/api/bookmarks/?limit=100&offset=N` (paginates, collects all pages) |
| `linkding--fetch-tags CALLBACK` | GET | `/api/tags/?limit=1000` |
| `linkding--create-bookmark FIELDS CALLBACK` | POST | `/api/bookmarks/` |
| `linkding--update-bookmark ID FIELDS CALLBACK` | PATCH | `/api/bookmarks/:id/` |
| `linkding--delete-bookmark ID CALLBACK` | DELETE | `/api/bookmarks/:id/` |

### Cache

```elisp
(defvar linkding--bookmarks nil "Cached list of bookmark alists.")
(defvar linkding--tags nil "Cached list of tag name strings.")
```

Both start nil. Populated on first use or via `linkding-refresh`. `linkding-refresh` (interactive) re-fetches both and refreshes any live `*linkding*` buffer.

## Filter Format

Elfeed-compatible filter string parsed by `linkding--parse-filter`:

| Token | Meaning | API mapping |
|---|---|---|
| `+emacs` | include tag | `tag=emacs` query param |
| `-emacs` | exclude tag | client-side post-filter |
| `+unread` | unread only | `is_unread=yes` |
| `+archived` | archived only | `is_archived=yes` |
| plain string | full-text search | `q=` query param |

Multiple tokens are ANDed. Example: `"+unread +emacs"` fetches `is_unread=yes&tag=emacs`.

## Capture

### `linkding-add-bookmark &optional URL TITLE` (interactive)

Context-aware capture:
- **EWW buffer**: reads URL and title from `eww-data` automatically
- **Other buffers**: reads URL from `thing-at-point 'url`, falls back to minibuffer prompt
- Title: prompted with auto-detected value as default (user can edit)
- Tags: `completing-read-multiple` against `linkding--tags` cache (fetches if nil)
- `C-u` prefix: prompts for description and offers `is_unread` toggle
- On success: `message "Linkding: saved <url>"`

## Quick Search (`completing-read`)

### `linkding-open-bookmark` (interactive)
- Reads from `linkding--bookmarks` cache (fetches if nil)
- Candidates formatted as `[U] title  <url>  [tag1 tag2]`
- Opens selected URL via `linkding-open-fn`
- `C-u` prefix forces cache refresh before showing candidates

### `linkding-search` (interactive)
- Prompts for a filter string (elfeed format)
- Hits API live with parsed params
- Shows results via same `completing-read` interface

## Tabulated List View

### `linkding-list` (interactive)

Opens `*linkding*` buffer in `linkding-list-mode` (derived from `tabulated-list-mode`). Fetches all bookmarks via paginated API calls. Echo area shows `(N bookmarks)` when done.

### `linkding-saved-search NAME` (interactive)

`completing-read` over `linkding-saved-searches`, opens `*linkding*` buffer pre-filtered. Mode line shows active search name.

### Columns

| Column | Width | Notes |
|---|---|---|
| `U` | 1 | `*` if unread, blank otherwise |
| `Title` | 40 | Truncated with ellipsis |
| `Tags` | 25 | Space-separated |
| `Date` | 10 | `YYYY-MM-DD` |

Full URL stored as text property on each row.

### Keybindings

| Key | Action |
|---|---|
| `RET` | Open URL via `linkding-open-fn` |
| `r` | Toggle `is_unread` — PATCH immediately, refresh row |
| `A` | Toggle `is_archived` — PATCH immediately, refresh row |
| `e` | Edit bookmark (title, tags, description, unread) |
| `d` | Delete bookmark (confirm prompt) |
| `n` / `p` | Next / previous entry |
| `s` | Edit active filter string (pre-filled, elfeed-style) |
| `S` | Pick saved search by name via `completing-read` |
| `g` | Refresh (re-run active filter) |
| `q` | Quit / bury buffer |

Filter state stored as buffer-local var; multiple `*linkding*` buffers track independent filters.

## Edit Bookmark

`linkding-edit-bookmark` (bound to `e` in list, also interactive standalone):
- Reads current fields from cache
- Prompts sequentially: title (pre-filled), tags (pre-filled, multi-completion), description (pre-filled), is_unread toggle
- PATCHes only changed fields
- Updates cache entry and refreshes list row in place

## Embark Integration

Guarded behind `(with-eval-after-load 'embark …)` — no hard dependency. Adds a `linkding-embark-actions` map that registers "Save to Linkding" as an action on URL targets.

## Package Structure

```
linkding.el          ← entire package
linkding-pkg.el      ← auto-generated by MELPA tooling
README.md
CHANGELOG.md
```

### MELPA Header

```elisp
;; Author: Srijan Choudhary <you@work.example>
;; Package-Requires: ((emacs "28.1"))
;; Version: 0.1.0
;; Keywords: bookmarks, linkding, web, hypermedia
;; URL: https://github.com/srijan-c/linkding.el
```

## Out of Scope

- Bulk import/export
- Favicon display
- Notes/full-text content fetching
- OAuth / multi-instance support
