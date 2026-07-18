# Emacs configuration

A literate GNU Emacs configuration built on top of
[minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d), using
[Elpaca](https://github.com/progfolio/elpaca) for package management. Everything
lives in a single org file, [`config.org`](config.org), which *tangles* into the
Emacs Lisp files that are actually loaded.

Runs on macOS, Linux, and Android. Personal identifiers (emails, hostnames,
employer, sync paths) are kept out of this public repo by storing them
**age-encrypted** in `private.json.age`; the config falls back to harmless
placeholders when the key isn't present, so it loads fine on any machine.

## How it works

`init.el` and `early-init.el` are symlinks into the `minimal-emacs.d` **git
submodule**. minimal-emacs.d then loads, in order, these four user files if they
exist:

```
pre-early-init.el  →  post-early-init.el  →  pre-init.el  →  post-init.el
```

I don't edit those `.el` files directly. They are **generated** ("tangled") from
`config.org`. The mapping:

| Tangled file                              | Purpose                                       |
|-------------------------------------------|-----------------------------------------------|
| `pre-early-init.el`, `post-early-init.el` | earliest setup (UI features, `$PATH`)         |
| `pre-init.el`                             | Elpaca bootstrap                              |
| `post-init.el`                            | the bulk of the config                        |
| `srijan-lisp/*.el`                        | custom libraries (e.g. KOReader importer)     |
| `<sync-dir>/docs/notes/denote_config.el`  | Denote/notes config, kept in the notes folder |

**The tangled `.el` files are gitignored.** A fresh clone contains `config.org`
but none of the generated output — you tangle it yourself after cloning (see
below). This keeps the repo to a single source of truth.

## Installation (macOS / Linux)

```sh
# 1. Clone WITH the submodule (init.el is a symlink into it)
git clone --recursive git@github.com:srijan/emacs-v4.git ~/.emacs.d
# (already cloned without --recursive?)
git -C ~/.emacs.d submodule update --init

# 2. Tangle config.org → the .el files, headless
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "~/.emacs.d/config.org"))'

# 3. Start Emacs. Elpaca will bootstrap itself and install every package
#    on this first run — give it a minute.
emacs
```

You can skip step 2 and instead just start Emacs, open `config.org`, and press
`C-c C-v C-t` (`org-babel-tangle`) — but Emacs needs the tangled files to load
the config in the first place, so the headless tangle is the cleaner bootstrap.

## Editing the config

1. Edit [`config.org`](config.org).
2. Re-tangle with `C-c C-v C-t` (or evaluate the `(org-babel-tangle)` block near
   the top of the file).
3. Restart Emacs, or evaluate the changed block(s).

## Secrets (`private.json.age`)

Personal values live encrypted in `private.json.age` and are injected at startup
by `sj/load-private` in `config.org`. The variables it sets (with public
placeholder defaults in `config.org`):

`sj/mail-personal`, `sj/mail-fastmail`, `sj/mail-work`, `sj/mindwtr-url`,
`sj/miniflux-host`, `sj/irc-server`, `sj/jira-base-url`, `sj/employer`,
`sj/sync-dir`, `sj/koreader-scp-source`, `sj/koreader-scp-port`, `sj/hass-host`.

At startup the config decrypts `private.json.age` with the [age](https://github.com/FiloSottile/age)
identity at `~/.config/age/keys.txt` and overrides the placeholders. **If `age`
or the key is missing, startup still succeeds** with the placeholder values —
mail/jira/etc. just won't be wired to real endpoints.

### Setting it up on a new machine

```sh
brew install age                        # or: pkg install age  (Termux)
mkdir -p ~/.config/age
# copy your existing keys.txt here (back it up — it's the ONLY thing that can
# decrypt private.json.age):
cp /path/to/backup/keys.txt ~/.config/age/keys.txt
```

### Adding or changing a secret

Decrypt, edit the JSON, re-encrypt to your own public recipient (the
`age1...` line in `keys.txt`):

```sh
age -d -i ~/.config/age/keys.txt private.json.age > /tmp/private.json
# ...edit /tmp/private.json...
age -r <your-age1-public-recipient> -o private.json.age /tmp/private.json
rm /tmp/private.json                    # never commit the plaintext
```

`private.json` / `private.dec.json` are gitignored as a safety net, but delete
plaintext when you're done regardless.

## Android

`config.org` detects Android via `ANDROID_ROOT` (`my-phone-p`), set on both
**Termux Emacs** and the **native Android port**
([android-ports-for-gnu-emacs](https://sourceforge.net/projects/android-ports-for-gnu-emacs/)),
and enables a touch-friendly setup: top toolbar, always-on touch-screen keyboard
(`touch-screen-display-keyboard`), momentum scrolling, `touchpad-scroll-mode`,
and an enlarged `tool-bar-button-margin` to compensate for Android's display
density. A few things need care.

### First-time setup

1. **Install Termux first, then a Termux-compatible Emacs** (native port). The
   port only sees Termux's binaries (git, age, …) if it's the **Termux variant**
   — an Emacs signed with Termux's key and sharing its user ID (the port
   distributes such a build); a stock build can't run Termux binaries. Install
   Termux before Emacs. Termux and these builds require Android 7.0+.
2. **Clone on app-private / ext4 storage, not shared storage.** `init.el` /
   `early-init.el` are symlinks, and symlinks don't survive on `/sdcard`
   (exFAT/FAT). Clone into Termux's `$HOME`, or the native port's home
   (`/data/data/org.gnu.emacs/files`) — not `/sdcard/...`.
3. **Pull in the submodule:** `git submodule update --init` (or clone with
   `--recursive`). Without it, the `init.el` symlink dangles and no config
   loads.
4. **Tangle on-device** (the `.el` files are gitignored, so a fresh clone has
   none):
   ```sh
   emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "config.org"))'
   ```
   then restart Emacs. Prefer a Termux shell for this — running a command-line
   Emacs from inside the GUI Emacs is unreliable on some Android versions.

### External tools

Package installation and several features shell out to native binaries, which on
Android means **Termux** with them installed and on `$PATH`
(`post-early-init.el` already prepends `/data/data/com.termux/files/usr/bin`):

- **`git` is required** — Elpaca and Magit can't do anything without it.
- Optional, per feature: `notmuch`, `gmi`, `msmtp` (mail), `vdirsyncer`
  (calendar), `pandoc`, `gpg`, `scp` (KOReader sync).

Native-compilation is not available on the Android port, so packages
byte-compile only — the first Elpaca run is slower but works. Confirm on-device
with `(native-comp-available-p)`.

### Shared storage & sync

If your notes/org live under `sj/sync-dir` outside the app-private home, mind
Android's two separate storage restrictions (native port):

- **`/sdcard` (external storage):** grant the **Files and Media** permission,
  and on **Android 11+** also disable Scoped Storage for Emacs at
  *System → Apps → Special App Access → All files access → Emacs* — otherwise
  Emacs can't `open`/`readdir` there even with the permission.
- **Document providers (SAF)** show up under `/content/storage/...` after you run
  `M-x android-request-directory-access`. They can be slow (may hit the network),
  and Emacs can't create symlinks/hardlinks inside them.
- **Subprocesses can't touch `/assets` or `/content` paths at all** — anything
  that shells out (git, age, scp, notmuch — including `age` decrypting
  `private.json.age`) only sees the real filesystem. Simplest is to keep the
  repo, the age key, and anything tools operate on under the app-private home
  (`~`).

### Secrets on Android

`age` is usually absent, so the `sj/*` values stay at their placeholders and
mail/jira/etc. are inert. To enable them, `pkg install age` and copy
`~/.config/age/keys.txt` onto the device — weighing that this key decrypts
everything in `private.json.age`. (`age` runs as a subprocess, so the key and
`private.json.age` must be on a real path, not `/content` — see above.)

### Fonts

Install custom fonts by dropping **TrueType (`.ttf`)** files into the `fonts`
directory inside the Emacs home directory — i.e. `~/fonts`
(`/data/data/org.gnu.emacs/files/fonts` on the native port) — then **restart
Emacs** (fonts are enumerated only at startup). Emacs also scans `/system/fonts`
and `/product/fonts`.

- The Android `sfnt-android` backend supports TrueType (including variable / GX
  fonts) but **not OpenType (`.otf`) or color fonts** — so use the `.ttf` build
  of `Aporetic Sans Mono`, not the OTF. This is the usual reason the phone font
  doesn't show.
- Until it's installed, the phone block falls back to a default face (the font
  call is guarded so a missing family can't abort init).
- `all-the-icons` glyphs need their own fonts: `M-x all-the-icons-install-fonts`
  (its `.ttf`s land in `~/fonts` too).
- Avoid the GUI "Set Default Font" menu — it lists fonts that often aren't
  really present; `set-frame-font` / Customize (what the config uses) is reliable.

### Touch tips

- **Rapid volume-down presses = `C-g`** — a quit key when no keyboard is up.
- The config uses `tool-bar-position` `top`; set it to `bottom` to keep buttons
  nearer your thumbs, and enable `modifier-bar-mode` for a Ctrl/Meta button row.
- If an on-screen keyboard fights Emacs while typing, toggle
  `text-conversion-style` (per-buffer) or `overriding-text-conversion-style`
  (global).

The config's unconditional `(server-start)` matters on Android: the port's
"open file", `org-protocol`, and `mailto:` handoffs all go through an
`emacsclient` wrapper that only works when the Emacs server is already running.

### If Emacs won't start (recovery)

Android has no command line, so a broken init (e.g. a bad tangle) can lock you
out — and other apps can't reach Emacs's home directory. Recovery paths:

- Start with `--quick` or `--debug-init` from the **app-info preferences** screen
  (Android 7+: the Emacs entry in system Settings; older: a separate "Emacs
  options" desktop icon).
- Emacs also exports its home directory as a **documents provider**, so a file
  manager can open `~/post-init.el` / `config.org` to fix or delete the offending
  file.
- A corrupted **dump file** (built on first run to speed startup) can be cleared
  from that same preferences screen.

### Background sync

Android 12+ kills background processes that burn CPU (the "phantom process"
killer), which can sever long background syncs (gmi, mbsync, notmuch). Options:
run big syncs in the foreground, keep an Emacs frame active, or disable the
killer over adb:

```sh
adb shell "settings put global settings_enable_monitor_phantom_procs false"
```

Emacs shows a permanent notification to lower its chance of being killed; see
[dontkillmyapp.com](https://dontkillmyapp.com/) for vendor-specific quirks.

## Layout

```
config.org            ← single source of truth (edit this)
init.el, early-init.el← symlinks into the minimal-emacs.d submodule
minimal-emacs.d/      ← submodule (baseline early-init/init)
pre-/post- *.el       ← tangled from config.org (gitignored)
srijan-lisp/          ← tangled custom libraries (gitignored)
private.json.age      ← age-encrypted personal values (committed)
scripts/              ← helper scripts
```
