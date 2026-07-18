# linkding.el — Design Spec

**Date:** 2026-05-17
**Status:** Approved — revised 2026-05-18

## Overview

A single-file Emacs package providing a full CRUD client for [Linkding](https://linkding.link), a self-hosted bookmark manager. Published to MELPA. No external dependencies beyond Emacs built-ins (`url.el`, `json.el`). Minimum Emacs version: 28.1.

## Configuration

```elisp
(defgroup linkding nil "Linkding bookmark client." :group 'web)

(defcustom linkding-url nil "Base URL of your Linkding instance."
  :type '(choice (const nil) string))
(defcustom linkding-token nil "Linkding REST API token."
  :type '(choice (const nil) string))
(defcustom linkding-open-fn #'browse-url "Function to open bookmark URLs."
  :type 'function)
(defcustom linkding-default-filter "" "Default filter string for linkding-list."
  :type 'string)
(defcustom linkding-saved-searches nil
  "Alist of (NAME . FILTER-STRING) saved searches."
  :type '(alist :key-type string :value-type string))
```

Every `defcustom` carries a `:type` declaration — required by MELPA `package-lint`.

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
| `+TAG` (first) | include tag | `tag=TAG` query param |
| `+TAG` (subsequent) | include tag | client-side AND post-filter (Linkding API honors only one `tag=` param) |
| `-TAG` | exclude tag | client-side post-filter |
| `+unread` | unread only | `is_unread=yes` |
| `+archived` | archived only | `is_archived=yes` |
| plain string | full-text search | `q=` query param |

Multiple tokens are ANDed. Examples:
- `"+unread +emacs"` fetches `is_unread=yes&tag=emacs`.
- `"+emacs +lisp"` fetches `tag=emacs` and then keeps only results that also contain the `lisp` tag, applied client-side.

`linkding--parse-filter` returns a 3-element list `(API-PARAMS INCLUDE-TAGS EXCLUDE-TAGS)` so callers can run the API call and the client-side filter pass uniformly.

## Capture

### `linkding-add-bookmark &optional URL TITLE` (interactive)

Context-aware capture. When called from elisp, URL and TITLE override auto-detection (useful for things like org-capture templates). When called interactively, both args are nil and auto-detection runs.

- **EWW buffer**: reads URL and title from `eww-data` automatically
- **Other buffers**: reads URL from `thing-at-point 'url`, falls back to minibuffer prompt
- Title: prompted with auto-detected value as default (user can edit)
- Tags: `completing-read-multiple` against `linkding--tags` cache (fetches if nil)
- `C-u` prefix: prompts for description and offers `is_unread` toggle
- On success: `message "Linkding: saved <url>"`

## Quick Search (`completing-read`)

### `linkding-open-bookmark` (interactive)
- Reads from `linkding--bookmarks` cache (fetches if nil)
- Candidates formatted as `U title-or-url(40w)  tag1 tag2` — leading `*` if unread (space if read), then the truncated title (falling back to URL when title is empty), then space-joined tags. The full bookmark alist is attached as a text property so the URL is available even though it isn't shown in long candidates.
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

Guarded behind `(with-eval-after-load 'embark …)` — no hard dependency. Adds a `linkding-embark-url-actions` map registered for the `url` target type, so the embark action prompter offers "Save to Linkding" (`l`) when point is on a URL.

## Package Structure

```
linkding.el     ← entire package (single file)
README.md
CHANGELOG.md
```

Single-file packages don't need a `-pkg.el`; MELPA's `package-build` derives the package descriptor from the `Package-Requires` header.

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

## Implementation Deviations

The implementation plan (`docs/superpowers/plans/2026-05-17-linkding-emacs-package.md`) splits the single async `linkding--request` described above into two helpers:

- `linkding--request-sync` — used by reads (`linkding--fetch-bookmarks-sync`, `linkding--fetch-tags-sync`) so that `completing-read` and `linkding-list` can build their candidate lists in a single call without callback gymnastics.
- `linkding--request-async` — used by writes (create / update / delete), which fire-and-forget with echo-area feedback.

This is a pragmatic concession: blocking sync reads can freeze the UI for users with very large bookmark sets, but the simplicity benefit for v0.1.0 is large. Switching reads back to async with a cache-warm-on-load approach is a candidate enhancement for a future version.
