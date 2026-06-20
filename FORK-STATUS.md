# gastown-mission-district Fork Status

**Last updated:** June 20, 2026
**Fork:** `mindfu23/gastown-mission-district` (`origin`)
**Upstream:** `steveyegge/gastown` (`upstream` remote) — synced to **v1.2.1-130 (`51183512`)**
**Contribution fork:** `mindfu23/gastown` (`proper-fork` remote, present in the sibling `../gastown` checkout)

---

## Repos, remotes & pushing (read before you push)

There are **two local checkouts** of this fork, with different roles:

| Local dir | `origin` | other remotes | Role |
|---|---|---|---|
| `gastown-mission-district/` (this one) | `mindfu23/gastown-mission-district` | `upstream` | Personal fork: upstream + the kept files below |
| `../gastown/` (sibling) | `steveyegge/gastown` (open source — **read-only**, you can't push to it) | `proper-fork` = `mindfu23/gastown`, `upstream` | PR staging: pull from open source, push PR branches to `proper-fork` |

**Sibling `origin` points at open source (set 2026-06-20).** The sibling originally
shared `origin` with the personal fork, which made `git push origin main` there a
footgun (it would overwrite the personal fork with bare upstream). Fixed *structurally*
by repointing the sibling's `origin` to `steveyegge/gastown`:
- `git pull` / `git pull origin main` → pulls from **open source**.
- `git push origin …` → **denied by GitHub** (you don't own `steveyegge/gastown`) — remote-enforced read-only, no local hooks needed.
- PRs still go via `git push proper-fork <branch>`.
- (`origin` and `upstream` now point at the same open-source repo — harmless redundancy.)

The personal fork is pushed **only from this checkout**: `git push origin main --force-with-lease`.

Nothing has been pushed yet (as of the 2026-06-20 rebuild); GitHub still holds the old pre-rebuild state until you push from here.

### code-wiki visibility

This repo is indexed by the local **code-wiki** app, via two paths:
- **MCP tools** (`get_file`, `search_repos`) read the **local filesystem live** — changes here (e.g. this file) are visible to agents immediately, no push needed. `list_repos` uses a **cached index** that lags until `sync_repos` is run.
- **Web/wiki UI** uses **GitHub as the source of truth** (daily GitHub Actions rebuild). New/edited markdown surfaces there only **after you push** to GitHub, then on the next index build. Root-level `.md` like this file is indexed as a project doc.

---

## What happened on 2026-06-20 (clean rebuild)

The fork had drifted **2,403 commits behind** upstream (last real sync: Feb 28, 2026).
In that window upstream natively implemented **both** headline features this fork
originally added, so the fork was rebuilt cleanly on top of current `upstream/main`
rather than rebased through 2,403 commits of conflicts.

- Old `main` (with the multi-model scripts, token tracker, and WeirdChess imagen
  commits) is preserved at:
  - branch `archive/pre-resync-2026-06-20`
  - tag `archive/pre-resync-2026-06-20-tag`  (both at `f62d1049`)
- `main` was hard-reset to `upstream/main`, then the **still-useful new files**
  (all additive, zero upstream-file edits) were re-added on top.

### Supersession: what upstream now does natively (so we dropped it)

| Old fork feature | Upstream replacement (v1.2.x) |
|---|---|
| Token tracking: `bin/gt-usage`, `agents/lib/usage-tracker.sh`, `agents/claude-tracked` | **`gt costs`** — `internal/cmd/costs.go` (live/`--today`/`--week`, `--by-role`, `--by-rig`, `--json`, `record` Stop-hook, `digest` into beads) |
| Multi-model router: `agent_router` route-agent + `models.yaml` (role→model, cost_tier) | **Cost tiers** — `internal/config/cost_tier.go` (`standard`/`economy`/`budget`/`custom-groq-*`, `CostTierRoleAgents`, `CostTierRoleEffort`) |
| Provider wrappers: `agents/gemini-*`, `agents/gpt4o*` | Native **agent presets** in `internal/config/agents.go` (claude, gemini, codex, cursor, **opencode** multi-model, copilot, **groq-compound**) + **ACP** (Agent Client Protocol) |

**Dropped** (superseded, recoverable from the archive ref): `bin/gt-usage`,
`agents/claude-tracked`, `agents/gemini-agent|flash|pro`, `agents/gpt4o|gpt4o-mini`,
`agents/lib/usage-tracker.sh`, `docs/MULTI-MODEL-AGENTS.md`, the old README
multi-model section, the local `ci.yml` / `nightly-integration.yml` / `sync-upstream.yml`
edits, the two local Go test parallelism patches (upstream has its own), and the
`.feed.jsonl` / `.beads/issues.jsonl` runtime state.

### Kept (re-added on current upstream — all new files, no conflicts)

- **Personal towns:** `agent_router/`, `fractasy/`, `weirdchess/`
  - NOTE: the `route-agent` script + `agent_router/.../models.yaml` inside `agent_router/`
    are the **superseded** router engine, retained only as the personal town shell and
    historical reference. Prefer `gt` cost tiers (`gt config cost-tier ...`) for routing now.
- **Imagen pipeline (WeirdChess):** `agents/imagen`, `agents/imagen-batch`,
  `agents/lib/imagen-projects/`, `docs/IMAGEN.md`
- **Perplexity wrapper:** `agents/perplexity` — the one capability with **no** native
  upstream equivalent (see `docs/PERPLEXITY-PRESET-PR-PLAN.md`)
- **Automation + setup docs:** `scripts/overnight-mayor.sh`, `GEMINI-SETUP.md`,
  `GETTING-STARTED.md`, `OVERNIGHT-CRON-SETUP.md`
- **Tracked WeirdChess assets:** `weirdchess-pieces/` (takes 1–9). In-progress
  takes 10–12 + `docs/WEIRDCHESS-IMAGEN-STATUS.md` remain **untracked** — commit
  separately with WeirdChess context.

### Local-only (gitignored, regenerated — not from git)

- `settings/` (agent registry, `config.json`) — provisioned by `gt install` / `gt config`.
  The live copy is in the sibling `../gastown/settings/config.json`.

---

## Build / verify

- Build: `go build ./cmd/gt` (binary → `./gt`). **Requires ICU dev headers** for the
  Dolt CGO dep (`go-icu-regex`). On macOS: `brew install icu4c` and export the
  matching `CGO_CFLAGS`/`CGO_LDFLAGS` (or use upstream's `make build`). Without ICU,
  the build fails at `unicode/regex.h` — this is environment, not fork, related.
- The rebuild touched **zero `.go` files**, so it cannot affect compilation.
- `bd` (beads) must be **0.55.4+** for current upstream: `go install github.com/steveyegge/beads/cmd/bd@latest`.

## Re-sync workflow going forward

Because all personal additions are new files on top of upstream, staying current is:

```bash
git fetch upstream
git checkout main
git tag archive/pre-sync-$(date +%F)-tag        # safety
git reset --hard upstream/main                   # take upstream wholesale
git checkout archive/pre-sync-<prev>-tag -- \    # re-add personal new files
  agent_router/ fractasy/ weirdchess/ weirdchess-pieces/ \
  agents/imagen agents/imagen-batch agents/lib/imagen-projects \
  agents/perplexity docs/IMAGEN.md scripts/overnight-mayor.sh \
  GEMINI-SETUP.md GETTING-STARTED.md OVERNIGHT-CRON-SETUP.md
go build ./cmd/gt                                 # verify (needs ICU)
git commit -m "sync: rebuild on upstream <tag>, re-add personal files"
git push origin main --force-with-lease
```

Re-check each sync whether any kept file has gained a native upstream equivalent
(as the router + token tracker did), and demote it if so.
