# Google Keep to Org Importer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a pure elisp package that fetches Google Keep notes and inserts them as org headings, with deduplication and auto-archive.

**Architecture:** Single file `srijan-lisp/gkeep-to-org.el` using `url.el` for HTTP and `auth-source` for credentials. Follows the same structural pattern as `slack-saved-to-org.el`: defgroup + defcustoms, internal state vars, HTTP layer, API wrappers, org insertion, interactive command.

**Tech Stack:** Emacs Lisp, url.el, auth-source, json.el, org-mode APIs

**Reference files:**
- `srijan-lisp/slack-saved-to-org.el` — structural pattern to follow
- `docs/superpowers/specs/2026-03-27-gkeep-to-org-design.md` — full spec

---

### Task 1: File Header, Requires, Defgroup, and Defcustoms

**Files:**
- Create: `srijan-lisp/gkeep-to-org.el`

This task creates the file with all customization options. No HTTP or logic yet.

- [ ] **Step 1: Create the file with header, requires, defgroup, and all defcustoms**

```elisp
;;; gkeep-to-org.el --- Fetch Google Keep notes as org entries -*- lexical-binding: t; -*-

;; Standalone elisp package. Uses Google Keep's unofficial API directly.
;; Credentials are read from auth-source (configurable host/user).
;;
;; Authentication requires a one-time master token obtained externally
;; via the gpsoauth Python library, stored in auth-source.
;;
;; Features:
;;   - Fetches notes from Google Keep via the unofficial Keep API
;;   - Inserts org headings with title, body, date, labels as tags, and :keep: tag
;;   - Deduplication: scans org-agenda-files for existing GKEEP_ID properties
;;   - Configurable max items with dedup-aware counting
;;   - Filters: exclude pinned, archived, trashed; optional label filter
;;   - Auto-archives imported notes in Keep
;;   - Handles pagination for large note collections
;;   - Progress messages during fetch and processing
;;
;; Usage:
;;   M-x gkeep-to-org       — fetch all (or gkeep-max-items) new notes
;;   C-u 10 M-x gkeep-to-org — fetch 10 new notes
;;
;; Setup:
;;   1. Install gpsoauth: pip install gpsoauth
;;   2. Run the helper script to obtain a master token
;;   3. Add to auth-source (~/.authinfo.gpg):
;;      machine google-keep login email password your@gmail.com
;;      machine google-keep login master-token password oauth2rt_1/...

;;; Code:

(require 'cl-lib)
(require 'url)
(require 'url-http)
(require 'auth-source)
(require 'json)

;;; Customization

(defgroup gkeep-to-org nil
  "Fetch Google Keep notes and insert as org entries."
  :group 'org
  :prefix "gkeep-")

(defcustom gkeep-auth-host "google-keep"
  "Auth-source :host for Google Keep credentials."
  :type 'string
  :group 'gkeep-to-org)

(defcustom gkeep-email-user "email"
  "Auth-source :user for the Google account email."
  :type 'string
  :group 'gkeep-to-org)

(defcustom gkeep-master-token-user "master-token"
  "Auth-source :user for the Google Play Services master token."
  :type 'string
  :group 'gkeep-to-org)

(defcustom gkeep-exclude-pinned t
  "When non-nil, skip pinned notes during import."
  :type 'boolean
  :group 'gkeep-to-org)

(defcustom gkeep-max-items nil
  "Maximum number of notes to fetch. Nil means fetch all."
  :type '(choice (const :tag "All" nil) integer)
  :group 'gkeep-to-org)

(defcustom gkeep-skip-existing t
  "When non-nil, skip notes already present in org agenda files.
Checks for matching GKEEP_ID property across `org-agenda-files'."
  :type 'boolean
  :group 'gkeep-to-org)

(defcustom gkeep-label-filter nil
  "When non-nil, only import notes with these labels.
A list of label name strings."
  :type '(repeat string)
  :group 'gkeep-to-org)

(defcustom gkeep-archive-after-import t
  "When non-nil, archive notes in Google Keep after importing them."
  :type 'boolean
  :group 'gkeep-to-org)
```

- [ ] **Step 2: Add internal state variables after the defcustoms**

```elisp
;;; Internal state

(defvar gkeep--email nil "Google account email for current session.")
(defvar gkeep--master-token nil "Google Play Services master token.")
(defvar gkeep--auth-token nil "Current OAuth token (short-lived).")
(defvar gkeep--sync-version nil "Current sync version from Keep API.")
(defvar gkeep--label-map nil "Hash table mapping label ID to label name.")
(defvar gkeep--existing-ids nil "Hash set of GKEEP_ID values already in org files.")
```

- [ ] **Step 3: Verify the file loads without errors**

Open Emacs, evaluate the buffer or run:
```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: prints "OK" with no errors.

- [ ] **Step 4: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add file header, requires, defgroup, and defcustoms"
```

---

### Task 2: Credential Loading and OAuth Token Refresh

**Files:**
- Modify: `srijan-lisp/gkeep-to-org.el`

Implements `gkeep--init` (load credentials from auth-source) and `gkeep--refresh-token` (POST to Google auth endpoint to get an OAuth token).

- [ ] **Step 1: Add `gkeep--init` to load credentials from auth-source**

Insert after the internal state variables section:

```elisp
;;; Authentication

(defun gkeep--init ()
  "Load credentials from auth-source and initialize session state."
  (setq gkeep--email
        (or (auth-source-pick-first-password
             :host gkeep-auth-host
             :user gkeep-email-user)
            (error "No email found in auth-source for host=%s user=%s"
                   gkeep-auth-host gkeep-email-user)))
  (setq gkeep--master-token
        (or (auth-source-pick-first-password
             :host gkeep-auth-host
             :user gkeep-master-token-user)
            (error "No master token found in auth-source for host=%s user=%s"
                   gkeep-auth-host gkeep-master-token-user)))
  (setq gkeep--sync-version nil)
  (setq gkeep--label-map (make-hash-table :test 'equal))
  (setq gkeep--existing-ids
        (if gkeep-skip-existing
            (gkeep--collect-existing-ids)
          (make-hash-table :test 'equal))))
```

- [ ] **Step 2: Add `gkeep--collect-existing-ids` for deduplication**

```elisp
(defun gkeep--collect-existing-ids ()
  "Collect GKEEP_ID values from all org agenda files into a hash set."
  (let ((id-set (make-hash-table :test 'equal)))
    (message "Scanning org files for existing Keep notes...")
    (org-map-entries
     (lambda ()
       (when-let ((id (org-entry-get nil "GKEEP_ID")))
         (puthash id t id-set)))
     "GKEEP_ID<>\"\""
     'agenda)
    (message "Found %d existing Keep notes in org files" (hash-table-count id-set))
    id-set))
```

- [ ] **Step 3: Add `gkeep--refresh-token` to get an OAuth token**

```elisp
(defun gkeep--refresh-token ()
  "Refresh the OAuth token using the master token.
POSTs to Google Play Services auth endpoint and extracts the Auth token."
  (let* ((url-request-method "POST")
         (url-request-extra-headers
          '(("Content-Type" . "application/x-www-form-urlencoded")))
         (params `(("accountType" . "HOSTED_OR_GOOGLE")
                   ("Email" . ,gkeep--email)
                   ("has_permission" . "1")
                   ("EncryptedPasswd" . ,gkeep--master-token)
                   ("service" . "oauth2:https://www.googleapis.com/auth/memento https://www.googleapis.com/auth/reminders")
                   ("source" . "android")
                   ("androidId" . "0000000000000000")
                   ("app" . "com.google.android.keep")
                   ("client_sig" . "38918a453d07199354f8b19af05ec6562ced5788")
                   ("device_country" . "us")
                   ("operatorCountry" . "us")
                   ("lang" . "en")
                   ("sdk_version" . "17")))
         (url-request-data
          (mapconcat (lambda (pair)
                       (concat (url-hexify-string (car pair))
                               "="
                               (url-hexify-string (cdr pair))))
                     params "&"))
         (buffer (url-retrieve-synchronously
                  "https://android.clients.google.com/auth" t)))
    (unwind-protect
        (with-current-buffer buffer
          (goto-char (point-min))
          (re-search-forward "\n\n")
          (let ((body (buffer-substring-no-properties (point) (point-max))))
            (if (string-match "^Auth=\\(.+\\)$" body)
                (setq gkeep--auth-token (match-string 1 body))
              (error "Failed to obtain OAuth token. Response:\n%s" body))))
      (kill-buffer buffer))
    (message "Google Keep: OAuth token refreshed")))
```

- [ ] **Step 4: Verify the file still loads**

```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: "OK" with no errors.

- [ ] **Step 5: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add credential loading and OAuth token refresh"
```

---

### Task 3: Keep API — Sync Endpoint and Note Fetching

**Files:**
- Modify: `srijan-lisp/gkeep-to-org.el`

Implements the HTTP call to `/changes`, pagination, node parsing, and filtering.

- [ ] **Step 1: Add the `gkeep--api-call` function for the sync endpoint**

Insert after the authentication section:

```elisp
;;; HTTP

(defun gkeep--request-header ()
  "Build the requestHeader object for Keep API calls."
  `(:clientSessionId ,(format "s--%s" (md5 (format "%s%s" (emacs-pid) (current-time))))
    :clientPlatform "ANDROID"
    :clientVersion (:major "9" :minor "9" :build "9" :revision "9")
    :capabilities [(:type "NC") (:type "PI") (:type "LB") (:type "AN")
                   (:type "SH") (:type "DR") (:type "TR") (:type "IN")
                   (:type "SNB") (:type "MI") (:type "CO")]))

(defun gkeep--api-call (endpoint payload)
  "POST JSON PAYLOAD to Keep API ENDPOINT. Return parsed plist."
  (let* ((url (concat "https://www.googleapis.com/notes/v1/" endpoint))
         (url-request-method "POST")
         (url-request-extra-headers
          `(("Authorization" . ,(format "OAuth %s" gkeep--auth-token))
            ("Content-Type" . "application/json")))
         (url-request-data
          (encode-coding-string (json-serialize payload) 'utf-8))
         (buffer (url-retrieve-synchronously url t)))
    (unwind-protect
        (with-current-buffer buffer
          (goto-char (point-min))
          (re-search-forward "\n\n")
          (json-parse-string
           (buffer-substring-no-properties (point) (point-max))
           :object-type 'plist
           :array-type 'list
           :false-object nil
           :null-object nil))
      (kill-buffer buffer))))
```

- [ ] **Step 2: Add `gkeep--fetch-all-nodes` with pagination**

```elisp
;;; API wrappers

(defun gkeep--fetch-all-nodes ()
  "Fetch all nodes from Keep, handling pagination.
Returns a list of all node plists. Also populates `gkeep--label-map'."
  (let ((all-nodes '())
        (done nil))
    (while (not done)
      (message "Fetching notes from Keep (version=%s)..."
               (or gkeep--sync-version "initial"))
      (let* ((payload `(:nodes []
                        :clientTimestamp ,(format-time-string "%Y-%m-%dT%H:%M:%S.000Z" nil t)
                        :requestHeader ,(gkeep--request-header)
                        ,@(when gkeep--sync-version
                            (list :targetVersion gkeep--sync-version))))
             (result (gkeep--api-call "changes" payload))
             (nodes (plist-get result :nodes))
             (user-info (plist-get result :userInfo))
             (labels (when user-info (plist-get user-info :labels)))
             (to-version (plist-get result :toVersion))
             (truncated (plist-get result :truncated)))
        ;; Build label map
        (dolist (label labels)
          (let ((id (plist-get label :mainId))
                (name (plist-get label :name)))
            (when (and id name)
              (puthash id name gkeep--label-map))))
        ;; Collect nodes
        (setq all-nodes (nconc all-nodes nodes))
        ;; Update sync version
        (when to-version
          (setq gkeep--sync-version to-version))
        ;; Check pagination
        (setq done (not truncated))))
    (message "Fetched %d total nodes from Keep" (length all-nodes))
    all-nodes))
```

- [ ] **Step 3: Add `gkeep--extract-notes` to filter and assemble note data**

```elisp
(defun gkeep--note-trashed-p (node)
  "Return non-nil if NODE has been trashed."
  (let* ((timestamps (plist-get node :timestamps))
         (trashed (when timestamps (plist-get timestamps :trashed))))
    (and trashed (not (string-empty-p trashed)))))

(defun gkeep--note-labels (node)
  "Return list of label name strings for NODE."
  (let ((label-ids (plist-get node :labelIds)))
    (cl-loop for entry in label-ids
             for id = (plist-get entry :labelId)
             for name = (gethash id gkeep--label-map)
             when name collect name)))

(defun gkeep--extract-notes (all-nodes)
  "Filter ALL-NODES to importable notes. Returns list of plists with:
:id, :server-id, :base-version, :title, :text, :labels, :timestamp."
  (let ((note-map (make-hash-table :test 'equal))
        (child-map (make-hash-table :test 'equal))
        (notes '()))
    ;; First pass: index all nodes
    (dolist (node all-nodes)
      (let ((id (plist-get node :id))
            (parent-id (plist-get node :parentId))
            (type (plist-get node :type)))
        (when (equal type "NOTE")
          (puthash id node note-map))
        ;; Child nodes (text content) have a parentId pointing to the NOTE
        (when (and parent-id (not (equal parent-id "root")))
          (push node (gethash parent-id child-map)))))
    ;; Second pass: assemble filtered notes
    (maphash
     (lambda (id node)
       (let* ((archived (plist-get node :isArchived))
              (pinned (plist-get node :isPinned))
              (trashed (gkeep--note-trashed-p node))
              (server-id (or (plist-get node :serverId) id))
              (base-version (plist-get node :baseVersion))
              (title (or (plist-get node :title) ""))
              (children (gethash id child-map))
              (child-text (or (plist-get (car children) :text) ""))
              (labels (gkeep--note-labels node))
              (timestamps (plist-get node :timestamps))
              (date-str (or (when timestamps
                              (plist-get timestamps :userEdited))
                            (when timestamps
                              (plist-get timestamps :created))))
              (existing (gethash server-id gkeep--existing-ids)))
         (unless (or archived trashed
                     (and gkeep-exclude-pinned pinned)
                     (and gkeep-skip-existing existing)
                     (and gkeep-label-filter
                          (not (cl-intersection labels gkeep-label-filter
                                                :test #'string=))))
           (push (list :id id
                       :server-id server-id
                       :base-version base-version
                       :title title
                       :text child-text
                       :labels labels
                       :timestamp date-str)
                 notes))))
     note-map)
    (nreverse notes)))
```

- [ ] **Step 4: Verify the file still loads**

```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: "OK" with no errors.

- [ ] **Step 5: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add Keep API sync endpoint, pagination, and note filtering"
```

---

### Task 4: Auto-Archive in Keep

**Files:**
- Modify: `srijan-lisp/gkeep-to-org.el`

Implements pushing archive updates back to Keep after import.

- [ ] **Step 1: Add `gkeep--archive-note` function**

Insert after the `gkeep--extract-notes` function:

```elisp
(defun gkeep--archive-note (note)
  "Archive NOTE in Google Keep by setting isArchived to true.
NOTE is a plist from `gkeep--extract-notes'."
  (let* ((id (plist-get note :id))
         (base-version (plist-get note :base-version))
         (payload `(:nodes [(:id ,id
                             ,@(when base-version
                                 (list :baseVersion base-version))
                             :isArchived t)]
                    :clientTimestamp ,(format-time-string "%Y-%m-%dT%H:%M:%S.000Z" nil t)
                    :requestHeader ,(gkeep--request-header)
                    ,@(when gkeep--sync-version
                        (list :targetVersion gkeep--sync-version))))
         (result (gkeep--api-call "changes" payload))
         (to-version (plist-get result :toVersion)))
    (when to-version
      (setq gkeep--sync-version to-version))))
```

- [ ] **Step 2: Verify the file still loads**

```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: "OK" with no errors.

- [ ] **Step 3: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add auto-archive of imported notes in Keep"
```

---

### Task 5: Org Heading Insertion

**Files:**
- Modify: `srijan-lisp/gkeep-to-org.el`

Implements the org heading insertion — title, tags, properties, timestamp, body.

- [ ] **Step 1: Add `gkeep--sanitize-tag` and `gkeep--insert-note` functions**

Insert after the archive function:

```elisp
;;; Org insertion

(defun gkeep--sanitize-tag (label)
  "Sanitize LABEL to a valid org tag (alphanumeric, underscores, hyphens)."
  (replace-regexp-in-string
   "[^a-zA-Z0-9_@-]" "_"
   (replace-regexp-in-string "\\s-+" "_" label)))

(defun gkeep--format-timestamp (iso-str)
  "Convert ISO-8601 string ISO-STR to an org inactive timestamp string."
  (when (and iso-str (not (string-empty-p iso-str)))
    (let* ((time (date-to-time iso-str)))
      (format-time-string "[%Y-%m-%d %a]" time))))

(defun gkeep--insert-note (note)
  "Insert NOTE as an org heading at point.
NOTE is a plist from `gkeep--extract-notes'."
  (let* ((title (plist-get note :title))
         (text (plist-get note :text))
         (labels (plist-get note :labels))
         (server-id (plist-get note :server-id))
         (timestamp (plist-get note :timestamp))
         ;; Use title, or first ~60 chars of body, or "Untitled"
         (heading (cond
                   ((and title (not (string-empty-p title))) title)
                   ((and text (not (string-empty-p text)))
                    (let ((first-line (car (split-string text "\n" t))))
                      (if (> (length first-line) 60)
                          (concat (substring first-line 0 57) "...")
                        first-line)))
                   (t "Untitled")))
         (tags (mapconcat #'gkeep--sanitize-tag
                          (cons "keep" labels) ":"))
         (date (gkeep--format-timestamp timestamp)))
    (insert (format "* %s :%s:\n" heading tags))
    (org-set-property "GKEEP_ID" server-id)
    (org-end-of-meta-data t)
    (when date
      (insert date "\n"))
    (when (and text (not (string-empty-p text)))
      (insert text "\n"))
    (insert "\n")))
```

- [ ] **Step 2: Verify the file still loads**

```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: "OK" with no errors.

- [ ] **Step 3: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add org heading insertion with tags, properties, timestamp"
```

---

### Task 6: Interactive Command and Provide

**Files:**
- Modify: `srijan-lisp/gkeep-to-org.el`

Wires everything together into the `gkeep-to-org` interactive command.

- [ ] **Step 1: Add the `gkeep-to-org` interactive command**

Insert after the org insertion section:

```elisp
;;; Main command

;;;###autoload
(defun gkeep-to-org (max)
  "Fetch Google Keep notes and insert as org entries at point.
With prefix arg MAX, fetch at most MAX items."
  (interactive "P")
  (unless (derived-mode-p 'org-mode)
    (user-error "Current buffer is not an org-mode buffer"))
  (gkeep--init)
  (message "Refreshing OAuth token...")
  (gkeep--refresh-token)
  (let* ((all-nodes (gkeep--fetch-all-nodes))
         (notes (gkeep--extract-notes all-nodes))
         (limit (or (when max (prefix-numeric-value max))
                    gkeep-max-items))
         (notes (if (and limit (< limit (length notes)))
                    (seq-take notes limit)
                  notes))
         (total (length notes))
         (count 0)
         (archived 0))
    (message "Processing %d notes..." total)
    (dolist (note notes)
      (cl-incf count)
      (message "Processing %d/%d..." count total)
      (condition-case err
          (progn
            (gkeep--insert-note note)
            (when gkeep-archive-after-import
              (condition-case archive-err
                  (progn
                    (gkeep--archive-note note)
                    (cl-incf archived))
                (error (warn "gkeep: Failed to archive note %s: %s"
                             (plist-get note :server-id)
                             (error-message-string archive-err))))))
        (error (warn "gkeep: Skipping note %s: %s"
                     (plist-get note :server-id)
                     (error-message-string err)))))
    (font-lock-ensure)
    (message "Inserted %d notes%s"
             total
             (if (> archived 0)
                 (format ", archived %d in Keep" archived)
               ""))))

(provide 'gkeep-to-org)
;;; gkeep-to-org.el ends here
```

- [ ] **Step 2: Verify the file loads cleanly**

```
emacs --batch -l srijan-lisp/gkeep-to-org.el --eval '(message "OK")'
```
Expected: "OK" with no errors.

- [ ] **Step 3: Commit**

```bash
git add srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): add gkeep-to-org interactive command, wire everything together"
```

---

### Task 7: Wire into Config and Add Helper Script

**Files:**
- Modify: `config.org` (add `(require 'gkeep-to-org)` in the appropriate section)
- Create: `scripts/gkeep-master-token.py` (one-time helper)

- [ ] **Step 1: Add require to config.org**

Find the section near where `slack-saved-to-org` is required (around line 3807 in config.org) and add:

```org
(require 'gkeep-to-org)
```

Place it in an appropriate section — either the existing GTD/productivity section or near the Slack section.

- [ ] **Step 2: Create the helper Python script for master token generation**

```python
#!/usr/bin/env python3
"""One-time helper to obtain a Google Play Services master token for Keep API.

Usage:
    pip install gpsoauth
    python scripts/gkeep-master-token.py

The script will prompt for your Google email and an app password
(generate one at https://myaccount.google.com/apppasswords).

Copy the printed master token into your auth-source file:
    machine google-keep login master-token password <token>
"""

import getpass
import sys

try:
    import gpsoauth
except ImportError:
    print("Error: gpsoauth not installed. Run: pip install gpsoauth")
    sys.exit(1)

email = input("Google email: ").strip()
password = getpass.getpass("App password (from https://myaccount.google.com/apppasswords): ")

ANDROID_ID = "0000000000000000"

print("\nExchanging credentials for master token...")
result = gpsoauth.perform_master_login(email, password, ANDROID_ID)

if "Token" not in result:
    print(f"Error: {result.get('Error', 'Unknown error')}")
    if "NeedsBrowser" in result.get("Url", ""):
        print("You may need to approve access at the URL above.")
    sys.exit(1)

master_token = result["Token"]
print(f"\nMaster token obtained. Add this to your auth-source file:\n")
print(f"machine google-keep login email password {email}")
print(f"machine google-keep login master-token password {master_token}")
```

- [ ] **Step 3: Commit**

```bash
git add config.org scripts/gkeep-master-token.py srijan-lisp/gkeep-to-org.el
git commit -m "feat(gkeep): wire into config.org and add master token helper script"
```

---

### Task 8: Manual Integration Test

**Files:** None (testing only)

This is a manual test against the real Keep API.

- [ ] **Step 1: Run the helper script to get a master token**

```bash
pip install gpsoauth
python scripts/gkeep-master-token.py
```

Add the output to `~/.authinfo.gpg`.

- [ ] **Step 2: Create a test note in Google Keep**

Open Google Keep, create a note with:
- Title: "Test import to org"
- Body: "This is a test note for the gkeep-to-org importer."
- Add a label (e.g., "test")
- Do NOT pin it

- [ ] **Step 3: Run the importer in Emacs**

Open an org buffer, position point where you want headings inserted, then:
```
M-x gkeep-to-org
```

Expected: the test note appears as an org heading with `:keep:test:` tags, `GKEEP_ID` property, timestamp, and body text.

- [ ] **Step 4: Verify auto-archive**

Check Google Keep — the test note should now be in the Archive.

- [ ] **Step 5: Run again to verify deduplication**

```
M-x gkeep-to-org
```

Expected: "Inserted 0 notes" — the test note is already in org files and already archived in Keep.
