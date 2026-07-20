# Dashboard launcher + toolbar slot icons — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a tap-first dashboard (recents/agenda widgets + clickable action buttons, shown at startup) and give the Android toolbar's quick slots meaningful Material icons.

**Architecture:** Two independent edits to `config.org` (the single source of truth), each landing as its own commit. Task 1 adds a `dashboard.el` block tangling to `post-init.el`. Task 2 refactors the Android toolbar's quick slots in the `android-support.el` block to be data-driven so each slot carries its own icon.

**Tech Stack:** Emacs Lisp, literate org (`config.org` → tangled `.el`), Elpaca + use-package, `dashboard.el`, `material-pbm-icons` (MDI icon names).

**Design spec:** `docs/superpowers/specs/2026-07-19-emacs-dashboard-launcher-design.md`

## Global Constraints

- **All edits go in `config.org`.** Never edit the tangled `.el` files (they are gitignored and regenerated).
- **Two separate commits**, in this order: Task 1 (dashboard) then Task 2 (toolbar slots). Task 2's slot ① binds `dashboard-open`, which Task 1 provides.
- `use-package-always-defer` is `t` — `dashboard` needs `:demand t`.
- `minimal-emacs-user-directory` is the repo root (`~/.emacs.d/`). **Do not use `user-emacs-directory`** — it is redirected to `var/`.
- Startup must never break: guard optional things (icon packages, missing files) so a failure degrades with a `message` instead of aborting init.
- All icon names must exist in `material-pbm-icons` (MDI slugs). The five in Task 2 are verified present.
- **No test framework exists in this repo.** Verification = successful tangle + clean byte-compile + batch load sanity. Follow the exact commands given.

### Known tangle quirk (applies to every tangle step)

`emacs -Q --batch … org-babel-tangle-file` errors on `~/Sync/docs/notes/denote_config.el` (unbound `sj/sync-dir` falls back to a nonexistent `~/Sync`) and **exits non-zero** — but it still writes every other target file correctly. **Ignore the exit code**; verify the target files' contents instead, as each step's verification does.

---

## File Structure

| File | Responsibility | Change |
|---|---|---|
| `config.org` — `** Hyperbole / Dashboard` section | dashboard config + action commands | Task 1: add |
| `config.org` — `*** Android on-screen toolbar` section | toolbar library source | Task 2: modify |
| `post-init.el` | tangled output | Task 1: regenerated |
| `srijan-lisp/android-support.el` | tangled output | Task 2: regenerated |

---

### Task 1: Dashboard (launcher + widgets)

**Files:**
- Modify: `config.org` — the `** Hyperbole / Dashboard` section (locate by that exact heading; do not trust a line number, earlier edits shifted them)
- Regenerated: `post-init.el`

**Interfaces:**
- Consumes: `minimal-emacs-user-directory`, `sj/sync`, `my-reload-emacs-configuration`, `my-phone-p` (all already defined earlier in `post-init.el`).
- Produces (Task 2 and the user rely on these): the command **`dashboard-open`** (from `dashboard.el`), and the new commands `sj-dashboard-pull`, `sj-dashboard-tangle`, `sj-dashboard-visit-config`, `sj-dashboard-visit-mindwtr`.

- [ ] **Step 1: Add the dashboard block to `config.org`**

Find the section heading `** Hyperbole / Dashboard`. Leave the existing `:disabled` hyperbole `use-package` exactly as it is. **Inside the same `#+begin_src emacs-lisp :tangle "post-init.el"` block, after the hyperbole form**, append the following:

```elisp
  ;;;; Dashboard action commands (also usable from M-x and the Android tool bar)

  (defun sj-dashboard--confirm (prompt)
    "Ask PROMPT, preferring a tappable dialog on graphical frames.
  When invoked from a mouse/touch event, `y-or-n-p' shows a clickable dialog,
  so no keyboard is needed; falls back to a normal prompt in a terminal."
    (let ((use-dialog-box (display-graphic-p)))
      (y-or-n-p prompt)))

  (defun sj-dashboard-visit-config ()
    "Visit config.org."
    (interactive)
    (find-file (expand-file-name "config.org" minimal-emacs-user-directory)))

  (defun sj-dashboard-visit-mindwtr ()
    "Visit mindwtr.org in the sync folder."
    (interactive)
    (find-file (sj/sync "docs/org/mindwtr.org")))

  (defun sj-dashboard-tangle ()
    "Tangle config.org into its .el files."
    (interactive)
    (let ((config (expand-file-name "config.org" minimal-emacs-user-directory)))
      (org-babel-tangle-file config)
      (message "Tangled %s" config)))

  (defun sj-dashboard-pull ()
    "Pull changes in the Emacs config repo.  Asks first (network)."
    (interactive)
    (when (sj-dashboard--confirm "Pull Emacs repo changes? ")
      (let ((default-directory minimal-emacs-user-directory))
        (async-shell-command "git pull" "*emacs-repo-pull*"))))

  (use-package dashboard
    :ensure (:host github :repo "emacs-dashboard/dashboard")
    :demand t
    :custom
    (dashboard-items '((agenda . 5) (recents . 5) (bookmarks . 5)))
    (dashboard-center-content t)
    (dashboard-set-footer nil)
    :config
    ;; Icons: skip file/heading icons on the phone (they need an icon font).
    ;; Guarded so a missing icon package can never abort startup.
    (condition-case err
        (if my-phone-p
            (setq dashboard-set-file-icons nil
                  dashboard-set-heading-icons nil)
          (cond
           ((require 'nerd-icons nil t)
            (setq dashboard-icon-type 'nerd-icons
                  dashboard-display-icons-p t
                  dashboard-set-file-icons t
                  dashboard-set-heading-icons t))
           ((require 'all-the-icons nil t)
            (setq dashboard-icon-type 'all-the-icons
                  dashboard-display-icons-p t
                  dashboard-set-file-icons t
                  dashboard-set-heading-icons t))
           (t
            (setq dashboard-set-file-icons nil
                  dashboard-set-heading-icons nil))))
      (error (message "dashboard icons: %s" (error-message-string err))))

    ;; Tappable action buttons.  Each entry is (ICON TITLE HELP ACTION).
    ;; `call-interactively' so commands with interactive specs behave normally.
    (setq dashboard-navigator-buttons
          `((("⟳" "Pull repo" "Pull Emacs repo changes"
              (lambda (&rest _) (call-interactively #'sj-dashboard-pull)))
             ("⚙" "Tangle" "Tangle config.org"
              (lambda (&rest _) (call-interactively #'sj-dashboard-tangle)))
             ("↻" "Reload" "Reload the configuration"
              (lambda (&rest _) (call-interactively #'my-reload-emacs-configuration)))
             ("✎" "config.org" "Visit config.org"
              (lambda (&rest _) (call-interactively #'sj-dashboard-visit-config))))
            (("✎" "mindwtr.org" "Visit mindwtr.org"
              (lambda (&rest _) (call-interactively #'sj-dashboard-visit-mindwtr)))
             ("＋" "Capture" "Capture to inbox"
              (lambda (&rest _) (call-interactively #'org-capture-inbox)))
             ("🗓" "Agenda" "GTD agenda"
              (lambda (&rest _) (call-interactively #'mindwtr-engage)))
             ("🔍" "Notes" "Browse notes"
              (lambda (&rest _) (call-interactively #'consult-notes))))))

    ;; Roomier tap targets on touch screens.
    (add-hook 'dashboard-mode-hook
              (lambda () (setq-local line-spacing 0.4)))

    (dashboard-setup-startup-hook))

  ;; `initial-buffer-choice' must return a buffer.  Set at top level (not in
  ;; :config) and guarded, because Elpaca installs asynchronously: on a very
  ;; first run dashboard may not be built yet, and an erroring
  ;; `initial-buffer-choice' would break startup.
  (setq initial-buffer-choice
        (lambda ()
          (if (fboundp 'dashboard-open)
              (or (ignore-errors (dashboard-open))
                  (get-buffer "*dashboard*")
                  (get-buffer-create "*scratch*"))
            (get-buffer-create "*scratch*"))))
```

- [ ] **Step 2: Re-tangle**

Run from the repo root:
```bash
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "config.org"))'
```
Expected: non-zero exit with a `~/Sync/docs/notes/denote_config.el` error (see Global Constraints). Ignore it.

- [ ] **Step 3: Verify the tangled output**

```bash
grep -c "sj-dashboard-pull\|dashboard-navigator-buttons\|initial-buffer-choice" post-init.el
```
Expected: a count of at least `4` (the defun, its call in the navigator, the navigator setq, and the initial-buffer-choice setq).

```bash
grep -n "use-package dashboard" post-init.el
```
Expected: exactly one match.

- [ ] **Step 4: Verify it parses**

```bash
emacs -Q --batch --eval '(with-temp-buffer (insert-file-contents "post-init.el") (goto-char (point-min)) (condition-case e (progn (while (ignore-errors (read (current-buffer)))) (message "PARSE OK")) (error (message "PARSE FAIL: %S" e))))'
```
Expected output: `PARSE OK`

- [ ] **Step 5: Commit**

```bash
git add config.org
git commit -m "feat: add dashboard launcher with recents/agenda widgets

Adds dashboard.el as the startup buffer with agenda/recents/bookmarks
widgets plus a row of tappable navigator buttons for common actions
(pull, tangle, reload, visit config.org/mindwtr.org, capture, agenda,
notes). Actions are named commands so they are reusable from M-x and
the Android tool bar. Network actions confirm via a tappable dialog."
```

---

### Task 2: Toolbar quick slots with meaningful icons

**Files:**
- Modify: `config.org` — the `*** Android on-screen toolbar` section (the block tangling to `srijan-lisp/android-support.el`)
- Regenerated: `srijan-lisp/android-support.el`

**Interfaces:**
- Consumes: `dashboard-open` (from Task 1), plus the already-autoloaded `org-capture-inbox`, `mindwtr-engage`, `denote-journal-new-or-existing-entry`, `consult-notes`.
- Produces: `android-support-global-tool-bar-slots` (the new defcustom). **Removes** `android-support-global-tool-bar-custom-commands`, the `android-support--define-custom-commands` macro, and the generated `android-support-global-tool-bar-custom-command-1..6` commands.

- [ ] **Step 1: Replace the slots defcustom and delete the wrapper macro**

In the `srijan-lisp/android-support.el` block, find this text (the `;;;; Six configurable quick-command slots` comment through the `(android-support--define-custom-commands 6)` call) and **replace all of it**:

```elisp
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
                                     (when-let* ((,command (nth ,(1- i) android-support-global-tool-bar-custom-commands)))
                                       (if (commandp ,command)
                                           (call-interactively ,command)
                                         (message "android-support: `%s' is not available" ,command))))))))
  (android-support--define-custom-commands 6)
```

with exactly this:

```elisp
  ;;;; Configurable quick-command slots
  ;; Each slot carries its own Material Design Icon name, so adding, removing
  ;; or reordering a slot is a one-line edit here.
  (defcustom android-support-global-tool-bar-slots
    '((dashboard-open                       . "view-dashboard-outline")
      (org-capture-inbox                    . "inbox-arrow-down-outline")
      (mindwtr-engage                       . "calendar-check-outline")
      (denote-journal-new-or-existing-entry . "notebook-outline")
      (consult-notes                        . "text-box-search-outline"))
    "Quick-command slots on the Android tool bar, as (COMMAND . MDI-ICON-NAME)."
    :type '(alist :key-type function :value-type string)
    :group 'android-support)
```

- [ ] **Step 2: Remove the numbered slot entries from the items list**

In `android-support-global-tool-bar-items`, delete these seven lines (the comment and the six numeric entries):

```elisp
      ;; numbered quick-command slots 1-6
      ("numeric-1-circle-outline" android-support-global-tool-bar-custom-command-1)
      ("numeric-2-circle-outline" android-support-global-tool-bar-custom-command-2)
      ("numeric-3-circle-outline" android-support-global-tool-bar-custom-command-3)
      ("numeric-4-circle-outline" android-support-global-tool-bar-custom-command-4)
      ("numeric-5-circle-outline" android-support-global-tool-bar-custom-command-5)
      ("numeric-6-circle-outline" android-support-global-tool-bar-custom-command-6))
```

The preceding line is `("magnify" isearch-forward)` — it must now close the list, becoming:

```elisp
      ("magnify" isearch-forward))
```

Also update the list's leading comment, replacing:
```elisp
    ;; Grouped for a single-row layout: arrows, then edit/buffer actions,
    ;; then quit + prefix/chord keys, then the six numbered slots.
```
with:
```elisp
    ;; Grouped for a single-row layout: arrows, then edit/buffer actions,
    ;; then quit + prefix/chord keys.  The quick slots are appended at setup
    ;; time from `android-support-global-tool-bar-slots'.
```

- [ ] **Step 3: Append the slots in the toolbar setup function**

Replace:

```elisp
  (defun android-support-global-tool-bar-setup ()
    "Rebuild the global `tool-bar-map' from `android-support-global-tool-bar-items'."
    (setf tool-bar-map (list 'keymap nil))
    (cl-loop for (icon command key) in android-support-global-tool-bar-items
             do (tool-bar-add-item icon command (or key command))))
```

with:

```elisp
  (defun android-support-global-tool-bar-setup ()
    "Rebuild the global `tool-bar-map' from the fixed items and the quick slots."
    (setf tool-bar-map (list 'keymap nil))
    (cl-loop for (icon command key) in android-support-global-tool-bar-items
             do (tool-bar-add-item icon command (or key command)))
    ;; Quick slots: bind the real command directly, the same way the fixed
    ;; items above do (e.g. `consult-buffer').
    (cl-loop for (command . icon) in android-support-global-tool-bar-slots
             do (tool-bar-add-item icon command command)))
```

- [ ] **Step 4: Re-tangle**

```bash
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "config.org"))'
```
Expected: non-zero exit from the known `denote_config.el` quirk. Ignore it.

- [ ] **Step 5: Verify the old machinery is gone and the new is present**

```bash
grep -c "custom-command\|numeric-.-circle-outline" srijan-lisp/android-support.el
```
Expected: `0`

```bash
grep -n "android-support-global-tool-bar-slots" srijan-lisp/android-support.el
```
Expected: exactly two matches (the defcustom, and the `cl-loop` in setup).

- [ ] **Step 6: Byte-compile cleanly**

```bash
emacs -Q --batch -f batch-byte-compile srijan-lisp/android-support.el; echo "exit=$?"
```
Expected: `exit=0` and no `Error:` lines. (Warnings about undefined free variables/functions from not-yet-loaded packages are acceptable; errors are not.)

- [ ] **Step 7: Batch load sanity**

```bash
emacs -Q --batch --eval '(progn (add-to-list (quote load-path) (expand-file-name "srijan-lisp")) (require (quote android-support)) (message "slots=%d first=%S" (length android-support-global-tool-bar-slots) (car android-support-global-tool-bar-slots)) (message "macro-gone=%S" (fboundp (quote android-support--define-custom-commands))))'
```
Expected output contains:
```
slots=5 first=(dashboard-open . "view-dashboard-outline")
macro-gone=nil
```
(`%S` prints the icon string with its quotes — that is expected.)

- [ ] **Step 8: Commit**

```bash
git add config.org
git commit -m "feat(android): meaningful icons on toolbar quick slots

Replaces the six numbered toolbar slots with five data-driven slots that
each carry their own Material Design Icon: dashboard, capture inbox, GTD
agenda, today's journal, and search notes. Drops the wrapper-command macro
in favour of binding the real commands directly, matching how the fixed
toolbar items already work."
```

---

## Manual verification (user, after both commits)

Not automatable — report these as "for the user to confirm", do not block on them:

- **Desktop:** restart Emacs; dashboard appears at startup with agenda + recents; each navigator button runs its action on click; "Pull repo" shows a Yes/No dialog first.
- **Android:** dashboard is the startup buffer; navigator buttons run on tap with no keyboard; "Pull repo" shows a tappable dialog; toolbar slots ①–⑤ show the new icons (dashboard / inbox-arrow / calendar-check / notebook / text-box-search) and launch their commands.
