# PR Plan — Perplexity research provider for Gas Town

**Status:** PLAN ONLY — not implemented. Do this *after* the fork rebuild (2026-06-20)
has settled, then re-survey before writing code (see step 0).

## Why this is the only PR-worthy remnant

After upstream's v1.2.x work, this fork's router and token tracker are fully
superseded (see `FORK-STATUS.md`). The **one capability with no native upstream
equivalent is Perplexity** — there is no `perplexity` entry in
`internal/config/agents.go` and no Perplexity preset/provider anywhere upstream.

## The architectural catch (read before coding)

Upstream agent presets (`AgentClaude`, `AgentGemini`, `AgentCodex`, `AgentOpenCode`,
`AgentGroqCompound`, …) are **agentic, session-based CLIs** that Gas Town drives via
tmux + the **ACP (Agent Client Protocol)** for multi-turn work — they take over a rig
and iterate. The fork's `agents/perplexity` is a **single-shot Q&A wrapper** over the
sonar API (query in → cited answer out). It is *not* an agentic loop, so it is **not a
drop-in agent preset**. Submitting it as `AgentPerplexity` would misfit the contract.

Two honest integration shapes — pick one in step 0:

- **A. Research tool, not a worker (recommended).** Expose Perplexity as a *lookup
  tool* that existing agents (or the Mayor/Deacon) call for web research with
  citations — e.g. a small `gt research <query>` subcommand, or an MCP tool. This
  matches what the script actually is and is the smaller, cleaner PR.
- **B. Native preset via OpenAI-compatible proxy.** Mirror the `groq-compound`
  pattern (`AgentGroqCompound` routes the claude CLI to Groq's OpenAI-compatible
  endpoint). Perplexity's API is also OpenAI-compatible, so a `perplexity` preset
  could route the claude CLI at `api.perplexity.ai`. This fits the preset registry but
  Perplexity's sonar models are research-tuned, not coding-agent-tuned — verify they
  can actually drive a rig before committing to this shape.

## Step 0 — Re-survey first (do not skip)

The rebuild puts us on current upstream. Before writing code, re-confirm:

1. Still no `perplexity` in `internal/config/agents.go` / `internal/agent/provider/`.
2. Whether `opencode` (multi-model CLI preset) already reaches Perplexity as a model —
   if OpenCode supports Perplexity, the cleanest "PR" may be **docs + a
   `templates/agents/opencode-models.json` entry**, not new Go code.
3. Whether upstream added any `gt research` / web-tool surface since.
4. Re-scope this plan to whatever is *actually* still missing — new upstream
   functionality may open better integration points (or close this gap entirely).

## Step 1 — Branch off the contribution fork

PRs go through `proper-fork` (`mindfu23/gastown`), which lives in the sibling
`../gastown` checkout, **not** this `gastown-mission-district` checkout (origin-only).

```bash
cd ../gastown
git fetch upstream
git switch -c feat/perplexity-research upstream/main
```

## Step 2 — Implement (per the shape chosen in step 0)

- **Shape A:** add `internal/cmd/research.go` (`gt research <query>`), reading
  `PERPLEXITY_API_KEY`, calling `https://api.perplexity.ai/chat/completions` with
  `return_citations`, printing answer + sources; wire into the command registry and
  `GroupDiag`/appropriate group. Add a unit test with a mocked HTTP client.
- **Shape B:** add `AgentPerplexity` to `internal/config/agents.go` mirroring
  `AgentGroqCompound` (claude CLI as SDK proxy → `api.perplexity.ai`), env
  `PERPLEXITY_API_KEY`, plus `agents_test.go` coverage.

Port the genuinely useful bits from `agents/perplexity` (model choices
`sonar`/`sonar-pro`/`sonar-reasoning`, citation formatting, the missing-key help text).

## Step 3 — Conform to CONTRIBUTING.md

Upstream requires bead IDs in commits and ZFC compliance — read `CONTRIBUTING.md`
in `../gastown` first. Run `go build ./cmd/gt` (needs ICU; see FORK-STATUS) and
`go test ./internal/...`.

## Step 4 — Open the PR (do NOT push until reviewed)

```bash
git push proper-fork feat/perplexity-research     # only when ready
gh pr create --repo steveyegge/gastown --base main \
  --head mindfu23:feat/perplexity-research \
  --title "feat: Perplexity research provider" \
  --body  "<your message>"
```

Leave the title/body for the user's own message, per request.

## Decision gate

If step 0 shows OpenCode/opencode-models already covers Perplexity, **don't open a Go
PR** — submit a one-line docs/model-config contribution instead, or skip entirely.
