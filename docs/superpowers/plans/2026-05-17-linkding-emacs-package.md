# linkding.el Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish a full CRUD Emacs client for the Linkding bookmark manager as a standalone MELPA package.

**Architecture:** Single `linkding.el` file with no external dependencies. Synchronous HTTP via `url-retrieve-synchronously` for read operations (completing-read, list view); async `url-retrieve` for writes (fire-and-forget with echo-area feedback). Local cache for bookmarks and tags, refreshed on demand.

**Tech Stack:** Emacs 28.1+, `url.el`, `json.el`, `tabulated-list-mode`, ERT for tests.

---

## File Map

| File | Purpose |
|---|---|
| `~/src/linkding.el/linkding.el` | Entire package — all public commands, internal helpers, mode definition |
| `~/src/linkding.el/tests/linkding-tests.el` | ERT test suite |
| `~/src/linkding.el/README.md` | User documentation |
| `~/src/linkding.el/CHANGELOG.md` | Version history |

---

## Task 1: Project Scaffold

**Files:**
- Create: `~/src/linkding.el/linkding.el`
- Create: `~/src/linkding.el/tests/linkding-tests.el`

- [ ] **Step 1: Create the project directory and git repo**

```bash
mkdir -p ~/src/linkding.el/tests
cd ~/src/linkding.el
git init
```

- [ ] **Step 2: Write the linkding.el skeleton**

Create `~/src/linkding.el/linkding.el`:

```elisp
;;; linkding.el --- Linkding bookmark manager client -*- lexical-binding: t; -*-

;; Author: Srijan Choudhary <you@work.example>
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: bookmarks, linkding, web, hypermedia
;; URL: https://github.com/srijan-c/linkding.el

;;; Commentary:
;; Full CRUD client for Linkding, a self-hosted bookmark manager.
;; Configure linkding-url and linkding-token, then use:
;;   linkding-add-bookmark   — save current page or URL at point
;;   linkding-open-bookmark  — open a bookmark via completing-read
;;   linkding-list           — browse all bookmarks in a tabulated buffer
;;   linkding-saved-search   — open a named saved search

;;; Code:

(require 'url)
(require 'url-util)
(require 'json)
(require 'tabulated-list)
(require 'cl-lib)

;; External variables (declared to satisfy byte-compiler and package-lint).
(defvar eww-data)

;;;; Customization

(defgroup linkding nil
  "Linkding bookmark manager client."
  :group 'web
  :prefix "linkding-")

(defcustom linkding-url nil
  "Base URL of your Linkding instance, e.g. \"https://links.example.com\"."
  :type '(choice (const nil) string))

(defcustom linkding-token nil
  "Linkding REST API token. Find it at Settings → Integrations."
  :type '(choice (const nil) string))

(defcustom linkding-open-fn #'browse-url
  "Function called with a URL string to open a bookmark."
  :type 'function)

(defcustom linkding-default-filter ""
  "Default elfeed-style filter string applied when opening `linkding-list'."
  :type 'string)

(defcustom linkding-saved-searches nil
  "Alist of (NAME . FILTER-STRING) named searches.
Example:
  \\='((\"Unread\" . \"+unread\")
    (\"Emacs\"  . \"+emacs\"))"
  :type '(alist :key-type string :value-type string))

;;;; Cache

(defvar linkding--bookmarks nil
  "Cached list of bookmark alists fetched from Linkding.")

(defvar linkding--tags nil
  "Cached list of tag name strings fetched from Linkding.")

(provide 'linkding)
;;; linkding.el ends here
```

- [ ] **Step 3: Write the test skeleton**

Create `~/src/linkding.el/tests/linkding-tests.el`:

```elisp
;;; linkding-tests.el --- ERT tests for linkding.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'linkding (expand-file-name "../linkding.el"
                                     (file-name-directory load-file-name)))

;;; Helpers

(defmacro linkding-with-mock-response (status-code body &rest forms)
  "Run FORMS with `url-retrieve-synchronously' returning a mock HTTP buffer."
  (declare (indent 2))
  `(cl-letf (((symbol-function 'url-retrieve-synchronously)
               (lambda (&rest _)
                 (let ((buf (generate-new-buffer " *linkding-mock*")))
                   (with-current-buffer buf
                     (insert (format "HTTP/1.1 %d OK\r\n\r\n%s" ,status-code ,body)))
                   buf))))
     ,@forms))

(provide 'linkding-tests)
;;; linkding-tests.el ends here
```

- [ ] **Step 4: Verify the file loads without error**

```bash
cd ~/src/linkding.el
emacs --batch -l linkding.el --eval '(message "OK")'
```

Expected output: `OK`

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: project scaffold with defcustoms and cache vars"
```

---

## Task 2: HTTP Helpers

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding--request-sync` and `linkding--request-async`
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add HTTP helper tests

- [ ] **Step 1: Write the failing tests**

Add to `tests/linkding-tests.el` before `(provide 'linkding-tests)`:

```elisp
;;; HTTP helpers

(ert-deftest linkding-request-sync-returns-parsed-json ()
  (let ((linkding-url "http://example.com")
        (linkding-token "tok"))
    (linkding-with-mock-response 200 "{\"count\":1,\"results\":[]}"
      (let ((result (linkding--request-sync "GET" "/api/bookmarks/")))
        (should (equal (alist-get 'count result) 1))
        (should (equal (alist-get 'results result) nil))))))

(ert-deftest linkding-request-sync-returns-nil-on-4xx ()
  (let ((linkding-url "http://example.com")
        (linkding-token "tok"))
    (linkding-with-mock-response 401 "{\"detail\":\"Invalid token\"}"
      (let ((result (linkding--request-sync "GET" "/api/bookmarks/")))
        (should (null result))))))

(ert-deftest linkding-request-sync-errors-without-config ()
  (let ((linkding-url nil)
        (linkding-token nil))
    (should-error (linkding--request-sync "GET" "/api/bookmarks/")
                  :type 'user-error)))
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el \
  -f ert-run-tests-batch-and-exit
```

Expected: 3 failures (functions not defined yet).

- [ ] **Step 3: Implement the HTTP helpers**

Add to `linkding.el` after the cache vars, before `(provide 'linkding)`:

```elisp
;;;; HTTP Helpers

(defun linkding--base-url ()
  "Return the trimmed base URL, signalling an error if unconfigured."
  (unless (and linkding-url linkding-token)
    (user-error "linkding: set `linkding-url' and `linkding-token'"))
  (string-trim-right linkding-url "/"))

(defun linkding--headers (&optional with-content-type)
  "Return the standard request headers alist."
  `(("Authorization" . ,(concat "Token " linkding-token))
    ,@(when with-content-type
        '(("Content-Type" . "application/json")))))

(defun linkding--parse-response-buffer (buf)
  "Parse HTTP status and JSON body from BUF. Return (STATUS . JSON-OR-NIL)."
  (with-current-buffer buf
    (goto-char (point-min))
    (let ((code (when (re-search-forward "HTTP/[0-9.]+ \\([0-9]+\\)" nil t)
                  (string-to-number (match-string 1)))))
      (cons code
            (when (and code (< code 400))
              (when (re-search-forward "^$" nil t)
                (condition-case nil
                    (unless (eobp) (json-read))
                  (error nil))))))))

(defun linkding--request-sync (method endpoint &optional payload)
  "Synchronous Linkding API call. Returns parsed JSON alist or nil on error.
METHOD is \"GET\", \"POST\", \"PATCH\", or \"DELETE\".
ENDPOINT is the path, e.g. \"/api/bookmarks/\".
PAYLOAD is an alist encoded as JSON (for POST/PATCH)."
  (let* ((url-request-method method)
         (url-request-extra-headers (linkding--headers payload))
         (url-request-data
          (when payload (encode-coding-string (json-encode payload) 'utf-8)))
         (full-url (concat (linkding--base-url) endpoint))
         (buf (url-retrieve-synchronously full-url t)))
    (when buf
      (unwind-protect
          (let* ((parsed (linkding--parse-response-buffer buf))
                 (code (car parsed))
                 (body (cdr parsed)))
            (if (and code (>= code 400))
                (prog1 nil (message "linkding: HTTP %d for %s" code endpoint))
              body))
        (kill-buffer buf)))))

(defun linkding--request-async (method endpoint &optional payload callback)
  "Async Linkding API call (fire-and-forget for writes).
CALLBACK is called with parsed JSON alist or nil on error."
  (let* ((url-request-method method)
         (url-request-extra-headers (linkding--headers payload))
         (url-request-data
          (when payload (encode-coding-string (json-encode payload) 'utf-8)))
         (full-url (concat (linkding--base-url) endpoint)))
    (url-retrieve full-url
                  (lambda (status)
                    (unwind-protect
                        (let ((err (plist-get status :error)))
                          (if err
                              (message "linkding: request error: %S" (cadr err))
                            (let* ((parsed (linkding--parse-response-buffer
                                            (current-buffer)))
                                   (code (car parsed))
                                   (body (cdr parsed)))
                              (if (and code (>= code 400))
                                  (message "linkding: HTTP %d for %s" code endpoint)
                                (when callback (funcall callback body))))))
                      (kill-buffer (current-buffer))))
                  nil t)))
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add synchronous and async HTTP helpers"
```

---

## Task 3: API Wrappers

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add five API wrapper functions
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add pagination test

- [ ] **Step 1: Write the failing test**

Add to `tests/linkding-tests.el`:

```elisp
;;; API wrappers

(ert-deftest linkding-fetch-bookmarks-paginates ()
  "Fetches all pages and concatenates results."
  (let ((linkding-url "http://example.com")
        (linkding-token "tok")
        (call-count 0))
    (cl-letf (((symbol-function 'url-retrieve-synchronously)
               (lambda (url &rest _)
                 (cl-incf call-count)
                 (let ((buf (generate-new-buffer " *linkding-mock*"))
                       (body (if (string-match-p "offset=0" url)
                                 "{\"count\":2,\"next\":\"http://example.com/api/bookmarks/?offset=100\",\"results\":[{\"id\":1,\"url\":\"http://a.com\",\"title\":\"A\",\"tag_names\":[],\"is_unread\":false,\"is_archived\":false,\"date_added\":\"2024-01-01T00:00:00Z\"}]}"
                               "{\"count\":2,\"next\":null,\"results\":[{\"id\":2,\"url\":\"http://b.com\",\"title\":\"B\",\"tag_names\":[],\"is_unread\":false,\"is_archived\":false,\"date_added\":\"2024-01-02T00:00:00Z\"}]}")))
                   (with-current-buffer buf (insert "HTTP/1.1 200 OK\r\n\r\n" body))
                   buf))))
      (let ((results (linkding--fetch-bookmarks-sync)))
        (should (= (length results) 2))
        (should (= call-count 2))
        (should (equal (alist-get 'id (car results)) 1))
        (should (equal (alist-get 'id (cadr results)) 2))))))
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 1 failure (linkding--fetch-bookmarks-sync not defined).

- [ ] **Step 3: Implement the API wrappers**

Add to `linkding.el` after the HTTP helpers section:

```elisp
;;;; API Wrappers

(defun linkding--fetch-bookmarks-sync (&optional params)
  "Fetch all bookmarks synchronously, paging through results.
PARAMS is an alist of extra query string pairs, e.g. \\='((\"tag\" \"emacs\")).
Returns a list of bookmark alists."
  (let ((collected '())
        (offset 0)
        (done nil))
    (while (not done)
      (let* ((query (url-build-query-string
                     (append `(("limit" "100") ("offset" ,(number-to-string offset)))
                             params)))
             (data (linkding--request-sync "GET" (concat "/api/bookmarks/?" query))))
        (if (null data)
            (setq done t)
          (setq collected (append collected (alist-get 'results data)))
          (if (alist-get 'next data)
              (setq offset (+ offset 100))
            (setq done t)))))
    collected))

(defun linkding--fetch-tags-sync ()
  "Fetch all tag name strings synchronously. Returns a list of strings."
  (let ((data (linkding--request-sync "GET" "/api/tags/?limit=1000")))
    (when data
      (mapcar (lambda (tag) (alist-get 'name tag))
              (alist-get 'results data)))))

(defun linkding--create-bookmark (fields callback)
  "POST a new bookmark. FIELDS is an alist; CALLBACK receives the created alist."
  (linkding--request-async "POST" "/api/bookmarks/" fields callback))

(defun linkding--update-bookmark (id fields callback)
  "PATCH bookmark ID with FIELDS. CALLBACK receives the updated alist."
  (linkding--request-async "PATCH"
                           (format "/api/bookmarks/%d/" id)
                           fields callback))

(defun linkding--delete-bookmark (id callback)
  "DELETE bookmark ID. CALLBACK receives nil (204 No Content)."
  (linkding--request-async "DELETE"
                           (format "/api/bookmarks/%d/" id)
                           nil callback))
```

- [ ] **Step 4: Run tests**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add paginated API wrappers for bookmarks, tags, CRUD"
```

---

## Task 4: Cache and Refresh

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding-refresh`

- [ ] **Step 1: Implement cache helpers and `linkding-refresh`**

Add to `linkding.el` after the API wrappers:

```elisp
;;;; Cache and Refresh

(defun linkding--ensure-bookmarks ()
  "Populate `linkding--bookmarks' from API if nil. Returns the cache."
  (unless linkding--bookmarks
    (setq linkding--bookmarks (linkding--fetch-bookmarks-sync)))
  linkding--bookmarks)

(defun linkding--ensure-tags ()
  "Populate `linkding--tags' from API if nil. Returns the cache."
  (unless linkding--tags
    (setq linkding--tags (linkding--fetch-tags-sync)))
  linkding--tags)

;; Forward declaration — defined in the list-mode section below.
(declare-function linkding--list-refresh "linkding")

(defun linkding-refresh ()
  "Re-fetch bookmarks and tags from Linkding, update any live *linkding* buffer."
  (interactive)
  (message "linkding: refreshing…")
  (setq linkding--bookmarks (linkding--fetch-bookmarks-sync))
  (setq linkding--tags (linkding--fetch-tags-sync))
  (message "linkding: %d bookmarks, %d tags cached"
           (length linkding--bookmarks) (length linkding--tags))
  (when-let ((buf (get-buffer "*linkding*")))
    (with-current-buffer buf
      (linkding--list-refresh))))
```

- [ ] **Step 2: Verify the file still loads**

```bash
cd ~/src/linkding.el
emacs --batch -l linkding.el --eval '(message "OK")'
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el
git commit -m "feat: add cache helpers and linkding-refresh command"
```

---

## Task 5: Filter Parser

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding--parse-filter`
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add parser tests

- [ ] **Step 1: Write the failing tests**

Add to `tests/linkding-tests.el`:

```elisp
;;; Filter parser

(ert-deftest linkding-parse-filter-empty ()
  (should (equal (linkding--parse-filter "") '(nil nil nil))))

(ert-deftest linkding-parse-filter-unread ()
  (cl-destructuring-bind (params include exclude) (linkding--parse-filter "+unread")
    (should (member '("is_unread" "yes") params))
    (should (null include))
    (should (null exclude))))

(ert-deftest linkding-parse-filter-archived ()
  (cl-destructuring-bind (params _i _e) (linkding--parse-filter "+archived")
    (should (member '("is_archived" "yes") params))))

(ert-deftest linkding-parse-filter-include-tag ()
  (cl-destructuring-bind (params _i _e) (linkding--parse-filter "+emacs")
    (should (member '("tag" "emacs") params))))

(ert-deftest linkding-parse-filter-multiple-include-tags ()
  "Second +TAG is added to client-side INCLUDE list, not EXCLUDE."
  (cl-destructuring-bind (params include exclude)
      (linkding--parse-filter "+emacs +lisp")
    (should (member '("tag" "emacs") params))
    (should (member "lisp" include))
    (should-not (member "lisp" exclude))))

(ert-deftest linkding-parse-filter-exclude-tag ()
  (cl-destructuring-bind (_p _i exclude) (linkding--parse-filter "-emacs")
    (should (member "emacs" exclude))))

(ert-deftest linkding-parse-filter-query ()
  (cl-destructuring-bind (params _i _e) (linkding--parse-filter "hello world")
    (should (member '("q" "hello world") params))))

(ert-deftest linkding-parse-filter-combined ()
  "+unread +emacs -python foo"
  (cl-destructuring-bind (params _i exclude)
      (linkding--parse-filter "+unread +emacs -python foo")
    (should (member '("is_unread" "yes") params))
    (should (member '("tag" "emacs") params))
    (should (member "python" exclude))
    (should (member '("q" "foo") params))))
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 8 failures.

- [ ] **Step 3: Implement `linkding--parse-filter` and `linkding--apply-client-filters`**

Add to `linkding.el` after the cache section:

```elisp
;;;; Filter Parser

(defun linkding--parse-filter (filter-string)
  "Parse elfeed-style FILTER-STRING into (API-PARAMS INCLUDE-TAGS EXCLUDE-TAGS).
API-PARAMS is a list of (KEY VALUE) pairs for `url-build-query-string'.
INCLUDE-TAGS is a list of additional tag names beyond the first +TAG, applied
as a client-side AND filter (Linkding's API only honors one `tag' param).
EXCLUDE-TAGS is a list of tag names to remove client-side.

Tokens:
  +unread   → is_unread=yes API param
  +archived → is_archived=yes API param
  +TAG      → first one becomes the API `tag' param; extras go into INCLUDE-TAGS
  -TAG      → added to EXCLUDE-TAGS
  WORD      → appended to q= API param"
  (let ((tokens (split-string (string-trim filter-string)))
        (api-params '())
        (include-tags '())
        (exclude-tags '())
        (query-parts '())
        (tag-param-set nil))
    (dolist (token tokens)
      (cond
       ((string= token "+unread")
        (push '("is_unread" "yes") api-params))
       ((string= token "+archived")
        (push '("is_archived" "yes") api-params))
       ((string-prefix-p "+" token)
        (let ((tag (substring token 1)))
          (if tag-param-set
              (push tag include-tags)
            (push `("tag" ,tag) api-params)
            (setq tag-param-set t))))
       ((string-prefix-p "-" token)
        (push (substring token 1) exclude-tags))
       (t
        (push token query-parts))))
    (when query-parts
      (push `("q" ,(string-join (nreverse query-parts) " ")) api-params))
    (list api-params include-tags exclude-tags)))

(defun linkding--apply-client-filters (bookmarks include-tags exclude-tags)
  "Return BOOKMARKS filtered by INCLUDE-TAGS (AND) and EXCLUDE-TAGS."
  (if (and (null include-tags) (null exclude-tags))
      bookmarks
    (cl-remove-if-not
     (lambda (bm)
       (let ((tags (alist-get 'tag_names bm)))
         (and (cl-every (lambda (tag) (cl-find tag tags :test #'string=))
                        include-tags)
              (not (cl-intersection exclude-tags tags :test #'string=)))))
     bookmarks)))
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add elfeed-style filter parser with tests"
```

---

## Task 6: Capture Command

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding-add-bookmark`
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add capture tests

- [ ] **Step 1: Write the failing tests**

Add to `tests/linkding-tests.el`:

```elisp
;;; Capture

(ert-deftest linkding-detect-url-from-eww ()
  "linkding--detect-url reads from eww-data in eww-mode."
  (with-temp-buffer
    (setq-local major-mode 'eww-mode)
    (setq-local eww-data '(:url "http://example.com" :title "Example"))
    (should (equal (linkding--detect-url) "http://example.com"))
    (should (equal (linkding--detect-title) "Example"))))

(ert-deftest linkding-detect-url-from-thing-at-point ()
  "linkding--detect-url reads URL at point in non-eww buffers."
  (with-temp-buffer
    (insert "visit http://example.org for more")
    (goto-char 7)
    (should (equal (linkding--detect-url) "http://example.org"))))
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 2 failures.

- [ ] **Step 3: Implement context detection and `linkding-add-bookmark`**

Add to `linkding.el` after the filter parser section:

```elisp
;;;; Capture

(defun linkding--detect-url ()
  "Return URL for the current context: eww-data, thing-at-point, or nil."
  (if (derived-mode-p 'eww-mode)
      (plist-get eww-data :url)
    (thing-at-point 'url t)))

(defun linkding--detect-title ()
  "Return page title for the current context, or nil."
  (when (derived-mode-p 'eww-mode)
    (plist-get eww-data :title)))

(defun linkding-add-bookmark (&optional url-arg title-arg prefix)
  "Save a bookmark to Linkding.
Optional URL-ARG and TITLE-ARG let elisp callers bypass auto-detection
(e.g. for an `org-capture' template). When unset, runs context detection:
in an EWW buffer, captures URL and title from `eww-data' automatically;
elsewhere, reads URL from `thing-at-point' or prompts.
With PREFIX arg (\\[universal-argument]), also prompts for description and unread status."
  (interactive (list nil nil current-prefix-arg))
  (let* ((detected-url (or url-arg (linkding--detect-url)))
         (detected-title (or title-arg (linkding--detect-title)))
         (url (or detected-url
                  (read-string "URL: ")))
         (title (read-string "Title: " detected-title))
         (tags (completing-read-multiple
                "Tags: " (linkding--ensure-tags)))
         (description (when prefix (read-string "Description: ")))
         (is-unread (when prefix
                      (y-or-n-p "Mark as unread? ")))
         (fields `((url . ,url)
                   (title . ,title)
                   (tag_names . ,(vconcat tags))
                   ,@(when description `((description . ,description)))
                   ,@(when prefix `((is_unread . ,(if is-unread t :json-false)))))))
    (linkding--create-bookmark
     fields
     (lambda (created)
       (message "linkding: saved <%s>" url)
       ;; Insert into the local cache instead of refetching everything.
       (when (and created linkding--bookmarks)
         (push created linkding--bookmarks))
       ;; Refresh any live list buffer so the new bookmark shows up there too.
       (when-let ((buf (get-buffer "*linkding*")))
         (with-current-buffer buf
           (linkding--list-refresh)))))))
```

- [ ] **Step 4: Run tests**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add context-aware linkding-add-bookmark capture command"
```

---

## Task 7: Quick Search

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding-open-bookmark` and `linkding-search`
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add formatting test

- [ ] **Step 1: Write the failing test**

Add to `tests/linkding-tests.el`:

```elisp
;;; Candidate formatting

(ert-deftest linkding-format-candidate-unread ()
  (let* ((bm '((id . 1) (url . "http://a.com") (title . "Alpha")
               (tag_names . ("emacs" "lisp")) (is_unread . t)))
         (candidate (linkding--format-candidate bm)))
    (should (string-prefix-p "*" candidate))
    (should (string-match-p "Alpha" candidate))
    (should (string-match-p "emacs lisp" candidate))))

(ert-deftest linkding-format-candidate-read ()
  (let* ((bm '((id . 2) (url . "http://b.com") (title . "Beta")
               (tag_names . ()) (is_unread . :json-false)))
         (candidate (linkding--format-candidate bm)))
    (should (string-prefix-p " " candidate))))
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 2 failures.

- [ ] **Step 3: Implement candidate formatting and quick search commands**

Add to `linkding.el` after the capture section:

```elisp
;;;; Quick Search

(defun linkding--format-candidate (bookmark)
  "Format BOOKMARK as a completing-read candidate string.
Stores the bookmark alist as a text property for retrieval."
  (let* ((title (alist-get 'title bookmark))
         (url (alist-get 'url bookmark))
         (tags (alist-get 'tag_names bookmark))
         (unread (eq (alist-get 'is_unread bookmark) t))
         (display (if (or (null title) (string-empty-p title)) url title)))
    (propertize
     (format "%s %-45s  %s"
             (if unread "*" " ")
             (truncate-string-to-width display 45 nil nil "…")
             (string-join tags " "))
     'linkding-bookmark bookmark)))

(defun linkding--candidates-from (bookmarks)
  "Return a list of formatted candidate strings from BOOKMARKS."
  (mapcar #'linkding--format-candidate bookmarks))

(defun linkding--open-candidate (candidate)
  "Open the URL stored in CANDIDATE's text property."
  (when-let ((bm (get-text-property 0 'linkding-bookmark candidate)))
    (funcall linkding-open-fn (alist-get 'url bm))))

(defun linkding-open-bookmark (&optional refresh)
  "Select and open a bookmark via `completing-read'.
With prefix arg REFRESH, re-fetch bookmarks first."
  (interactive "P")
  (when refresh (setq linkding--bookmarks nil))
  (let* ((bookmarks (linkding--ensure-bookmarks))
         (candidates (linkding--candidates-from bookmarks))
         (chosen (completing-read "Bookmark: " candidates nil t)))
    (linkding--open-candidate chosen)))

(defun linkding-search (filter)
  "Search Linkding with elfeed-style FILTER string and open a result."
  (interactive "sFilter: ")
  (cl-destructuring-bind (api-params include-tags exclude-tags)
      (linkding--parse-filter filter)
    (let* ((bookmarks (linkding--fetch-bookmarks-sync api-params))
           (filtered (linkding--apply-client-filters
                      bookmarks include-tags exclude-tags))
           (candidates (linkding--candidates-from filtered))
           (chosen (completing-read "Bookmark: " candidates nil t)))
      (linkding--open-candidate chosen))))
```

- [ ] **Step 4: Run tests**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add linkding-open-bookmark and linkding-search commands"
```

---

## Task 8: Tabulated List Mode

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding-list-mode`, `linkding-list`, `linkding-saved-search`
- Modify: `~/src/linkding.el/tests/linkding-tests.el` — add entry format test

- [ ] **Step 1: Write the failing test**

Add to `tests/linkding-tests.el`:

```elisp
;;; List mode

(ert-deftest linkding-make-entry-format ()
  (let* ((bm '((id . 42) (url . "http://a.com") (title . "Alpha")
               (tag_names . ("emacs")) (is_unread . t)
               (date_added . "2024-06-01T12:00:00Z")))
         (entry (linkding--make-entry bm)))
    (should (equal (car entry) 42))
    (should (equal (length (cadr entry)) 4))
    (should (string= (aref (cadr entry) 0) "*"))
    (should (string-match-p "Alpha" (aref (cadr entry) 1)))
    (should (string= (aref (cadr entry) 2) "emacs"))
    (should (string= (aref (cadr entry) 3) "2024-06-01"))))
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: 1 failure.

- [ ] **Step 3: Implement the list mode**

Add to `linkding.el` after the quick search section:

```elisp
;;;; Tabulated List Mode

;; Forward declaration — defined in the edit section below.
(declare-function linkding-edit-bookmark "linkding")

(defun linkding--make-entry (bookmark)
  "Convert BOOKMARK alist into a `tabulated-list-mode' entry."
  (let* ((id (alist-get 'id bookmark))
         (title (or (alist-get 'title bookmark) ""))
         (url (alist-get 'url bookmark))
         (tags (string-join (alist-get 'tag_names bookmark) " "))
         (date (substring (or (alist-get 'date_added bookmark) "0000-00-00") 0 10))
         (unread (eq (alist-get 'is_unread bookmark) t))
         (display (if (string-empty-p title) url title))
         (title-str (propertize
                     (truncate-string-to-width display 40 nil nil "…")
                     'linkding-bookmark bookmark
                     'help-echo url)))
    (list id (vector (if unread "*" " ") title-str tags date))))

(defun linkding--bookmark-at-point ()
  "Return the bookmark alist for the list entry at point, or nil."
  (when-let* ((id (tabulated-list-get-id))
              (bms (buffer-local-value 'linkding--list-bookmarks
                                       (current-buffer))))
    (cl-find id bms :key (lambda (bm) (alist-get 'id bm)) :test #'equal)))

(defun linkding--list-refresh ()
  "Re-fetch bookmarks for the active filter and repopulate this buffer."
  (cl-destructuring-bind (api-params include-tags exclude-tags)
      (linkding--parse-filter linkding--active-filter)
    (let* ((bookmarks (linkding--fetch-bookmarks-sync api-params))
           (filtered (linkding--apply-client-filters
                      bookmarks include-tags exclude-tags)))
      (setq linkding--list-bookmarks filtered)
      (setq tabulated-list-entries (mapcar #'linkding--make-entry filtered))
      (tabulated-list-print t)
      (message "linkding: %d bookmarks" (length filtered)))))

(define-derived-mode linkding-list-mode tabulated-list-mode "Linkding"
  "Major mode for browsing Linkding bookmarks.
\\{linkding-list-mode-map}"
  (setq tabulated-list-format
        [("U" 1 t) ("Title" 40 t) ("Tags" 25 nil) ("Date" 10 t)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key '("Date" . t))
  (tabulated-list-init-header))

;; `define-derived-mode' auto-creates `linkding-list-mode-map' with the
;; tabulated-list-mode parent keymap, so motion keys like `n'/`p' work.
;; We just layer our bindings on top.
(define-key linkding-list-mode-map (kbd "RET") #'linkding-list-open)
(define-key linkding-list-mode-map (kbd "r")   #'linkding-list-toggle-unread)
(define-key linkding-list-mode-map (kbd "A")   #'linkding-list-toggle-archived)
(define-key linkding-list-mode-map (kbd "e")   #'linkding-edit-bookmark)
(define-key linkding-list-mode-map (kbd "d")   #'linkding-list-delete)
(define-key linkding-list-mode-map (kbd "s")   #'linkding-list-set-filter)
(define-key linkding-list-mode-map (kbd "S")   #'linkding-list-saved-search)
(define-key linkding-list-mode-map (kbd "g")   #'linkding-list-refresh)
(define-key linkding-list-mode-map (kbd "q")   #'quit-window)

(defvar-local linkding--active-filter ""
  "Active elfeed-style filter string for this linkding-list buffer.")

(defvar-local linkding--active-search-name nil
  "Name of the active saved search, or nil.")

(defvar-local linkding--list-bookmarks nil
  "The list of bookmark alists currently displayed in this buffer.")

(defun linkding-list ()
  "Open a *linkding* buffer showing all bookmarks."
  (interactive)
  (let ((buf (get-buffer-create "*linkding*")))
    (with-current-buffer buf
      (linkding-list-mode)
      (setq linkding--active-filter linkding-default-filter)
      (setq linkding--active-search-name nil)
      (message "linkding: fetching…")
      (linkding--list-refresh))
    (switch-to-buffer buf)))

(defun linkding-saved-search ()
  "Open *linkding* buffer filtered by a named saved search."
  (interactive)
  (unless linkding-saved-searches
    (user-error "linkding: set `linkding-saved-searches' first"))
  (let* ((name (completing-read "Saved search: "
                                (mapcar #'car linkding-saved-searches)
                                nil t))
         (filter (alist-get name linkding-saved-searches nil nil #'string=))
         (buf (get-buffer-create "*linkding*")))
    (with-current-buffer buf
      (linkding-list-mode)
      (setq linkding--active-filter filter)
      (setq linkding--active-search-name name)
      (setq mode-name (format "Linkding[%s]" name))
      (force-mode-line-update)
      (message "linkding: fetching '%s'…" name)
      (linkding--list-refresh))
    (switch-to-buffer buf)))
```

- [ ] **Step 4: Run tests**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el tests/linkding-tests.el
git commit -m "feat: add linkding-list-mode, linkding-list, linkding-saved-search"
```

---

## Task 9: List Action Commands

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — implement the action commands bound in the keymap

- [ ] **Step 1: Implement all list action commands**

Add to `linkding.el` after the list mode section:

```elisp
;;;; List Actions

(defun linkding-list-open ()
  "Open the bookmark at point via `linkding-open-fn'."
  (interactive)
  (if-let ((bm (linkding--bookmark-at-point)))
      (funcall linkding-open-fn (alist-get 'url bm))
    (user-error "linkding: no bookmark at point")))

(defun linkding--update-cached-bookmark (id updated)
  "Replace the cached `linkding--bookmarks' entry for ID with UPDATED, if cached."
  (when (and updated linkding--bookmarks)
    (setq linkding--bookmarks
          (cl-substitute-if (append updated nil)
                            (lambda (b) (equal (alist-get 'id b) id))
                            linkding--bookmarks))))

(defun linkding--list-replace-row (buffer id updated)
  "Swap the row for bookmark ID in BUFFER for one built from UPDATED.
Looks the row up by ID (not by current point) so callers don't have to
remain on the row while async work completes. Also updates `linkding--bookmarks'."
  (linkding--update-cached-bookmark id updated)
  (when (and updated (buffer-live-p buffer))
    (with-current-buffer buffer
      (let* ((new-bm (append updated nil))
             (new-entry (linkding--make-entry new-bm))
             (pos (point)))
        (setq linkding--list-bookmarks
              (cl-substitute-if new-bm
                                (lambda (b) (equal (alist-get 'id b) id))
                                linkding--list-bookmarks))
        (setq tabulated-list-entries
              (cl-substitute-if new-entry
                                (lambda (entry) (equal (car entry) id))
                                tabulated-list-entries))
        (tabulated-list-print t)
        (goto-char pos)))))

(defun linkding--list-patch-at-point (fields)
  "PATCH bookmark at point with FIELDS alist. Refreshes the row on success."
  (if-let ((bm (linkding--bookmark-at-point)))
      (let ((id (alist-get 'id bm))
            (buf (current-buffer)))
        (linkding--update-bookmark
         id fields
         (lambda (updated)
           (linkding--list-replace-row buf id updated))))
    (user-error "linkding: no bookmark at point")))

(defun linkding-list-toggle-unread ()
  "Toggle the is_unread status of the bookmark at point."
  (interactive)
  (if-let ((bm (linkding--bookmark-at-point)))
      (let ((now-unread (eq (alist-get 'is_unread bm) t)))
        (linkding--list-patch-at-point
         `((is_unread . ,(if now-unread :json-false t)))))
    (user-error "linkding: no bookmark at point")))

(defun linkding-list-toggle-archived ()
  "Toggle the is_archived status of the bookmark at point."
  (interactive)
  (if-let ((bm (linkding--bookmark-at-point)))
      (let ((now-archived (eq (alist-get 'is_archived bm) t)))
        (linkding--list-patch-at-point
         `((is_archived . ,(if now-archived :json-false t)))))
    (user-error "linkding: no bookmark at point")))

(defun linkding-list-delete ()
  "Delete the bookmark at point after confirmation."
  (interactive)
  (if-let ((bm (linkding--bookmark-at-point)))
      (let ((id (alist-get 'id bm))
            (url (alist-get 'url bm))
            (buf (current-buffer)))
        (when (yes-or-no-p (format "Delete bookmark <%s>? " url))
          (linkding--delete-bookmark
           id
           (lambda (_)
             (when (buffer-live-p buf)
               (with-current-buffer buf
                 (setq linkding--list-bookmarks
                       (cl-remove id linkding--list-bookmarks
                                  :key (lambda (b) (alist-get 'id b))
                                  :test #'equal))
                 (setq tabulated-list-entries
                       (cl-remove id tabulated-list-entries
                                  :key #'car :test #'equal))
                 (tabulated-list-print t)
                 (message "linkding: deleted <%s>" url)))))))
    (user-error "linkding: no bookmark at point")))

(defun linkding-list-set-filter (filter)
  "Edit the active filter string for this buffer and refresh."
  (interactive
   (list (read-string "Filter: " linkding--active-filter)))
  (setq linkding--active-filter filter)
  (setq linkding--active-search-name nil)
  (setq mode-name "Linkding")
  (force-mode-line-update)
  (linkding--list-refresh))

(defun linkding-list-saved-search ()
  "Switch this buffer to a named saved search."
  (interactive)
  (unless linkding-saved-searches
    (user-error "linkding: set `linkding-saved-searches' first"))
  (let* ((name (completing-read "Saved search: "
                                (mapcar #'car linkding-saved-searches)
                                nil t))
         (filter (alist-get name linkding-saved-searches nil nil #'string=)))
    (setq linkding--active-filter filter)
    (setq linkding--active-search-name name)
    (setq mode-name (format "Linkding[%s]" name))
    (force-mode-line-update)
    (linkding--list-refresh)))

(defun linkding-list-refresh ()
  "Re-run the active filter and repopulate this buffer."
  (interactive)
  (message "linkding: refreshing…")
  (linkding--list-refresh))
```

- [ ] **Step 2: Verify the file loads**

```bash
cd ~/src/linkding.el
emacs --batch -l linkding.el --eval '(message "OK")'
```

Expected: `OK`

- [ ] **Step 3: Run full test suite**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el
git commit -m "feat: implement list action commands (open, toggle, delete, filter)"
```

---

## Task 10: Edit Bookmark

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add `linkding-edit-bookmark`

- [ ] **Step 1: Implement `linkding-edit-bookmark`**

Add to `linkding.el` after the list actions section:

```elisp
;;;; Edit Bookmark

(defun linkding-edit-bookmark (&optional bookmark)
  "Edit a bookmark's title, tags, description, and unread status.
When called from `linkding-list-mode', edits the bookmark at point.
When called interactively elsewhere, prompts via `completing-read'."
  (interactive)
  (let* ((bm (or bookmark
                 (linkding--bookmark-at-point)
                 (let* ((bookmarks (linkding--ensure-bookmarks))
                        (candidates (linkding--candidates-from bookmarks))
                        (chosen (completing-read "Edit bookmark: " candidates nil t)))
                   (get-text-property 0 'linkding-bookmark chosen))))
         (id (alist-get 'id bm))
         (orig-title (or (alist-get 'title bm) ""))
         (orig-tags (alist-get 'tag_names bm))
         (orig-desc (or (alist-get 'description bm) ""))
         (orig-unread (eq (alist-get 'is_unread bm) t)))
    (unless bm (user-error "linkding: no bookmark selected"))
    (let* ((new-title (read-string "Title: " orig-title))
           (new-tags (completing-read-multiple
                      "Tags: " (linkding--ensure-tags)
                      nil nil (string-join orig-tags ",")))
           (new-desc (read-string "Description: " orig-desc))
           (new-unread (y-or-n-p (format "Unread? (currently %s) "
                                         (if orig-unread "yes" "no"))))
           ;; Build the PATCH payload with only the fields that actually changed.
           (fields (append
                    (unless (equal new-title orig-title)
                      `((title . ,new-title)))
                    (unless (equal new-tags orig-tags)
                      `((tag_names . ,(vconcat new-tags))))
                    (unless (equal new-desc orig-desc)
                      `((description . ,new-desc)))
                    (unless (eq new-unread orig-unread)
                      `((is_unread . ,(if new-unread t :json-false))))))
           (buf (when (derived-mode-p 'linkding-list-mode) (current-buffer))))
      (if (null fields)
          (message "linkding: no changes")
        (linkding--update-bookmark
         id fields
         (lambda (updated)
           (message "linkding: updated <%s>" (alist-get 'url bm))
           ;; In-place row swap when called from a list buffer (matches the spec's
           ;; "refreshes list row in place"); cache update happens regardless.
           (if buf
               (linkding--list-replace-row buf id updated)
             (linkding--update-cached-bookmark id updated))))))))
```

- [ ] **Step 2: Verify the file loads**

```bash
cd ~/src/linkding.el
emacs --batch -l linkding.el --eval '(message "OK")'
```

Expected: `OK`

- [ ] **Step 3: Run full test suite**

```bash
cd ~/src/linkding.el
emacs --batch -l tests/linkding-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el
git commit -m "feat: add linkding-edit-bookmark for in-place and standalone editing"
```

---

## Task 11: Embark Integration

**Files:**
- Modify: `~/src/linkding.el/linkding.el` — add embark integration guarded by `with-eval-after-load`

- [ ] **Step 1: Implement Embark integration**

Add to `linkding.el` after the edit section, before `(provide 'linkding)`:

```elisp
;;;; Embark Integration

(with-eval-after-load 'embark
  (defvar linkding-embark-url-actions
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "l") #'linkding-add-bookmark)
      map)
    "Embark action map for URL targets. `l' saves to Linkding.")

  (add-to-list 'embark-keymap-alist
               '(url . linkding-embark-url-actions)))
```

- [ ] **Step 2: Verify the file loads with and without embark present**

```bash
cd ~/src/linkding.el
emacs --batch -l linkding.el --eval '(message "OK")'
```

Expected: `OK` (embark block is skipped silently when embark is absent).

- [ ] **Step 3: Commit**

```bash
cd ~/src/linkding.el
git add linkding.el
git commit -m "feat: add embark URL action for linkding-add-bookmark"
```

---

## Task 12: Documentation

**Files:**
- Create: `~/src/linkding.el/README.md`
- Create: `~/src/linkding.el/CHANGELOG.md`

- [ ] **Step 1: Write README.md**

Create `~/src/linkding.el/README.md`:

```markdown
# linkding.el

An Emacs client for [Linkding](https://linkding.link), a self-hosted bookmark manager.

## Installation

Not yet on MELPA. For now, clone and add to your load path:

```elisp
(add-to-list 'load-path "~/src/linkding.el")
(require 'linkding)
```

## Configuration

```elisp
(setq linkding-url "https://your-linkding-instance.example.com")
(setq linkding-token "your-api-token")  ; Settings → Integrations in Linkding

;; Optional: how URLs are opened (default: browse-url)
(setq linkding-open-fn #'eww-browse-url)

;; Optional: named saved searches (elfeed-style filter strings)
(setq linkding-saved-searches
  '(("Unread"     . "+unread")
    ("Emacs"      . "+emacs")
    ("Read later" . "+unread -archived")))
```

## Usage

| Command | Description |
|---|---|
| `linkding-add-bookmark` | Save current EWW page or URL at point |
| `linkding-open-bookmark` | Open a bookmark via completing-read |
| `linkding-search` | Search with elfeed-style filter |
| `linkding-list` | Browse all bookmarks in a tabulated buffer |
| `linkding-saved-search` | Open a named saved search |
| `linkding-refresh` | Re-fetch bookmarks and tags from server |

### Filter Syntax

Filters use elfeed-compatible syntax:

| Token | Effect |
|---|---|
| `+emacs` | Include tag `emacs` |
| `-emacs` | Exclude tag `emacs` (client-side) |
| `+unread` | Unread bookmarks only |
| `+archived` | Archived bookmarks only |
| `word` | Full-text search |

### linkding-list keybindings

| Key | Action |
|---|---|
| `RET` | Open URL |
| `r` | Toggle read/unread |
| `A` | Toggle archived |
| `e` | Edit bookmark |
| `d` | Delete bookmark |
| `s` | Edit filter |
| `S` | Switch to saved search |
| `g` | Refresh |
| `q` | Quit |

## Embark Integration

If [Embark](https://github.com/oantolin/embark) is installed, `l` is registered as a URL action to save to Linkding.
```

- [ ] **Step 2: Write CHANGELOG.md**

Create `~/src/linkding.el/CHANGELOG.md`:

```markdown
# Changelog

## 0.1.0 (unreleased)

### Added
- `linkding-add-bookmark` — context-aware capture from EWW or URL at point
- `linkding-open-bookmark` — completing-read over cached bookmarks
- `linkding-search` — live search with elfeed-style filter syntax
- `linkding-list` — tabulated buffer with full CRUD actions
- `linkding-saved-search` — named saved searches
- `linkding-edit-bookmark` — edit title, tags, description, unread status
- `linkding-refresh` — manual cache refresh
- Embark integration for URL targets
```

- [ ] **Step 3: Commit**

```bash
cd ~/src/linkding.el
git add README.md CHANGELOG.md
git commit -m "docs: add README and CHANGELOG"
```

---

## Task 13: Wire Into .emacs.d

**Files:**
- Modify: `~/.emacs.d/config.org` — replace the prototype Linkding section with a `use-package` call

- [ ] **Step 1: Load the package during development by adding to load-path**

In `~/.emacs.d/config.org`, replace the entire existing `*** Linkding` section (a prototype with `sj-linkding-*` functions that lives around line 3659 — verify with `grep -n "^\*\*\* Linkding" config.org` before editing) with the block below. If no such section exists, add this under a suitable parent heading instead:

```org
*** Linkding
#+begin_src emacs-lisp :tangle "post-init.el"
  (use-package linkding
    :load-path "~/src/linkding.el"
    :commands (linkding-add-bookmark linkding-open-bookmark
               linkding-search linkding-list linkding-saved-search)
    :custom
    (linkding-open-fn #'eww-browse-url)
    (linkding-saved-searches
     '(("Unread"     . "+unread")
       ("Emacs"      . "+emacs")))
    :bind
    (:map eww-mode-map
          ("b" . linkding-add-bookmark)))
#+end_src
```

Set credentials outside of the tangled file (in `custom.el` or similar, not committed):

```elisp
(setq linkding-url   "https://your-linkding-instance.example.com")
(setq linkding-token "your-api-token-here")
```

- [ ] **Step 2: Verify the config tangles without error**

```bash
cd ~/.emacs.d
emacs --batch -l org --eval \
  '(org-babel-tangle-file "config.org" "post-init.el" "emacs-lisp")'
```

Expected: no errors.

- [ ] **Step 3: Commit the config change**

```bash
cd ~/.emacs.d
git add config.org
git commit -m "config: wire linkding.el package into Emacs config"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** All spec sections have corresponding tasks: config (Task 1), HTTP (Task 2), API wrappers (Task 3), cache (Task 4), filter (Task 5), capture (Task 6), quick search (Task 7), tabulated list (Task 8), keybindings/actions (Task 9), edit (Task 10), embark (Task 11), docs (Task 12), config wiring (Task 13).
- [x] **No placeholders:** All tasks contain full code.
- [x] **Type consistency:** `linkding--make-entry` uses `alist-get 'tag_names` (list of strings, matching API wrapper output). `linkding--bookmark-at-point` looks up from `linkding--list-bookmarks` (set in `linkding--list-refresh`). `linkding--candidates-from` defined in Task 7, used in Task 10 — correct.
- [x] **Forward references guarded:** `linkding--list-refresh` (defined in Task 8) is referenced in Tasks 4 and 6 — guarded by a `declare-function` in Task 4. `linkding-edit-bookmark` (defined in Task 10) is referenced in the Task 8 keymap — guarded by a `declare-function` in Task 8. Task 10's `linkding-edit-bookmark` calls `linkding--list-replace-row` / `linkding--update-cached-bookmark` (Task 9, earlier in load order — no forward ref needed). All such calls happen at runtime, after the whole file is loaded.
- [x] **Filter parser:** Multiple `+TAG` tokens correctly compose — first becomes the API `tag` param, the rest go through `linkding--apply-client-filters` as a client-side AND. `-TAG` tokens are exclude-filters. Return shape is `(API-PARAMS INCLUDE-TAGS EXCLUDE-TAGS)`.
- [x] **Keymap inheritance:** `linkding-list-mode-map` is the one auto-generated by `define-derived-mode`, so it inherits motion keys (`n`/`p` etc.) from `tabulated-list-mode-map` as the spec requires. Custom keys are layered on top with `define-key` after the mode definition.
- [x] **MELPA lint hygiene:** `eww-data` is declared with `(defvar eww-data)` at the top of the file to suppress free-variable warnings in `linkding--detect-url`.
