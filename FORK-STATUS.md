# gastown-mission-district Fork Status

**Last updated:** February 28, 2026
**Fork:** `mindfu23/gastown-mission-district` (local: `/Users/jamesbeach/.../gastown`)
**Upstream:** `steveyegge/gastown` (`upstream` remote)
**Personal contribution fork:** `mindfu23/gastown` (`proper-fork` remote)

---

## Repo Structure (Three Remotes)

| Remote | Repo | Purpose |
|---|---|---|
| `origin` | `mindfu23/gastown-mission-district` | Personal fork with multi-model additions |
| `proper-fork` | `mindfu23/gastown` | Fork for sending PRs upstream |
| `upstream` | `steveyegge/gastown` | Steve Yegge's original project |

---

## Current State (Post-Resync)

### Branch Structure

| Branch | Status |
|---|---|
| `main` | Active — rebased onto `upstream/main` with 4 personal commits on top |

All stale branches have been cleaned up. Archive tags preserve old state:
- `pre-resync-archive` — old `main` before resync (13 personal commits, 2,238 behind upstream)
- `personaldev-archive` — old `personaldev` branch (superseded by main)

### Upstream Sync

- **Commits behind upstream/main:** 0
- **Commits ahead of upstream/main:** 4 (personal additions only — new files, no Go source modifications)
- **Last synced:** February 28, 2026

### Personal Commits (on top of upstream/main)

1. `feat: Add multi-model AI agent scripts and documentation` — agents/, bin/gt-usage, docs
2. `feat: Add personal town configurations and overnight automation` — agent_router/, fractasy/, weirdchess/, scripts/
3. `docs: Add multi-model orchestration section to README, extend .gitignore`
4. `docs: Add fork status and maintenance documentation`

### Settings

- `settings/config.json` — gitignored (by design). Locally configured with all agents using relative paths.
- `default_agent` is set to `router` (multi-model routing agent)

---

## Sync Workflow (How to Stay Current)

The fork is structured as a thin layer of personal commits on top of upstream.
All personal additions are **new files** — no upstream Go source is modified.
This makes syncing a simple rebase.

### Regular Sync (weekly recommended)

```bash
git fetch upstream
git rebase upstream/main
# Conflicts are unlikely since personal commits only add new files.
# If conflicts occur, they'll be in README.md or .gitignore — resolve manually.
go build ./cmd/gt          # Verify build
git push origin main --force-with-lease   # Update personal remote
```

### If Rebase Has Conflicts

The only files that touch upstream content are:
- `README.md` — multi-model section inserted before "## Core Concepts"
- `.gitignore` — town worktree and runtime state patterns appended at bottom

Resolve these manually, then `git rebase --continue`.

### After Sync Checklist

- [ ] `go build ./cmd/gt` succeeds
- [ ] `./gt config agent list` shows all custom agents
- [ ] Check upstream release notes for breaking changes to agent-provider interface

---

## File Inventory: What's in the Fork

### Multi-model agent scripts (tracked)
- `agents/claude-tracked` — Claude with token tracking
- `agents/gemini-agent`, `agents/gemini-flash`, `agents/gemini-pro` — Gemini API wrappers
- `agents/gpt4o`, `agents/gpt4o-mini` — OpenAI API wrappers
- `agents/imagen`, `agents/imagen-batch` — Google Imagen API wrappers
- `agents/perplexity` — Perplexity API wrapper
- `agents/lib/` — Shared libraries (usage-tracker, imagen-projects templates)
- `bin/gt-usage` — Personal token usage tracker

### Documentation (tracked)
- `docs/MULTI-MODEL-AGENTS.md`, `docs/IMAGEN.md` — Multi-model agent docs
- `GEMINI-SETUP.md`, `GETTING-STARTED.md`, `OVERNIGHT-CRON-SETUP.md` — Setup guides

### Personal town configurations (tracked)
- `agent_router/` — Multi-model routing town config (includes route-agent binary)
- `fractasy/` — Personal town config
- `weirdchess/` — Personal town config
- `scripts/overnight-mayor.sh` — Overnight cron automation

### Local runtime files (gitignored, not tracked)
- `settings/config.json` — Local agent registry
- `settings/escalation.json` — Local escalation config
- `.beads/formulas/` — Runtime formula copies (provisioned by `gt install`)
- `mayor/`, `deacon/` — Runtime state
- `.claude/` — Local Claude Code state

---

## Upstream Contribution Candidates

The Go infrastructure files from the old fork (gate.go, park.go, convoy_watcher.go, etc.)
were **not carried forward** into the resynced main. They are preserved in the
`pre-resync-archive` tag for reference.

Before contributing these upstream:
1. Check if upstream already has equivalent functionality (the codebase has evolved significantly)
2. Port the files individually onto a fresh branch from `upstream/main`
3. Verify they compile against current internal APIs
4. Read `CONTRIBUTING.md` for upstream requirements (bead IDs, ZFC compliance, etc.)
5. Submit via `proper-fork` remote → `steveyegge/gastown`

### Files available in `pre-resync-archive`:

| File | Description |
|---|---|
| `internal/cmd/gate.go` | `gt gate` — async gate coordination |
| `internal/cmd/park.go` | `gt park` — park work on a gate |
| `internal/cmd/prime_state.go` | Session state detection |
| `internal/convoy/observer.go` | Shared convoy observation |
| `internal/daemon/convoy_watcher.go` + test | Convoy activity monitoring |
| `internal/beads/daemon.go` + test | Daemon status helpers |
| `internal/doctor/bd_daemon_check.go` | bd daemon health check |
| `internal/doctor/repo_fingerprint_check.go` | Repo identity check |
| `internal/doctor/sqlite3_check.go` | sqlite3 availability check |
| `internal/polecat/pending.go` | Pending-work lifecycle |
| `internal/witness/types.go` + test | Witness types |
| `internal/templates/commands/handoff.md` | Improved handoff template |

---

## Key Technical Notes

1. **Build command:** `go build ./cmd/gt` or `make build` — binary outputs as `./gt`
2. **Test command:** `go test ./...`
3. **The `settings/` directory is gitignored** — do not track it
4. **The `router` agent** binary is at `agent_router/refinery/rig/bin/route-agent` — rebuild if source changes
5. **Upstream agent-provider interface:** Custom agents via `gt config agent set <name> "<command>"` — this is the long-term integration path for the Python agent scripts
6. **`gt-model-eval/`** in upstream — promptfoo-based model evaluation harness, worth exploring for multi-model routing validation
7. **Beads upgrade needed:** Current local `bd` is 0.47.1, upstream requires 0.55.4+. Run `go install github.com/steveyegge/beads/cmd/bd@latest`
