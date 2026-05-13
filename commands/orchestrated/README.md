# Orchestrated Workflow Trio: `/research` → `/plan` → `/implement`

A rigorous, multi-agent, three-stage workflow for substantial feature work. Each stage produces an artifact the next stage consumes mechanically.

This is the heavyweight counterpart to the simpler commands under `commands/research/`, `commands/planning/`, and `commands/implementation/`. Use the simpler ones for quick informal work; use this trio when shipping the feature on the first attempt matters.

---

## When to use this trio

| Scenario | Use trio? | Why |
|---|---|---|
| Feature integration across multiple files | ✅ YES | Three-tier verification + cumulative regression catches breakage early |
| Multi-week project with phased delivery | ✅ YES | Progress.md + checkpoints + session recovery |
| Spec-driven work where deviation is costly | ✅ YES | Codex AC contract (optional) prevents quietly relaxed test coverage |
| Risky refactor of load-bearing code | ✅ YES | Worktree isolation + constraint validation |
| Quick bug fix or single-file change | ❌ NO | Use the simpler commands or do it directly |
| Exploratory prototyping | ❌ NO | Overhead unjustified |

---

## The three commands

### `/research <feature description>`

Multi-round orchestrated research. 3 rounds across internal codebase analysis (locator + analyzer + pattern-finder + history + risks + architecture), external web research (official docs + ecosystem + industry examples + community + patterns + perf/security), and synthesis (cross-validator + gap-analyst + synthesizer).

**Input**: Feature description (and optional flags `--quick`, `--internal-only`)
**Output**: `<research_output_dir>/<date>-<slug>/<date>-<slug>-comprehensive-research.md`

### `/plan <research-path>`

3-round planning workflow. Round 1 (codebase + convention + architecture deep dives) produces draft plan. Round 2 (external pitfalls + internal integration) anticipates problems. Round 3 (senior-engineer synthesis) produces the final plan compliant with `rules/implementation-plan-standard.md`.

**Phase 1.5 (optional)**: Codex CLI produces a LOCKED test-criteria contract via the `test-criteria-codex` skill.

**Input**: Path to research artifact (and optional flags `--interactive`, `--no-codex`)
**Output**: `<plan_output_dir>/<date>-<slug>/<date>-<slug>-implementation-plan.md` + optional `test-criteria.md`

### `/implement <plan-path>`

Execute the plan with small code+test increments, three-tier cumulative verification (Build → Test → Integration) at every phase boundary, and **independent verification sub-agents** at per-task, per-phase, and pre-commit granularities. Optional Codex Criterion Gate enforces the LOCKED AC contract from `/plan` Phase 1.5.

Includes a regression mismatch protocol with stash-revert disambiguation for ambiguous test failures.

**Input**: Path to implementation plan (and optional flags `--phase=N`, `--continue`, `--verify-only`, `--fast-verify`, `--skip-verify`)
**Output**: Working code + tests + `progress.md` at `<implementation_output_dir>/<feature>/progress.md`

---

## Configuration

Create `<project-root>/.claude/workflow-config.json`. See `workflow-config.example.json` in this directory for the schema.

If absent, all three commands use sensible Node/npm defaults: output to `thoughts/`, `npm run typecheck` / `npm run test:unit` / `npm run test:e2e`, etc.

For non-Node projects, drop in the config file with your project's test commands.

---

## The "graded your own homework" problem (and the optional Codex fix)

When Claude writes both the code AND the tests for a feature, the test set is bounded by what Claude thinks is sufficient. The independent verification sub-agent catches false-positive PASS claims but cannot catch **insufficient test coverage** — Claude can't tell you its test set is too small to prove the spec was implemented.

The `test-criteria-codex` skill (under `skills/test-criteria-codex/`) closes this gap by invoking OpenAI Codex CLI as an unbiased third-party reviewer of the spec + draft plan. Codex emits a strict machine-parseable list of test criteria that:

- Each cite a specific spec line (no inventing requirements not in the spec)
- Each get a tier (unit / integration / e2e / performance / manual)
- Each name a target file path under the project's test tree
- Each get a suggested test name
- Each are assigned to a specific plan phase

The criteria become **AUTHORITATIVE + LOCKED** acceptance criteria for the plan's §7.5. `/implement` MUST satisfy every criterion as part of per-phase verification. Claude cannot unilaterally skip criteria — only the user can edit `test-criteria.md` to mark a criterion `REMOVED-BY-USER`, producing a commit-tracked audit trail.

**This step is optional** — set `codex.enabled: false` in workflow-config.json or pass `--no-codex` to `/plan` to skip. Without Codex, the standard three-tier verification + independent verification sub-agent still apply; only the upstream "what new tests must exist" contract is missing.

**Prerequisite for Codex**: `codex --version` ≥ 0.130.0 + `~/.codex/config.toml` with a configured profile. See `skills/test-criteria-codex/SKILL.md` for setup.

---

## How they chain

```
/research "Add real-time collaboration to document editor"
  └── thoughts/research/2026-05-13-real-time-collab/
      ├── round-1/R1-*.md (6 internal-research artifacts)
      ├── round-2/R2-*.md (6 external-research artifacts)
      ├── round-3/R3-*.md (3-4 synthesis artifacts)
      └── 2026-05-13-real-time-collab-comprehensive-research.md   ← consumed by /plan

/plan thoughts/research/2026-05-13-real-time-collab/2026-05-13-real-time-collab-comprehensive-research.md
  └── thoughts/plans/2026-05-13-real-time-collab/
      ├── R1-plan-*.md (3 round-1 inputs)
      ├── round-1-draft-plan.md
      ├── R2-plan-*.md (2 round-2 inputs)
      ├── round-2-potential-issues.md
      ├── round-3-synthesis.md
      ├── test-criteria.md   ← optional, from Codex
      └── 2026-05-13-real-time-collab-implementation-plan.md   ← consumed by /implement

/implement thoughts/plans/2026-05-13-real-time-collab/2026-05-13-real-time-collab-implementation-plan.md
  └── thoughts/implementation/real-time-collab/
      ├── progress.md
      ├── test-results/
      └── screenshots/
```

Each artifact is self-contained and resumable. If a session drops mid-`/implement`, run `/implement <plan-path> --continue` and the orchestrator picks up from the last checkpoint in `progress.md`.

---

## Related rules in this framework

These commands rely on rules that ship with this framework. The orchestrator loads them automatically:

- `rules/orchestration-quality-standard.md` — 5-pillar quality standard governing the whole workflow
- `rules/sub-agent-orchestration.md` — agent patterns, lean orchestrator, file-based piping, three-tier verification model
- `rules/implementation-plan-standard.md` — 16-section gold-standard plan template the `/plan` output complies with
- `rules/intent-encoding-standard.md` — intent capture at Phase 0 (preserved through every command's prompt block)
- `rules/task-list-management.md` — always-on TaskCreate decomposition

If you fork these commands into another framework, port these rules too — the commands assume their patterns are loaded.

---

## See also

- `commands/research/research_codebase_generic.md` — single-pass codebase research (use for quick questions)
- `commands/planning/create_plan_generic.md` — single-pass plan creation (use when research already exists in your head)
- `commands/implementation/implement_plan.md` — informal plan execution (use for short plans without the rigor budget)
- `commands/second-opinion.md` — multi-agent Codex cross-check (different output, complementary to `test-criteria-codex`)
