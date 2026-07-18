# Android on-screen toolbar — design

Date: 2026-07-18
Status: approved (design), pending implementation plan

## Purpose

Make Emacs genuinely usable one-handed on Android (native port / Termux),
without a hardware or software keyboard. Reproduce the on-screen toolbar
demonstrated by bohonghuang's
[`android-support.el`](https://github.com/bohonghuang/.emacs.d/blob/master/modules/android-support.el)
(seen in [this Reddit video](https://www.reddit.com/r/emacs/comments/1un91s6/memorize_vocabulary_on_the_go_on_emacs_android/)):
a bottom toolbar of Material-design icon buttons — arrow keys, common editing
commands, and modifier/prefix chords — that together act as a compact chorded
keyboard, plus a row of user-defined "quick command" buttons for on-the-go
workflows (capture, notes, GTD).

This is a faithful **full port** of his approach, adapted to this config's
packages and gated to Android only.

## Context

- `config.org` already detects Android via `my-phone-p` (`ANDROID_ROOT`) and has
  a Phone block that sets `tool-bar-mode 1`, `tool-bar-position 'top`,
  `tool-bar-button-margin 20`, `touch-screen-display-keyboard t`, and
  `touchpad-scroll-mode`; `modifier-bar-mode` is present but commented out.
- The config tangles custom libraries to `srijan-lisp/*.el` (e.g.
  `koreader-json-to-org.el`) and loads them from `load-path`.
- Package management is Elpaca + use-package.
- Verified commands available for the quick-command slots: `org-capture-inbox`,
  `mindwtr-engage`, `mindwtr-projects`, `my/denote-inbox-note`,
  `denote-journal-new-or-existing-entry`, `consult-notes`. Also available and
  referenced by the toolbar: `consult-buffer`, `consult-imenu`,
  `consult-ripgrep`, `project-find-file`, `bookmark-set`.
- Not present: `expand-region` (his file binds `er/expand-region`).

## Design

### Placement

A new tangled module **`srijan-lisp/android-support.el`**, produced from a
`config.org` source block, loaded via `(when my-phone-p (require 'android-support))`
from the Phone block. Rationale: matches the existing `srijan-lisp/` pattern,
keeps ~80 lines of toolbar machinery out of `post-init.el`, and makes the whole
feature self-contained and trivially disableable. The module `(provide
'android-support)` at the end.

### Components

1. **Icons** — depend on `material-pbm-icons` via Elpaca:
   `(material-pbm-icons :host github :repo "bohonghuang/material-pbm-icons" :files ("*.el" "pbm"))`,
   `:demand t`. PBM bitmaps render reliably on Android's toolbar. (His file uses
   quelpa; we use the Elpaca recipe equivalent.)

2. **Bar configuration** — under `my-phone-p`:
   - `tool-bar-position` → `'bottom` (change from the current `'top`).
   - Enable `modifier-bar-mode` (the Ctrl/Meta/Alt button row).
   - Keep the existing `tool-bar-button-margin` (20); tunable later (his is 25).
   - `kill-local-tool-bar-map`: a hook on `prog-mode`, `text-mode`,
     `special-mode`, `compilation-mode` that kills the buffer-local
     `tool-bar-map`, so the custom global bar is shown in those buffers instead
     of a mode-specific one.

3. **Global toolbar grid** — rebuild `tool-bar-map` as a flat keymap and add his
   ~20 items with `tool-bar-add-item`: `keyboard-quit`, `universal-argument`,
   buffer switch (`consult-buffer`/`switch-to-buffer`), `undo`, the four arrow
   keys, save (`android-support-save-buffer`/`save-buffer`), `imenu`,
   `indent-for-tab-command`, `execute-extended-command`,
   `exchange-point-and-mark`, `isearch-forward` (magnify), and the six numbered
   custom-command buttons.

4. **Chord mechanism** — the core trick: `key-translation-map` entries mapping
   `<tool-bar> <symbol>` events to real key sequences so buttons emit keys and
   compose:
   - direct keys: `keyboard-quit`→`C-g`, `indent-for-tab-command`→`TAB`, the
     four arrows→`<up>/<down>/<left>/<right>`.
   - prefixes: `execute-extended-command`→`C-c`, `exchange-point-and-mark`→`C-x`,
     `imenu`→`M-g`, `isearch-forward`→`M-s`.
   Then `global-set-key` bindings on the composed sequences (e.g.
   `C-c <tool-bar> <switch-to-buffer>` → `project-find-file`,
   `C-x <tool-bar> <switch-to-buffer>` → `find-file`, `M-g M-s` →
   `consult-imenu`, `M-s M-g` → `consult-ripgrep`, etc.), plus his window/helper
   bindings (`C-x <up>` split/other-window helpers,
   `android-support-toggle-touch-screen-keyboard`, `android-support-kill-buffer`,
   `android-support-save-buffer`).

5. **Six custom quick-command slots** — a defcustom
   `android-support-global-tool-bar-custom-commands` (a list of commands) plus
   his macro that generates `android-support-global-tool-bar-custom-command-1..6`
   wrappers calling the Nth entry. Pre-filled default value:

   | Slot | Command | Purpose |
   |------|---------|---------|
   | 1 | `org-capture-inbox` | quick capture to inbox |
   | 2 | `mindwtr-engage` | GTD agenda / engage |
   | 3 | `my/denote-inbox-note` | new quick note |
   | 4 | `denote-journal-new-or-existing-entry` | today's journal |
   | 5 | `mindwtr-projects` | GTD projects view |
   | 6 | `consult-notes` | browse / search notes |

   The user edits this list to reorder or replace slots at will.

### Adaptations from the source

- **Drop the `er/expand-region` binding** (no `expand-region` package here);
  leave that `C-x`+`universal-argument` chord unbound rather than add a package.
- Convert quelpa → Elpaca recipe for `material-pbm-icons`.
- Keep `consult-*` / `project-find-file` / `bookmark-set` bindings (all present).

### Gating & safety

- The module is only required under `my-phone-p`; desktop Emacs never loads it.
- Loading is guarded (like the existing font fix) so a missing package/icon
  can't abort init — wrap the `require`/setup so failure degrades to the plain
  Phone toolbar with a `message`, not a broken startup.

## Testing

- Tangle `config.org` and confirm `srijan-lisp/android-support.el` and
  `post-init.el` are generated and parse cleanly (`check-parens` / read loop),
  as done for prior changes.
- Batch-load sanity: `emacs -Q --batch` load of the module with `my-phone-p`
  forced non-nil should define the commands/keymaps without error (icons/toolbar
  rendering can't be verified headless).
- Manual on-device check (user): bottom bar appears, modifier bar present, arrows
  and `C-g` work, a chord (e.g. `M-x`-button → command-button) composes, and each
  of the six slots launches its command.

## Out of scope

- Any flashcard/vocabulary package (`org-drill`/Anki) — the video's *content*
  workflow. Not currently in this config; not part of this feature.
- Changing desktop toolbar behaviour.
- Landscape/tablet-specific layouts.
