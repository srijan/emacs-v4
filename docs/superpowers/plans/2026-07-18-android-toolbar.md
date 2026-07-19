# Android On-Screen Toolbar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom on-screen toolbar (Material-icon buttons + modifier bar acting as a chorded keyboard, plus six quick-command slots) that makes Emacs usable one-handed on Android, gated to `my-phone-p`.

**Architecture:** A new library `srijan-lisp/android-support.el` (tangled from a new `config.org` source block) holds all toolbar machinery — helper commands, the six custom-slot commands, the icon/command grid, and the `key-translation-map` chord bindings — and exposes one entry point `android-support-enable`. The existing Phone block in `post-init.el` installs `material-pbm-icons` via Elpaca and, in that package's `:config` (so `image-load-path` already contains the PBM icons), requires the library and calls `android-support-enable`, wrapped in `condition-case` so a failure degrades to the plain toolbar.

**Tech Stack:** Emacs Lisp, org-babel tangle, Elpaca/use-package, `material-pbm-icons` (PBM Material Design icons), built-in `tool-bar`/`modifier-bar-mode`/`key-translation-map`.

## Global Constraints

- All new runtime code must load **only under `my-phone-p`**; desktop Emacs must be unaffected.
- The toolbar library tangles to `srijan-lisp/android-support.el` (the `srijan-lisp/` directory is gitignored, like all tangled output — do **not** commit generated `.el`/`.elc`).
- Load must be **guarded**: a missing package or icon must not abort startup (mirror the existing font-guard pattern).
- Reuse commands that already exist in this config; do **not** add packages beyond `material-pbm-icons`. In particular, do **not** reintroduce the source's `er/expand-region` binding (no `expand-region` here).
- The six custom slots default to (in order): `org-capture-inbox`, `mindwtr-engage`, `my/denote-inbox-note`, `denote-journal-new-or-existing-entry`, `mindwtr-projects`, `consult-notes`.
- Source of truth is `config.org`; never edit tangled `.el` directly. Re-tangle after edits.

---

### Task 1: Create the `android-support` library

**Files:**
- Modify: `config.org` (add a new subsection after the `*** Phone` block, ~line 539) — a source block that tangles to `srijan-lisp/android-support.el`
- Generated (gitignored): `srijan-lisp/android-support.el`

**Interfaces:**
- Produces (used by Task 2):
  - `(android-support-enable)` — interactive-less entry point; sets `tool-bar-position` to `bottom`, enables `modifier-bar-mode` when available, installs the buffer-local-toolbar-suppression hooks, the chord bindings, and rebuilds the global `tool-bar-map`.
  - `android-support-global-tool-bar-custom-commands` — a `defcustom` list the user edits to change the six numbered slots.
  - Feature symbol `android-support` (via `provide`).

- [ ] **Step 1: Add the source block to `config.org`**

Insert this new subsection immediately after the `*** Phone` block's closing `#+end_src` (the block that ends with the `touchpad` `use-package`):

````markdown
*** Android on-screen toolbar
Ported from [[https://github.com/bohonghuang/.emacs.d/blob/master/modules/android-support.el][bohonghuang's android-support.el]]. Provides a bottom toolbar of
Material-icon buttons that double as a chorded keyboard (via
=key-translation-map=), plus six user-configurable quick-command slots. Loaded
from the Phone block via =material-pbm-icons= (see below). Design:
[[file:docs/superpowers/specs/2026-07-18-android-toolbar-design.md]].
#+begin_src emacs-lisp :tangle "srijan-lisp/android-support.el"
  ;;; android-support.el --- On-screen toolbar for Emacs on Android  -*- lexical-binding: t; -*-
  ;; Tangled from config.org. DO NOT EDIT.
  ;; Adapted from https://github.com/bohonghuang/.emacs.d (modules/android-support.el).
  (require 'cl-lib)

  (defgroup android-support nil
    "On-screen toolbar for Emacs on Android."
    :group 'environment)

  ;;;; Helper commands
  (defun android-support-kill-buffer (arg)
    "Kill the current buffer; with a prefix ARG >= 4 also kill its window."
    (interactive "p")
    (cond
     ((>= arg 4) (kill-buffer-and-window))
     ((>= arg 1) (kill-buffer))))

  (defun android-support-save-buffer ()
    "Save the current file buffer, or `save-some-buffers' elsewhere."
    (interactive)
    (if (and (buffer-modified-p)
             (or (derived-mode-p 'prog-mode) (derived-mode-p 'text-mode)))
        (save-buffer)
      (save-some-buffers)))

  (defun android-support-toggle-touch-screen-keyboard ()
    "Toggle the on-screen keyboard."
    (interactive)
    (message
     "Touch screen keyboard %s"
     (if (setf touch-screen-display-keyboard (not touch-screen-display-keyboard))
         "enabled" "disabled")))

  ;;;; Six configurable quick-command slots
  (defcustom android-support-global-tool-bar-custom-commands
    '(org-capture-inbox
      mindwtr-engage
      my/denote-inbox-note
      denote-journal-new-or-existing-entry
      mindwtr-projects
      consult-notes)
    "Commands bound to the six numbered buttons on the Android tool bar."
    :type '(repeat function)
    :group 'android-support)

  (defmacro android-support--define-custom-commands (n)
    "Define N wrapper commands that call the Nth entry of the slots list."
    `(progn . ,(cl-with-gensyms (command)
                 (cl-loop for i from 1 to n
                          collect `(defun ,(intern (format "%s-%d" 'android-support-global-tool-bar-custom-command i)) ()
                                     (interactive)
                                     (when-let ((,command (nth ,(1- i) android-support-global-tool-bar-custom-commands)))
                                       (call-interactively ,command)))))))
  (android-support--define-custom-commands 6)

  ;;;; The icon/command grid
  (defconst android-support-global-tool-bar-items
    '(("close-outline" keyboard-quit)
      ("plus-circle-multiple-outline" universal-argument)
      ("file-replace-outline" consult-buffer switch-to-buffer)
      ("arrow-u-left-top" undo)
      ("arrow-up" previous-line)
      ("content-save-outline" android-support-save-buffer save-buffer)
      ("numeric-1-circle-outline" android-support-global-tool-bar-custom-command-1)
      ("numeric-2-circle-outline" android-support-global-tool-bar-custom-command-2)
      ("numeric-3-circle-outline" android-support-global-tool-bar-custom-command-3)
      ("menu" imenu)
      ("arrow-collapse-right" indent-for-tab-command)
      ("circle-multiple-outline" execute-extended-command)
      ("close-circle-multiple-outline" exchange-point-and-mark)
      ("arrow-left" backward-char)
      ("arrow-down" next-line)
      ("arrow-right" forward-char)
      ("numeric-4-circle-outline" android-support-global-tool-bar-custom-command-4)
      ("numeric-5-circle-outline" android-support-global-tool-bar-custom-command-5)
      ("numeric-6-circle-outline" android-support-global-tool-bar-custom-command-6)
      ("magnify" isearch-forward))
    "List of (ICON COMMAND [KEY]) specs for the global tool bar.")

  (defun android-support-global-tool-bar-setup ()
    "Rebuild the global `tool-bar-map' from `android-support-global-tool-bar-items'."
    (setf tool-bar-map '(keymap nil))
    (cl-loop for (icon command key) in android-support-global-tool-bar-items
             do (tool-bar-add-item icon command (or key command))))

  (defun android-support-kill-local-tool-bar-map ()
    "Drop a buffer-local `tool-bar-map' so the global bar shows here."
    (kill-local-variable 'tool-bar-map))

  ;;;; Chord translations + composed bindings
  (defun android-support-setup-bindings ()
    "Wire tool-bar buttons to real key sequences so they compose as chords."
    (define-key key-translation-map (kbd "<tool-bar> <keyboard-quit>") (kbd "C-g"))
    (define-key key-translation-map (kbd "<tool-bar> <execute-extended-command>") (kbd "C-c"))
    (define-key key-translation-map (kbd "<tool-bar> <exchange-point-and-mark>") (kbd "C-x"))
    (define-key key-translation-map (kbd "<tool-bar> <imenu>") (kbd "M-g"))
    (define-key key-translation-map (kbd "<tool-bar> <isearch-forward>") (kbd "M-s"))
    (global-set-key (kbd "C-x <up>") #'delete-other-windows)
    (global-set-key (kbd "C-x <down>") #'split-window-below)
    (global-set-key (kbd "C-c <tool-bar> <universal-argument>") #'execute-extended-command)
    ;; NOTE: source also bound `C-x <tool-bar> <universal-argument>' to er/expand-region;
    ;; dropped here (no expand-region package in this config).
    (global-set-key (kbd "C-c <tool-bar> <undo>") #'pop-to-mark-command)
    (global-set-key (kbd "C-x <tool-bar> <undo>") #'quit-window)
    (global-set-key (kbd "C-c <tool-bar> <switch-to-buffer>") #'project-find-file)
    (global-set-key (kbd "C-x <tool-bar> <switch-to-buffer>") #'find-file)
    (global-set-key (kbd "C-c <tool-bar> <save-buffer>") #'bookmark-set)
    (global-set-key (kbd "C-x <tool-bar> <save-buffer>") #'android-support-kill-buffer)
    (global-set-key (kbd "M-s M-s") #'isearch-forward)
    (global-set-key (kbd "M-g M-s") #'consult-imenu)
    (global-set-key (kbd "M-s M-g") (if (executable-find "rg") #'consult-ripgrep #'consult-grep))
    (global-set-key (kbd "C-x M-g") #'android-support-toggle-touch-screen-keyboard)
    (global-set-key (kbd "C-x M-s") #'read-only-mode)
    (define-key key-translation-map (kbd "<tool-bar> <indent-for-tab-command>") (kbd "TAB"))
    (define-key key-translation-map (kbd "<tool-bar> <previous-line>") (kbd "<up>"))
    (define-key key-translation-map (kbd "<tool-bar> <next-line>") (kbd "<down>"))
    (define-key key-translation-map (kbd "<tool-bar> <backward-char>") (kbd "<left>"))
    (define-key key-translation-map (kbd "<tool-bar> <forward-char>") (kbd "<right>")))

  ;;;; Entry point
  (defun android-support-enable ()
    "Turn on the Android on-screen toolbar."
    (setq tool-bar-position 'bottom)
    (when (fboundp 'modifier-bar-mode) (modifier-bar-mode 1))
    (dolist (hook '(prog-mode-hook text-mode-hook special-mode-hook compilation-mode-hook))
      (add-hook hook #'android-support-kill-local-tool-bar-map))
    (android-support-setup-bindings)
    (android-support-global-tool-bar-setup))

  (provide 'android-support)
  ;;; android-support.el ends here
#+end_src
````

- [ ] **Step 2: Tangle the library**

Run:
```sh
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "config.org"))' 2>&1 | tail -1
```
Note: this may print a non-fatal `denote_config.el` "No such file" error at the end (unrelated — `sj/sync-dir` is unbound under `-Q`). Ignore the exit code; verify the target file in the next step.

- [ ] **Step 3: Verify the library byte-compiles cleanly**

Run:
```sh
emacs -Q --batch -f batch-byte-compile srijan-lisp/android-support.el; echo "exit=$?"
```
Expected: `exit=0`. Warnings about undefined functions (`mindwtr-engage`, `consult-notes`, `modifier-bar-mode`, `consult-imenu`, etc.) are expected and fine — they resolve at runtime on the phone. A non-zero exit or a `Error:` line means a structural problem (fix it). Then remove the artifact:
```sh
rm -f srijan-lisp/android-support.elc
```

- [ ] **Step 4: Verify the entry point and slots are defined**

Run:
```sh
emacs -Q --batch -l srijan-lisp/android-support.el \
  --eval '(princ (format "enable=%s cmd6=%s slots=%d\n" (fboundp (quote android-support-enable)) (fboundp (quote android-support-global-tool-bar-custom-command-6)) (length android-support-global-tool-bar-custom-commands)))'
```
Expected: `enable=t cmd6=t slots=6`

- [ ] **Step 5: Commit**

```sh
git add config.org
git commit -m "feat(android): add on-screen toolbar library (android-support)"
```

---

### Task 2: Wire the toolbar into the Phone block

**Files:**
- Modify: `config.org` — the `*** Phone` source block inside `(when my-phone-p …)` (currently tangles to `post-init.el`)
- Generated (gitignored): `post-init.el`

**Interfaces:**
- Consumes (from Task 1): `android-support` feature, `(android-support-enable)`.
- Produces: on-device, the bottom toolbar is active under `my-phone-p`.

- [ ] **Step 1: Update the Phone block**

In `config.org`, within the `*** Phone` block, change the toolbar position line and add the `material-pbm-icons` install that enables the toolbar. Replace this exact region:

```elisp
    (tool-bar-mode 1)
    ;; (modifier-bar-mode 1)
    (setopt tool-bar-position 'top)
    (setopt tool-bar-button-margin 20)
```

with:

```elisp
    (tool-bar-mode 1)
    (setopt tool-bar-position 'bottom)
    (setopt tool-bar-button-margin 20)
```

Then, immediately before the final `)` that closes `(when my-phone-p …)` (after the `touchpad` `use-package` form), insert:

```elisp
    ;; On-screen toolbar acting as a chorded keyboard.
    ;; material-pbm-icons adds its pbm/ dir to `image-load-path' on load, so
    ;; enable the toolbar from its :config, once the icons are resolvable.
    (use-package material-pbm-icons
      :ensure (:host github :repo "bohonghuang/material-pbm-icons" :files ("*.el" "pbm"))
      :demand t
      :config
      (condition-case err
          (progn
            (require 'android-support)
            (android-support-enable))
        (error (message "android-support: %s" (error-message-string err)))))
```

- [ ] **Step 2: Re-tangle**

Run:
```sh
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "config.org"))' 2>&1 | tail -1
```
(Same non-fatal `denote_config.el` note as before — ignore.)

- [ ] **Step 3: Verify `post-init.el` parses and contains the wiring**

Run:
```sh
emacs -Q --batch --eval '(with-temp-buffer (insert-file-contents "post-init.el") (goto-char (point-min)) (condition-case e (progn (while (progn (skip-chars-forward " \t\n\r") (not (eobp))) (read (current-buffer))) (princ "PARSE OK\n")) (error (princ (format "PARSE ERROR: %s\n" e)))))'
grep -n "material-pbm-icons\|android-support-enable\|tool-bar-position 'bottom" post-init.el
```
Expected: `PARSE OK`, and grep shows the `material-pbm-icons` `use-package`, the `android-support-enable` call, and `tool-bar-position 'bottom`.

- [ ] **Step 4: Commit**

```sh
git add config.org
git commit -m "feat(android): enable android-support toolbar in the Phone block"
```

---

### Task 3: Document and finalize

**Files:**
- Modify: `README.md` (Android section)
- Modify: `config.org` only if Task 1/2 verification surfaced a fix

**Interfaces:**
- Consumes: the completed feature from Tasks 1–2.
- Produces: user-facing docs; a clean tree.

- [ ] **Step 1: Add a README note**

In `README.md`, under the `## Android` section, add a new subsection after `### Touch tips`:

```markdown
### On-screen toolbar

Under `my-phone-p` the config loads a bottom Material-icon toolbar
(`srijan-lisp/android-support.el`, ported from bohonghuang's `android-support.el`)
that doubles as a chorded keyboard: arrow keys, `C-g`, undo/save/search, `M-x`,
and modifier/prefix buttons (`C-c`/`C-x`/`M-g`/`M-s`) that compose real key
sequences, plus six numbered quick-command slots. Edit
`android-support-global-tool-bar-custom-commands` to change the slots (defaults:
capture, GTD engage, new note, journal, GTD projects, browse notes). Icons come
from the `material-pbm-icons` package (TrueType-independent PBM bitmaps).
```

- [ ] **Step 2: Verify the whole tree is clean and tangled output is untracked**

Run:
```sh
git status --porcelain
```
Expected: only `README.md` staged/modified from this task; no `srijan-lisp/android-support.el`, `post-init.el`, or `.elc` appear (they are gitignored). If any tangled file appears as untracked, confirm `.gitignore` still covers `srijan-lisp/` and `post-init.el`.

- [ ] **Step 3: Commit**

```sh
git add README.md
git commit -m "docs(android): document the on-screen toolbar"
```

- [ ] **Step 4: Manual on-device verification (user, not automated)**

On the Android device, after `git pull` + re-tangle + restart Emacs:
- Bottom toolbar renders with Material icons; `modifier-bar-mode` row present.
- Arrow buttons move point; the `C-g` button quits.
- A chord composes: tap the `M-x` (circle) button then the buffer button → `project-find-file` (or `C-c` then a slot as intended).
- Each of the six numbered buttons launches its command (capture, GTD engage, new note, journal, GTD projects, browse notes).
- First launch may install `material-pbm-icons` (needs `git` in Termux and network); icons appear after the package builds and Emacs restarts.

---

## Self-Review

**Spec coverage:**
- Placement in `srijan-lisp/android-support.el` loaded under `my-phone-p` → Task 1 + Task 2 wiring. ✓
- `material-pbm-icons` via Elpaca → Task 2 Step 1. ✓
- Bottom bar + `modifier-bar-mode` + big margin + kill-local-tool-bar-map hooks → Task 1 (`android-support-enable`), Task 2 (position/margin). ✓
- Grid + chord `key-translation-map`/`global-set-key` bindings → Task 1 (`android-support-setup-bindings`, `android-support-global-tool-bar-setup`). ✓
- Six pre-filled configurable slots → Task 1 `defcustom` + macro. ✓
- Drop `er/expand-region` binding → Task 1 Step 1 (noted, omitted). ✓
- Guarded load → Task 2 `condition-case`; `modifier-bar-mode` `fboundp` guard. ✓
- Testing (tangle/parse/byte-compile + manual checklist) → Tasks 1–3. ✓
- Out of scope (flashcards, desktop) → not touched. ✓

**Placeholder scan:** none — all code is concrete.

**Type/name consistency:** `android-support-enable`, `android-support-global-tool-bar-setup`, `android-support-setup-bindings`, `android-support-kill-local-tool-bar-map`, `android-support-global-tool-bar-custom-commands`, and `android-support-global-tool-bar-custom-command-1..6` are used consistently across Tasks 1–2 and match the grid/`defcustom` definitions.
