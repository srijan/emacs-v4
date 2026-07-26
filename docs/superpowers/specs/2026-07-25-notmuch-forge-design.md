# Open GitHub PRs from notmuch in Magit Forge

**Date:** 2026-07-25
**Status:** Approved, ready for planning

## Goal

From a GitHub notification email in notmuch, jump straight to the Forge topic
buffer for that pull request, issue or discussion — without full-pulling large
repositories, without mutating any local clone, and without changing the branch
in any existing checkout.

Once in the topic buffer the user wants to: read, comment, approve, request
changes, optionally merge, and optionally check the PR out for investigation.

## Background: how Forge works

Verified against Forge 0.6.7 (`var/elpaca/sources/forge`).

Forge is a **local mirror**, not a live API client. `var/forge-database.sqlite`
holds `repository`, `pullreq`, `issue`, `discussion`, `*_post`, `label`,
`assignee` and `notification` tables. All Forge buffers render from SQLite;
network access happens only on an explicit pull. Objects are EIEIO classes
persisted through closql; the API layer is ghub (GraphQL for GitHub),
authenticating from `~/.authinfo` with `machine api.github.com login <user>^forge`.

Repositories are identified by a `(webhost owner name)` triple derived from a
remote URL by `forge--split-forge-url` (forge-core.el:251) against `forge-alist`.
Each row carries a `condition`:

| condition  | meaning                                                          |
|------------|------------------------------------------------------------------|
| `:tracked` | fully adopted — `forge-pull` refreshes it, appears in topic lists |
| `:known`   | a stub row, created as a side effect of resolving a link          |
| `:stub`    | in-memory only, never written                                     |

Repository discovery is **directory-driven**: `forge-get-repository`
(forge-repo.el:144) tries `forge-repository-at-point`, then
`forge-buffer-repository`, then the git remote of `default-directory`. None of
these resolve inside a notmuch buffer, so the repository must be passed
explicitly.

Topic buffers do **not** need a clone: `forge-topic-setup-buffer`
(forge-topic.el:1324) sets `:directory (or (forge-get-worktree repo) "/")`.

### Current state of this user's database

- `greyorange/butler_server` — the only `:tracked` repo, non-selective.
- ~dozens of `:known` stubs picked up incidentally from following links.
- `butler_server`'s `worktree` slot currently points at
  `.../butler_server-worktrees/butler_server/feature-GM-277585-pcr3-test-refactor/`
  — an arbitrary feature branch, because `forge-get-worktree` (forge-repo.el:341)
  does not search the filesystem; it records whatever `default-directory`
  happened to be in last and reuses it until it stops validating.

### What would break without this work

1. **Untracked repo → hard error.** `forge-visit-topic-from-url`
   (forge-commands.el:556) demands `:tracked`, so it fails on every repo except
   `butler_server`.
2. **Un-pulled topic → crash.** `forge-get-topic repo number` returns nil for a
   PR not in the DB, and `forge-topic-setup-buffer` then fails on `(oref repo slug)`.
3. **Accidental full pull.** A non-selective `forge-add-repository` on a
   `butler_server`-scale repo paginates tens of thousands of topics.
4. **Everything is async.** `forge-add-repository` and `forge--pull-topic`
   complete in ghub callbacks, so "add, then pull, then visit" cannot be written
   as straight-line code.

### Capability matrix

| Action           | Command                             | Needs a local clone?   |
|------------------|-------------------------------------|------------------------|
| Read PR/comments | `forge-topic-setup-buffer`          | No                     |
| Comment          | `forge-create-post` (`/r`)          | No — drafts fall back to `forge-post-fallback-directory` |
| Approve          | `forge-approve-pullreq` (`/A`)      | No — GraphQL mutation  |
| Request changes  | `forge-request-changes` (`/R`)      | No                     |
| Merge            | `forge-merge`                       | Yes, **incidentally** — see below |
| Checkout         | `forge-checkout-this-pullreq`       | Yes                    |

**Merge does not actually require a clone.** `forge--merge-pullreq`
(forge-github.el:1275) builds a `mergePullRequest` mutation from
`pullRequestId` and `(and hash (expectedHeadOid hash))` — the hash is optional,
and nil simply omits the field. `forge-merge` (forge-commands.el:1110) sources
that OID via `magit-commit-oid` on `(oref pullreq head-ref)`, a branch name that
only resolves in a clone. Forge already mirrors the value it is shelling out
for: `pullreq.head_rev`, populated from GitHub's `headRefOid`
(forge-github.el:632). Using `head-rev` is also *more* correct — `head-ref` for
a fork PR is the branch name on the fork, and resolving that name locally can
silently hit an unrelated local branch of the same name.

**Known limitation to set expectations:** Forge 0.6.7 has no line-level diff
review. `/A` and `/R` submit a single review body; per-line comments are not
supported.

## Design

### Layer 1 — `my/forge-*`, mail-agnostic

Added to the existing `use-package forge :config` block in the Git section of
`config.org`.

| Function                                    | Purpose                                    |
|---------------------------------------------|--------------------------------------------|
| `my/forge-visit-topic (host owner name number)` | The whole track → pull → visit chain    |
| `my/forge-find-clone (owner name)`          | Locate the main clone, or nil              |
| `my/forge-await (pred fn tries)`            | Bounded poll for async ghub callbacks      |
| `my/forge-merge`                            | Merge without a clone, via DB `head-rev`   |

### Layer 2 — `my/notmuch-forge-*`

A new block in the notmuch section, guarded `(not my-phone-p)` to match the
surrounding notmuch blocks.

| Function                        | Purpose                                        |
|---------------------------------|------------------------------------------------|
| `my/notmuch-github-topic-ref`   | Buffer → `(host owner name number)` or nil     |
| `my/notmuch-visit-forge-topic`  | Interactive command, bound `C-c f`             |

Rationale for splitting: the Forge-wrangling half is the hard part, and keeping
it free of mail concerns makes it testable from `M-:` and reusable from other
sources later. A single combined command is fewer lines but bakes notmuch into
logic that is not about mail.

### Extracting the reference from mail

Every message in a GitHub notification thread carries the coordinates in its
Message-ID. Confirmed against the real mail store:

```
srijan-infra/fleet-infra/pull/290@github.com
greyorange/butler_server/pull/21121/review/4761521005@github.com
greyorange/butler_server/pull/21121/before/d5164870.../after/358f5d51...@github.com
```

One regexp covers all forms:

```
\`\([^/]+\)/\([^/]+\)/\(pull\|issues\|discussions\)/\([0-9]+\)\(/.*\)?@\(.+\)\'
```

Per-mode message-id sources:

- `notmuch-show-mode` — `notmuch-show-get-message-id` with `bare` = t.
- `notmuch-tree-mode` — `:id` from `notmuch-tree-get-message-properties`.
- `notmuch-search-mode` — the result plist has no message-id, only `:thread`.
  Use `(notmuch-call-notmuch-sexp "search" "--format=sexp" "--output=messages" thread)`,
  which returns a bare list of ids, and scan for the first that matches.
  `notmuch-call-notmuch-sexp` does **not** add `--format=sexp` itself; the caller
  must pass it.

No raw message files are read — unlike `my/notmuch-message-account`, which has
to scrape the maildir path because notmuch's JSON omits `Delivered-To`,
everything needed here is in notmuch's own output.

The topic *type* from the msgid is deliberately ignored; `forge-get-topic`
dispatches on the number across discussion/issue/pullreq, which is what Forge
itself does.

### The track → pull → visit chain

```
1. repo := forge-get-repository "https://HOST/OWNER/NAME" nil :tracked?
2. if nil:
     repo := (... nil :valid?)          ; API check; nil => gone or no access
     y-or-n-p "Track OWNER/NAME selectively?"
     forge-add-repository repo :selective
     await (eq (oref repo condition) :tracked)
3. oset repo worktree (my/forge-find-clone owner name)   ; may be nil
4. topic := forge-get-topic repo number
   if nil: forge--pull-topic repo number
           await (forge-get-topic repo number)
5. forge-topic-setup-buffer topic
```

**Why `:selective`.** A normal add pulls every topic. `:selective` runs
`forge--github-sparse-repository-query` (labels, assignees, milestones — no
topics), marks the repo `:tracked`, and leaves individual topics to
`forge--pull-topic`. It also skips the `remote.origin.fetch` refspec mutation
and the git fetch a normal add performs (forge-commands.el:1344-1353), so it
never writes to the clone.

**Why polling.** Both `forge-add-repository` and `forge--pull-topic` complete in
ghub callbacks, and for `selective-p` repos `forge--pull` deliberately drops the
callback (forge-github.el:238), so there is no hook to chain from.
`my/forge-await` is a `run-with-timer` loop at 0.3s with a ~20s cap. It uses
`apply-partially` rather than lambda closures, per the config.org
lexical-binding constraint. Not elegant, but robust to Forge internals changing
in a way that advising `forge-refresh-buffer` would not be.

**Clone discovery.** `my/forge-find-clone` walks `my/forge-clone-roots`
(defaulting to `~/workspace` and `~/workspace/srijan`), looks for `<root>/<name>`,
and confirms via `git remote get-url` plus `forge--split-forge-url` that it is
really `owner/name`. Paths containing `-worktrees` are excluded so the main
clone always wins. Returns nil when there is no clone, in which case the topic
buffer's directory is `/` and read/comment/approve still work.

Writing the `worktree` slot is a deliberate improvement over the status quo: the
slot is persisted (closql writes through on `oset`), and pinning it to the main
clone replaces today's arbitrary drift with a deterministic value.

### Checkout

`forge-checkout-this-pullreq` (`/c`) switches the current clone's branch, which
is the behaviour to avoid. Set
`forge-checkout-worktree-read-directory-function` to seed the prompt with
`~/workspace/<name>-worktrees/<head-ref>` instead of Forge's default of "parent
of `default-directory`". The user still gets a `read-directory-name` prompt and
can place it anywhere.

The two existing conventions in this workspace (`<repo>-worktrees/<branch>` and
`<repo>-worktrees/<repo>/<branch>`) are not disambiguated; the prompt is
pre-filled with the flatter form and edited by hand.

This changes the prompt for all `forge-checkout-worktree` calls, not only
mail-initiated ones. Accepted.

### Merge

`my/forge-merge` calls `forge--merge-pullreq` with `(oref pullreq head-rev)`
instead of `magit-commit-oid`. It runs `forge--pull-topic` and awaits it first,
so `expectedHeadOid` is fresh rather than as-of-last-pull. Added to
`forge-topic-menu` via `transient-append-suffix`.

Cleanly separable: cutting this piece does not affect the visit path.

## Error handling

All failures are `user-error` leaving no partial state:

- Not a GitHub notification, or no matching id in the thread.
- Repository does not exist, or the token has no access.
- User declines tracking.
- Poll times out — message advises retrying, since the pull has usually landed.
- Topic still absent after pull (deleted, or private and invisible to the token).

## Verification

No test framework in this repo; verification is manual against the real mail
store and database.

1. A `butler_server` PR from `notmuch-show-mode` — already `:tracked` and likely
   already in the DB; should open instantly.
2. A `butler_server` PR whose number is absent from the `pullreq` table —
   exercises pull-and-wait.
3. A `srijan-infra/fleet-infra` PR — currently `:known`; exercises the full
   prompt → sparse add → pull → visit path. `~/workspace/srijan/fleet-infra`
   exists, so it also exercises clone discovery.
4. All three from `notmuch-search-mode` — exercises thread → message-ids lookup.
5. A non-GitHub message — clean `user-error`.
6. After (3), inspect the DB: `condition` is `:tracked`, `selective_p` non-nil,
   and the `pullreq` table gained exactly one row for that repo, not thousands.

## Out of scope

- Line-level diff review comments (unsupported by Forge 0.6.7).
- Auto-checkout on visit.
- Reconciling the two worktree naming conventions.
- Any source other than notmuch (Slack, browser handoff) — the Layer 1 split
  leaves the door open, but nothing is built for it.
