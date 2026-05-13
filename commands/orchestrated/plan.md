---
allowed-tools: Task, Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, Bash, TodoWrite, AskUserQuestion
description: Generate a comprehensive phased implementation plan from a /research artifact via 3 rounds of focused planning + optional Codex-authored test criteria contract
argument-hint: <research-artifact-path> [--interactive] [--no-codex]
---

# /plan — Orchestrated Implementation Planning

## Purpose

Turn a `/research` artifact into a **phased, verifiable implementation plan** through 3 rounds of focused planning. The output plan complies with `rules/implementation-plan-standard.md` and is consumable by `/implement` mechanically.

This is the **rigorous** counterpart to `commands/planning/create_plan_generic.md` — use that for quick single-pass planning, use this when you need:

- Round-by-round refinement (draft → anticipate problems → SME synthesis)
- Test inventory + per-phase regression risk prediction baked into the plan
- Optional LOCKED test-criteria contract authored by an independent reviewer (Codex CLI)
- Plan structure that `/implement` can execute autonomously with three-tier verification

---

## 3-Round Planning Architecture (MANDATORY)

| Round | Agents | Focus | Output |
|-------|--------|-------|--------|
| Round 1 | 2–3 (parallel) | Context-aware deep dive on research artifact | `round-1-draft-plan.md` |
| Round 2 | 2 (parallel) | Anticipate problems (external pitfalls + internal integration) | `round-2-potential-issues.md` |
| Round 3 | 1 | Senior-engineer synthesis | `round-3-synthesis.md` |
| Phase 1.5 (optional) | Codex CLI | LOCKED test-criteria contract | `test-criteria.md` |

---

## Configuration

Reads `.claude/workflow-config.json` (see `commands/orchestrated/research.md` for schema). Key fields used here:

- `project_root`
- `plan_output_dir` (default: `thoughts/plans`)
- `test_commands` — used when emitting verification gates in the plan
- `codex` (optional) — `{"enabled": true, "profile": "analyst", "sandbox": "read-only"}` enables Phase 1.5

If `.claude/workflow-config.json` is absent: defaults apply, Codex disabled.

---

## Step-by-step Instructions

### 1. Parse arguments

```
/plan <research-artifact-path> [--interactive] [--no-codex]
```

- Required: absolute or project-relative path to a `/research` comprehensive artifact
- `--interactive`: pause at decision points (pattern conflicts, phase count, etc.) and ask via `AskUserQuestion`
- `--no-codex`: skip Phase 1.5 even if `codex.enabled = true` in config

Validate the research artifact exists. If not, ask for the correct path.

### 2. Read the research artifact (MANDATORY)

Read the entire comprehensive research document. Extract:

- Feature being implemented
- Internal codebase analysis (files, patterns, history, architecture)
- External findings
- Recommended Approach (with trade-offs)
- Risk assessment
- Open questions / gaps

### 3. Derive slug + create output directory

```bash
SLUG="<feature-slug>"  # from research artifact
DATE=$(date +%Y-%m-%d)
mkdir -p "<plan_output_dir>/${DATE}-${SLUG}"
```

### 4. Initialize TaskCreate tracking

```
- Round 1: R1-Plan-Codebase-Traverser
- Round 1: R1-Plan-Convention-Traverser
- Round 1: R1-Plan-Architecture-Analyst
- Round 1: Create draft plan
- Round 2: R2-Plan-Pitfall-Researcher
- Round 2: R2-Plan-Integration-Analyst
- Round 2: Create potential issues document
- Round 3: R3-Plan-SME-Synthesizer
- Phase 1.5 (optional): Codex test-criteria contract — only if enabled
- Final: Comprehensive implementation plan
```

---

## Round 1: Context-Aware Deep Dive (2–3 agents in parallel)

**Goal**: Traverse the research artifact's file references, gather deeper context, and create a draft plan.

### Agent: R1-Plan-Codebase-Traverser (`research-specialist`)

```
**AGENT ID**: R1-Plan-Codebase-Traverser

You are creating an implementation plan for feature: [FEATURE FROM RESEARCH]

**RESEARCH ARTIFACT**: [path]

**YOUR SCOPE**: Traverse the CODEBASE-related file references in the research artifact.

**TASKS**:
1. Read the research artifact in full
2. Follow ALL codebase-related file references in round-1 (codebase-locator, codebase-analyzer, codebase-pattern-finder, architecture-analyst)
3. Read the actual source files mentioned
4. Determine EXACT integration points
5. Identify SPECIFIC files to create/modify (with line numbers where possible)

**OUTPUT**: Provide findings for the draft plan including:
- Specific files to create (with proposed paths)
- Specific files to modify (with line numbers if possible)
- Integration points (where new code connects)
- Module dependencies

Write findings to `<plan_output_dir>/<date>-<slug>/R1-plan-codebase-traverser.md`.

**RETURN FORMAT** (mandatory):
**AGENT COMPLETE**: R1-Plan-Codebase-Traverser
**OUTPUT FILE**: [absolute path]
**SUMMARY**: [2-3 sentences]
**KEY FINDING**: [single most important insight]
```

### Agent: R1-Plan-Convention-Traverser (`research-specialist`)

```
**AGENT ID**: R1-Plan-Convention-Traverser

You are creating an implementation plan for feature: [FEATURE FROM RESEARCH]

**RESEARCH ARTIFACT**: [path]

**YOUR SCOPE**: Traverse convention, pattern, and testing references in the research.

**TASKS**:
1. Read the research artifact in full
2. Follow ALL pattern/convention references
3. Extract specific patterns to apply (with code examples from skill tree or codebase)
4. Extract specific conventions to follow
5. **Build a Test Inventory** — read the project's `package.json` (or equivalent) to capture EXACT test script names from `test_commands` in workflow-config.json. Enumerate existing test files (glob `tests/**/*.{test,spec}.*`, `**/__tests__/*`, etc.) by category with counts. If a `known-failures.md` or similar registry exists, identify entries intersecting the feature blast radius.

**OUTPUT**: Provide findings for the draft plan including:
- Patterns to apply (with code examples)
- Conventions checklist
- Testing strategy
- Quality gates
- **§7a Existing Test Suite draft** (file paths + counts by category, EXACT test commands)
- **§7c Regression Risk Prediction draft** (per-phase at-risk specs by file name, NOT generic "all tests")
- **Known-failures intersect** (entries from any failure registry that fall within the feature blast radius)

Write findings to `<plan_output_dir>/<date>-<slug>/R1-plan-convention-traverser.md`.

**RETURN FORMAT** (mandatory).
```

### Agent: R1-Plan-Architecture-Analyst (`Plan`)

```
**AGENT ID**: R1-Plan-Architecture-Analyst

You are designing the implementation architecture for feature: [FEATURE FROM RESEARCH]

**RESEARCH ARTIFACT**: [path]

**YOUR SCOPE**: Design the overall implementation approach.

**TASKS**:
1. Read the research artifact's "Recommended Approach" section
2. Determine optimal phasing (how many phases?)
3. Design phase dependencies
4. Create code scaffolds for key components
5. Define success criteria per phase (three-tier: Build Gate + Test Gate + Integration Gate per `rules/implementation-plan-standard.md`)
6. **Design the test pyramid PER PHASE**: for each phase decide which tier(s) apply (unit / integration / E2E / visual / performance / manual)
7. Cite specific patterns from the codebase/research that each phase should follow

**OUTPUT** (write findings to `<plan_output_dir>/<date>-<slug>/R1-plan-architecture-analyst.md`):
- Phase breakdown with objectives
- Phase dependency diagram
- Code scaffolds for each phase
- Three-tier success criteria per phase (automated + manual)
- Per-phase test-pyramid map (each phase mapped to applicable test tiers with rationale)
- Pattern citations (specific patterns named for each test type)
- Deferred surfaces flagged (work that's needed eventually but out of scope for this plan)

**RETURN FORMAT** (mandatory).
```

### Create Round 1 output: `round-1-draft-plan.md`

After all three R1 agents return, orchestrator (or a dedicated synthesis agent) combines their outputs into a draft plan at `<plan_output_dir>/<date>-<slug>/round-1-draft-plan.md`. Format:

```markdown
# Round 1: Draft Implementation Plan

## Feature
[From research artifact]

## Source Research
- `<path-to-comprehensive-research>`

## Files to Create
| File | Purpose |

## Files to Modify
| File | Line(s) | Change |

## Patterns to Apply
[Code examples from R1-Plan-Convention-Traverser]

## Conventions Checklist
- [ ] [Project-specific convention 1]
- [ ] [Project-specific convention 2]

## Phase Breakdown
### Phase 1: [Name]
**Objective**: [Goal]
**Tasks**: [list]
**Files**: CREATE/MODIFY
**Code Scaffold**: [from architect]
**Three-Tier Success Criteria**:
- Tier 1 (Build Gate): `<typecheck>` && `<lint>` && `<build>` all exit 0
- Tier 2 (Test Gate, cumulative): `<test_unit>` passes (X new + Y existing tests)
- Tier 3 (Integration Gate, cumulative): `<test_e2e>` passes
- Manual: [criterion]

### Phase 2: [Name]
...

## Test Specifications (preliminary)
### Unit Tests (per phase)
| Test Name | System Under Test | Assertion | Priority |

### E2E Tests (per phase)
| Scenario | Steps | Expected Result |

## §7 Test Inventory
### 7a. Existing Test Suite
[From R1-Plan-Convention-Traverser]

### 7b. New Tests Plan (per phase)
| Phase | Test File | Type | New Tests | Cumulative Unit | Cumulative E2E |

### 7c. Regression Risk Prediction (per phase)
| Phase | Expected regression surface | Highest-risk existing specs |

## Open Questions for Round 2
[What could go wrong? What needs validation?]
```

---

## Round 2: Anticipate Problems (2 agents in parallel)

**Goal**: Identify potential issues BEFORE implementation.

### Agent: R2-Plan-Pitfall-Researcher (`research-specialist`)

```
**AGENT ID**: R2-Plan-Pitfall-Researcher

Research common problems and pitfalls for implementing: [FEATURE DESCRIPTION]

**CONTEXT**: Project uses [PROJECT_STACK from workflow-config.json or research artifact]. Draft plan: [path].

**SEARCH FOR**:
- Common bugs when implementing this type of feature
- Known issues in the project's framework/libraries
- Performance pitfalls
- Architectural mistakes to avoid
- Edge cases that bite

**OUTPUT** (write to `<plan_output_dir>/<date>-<slug>/R2-plan-pitfall-researcher.md`):
- Issue category
- Description
- Evidence/source (with URLs)
- Recommended mitigation

**RETURN FORMAT** (mandatory).
```

### Agent: R2-Plan-Integration-Analyst (`research-specialist`)

```
**AGENT ID**: R2-Plan-Integration-Analyst

Analyze the draft plan for potential integration issues: [FEATURE]

**DRAFT PLAN**: `<plan_output_dir>/<date>-<slug>/round-1-draft-plan.md`
**RESEARCH ARTIFACT**: [path]

**ANALYZE**:
1. Read draft plan phase breakdown
2. Check for missing dependencies between phases
3. Identify potential conflicts with existing code
4. Review module dependencies for issues
5. Check for missing error handling
6. Verify test inventory is realistic (no phantom tests)
7. Validate three-tier gates make sense per phase

**OUTPUT** (write to `<plan_output_dir>/<date>-<slug>/R2-plan-integration-analyst.md`):
- Potential integration issues
- Phase ordering concerns
- Missing dependencies
- Error handling gaps
- Recommendations

**RETURN FORMAT** (mandatory).
```

### Create Round 2 output: `round-2-potential-issues.md`

Synthesize both R2 agent outputs into a single document at `<plan_output_dir>/<date>-<slug>/round-2-potential-issues.md`. Include external pitfalls and internal integration concerns, with specific plan modifications recommended.

---

## Round 3: Senior-Engineer Synthesis (1 agent)

### Agent: R3-Plan-SME-Synthesizer (`Plan`)

```
**AGENT ID**: R3-Plan-SME-Synthesizer

You are a Senior Engineer creating the FINAL implementation plan for: [FEATURE]

**INPUT DOCUMENTS**:
1. Comprehensive Research: [path]
2. Draft Plan: `round-1-draft-plan.md`
3. Potential Issues: `round-2-potential-issues.md`

**YOUR TASK**: Create the FINAL implementation plan that:
1. Incorporates all research findings
2. Addresses identified potential issues
3. Maintains phase structure (modified as needed)
4. Includes complete code scaffolds
5. Has comprehensive three-tier success criteria per phase
6. Includes citations to source documents
7. Follows the gold-standard plan template from `rules/implementation-plan-standard.md`

**OUTPUT** (write to `<plan_output_dir>/<date>-<slug>/round-3-synthesis.md`): a brief document noting what changed from draft to final, plus the FULL final plan.

**RETURN FORMAT** (mandatory).
```

---

## Phase 1.5: Codex-Authored Test Criteria (OPTIONAL — LOCKED AC contract)

**Goal**: Generate the AUTHORITATIVE + LOCKED acceptance-criteria contract via an unbiased third party (OpenAI Codex CLI). This step runs ONCE per feature, immediately after Round 3, BEFORE the final plan is written. The output becomes the test contract `/implement` MUST satisfy per phase.

**Why it's optional**:
- Requires Codex CLI installed locally (`codex --version` ≥ 0.130.0)
- Adds 1–2 min latency
- Skip with `--no-codex` flag or by setting `codex.enabled: false` in workflow-config.json

**Why it's powerful**: Without this step, the implementation agent (a future Claude session running `/implement`) would write both the code AND the tests, bounding the test surface only by what Claude thinks is sufficient — the classic "graded your own homework" failure mode. Codex (or any unbiased third-party reviewer) provides an upstream definition of WHICH new tests must exist for the feature to be considered shipped.

### Step A: Check availability

```bash
codex --version
```

Expected: ≥ 0.130.0. If absent or older, the `test-criteria-codex` skill (see `skills/test-criteria-codex/SKILL.md`) will halt and offer recovery options:
- Install/upgrade Codex CLI
- Mark plan `codex-coverage:unavailable` and proceed without the gate
- Abort `/plan`

### Step B: Invoke the `test-criteria-codex` skill

```
Skill(test-criteria-codex)
```

Pass these inputs:
- `SPEC_PATH` = absolute path of the comprehensive-research artifact
- `DRAFT_PLAN_PATH` = absolute path of `round-3-synthesis.md`
- `PLAN_DIRECTORY` = `<plan_output_dir>/<date>-<slug>/`
- `PROJECT_ROOT` = from workflow-config.json

The skill executes per `skills/test-criteria-codex/invocation-protocol.md`:

1. Prints a status banner
2. Builds prompt from `codex-prompt-template.md` (substitutes SPEC_BODY + DRAFT_PLAN_BODY + EXISTING_TEST_INVENTORY)
3. Runs `cd <project-root> && codex exec -p <profile> -s <sandbox> - < /tmp/prompt.txt`
4. Validates Codex output against `output-schema.md` (1 retry on schema failure)
5. Writes `test-criteria.md` to the plan directory
6. Returns a §7.5 summary block for injection into the final plan
7. Returns `success` / `unavailable` / `abort` signal

### Step C: Handle skill outcome

**`success`**: Inject §7.5 summary into the final plan; mark Phase 1.5 task `completed`; continue.

**`unavailable`** (user opted to proceed without Codex): Inject §7.5 stub with `codex-coverage:unavailable` and user's reason; continue.

**`abort`** (user halted): Preserve rounds 1–3 outputs; DO NOT write the final plan; surface resume guidance.

### Step D: Update plan self-validation

The final plan's self-validation checklist gains:

- [ ] §7.5 (Codex-Authored Test Criteria) populated, OR plan explicitly marked `codex-coverage:unavailable`
- [ ] `test-criteria.md` artifact exists in plan directory (or unavailable-marker documented)
- [ ] Codex self-attestation is all ✅ (or `codex-coverage:unavailable`)

A plan that fails any of these is NOT ready for `/implement`.

### Reference

- Skill entry point: `skills/test-criteria-codex/SKILL.md`
- Invocation protocol: `skills/test-criteria-codex/invocation-protocol.md`
- Prompt template: `skills/test-criteria-codex/codex-prompt-template.md`
- Output schema: `skills/test-criteria-codex/output-schema.md`
- Integration contract: `skills/test-criteria-codex/integration-points.md`

---

## Decision Points (if `--interactive`)

If `--interactive` flag is set, pause at these points via `AskUserQuestion`:

- **Pattern conflicts**: Multiple valid patterns could apply — which?
- **Phase count**: Could implement in 2 / 3 / 4+ phases — which?
- **Risky path**: Plan suggests a known-risky approach — proceed or revise?

---

## Final: Create Implementation Plan

**File**: `<plan_output_dir>/<date>-<slug>/<date>-<slug>-implementation-plan.md`

Format follows `rules/implementation-plan-standard.md` exactly. Required sections (16-section gold standard):

0. **Intent** — why this matters, desired experience, preserve, anti-patterns (user's own words from research Phase 0 if available)
1. **Context / Problem Statement**
2. **Options Considered** (with 2a Architectural Decision when applicable)
3. **Worktree Setup** (if applicable)
4. **CONSTRAINTS (MUST NOT TOUCH)** with materialized constraint check command
5. **Current Inventory** (5a Pre-existing / 5b Net-new / 5c Modified with EVOLVE|EXTEND mode)
6. **Phased Implementation** with three-tier verification per phase
7. **Test Inventory** (7a Existing / 7b New per phase / 7c Regression risk prediction)
8. **Task List with Dependencies** (Phase/VERIFY/TOUCHBACK triplet pattern)
9. **Agent Architecture**
10. **Comprehensive Final Validation** (automated + visual sign-off)
11. **Edge Cases & Mitigations**
12. **Execution Order & Estimates**
13. **Key Reference Files**
14. **Critical Exploration Findings** (+ 14a Extension-Point Documentation when applicable)
15. **Plan File Location**
16. **Autonomous Execution Model** (self-healing verification loop + DIAGNOSE-FIX-RETRY)

Plus **§7.5 Codex-Authored Test Criteria** if Phase 1.5 ran successfully.

### Compliance Receipt (for Large+ scope)

At the end of the plan, include a CONCISE COMPLIANCE RECEIPT (5–10 lines) showing this plan's specific compliance with the gold standard. One line per major checklist category, with evidence:

```markdown
## Compliance Receipt
- Intent: §0 quotes user's exact words from research §0 INTENT
- Phase gates: all [N] phases have three-tier AC with exact test commands from workflow-config.json
- Test inventory: §7a enumerates [N] existing test files with EXACT script names; §7c maps each phase to specific at-risk specs by file name
- Constraints: §4 lists [N] MUST NOT TOUCH paths; constraint check command materialized in §4, §10, §16
- §7.5 Codex AC: populated with [N] criteria, [M]% coverage — OR — marked codex-coverage:unavailable per user opt-out
- Self-validation: all checklist items confirmed
```

---

## Reference Format

All documents use relative paths from the plan directory. Optionally augment with `[[wiki-links]]` if project uses Obsidian.

---

## Error Handling

- Research artifact doesn't exist → ask user for correct path
- Agent hits token limits → spawn continuation agents per `rules/sub-agent-orchestration.md`
- Decision points unclear (even without `--interactive`) → ask via `AskUserQuestion`
- Phases seem too complex → suggest splitting further
- Codex CLI unavailable and not opted out → halt with recovery options

---

## Expected Output

1. TaskCreate tracking all rounds + Phase 1.5 (if enabled) + final
2. Directory structure under `<plan_output_dir>/<date>-<slug>/`
3. Round 1: 3 draft-plan inputs + draft plan
4. Round 2: 2 issue inputs + potential issues document
5. Round 3: Senior-engineer synthesis
6. Phase 1.5 (if enabled): `test-criteria.md` + §7.5 block
7. Final: Comprehensive implementation plan compliant with `rules/implementation-plan-standard.md`
8. Output path printed — ready for `/implement <plan-path>`

---

## Companion Commands

- **`/research <feature>`** — produces the research artifact this command consumes
- **`/implement <plan-path>`** — executes this plan with three-tier independent verification
