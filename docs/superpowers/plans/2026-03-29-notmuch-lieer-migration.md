# notmuch + lieer Email Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add notmuch + lieer for work Gmail (you@work.example) alongside the existing mu4e + Fastmail setup. Incremental — mu4e and notmuch coexist on the same `~/Maildir/`, fastmail is excluded from notmuch for now.

**Architecture:** lieer syncs work Gmail to `~/Maildir/acme/` via Gmail API. notmuch indexes only `acme/` (fastmail excluded via `new.ignore`). mu4e continues to handle Fastmail unchanged. msmtp sends work mail via email-oauth2-proxy (Gmail SMTP OAuth2). A launchd timer runs `gmi sync` every 3 minutes.

**Tech Stack:** notmuch 0.40 (brew), lieer 1.6 (uv/brew-python3.14 workaround), emailproxy (uv), msmtp, notmuch.el, consult-notmuch, ol-notmuch

> **Note on afew:** afew 3.0.1 is broken on Python 3.14 (`SafeConfigParser` removed, `pkg_resources` gone). Not used. Auto-tagging done via shell `post-new` hook.

---

## Directory Layout

```
~/Maildir/
  fastmail/          ← untouched, used by mu4e only
  acme/        ← NEW: lieer account dir for work Gmail
    .lieer.json      ← lieer state (created by gmi init)
    mail/            ← actual Maildir (created by lieer)
      cur/
      new/
      tmp/
  queue/             ← existing msmtp queue, untouched
  .notmuch/          ← notmuch DB (created by notmuch new)
    hooks/
      post-new       ← shell auto-tagging script
```

---

## Task 1: Install tools ✅ DONE

- [x] `brew install notmuch` → notmuch 0.40
- [x] lieer installed via uv + brew python3.14 system-site-packages (notmuch2 PyPI sdist is broken):
  ```bash
  uv venv --python /opt/homebrew/bin/python3.14 --system-site-packages ~/.local/share/uv/tools/lieer
  uv pip install lieer --no-deps --python ~/.local/share/uv/tools/lieer
  uv pip install google_auth_oauthlib google-api-python-client tqdm --python ~/.local/share/uv/tools/lieer
  ln -sf ~/.local/share/uv/tools/lieer/bin/gmi ~/.local/bin/gmi
  ```
- [x] `uv tool install emailproxy` → emailproxy 2025.10.4

---

## Task 2: Create acme Maildir directory

**Files:**
- Create: `~/Maildir/acme/` (lieer will populate it)

- [ ] **Step 1: Create the directory**

```bash
mkdir -p ~/Maildir/acme
```

- [ ] **Step 2: Verify**

```bash
ls ~/Maildir/
# fastmail  acme  queue
```

---

## Task 3: Configure notmuch

**Files:**
- Create: `~/.notmuch-config`
- Create: `~/Maildir/.notmuch/hooks/post-new`

- [ ] **Step 1: Write ~/.notmuch-config directly**

```bash
cat > ~/.notmuch-config << 'EOF'
[database]
path=/Users/srijan.c/Maildir

[user]
name=Srijan Choudhary
primary_email=you@work.example
other_email=you@fastmail.example;you@example.com

[new]
tags=new
ignore=fastmail;queue;.mbsyncstate;.uidvalidity;.sync.json

[search]
exclude_tags=deleted;spam;

[maildir]
synchronize_flags=true
EOF
```

The key line is `ignore=fastmail;queue` — notmuch skips those subdirs entirely. Only `acme/` gets indexed.

- [ ] **Step 2: Create hooks directory**

```bash
mkdir -p ~/Maildir/.notmuch/hooks
```

- [ ] **Step 3: Create post-new hook**

```bash
cat > ~/Maildir/.notmuch/hooks/post-new << 'EOF'
#!/bin/bash
# Auto-tag new mail. Only processes tag:new (staging tag set by notmuch new).

# --- Sent mail: no inbox, no unread ---
notmuch tag +sent -inbox -unread -- tag:new and path:acme/mail/\[Gmail\]/Sent\ Mail/**

# --- Everything else gets inbox + unread ---
notmuch tag +inbox +unread -- tag:new and not tag:sent and not tag:spam

# --- Remove staging tag ---
notmuch tag -new -- tag:new
EOF
chmod +x ~/Maildir/.notmuch/hooks/post-new
```

- [ ] **Step 4: Initial notmuch index (acme will be empty, that's fine)**

```bash
notmuch new
```

Expected output: `No new mail.` (acme/mail/ doesn't exist yet — lieer creates it in Task 4).

---

## Task 4: Set up lieer for work Gmail

**Files:**
- Create: `~/Maildir/acme/.lieer.json` (by `gmi init`)
- Needs: Google Cloud project with Gmail API + OAuth2 Desktop App credentials

- [ ] **Step 1: Create Google Cloud OAuth credentials**

1. Go to https://console.cloud.google.com/
2. Create project (e.g. "lieer-email") or reuse one
3. APIs & Services → Enable APIs → "Gmail API" → Enable
4. APIs & Services → Credentials → Create Credentials → OAuth client ID
   - Type: **Desktop app**, Name: lieer
5. Download JSON → save as `~/Maildir/acme/credentials.json`

- [ ] **Step 2: Initialize lieer**

```bash
cd ~/Maildir/acme
gmi init --credentials-file credentials.json you@work.example
```

Browser opens for OAuth. Sign in as you@work.example and grant access.

**If blocked by org ("Access blocked"):** The Google Workspace admin needs to allowlist the OAuth client ID. Either ask IT, or use internal/domain app: in Google Workspace Admin Console → Security → API Controls → Trust internal apps.

- [ ] **Step 3: Initial sync**

```bash
cd ~/Maildir/acme
gmi sync
```

First sync downloads all mail → `~/Maildir/acme/mail/`. May take several minutes.

- [ ] **Step 4: Index in notmuch**

```bash
notmuch new
notmuch count tag:inbox
# should be non-zero
notmuch count path:acme/**
# same number
```

---

## Task 5: Configure email-oauth2-proxy for work Gmail SMTP

**Files:**
- Create: `~/.config/emailproxy/emailproxy.config`
- Create: `~/Library/LaunchAgents/ai.proxy.emailproxy.plist`
- Modify: `~/.msmtprc`

emailproxy runs a local SMTP proxy on port 1025. msmtp sends to `localhost:1025` with dummy credentials; the proxy exchanges them for OAuth2 tokens transparently.

- [ ] **Step 1: Extract client_id and client_secret from credentials.json**

```bash
python3 -c "import json; d=json.load(open('$HOME/Maildir/acme/credentials.json')); \
  print('client_id:', d['installed']['client_id']); \
  print('client_secret:', d['installed']['client_secret'])"
```

- [ ] **Step 2: Create emailproxy config**

Create `~/.config/emailproxy/emailproxy.config` (substitute real values from step 1):

```ini
[SMTP-1025]
server_address = smtp.gmail.com
server_port = 465

[Account you@work.example]
permission_url = https://accounts.google.com/o/oauth2/auth
token_url = https://oauth2.googleapis.com/token
oauth2_scope = https://mail.google.com/
redirect_uri = http://localhost
client_id = PASTE_CLIENT_ID_HERE
client_secret = PASTE_CLIENT_SECRET_HERE
token_expiry = 0
```

- [ ] **Step 3: First run to authorize**

```bash
emailproxy --config ~/.config/emailproxy/emailproxy.config --no-gui
```

It prints an authorization URL. Open it in a browser, sign in as you@work.example, grant access. The proxy stores the token and exits the auth flow.

- [ ] **Step 4: Create launchd agent for emailproxy**

Create `~/Library/LaunchAgents/ai.proxy.emailproxy.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>ai.proxy.emailproxy</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Users/srijan.c/.local/bin/emailproxy</string>
    <string>--config</string>
    <string>/Users/srijan.c/.config/emailproxy/emailproxy.config</string>
    <string>--no-gui</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/emailproxy.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/emailproxy.err</string>
</dict>
</plist>
```

```bash
launchctl load ~/Library/LaunchAgents/ai.proxy.emailproxy.plist
```

- [ ] **Step 5: Add acme account to msmtp**

Append to `~/.msmtprc`:

```
account         acme
host            127.0.0.1
port            1025
from            you@work.example
user            you@work.example
auth            plain
password        password
tls             off
```

Note: `password password` is correct — emailproxy accepts any value here, auth is handled by OAuth2 at the proxy level.

- [ ] **Step 6: Test sending**

```bash
echo "test from acme" | msmtp --account=acme you@work.example
```

Check that the email arrives.

---

## Task 6: Set up launchd timer for lieer sync

**Files:**
- Create: `~/Library/LaunchAgents/email.lieer.acme.plist`

- [ ] **Step 1: Create plist**

Create `~/Library/LaunchAgents/email.lieer.acme.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>email.lieer.acme</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>cd /Users/srijan.c/Maildir/acme &amp;&amp; gmi sync &amp;&amp; notmuch new &amp;&amp; emacsclient --server-file /Users/srijan.c/.emacs.d/var/server/server -n -e '(when (featurep (quote notmuch)) (notmuch-refresh-all-buffers))' 2&gt;/dev/null; true</string>
  </array>
  <key>StartInterval</key>
  <integer>180</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/lieer-acme.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/lieer-acme.err</string>
</dict>
</plist>
```

- [ ] **Step 2: Load it**

```bash
launchctl load ~/Library/LaunchAgents/email.lieer.acme.plist
```

- [ ] **Step 3: Verify it fires**

```bash
launchctl list | grep lieer
# email.lieer.acme should appear with a PID
tail -f /tmp/lieer-acme.log
```

---

## Task 7: Add notmuch.el config to Emacs

**Files:**
- Modify: `~/.emacs.d/config.org` — enable the `** notmuch` section (currently `:disabled`)

The existing `** mu4e` block stays untouched. Both run side by side: `C-c m` opens mu4e (Fastmail), notmuch.el handles acme.

- [ ] **Step 1: Replace the skeleton notmuch block**

In `config.org`, find the `** notmuch` section (~line 3351) and replace its content with:

```elisp
(use-package notmuch
  :if (not my-phone-p)
  :bind (("C-c n" . notmuch))
  :config
  (setopt notmuch-search-oldest-first nil)

  (setopt notmuch-saved-searches
          '((:name "Inbox Work"  :query "tag:inbox"            :key "i" :sort-order newest-first)
            (:name "Unread"      :query "tag:unread"           :key "u" :sort-order newest-first)
            (:name "Sent"        :query "tag:sent"             :key "s" :sort-order newest-first)
            (:name "Flagged"     :query "tag:flagged"          :key "f" :sort-order newest-first)
            (:name "All mail"    :query "path:acme/**"   :key "a" :sort-order newest-first)))

  ;; FCC: copy sent mail to acme Sent (lieer will push it to Gmail on next sync)
  (setopt notmuch-fcc-dirs
          '(("you@work.example" . "acme/mail +sent")))

  ;; Send via msmtp (same mechanism as mu4e)
  (setopt message-send-mail-function 'message-send-mail-with-sendmail)
  (setopt sendmail-program "/opt/homebrew/bin/msmtp")
  (setopt message-sendmail-f-is-evil t)
  (setopt message-sendmail-extra-arguments '("--read-envelope-from"))

  ;; From address for new mail
  (setopt notmuch-identities '("Srijan Choudhary <you@work.example>"))
  (setopt notmuch-always-prompt-for-sender nil)

  ;; Prefer plain text, render HTML on demand
  (setopt notmuch-multipart/alternative-discouraged '("text/html" "text/richtext"))

  (setopt message-kill-buffer-on-exit t)
  (add-hook 'notmuch-show-hook #'visual-line-mode)
  (add-hook 'message-setup-hook #'visual-line-mode)

  ;; Manual sync keybinding in notmuch-hello
  (define-key notmuch-hello-mode-map "G"
    (lambda ()
      (interactive)
      (message "Syncing acme...")
      (set-process-sentinel
       (start-process "gmi-sync" "*gmi-sync*" "/bin/sh" "-c"
                      "cd ~/Maildir/acme && gmi sync && notmuch new")
       (lambda (proc _event)
         (when (= 0 (process-exit-status proc))
           (notmuch-refresh-all-buffers)
           (message "Sync done."))))))

  (setopt notmuch-tagging-keys
          '(("a" notmuch-archive-tags "Archive")
            ("u" ("+unread") "Mark unread")
            ("f" ("+flagged") "Flag")
            ("d" notmuch-deleted-tags "Delete")
            ("s" ("+spam" "-inbox") "Mark spam"))))

(use-package ol-notmuch
  :if (not my-phone-p)
  :after (notmuch org))

(use-package consult-notmuch
  :if (not my-phone-p)
  :after notmuch
  :bind (:map notmuch-hello-mode-map
              ("/" . consult-notmuch-tree)))
```

Note: binding is `C-c n` (not `C-c m`) to avoid conflicting with mu4e.

- [ ] **Step 2: Add org keybindings for notmuch**

Add alongside the existing `use-package org :after mu4e` block:

```elisp
(use-package org
  :ensure nil
  :after notmuch
  :bind ((:map notmuch-show-mode-map
               ("C-c i" . org-capture-mail))
         (:map notmuch-search-mode-map
               ("C-c i" . org-capture-mail))))
```

`org-capture-mail` calls `org-store-link` then captures with `"@"`. With `ol-notmuch` loaded, `org-store-link` creates a `notmuch:` link instead of a `mu4e:` link — so the same capture function works for both.

- [ ] **Step 3: Tangle and reload**

```
M-x org-babel-tangle
M-x load-file RET ~/.emacs.d/post-init.el
```

Or restart Emacs.

- [ ] **Step 4: Verify**

- `C-c n` opens notmuch-hello with saved searches and counts
- `G` in notmuch-hello triggers a sync and updates buffers
- Reply to a work email → sends via acme msmtp account
- `C-c i` from notmuch-show captures to org-gtd with a `notmuch:` link

- [ ] **Step 5: Commit**

```bash
cd ~/.emacs.d
git add config.org
git commit -m "feat: add notmuch.el for acme work Gmail via lieer"
```

---

## Verification Checklist

- [ ] `notmuch count tag:inbox` returns work Gmail inbox count
- [ ] `notmuch count path:fastmail/**` returns 0 (fastmail excluded)
- [ ] `C-c n` opens notmuch-hello
- [ ] `G` in notmuch-hello syncs acme and refreshes
- [ ] Send a reply from notmuch — arrives in Gmail Sent
- [ ] `C-c i` from notmuch-show captures to org with notmuch: link
- [ ] Clicking the notmuch: link in org reopens the email
- [ ] launchd timer fires every 3 min: `launchctl list | grep lieer`

---

## Future: Adding Fastmail and personal Gmail to notmuch

When ready to consolidate everything into notmuch:

1. Remove `fastmail` from `new.ignore` in `~/.notmuch-config`
2. Run `notmuch new` — indexes all existing Fastmail mail (one-time, slow)
3. Update `post-new` hook to add Fastmail folder tags (Memos, @Action Support, etc.)
4. Disable mu4e, add Fastmail identity to `notmuch-identities` and `notmuch-fcc-dirs`
5. Add personal Gmail: `mkdir ~/Maildir/gmail-personal && cd ~/Maildir/gmail-personal && gmi init ...`
6. Add a second launchd timer for gmail-personal

---

## Notes

**lieer + notmuch tag sync:** Gmail labels ↔ notmuch tags are synced bidirectionally by lieer. Removing `inbox` tag in notmuch = archiving in Gmail on next `gmi sync`. Adding `spam` = marking spam in Gmail. The `archive` tag name is reserved by lieer — do not use it.

**FCC and sent mail:** `notmuch-fcc-dirs` writes a local copy of sent mail to `acme/mail/`. On next `gmi sync`, lieer pushes it to Gmail Sent, so it appears in Gmail's Sent folder too.

**mu and notmuch coexistence:** Both tools index the same `~/Maildir/` directory with completely separate databases (`~/Maildir/.mu/` and `~/Maildir/.notmuch/`). They do not interfere. Running `mu index` or `notmuch new` only affects the respective tool's DB.

**Credentials security:** Keep `~/Maildir/acme/credentials.json` out of version control. The `.lieer.json` state file (which stores OAuth tokens) should also not be committed.
