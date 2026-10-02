# Agent notes for this Emacs config

Literate config: `config.org` is the only source. `README.md` covers install, secrets (`private.json.age`), and Android; read it before touching startup, secrets, or phone-only code.

## Editing

- Edit `config.org`, never the tangled `.el` files (`pre-early-init.el`, `post-early-init.el`, `pre-init.el`, `post-init.el`, `srijan-lisp/android-support.el`, `srijan-lisp/koreader-json-to-org.el`). They are gitignored and overwritten on tangle. Each block's `:tangle` header names its target; nearly everything goes to `post-init.el`.
- Retired sections (Evil, mu4e, EAF, old org-gtd versions, Tabspaces, compile-angel) live in `config-old.org`, kept for reference and never tangled; `config.org` is the only source for the `.el` files. A heading marked `COMMENT` does not tangle either, and two such subtrees remain in `config.org`, so grep hits under one are dead config. The live outline is `grep -n '^\*\{1,2\} ' config.org` minus the `COMMENT` entries. Evil is off.
- `use-package-always-defer` is `t`. A block whose `:config` has side effects at startup (registering a browse-url handler, hooks, advice) needs `:demand t`, or the side effects wait for the first manual load of that package. Adding `:bind`/`:hook` to a block that already had `:demand t` keeps it demanded; dropping `:demand t` silently defers it.
- Say it with use-package keywords where one exists, not with code in `:config`: `:bind` (including `:prefix-map`/`:prefix` for a new prefix keymap, and `:map` for mode or project maps), `:bind-keymap`, `:hook`, `:mode`, `:commands`, `:custom`, `:after`. Keep in `:config` only what has no keyword: defuns, advice, `add-to-list`, and `setopt`s whose value calls the package's own functions. In one `:bind` list, `bind-keys` carries a group's `:map` into the groups after it, so put a global `:prefix-map` group before any `:map` group.
- Load packages on an event, not at startup. Prefer, in order: `:bind`/`:bind-keymap` (first key press), `:hook`/`:mode` (first matching buffer), `:commands` (first `M-x`), `:after` another package, or a lazy entry point such as a lambda the calling package evaluates when needed (the "Tools" section under "AI Assistants" loads `mcp-server-lib` from the init function its stdio script calls). `:commands` autoloads each command from the package's main file, so it breaks for commands defined in a file that main file never loads (`mcp-server-lib-start` is in `mcp-server-lib-commands.el`); `require` that file from the entry point instead. Use `:demand t` only when the package must act before any such event; `monet` was demanded just to enable a minor mode that only bound `C-c C-m`, and `:bind-keymap` replaced both.
- Naming: new code uses `sj-`; `sj/` is the secrets layer (`sj/load-private`, `sj/sync`, the `sj/…` placeholder variables); `my/` and `my-` are older and still live. Prefer `setopt` for user options.
- Personal identifiers (emails, hosts, employer, sync paths) never go into `config.org`. Use the `sj/...` placeholder variables set from `private.json.age` in "Private variables (age)".
- Machine-specific code is guarded by `my-phone-p` (Android) or `system-type`; keep the config loadable on all three platforms.
- To skip a whole package on Android, put `:install-if (not my-phone-p)` in its `use-package` block — a custom keyword (section "The :install-if use-package keyword") that, unlike the built-in `:if`/`:when`/`:unless`, also stops elpaca cloning and building it. Use `(when (not my-phone-p) ...)` only when the guard covers more than `use-package` forms.
- URL routing: `sj-browse-url-set-handler` / `sj-browse-url-set-handler-rx` (section "Social and Browser") is the single dispatcher that sends reddit, HN, mastodon, and Jira links to in-Emacs viewers. New link handlers register there, not by overriding `browse-url-browser-function`.
- `srijan-lisp/` is gitignored. Two files tangle from `config.org`; the rest (`gkeep-to-org.el`, `slack-inbox.el`, `slack-saved-to-org.el`, `materialized-theme.el`) are hand-written and have no versioned copy in this repo, so edits there do not show in `git diff`.

## Tangling and verifying

There is no test suite or lint step. Verification is against the running Emacs.

```sh
# server-use-tcp is on for macOS, so there is no default socket; EMACS_SERVER_FILE
# is exported by the fish and zsh configs.  If emacsclient says "can't find socket":
emacsclient --server-file ~/.emacs.d/var/server/server --eval '(...)'

# Tangle headlessly (from README); or in Emacs: C-c C-v C-t, or M-x sj-dashboard-tangle
emacs -Q --batch --eval '(progn (require (quote org)) (org-babel-tangle-file "~/.emacs.d/config.org"))'
```

- Check a changed block before tangling: extract the `#+begin_src`…`#+end_src` body to a temp file and run `check-parens` and a `read` loop on it through emacsclient.
- Evaluate changed forms live with lexical binding (`load` a file with a `lexical-binding: t` cookie, or `(eval form t)`). Org-babel's `C-c C-c` evaluates dynamically, so closures behave differently there than in the tangled files, which all carry `lexical-binding: t`.
- Package sources live in `var/elpaca/sources/<repo>/`; read them there when a package's behaviour matters (keymaps, hooks, buffer names). Builds are in `var/elpaca/builds/`.
- If `emacsclient` fails, stop and say so; do not fall back to `emacs -Q --batch` to load packages. Under an agent sandbox, batch Emacs mis-resolves the elpaca load-path and cannot read some directories (`~/Applications`), so its failures say nothing about the real config.
- Write scratch files to `$TMPDIR`, not `/tmp` or `var/`.
- Never read or decrypt secrets (`private.json.age`, `~/.authinfo`, session tokens) to make something work. Packages load their own credentials through the `sj/` layer; if a credential seems missing, ask.
- Do not call `backtrace-to-string` in hot paths (hooks, advice on frequent functions); it hangs Emacs.

## Git

- `config.org` usually carries unrelated uncommitted hunks. Stage your hunks by content (`git add -p`), never the whole file, and do not commit or push unless asked.
- Commit subjects are imperative and lowercase, optionally scoped: `fix(elfeed): …`, `add helpful for …`, `chore(minimal-emacs.d): …`.
- `init.el` and `early-init.el` are symlinks into the `minimal-emacs.d` submodule; changes to them belong upstream, not here.
- Design specs and implementation plans live in `docs/superpowers/specs/` and `docs/superpowers/plans/` as `YYYY-MM-DD-<slug>.md`.
