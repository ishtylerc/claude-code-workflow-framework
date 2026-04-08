# Implementation Plan Standard

**Purpose**: Single source of truth for what a comprehensive implementation plan must contain, how to trigger plan creation, and how to self-validate before presenting. This standard applies regardless of how plan creation is triggered (autonomous detection or manual `/create_plan_generic` invocation).

---

## Implementation Task Auto-Detection

### Trigger Keywords

**Auto-trigger keywords**: implement, build, create, develop, migrate, refactor, port, rewrite, integrate, add feature, redesign, overhaul, update (multi-file), setup/set up, configure, optimize, upgrade, deploy, scaffold, patch, extend, convert, extract, fix (multi-file)

### Two-Step Trigger Mechanism

Keywords activate a **scope assessment**, not immediate plan mode entry. This prevents false positives on non-code requests.

```
Step 1: Keywords detected → ASSESS scope
  - Is this a code/system change? (not "create a summary" or "build a comparison table")
  - Is this Medium+ complexity? (5+ steps, multi-file, architectural decisions)
  - Is this NOT handled by a project-specific command?

Step 2: ONLY if all three are YES → Enter plan mode
  - Invoke EnterPlanMode tool (requires user approval)
  - Follow Implementation Plan Flow below
```

**Exclusion patterns** (route elsewhere, not to plan mode):
- Questions: "how to implement", "explain how to build" → informational response
- Content generation: "create a summary", "build a comparison table" → not implementation
- Handled domains: "create a daily note", "add feature request to GDD" → existing commands
- Single-file trivial: typo fix, one-line change → execute directly

### Trigger Precedence: Research vs Implementation

When BOTH research and implementation keywords are present:
1. Default to TWO-PHASE approach: Research phase first → Implementation plan second
2. Research output feeds into implementation plan's Phase 1 context
3. Exception: If implementation keywords dominate and research keywords are incidental references ("implement X based on our research"), route to implementation

### Project-Specific Command Deference

If the request targets a project with dedicated commands (e.g., K-Town has `/ktown-plan`, `/ktown-implement`), suggest the project-specific command. These commands may incorporate project-specific context (test infrastructure, framework patterns) not in the general standard. Exception: If the user explicitly requests the general standard, use it.

---

## Implementation Plan Flow (Autonomous Pipeline)

This is the step-by-step procedure for producing a gold-standard plan from a single user request.

```
Step 1:  Detect implementation task (keyword triggers + scope assessment)

Step 2:  Enter plan mode
         - IF already in plan mode (system reminder present): Skip, proceed to Step 3
         - IF NOT in plan mode: Invoke EnterPlanMode tool (requires user approval)

Step 3:  Phase 0 -- Clarify until understanding (AskUserQuestion)
         INTENT FIRST:
         - Beyond functional requirements — what should this feel like?
         - What qualities of the current system must be preserved?
         THEN scope/requirements:
         - What exactly needs to change? What's the desired end state?
         - What must NOT change? What's fragile?
         - What test infrastructure exists? What verification is possible?
         - Worktree isolation needed? What branch strategy?
         - What blocks what? What can parallelize?
         - Continue asking until the TRUE ask is understood

Step 4:  Phase 1 -- Gather context (codebase exploration, 1-5 tool calls)
         - Read key files, grep for patterns, check existing tests
         - Understand current architecture before proposing changes

Step 5:  Propose artifact structure
         - Show the user what sections the plan will contain
         - Show the depth level (Small/Medium/Large/Mega)
         - Explain how it maps to the orchestration standards
         - Get user confirmation before writing the full plan

Step 6:  User confirms artifact structure

Step 7:  Create plan using template (scaled to complexity -- see Scaling Guide)

Step 8:  Self-validate plan against compliance checklist (see below)

Step 9:  If gaps found in validation, fill them (don't present incomplete plans)

Step 10: For Large+ tasks: Launch independent validation agent to review plan

Step 11: Present final plan (ExitPlanMode)
```

### Scope Upgrade During Planning

If during context gathering (Step 4), the task is discovered to be larger than initially assessed:
1. Notify user: "This task appears to be [Large/Mega] rather than [Medium]. I'll expand the plan."
2. Add missing template sections incrementally (do NOT restart from scratch)
3. Update the scope classification in the plan header

### Already-In-Plan-Mode Guard

If the system indicates plan mode is already active when Step 2 is reached, skip EnterPlanMode invocation and proceed directly to Phase 0 clarification.

---

## Plan Template (Gold Standard)

The template below represents the FULL gold-standard structure. Use the **Scaling Guide** to determine which sections apply at each complexity level.

**Quality benchmark**: Plans at Large/Mega complexity should structurally resemble the example in `thoughts/plans/Good Claude Code Plan Example.md`.

````markdown
# [Feature/Task Name] Implementation Plan

**Date**: YYYY-MM-DD
**Status**: DRAFT | FACT-CHECKED | APPROVED
**Scope**: Small | Medium | Large | Mega
**Target**: [One-line description of the desired end state]
**Quality Bar**: [Measurable success metric]

---

## 0. Intent

**Why this matters**: [The purpose — not what's being built, but why]
**Desired experience**: [How this should feel for the user when complete]
**Qualities to preserve**: [Existing characteristics that must survive this change]
**Anti-patterns**: [What this should NOT become, even if functionally "better"]

---

## 1. Context / Problem Statement

[Why this work is needed. Include production stats, current pain points, and what motivated the change. Not just "what" but "why now".]

---

## 2. Options Considered

| Path | Approach | Viability | Why |
|------|----------|-----------|-----|
| A | [Approach A] | [%] | [Accepted/Rejected + reasoning] |
| B | [Approach B] | [%] | [Accepted/Rejected + reasoning] |

**Selected approach**: [Which option and why]

---

## 3. Worktree Setup

**Source** (READ-ONLY): `[path-to-source or N/A]`
**Target** (ALL CHANGES HERE): `[path-to-target-worktree]`
**Branch**: `feature/[branch-name]`

**Setup commands**:
```bash
git worktree add [path] -b feature/[branch-name]
```

---

## 4. CONSTRAINTS (MUST NOT TOUCH)

| File/Component | Reason | Last Verified |
|---------------|--------|---------------|
| `[path]` | [Why it must not change] | [Date] |

---

## 5. Current Inventory (What Changes)

[Detailed inventory of files, components, dependencies that will be affected. Tables preferred.]

### Dependencies to Change

| Package | Current | Target | Notes |
|---------|---------|--------|-------|
| [pkg] | [ver] | [ver] | [Migration notes] |

---

## 6. Phased Implementation

### Phase N: [Descriptive Name]
**Risk:** LOW/MEDIUM/HIGH | **Effort:** Xh | **Blocked by:** Phase N-1

[What this phase accomplishes and why it's sequenced here. For HIGH-risk phases, explain the complexity source.]

**Files to create:**

| File | Description |
|------|-------------|
| `[path]` | [What this file does, its public API signature] |

**Files to modify:**

| File | Line(s) | Change |
|------|---------|--------|
| `[path]` | [line range] | [What changes] |

#### Implementation Specification

[For complex phases, provide the detailed implementation spec that the agent will follow. This is the "blueprint" -- the more precise this is, the fewer retries needed.]

**[Pipeline/Algorithm/Logic] details:**
1. [Step 1 with exact function calls, parameters, or patterns]
2. [Step 2 ...]
3. [Step N ...]

**[Configuration/Setup] block:**
```
[Exact code patterns, configuration values, or API calls the agent must produce]
```

#### Agent Assignment

**Agent**: `implementation-specialist` (single agent: code + tests + verification)
**Agent prompt context**: Read `[specific files]`, reference `[specific sections]`, all prior phase outputs

**[RISK-LEVEL]-RISK PHASE** agent prompt requirements:

| Risk | Agent Prompt MUST Include |
|------|--------------------------|
| LOW | File paths + verification commands |
| MEDIUM | Above + pattern references ("follow X.tsx patterns exactly for Y") + relevant edge cases from Section 11 |
| HIGH | Above + full implementation specification (all pipeline steps) + all applicable edge cases + explicit gotcha instructions |

#### Three-Tier Verification (with autonomous retry)

**Tier 1: Build Gate** (BLOCKING)
- [ ] `[exact typecheck command]` exits 0
- [ ] `[exact build command]` exits 0
- On FAIL: Agent reads error -> fixes -> re-runs (max 3 self-attempts)
- Common Phase N failures: [List 2-3 likely failure modes, e.g., "import paths, missing type annotations, incorrect API usage"]

**Tier 2: Test Gate** (BLOCKING -- cumulative)
New tests this phase ([N]):
- [ ] [Test case 1 description]
- [ ] [Test case 2 description]
- [ ] [Test case N description]
Regression check:
- [ ] `[full test command]` -- [total] tests pass (Phase 1 through N)
- On FAIL: Agent reads test output -> fixes code or test -> re-runs (max 3 self-attempts)

**Tier 3: Integration Gate** (BLOCKING -- cumulative)
- [ ] `[E2E test command]` -- [total] E2E tests pass (includes all prior phases)
- Or: N/A (existing E2E regression) -- if no new E2E tests this phase

**Phase-specific verification checks:**
- [ ] `[file]` exists and exports `[expected export]`
- [ ] `grep -r "[pattern]" [path]` returns 0 matches (confirms old pattern removed)
- [ ] Constraint check: `git diff --name-only` shows no MUST NOT TOUCH files

**Manual Verification** (NON-BLOCKING)
- [ ] [Specific criterion for user review]

**Rollback:** [What to delete/revert if this phase fails]

---

[Repeat for each phase...]

#### Phase Specification Quality Checklist

For each phase in the plan, verify:
- [ ] Risk level assigned with justification
- [ ] Implementation specification detail scales with risk (HIGH = full pipeline, LOW = brief)
- [ ] Agent prompt requirements listed per risk level
- [ ] Common failure modes documented per tier
- [ ] New test cases listed individually (not just count)
- [ ] Cumulative test count is correct (sum of all phases through N)
- [ ] Constraint check included in phase-specific verification
- [ ] Rollback instructions are specific (not just "revert changes")

---

## 7. Test Inventory

| Phase | Test File | Type | New Tests | Cumulative Total |
|-------|-----------|------|-----------|-----------------|
| Phase 1 | `[path]` | Unit | [N] | [N] |
| Phase 2 | `[path]` | E2E | [N] | [N] |

---

## 8. Task List with Dependencies

The task list follows a strict **Phase → VERIFY → TOUCHBACK** triplet pattern. Every code phase produces three tasks: the implementation task, the orchestrator verification task (with DIAGNOSE-FIX-RETRY), and the checkpoint update.

```
T0  | Setup: Create progress.md + TaskCreate entries                 | blocked by: --   | agent: orchestrator
T1  | Phase 1: Code + [N] tests + verification (autonomous)         | blocked by: T0   | agent: implementation-specialist
T2  | 🔒 VERIFY: Orchestrator confirms Phase 1 gates + retry        | blocked by: T1   | agent: orchestrator (DIAGNOSE-FIX-RETRY if FAIL)
T3  | 📍 TOUCHBACK: Update progress.md after Phase 1                | blocked by: T2   | agent: orchestrator
T4  | Phase 2: Code + [N] tests + verification (autonomous)         | blocked by: T3   | agent: implementation-specialist
T5  | 🔒 VERIFY: Orchestrator confirms Phase 2 gates + retry        | blocked by: T4   | agent: orchestrator (DIAGNOSE-FIX-RETRY if FAIL)
T6  | 📍 TOUCHBACK: Update progress.md after Phase 2                | blocked by: T5   | agent: orchestrator
...  [Repeat triplet for each code phase]
TN-3| Smoke test: [dev server start command] starts without crash    | blocked by: TN-4 | agent: orchestrator
TN-2| Phase [Final]: Visual validation + screenshots (Playwright)    | blocked by: TN-3 | agent: orchestrator (browser MCP)
TN-1| 📍 TOUCHBACK: Final progress.md update                        | blocked by: TN-2 | agent: orchestrator
TN  | USER GATE: Present visual checklist for sign-off               | blocked by: TN-1 | agent: orchestrator (ONLY user touchpoint)
```

### Dependency Graph

```
T0 (Setup) → T1 (Phase 1) → T2 (🔒 VERIFY + retry) → T3 (📍 TOUCH)
                                                              ↓
              T4 (Phase 2) → T5 (🔒 VERIFY + retry) → T6 (📍 TOUCH)
                                                              ↓
              ... [repeat for each phase] ...                  ↓
                                                              ↓
              TN-3 (Smoke) → TN-2 (Visual) → TN-1 (📍 TOUCH)
                                                              ↓
                                                     TN (USER GATE)
```

### Execution Model

- **T0 through TN-1**: Fully autonomous -- orchestrator runs end-to-end without user input
- **TN (USER GATE)**: ONLY user touchpoint -- visual sign-off on the validation checklist
- **Each 🔒 VERIFY task**: Orchestrator validates agent output, runs DIAGNOSE-FIX-RETRY if any tier failed (up to 3 attempts before HALT)
- **Phase tasks**: Combine code + tests + inline verification into a single agent run for efficiency
- **Default sequential**: All phases strictly sequential (each depends on prior phase output). Document parallel batch opportunities only if phases are truly independent

### Parallel Batch Opportunities

| Batch | Tasks | Can Run Concurrently | Justification |
|-------|-------|---------------------|---------------|
| [Batch N] | [Task IDs] | Yes/No | [Why these are independent] |

*Note: Most implementation workflows are strictly sequential. Only add parallel batches when phases have zero data dependencies.*

---

## 9. Agent Architecture

**Orchestration level**: Full Autonomous (self-healing pipeline with zero user intervention until visual sign-off)
**Execution model**: Single-agent-per-phase with inline verification + 3-attempt DIAGNOSE-FIX-RETRY
**Agents per phase**: 1 implementation-specialist (code + tests + verification in single run)
**Estimated phases**: [N] code phases + 1 visual validation = [N+1] total
**Max concurrent agents**: [1 for sequential | 2-3 for parallel batches]

### End-to-End Autonomous Pipeline

```
Orchestrator launches Phase 1 agent
    ↓
Agent: writes code + tests → runs verification cascade → returns PASS/FAIL
    ↓
├── PASS → Orchestrator: TOUCHBACK → launch Phase 2 agent
└── FAIL → Orchestrator: DIAGNOSE-FIX-RETRY (up to 3 attempts)
           ├── Attempt 1: Inline fix by orchestrator
           ├── Attempt 2: Debug agent with error context
           ├── Attempt 3: Expanded debug agent with full phase spec
           └── All fail → HALT with documented blocker
    ↓
[Repeat for Phases 2-N]
    ↓
Smoke test: dev server starts without crash
    ↓
Visual validation: Playwright screenshots + automated checks
    ↓
Present visual checklist results to user for sign-off
    ↓
DONE — Final working product delivered
```

### Agent Return Format (included in every agent prompt)

```
**AGENT COMPLETE**: Phase [N]: [Name]
**FILES CREATED**: [list with paths]
**FILES MODIFIED**: [list with paths]
**VERIFICATION**:
  Tier 1 (Build): PASS | FAIL [error if fail]
  Tier 2 (Test): PASS | FAIL [N/N tests, error if fail]
  Tier 3 (Integration): PASS | FAIL | N/A
  Constraints: PASS | FAIL [violation details if fail]
**SELF-FIX ATTEMPTS**: [0-3] (how many fix cycles the agent ran internally)
**SUMMARY**: [2-3 sentences describing what was done]
```

### TOUCHBACK Protocol (after EVERY phase)

1. **READ** progress.md -- refresh full state
2. **UPDATE** progress.md with checkpoint:
   - Timestamp
   - Phase completed
   - Artifacts created (file paths)
   - Verification results (all 3 tiers + constraint check)
   - Self-fix attempts count
   - Next phase
   - Recovery action (exact steps to resume from this point)
3. **Mark** TOUCHBACK task complete
4. **Immediately** launch next phase agent (no pause)

### Session Recovery Protocol

If session drops mid-execution:
1. Read progress file at `thoughts/plans/YYYY-MM-DD-[slug]/progress.md`
2. Find last completed TOUCHBACK checkpoint
3. Reconstruct TaskCreate entries from progress.md
4. Resume from next unfinished phase
5. Re-run verification on the last completed phase as a sanity check before proceeding

### Orchestrator Context Budget

The orchestrator receives ONLY agent summaries (~200 words each). It NEVER reads full source files written by agents. Inter-phase context flows through:
- **File paths** (agents read prior phase outputs directly from disk)
- **Progress file checkpoints** (accumulated state)
- **This plan document** (specification reference)

---

## 10. Comprehensive Final Validation

### Automated (orchestrator runs autonomously)

After all code phases are complete and all VERIFY gates have passed:

- [ ] All code phases complete with verified three-tier gates (all PASS)
- [ ] All [N] unit tests pass (`[test command]`)
- [ ] Typecheck + build clean (`[typecheck command] && [build command]`)
- [ ] CONSTRAINTS files unchanged (`git diff --name-only` filtered against constraint list = 0 hits)
- [ ] Existing E2E tests pass (regression)
- [ ] `[dev server command]` starts without crash (smoke test)
- [ ] No runtime errors in console (checked via Playwright `page.on('console')` if applicable)
- [ ] Debug hook returns expected shape via `page.evaluate()` (if applicable)

### Visual (user sign-off -- ONLY user touchpoint)

Orchestrator captures screenshots via Playwright MCP (or equivalent), then presents the visual checklist:

- [ ] [Visual criterion 1]
- [ ] [Visual criterion 2]
- [ ] [Visual criterion N]
- [ ] No console errors or warnings
- [ ] Acceptable performance at target load

### Failure Recovery at Final Validation

If automated validation discovers issues after all code phases:
1. Identify which phase's code is responsible
2. Launch targeted debug agent for that phase
3. Re-run full cumulative verification cascade
4. Update progress.md with fix details
5. Re-run final validation

---

## 11. Edge Cases & Mitigations

| # | Edge Case | Severity | Mitigation | Applies to Phase(s) |
|---|-----------|----------|------------|---------------------|
| 1 | [Case] | Critical | [How to handle] | [Phase N, N+1] |

*For HIGH-risk phases, the agent prompt MUST include all edge cases that apply to that phase (reference by number).*

---

## 12. Execution Order & Estimates

| Step | What | Depends On | Est. Time |
|------|------|------------|-----------|
| Phase 1 | [Name] | -- | Xh |
| Phase 2 | [Name] | Phase 1 | Xh |

**Total**: ~X hours
**Can start immediately**: [List]
**Blocked by external**: [List]

---

## 13. Key Reference Files

| File | Purpose |
|------|---------|
| `[path]` | [Why it's relevant] |

---

## 14. Critical Exploration Findings

[Facts discovered during planning that affect execution. Things the implementing agents need to know that aren't obvious from the codebase.]

---

## 15. Plan File Location

- **During plan mode**: Write to the system-assigned `.claude/plans/[slug].md`
- **After exiting plan mode**: Create progress file at `thoughts/plans/YYYY-MM-DD-[slug]/progress.md` that references the plan file and tracks execution checkpoints
- The plan file IS the implementation blueprint; the progress file tracks execution state
- `thoughts/shared/plans/` is deprecated for new work

---

## 16. Autonomous Execution Model

**Execution mode**: Fully autonomous | **User touchpoint**: Final visual sign-off only

### Self-Healing Verification Loop

Every phase runs through this autonomous loop:

```
Implementation Agent completes code + tests
        ↓
Tier 1: Build Gate → FAIL → DIAGNOSE-FIX-RETRY
        ↓ PASS
Tier 2: Test Gate (cumulative) → FAIL → DIAGNOSE-FIX-RETRY
        ↓ PASS
Tier 3: Integration Gate (cumulative) → FAIL → DIAGNOSE-FIX-RETRY
        ↓ PASS
Phase-specific checks → FAIL → DIAGNOSE-FIX-RETRY
        ↓ PASS
TOUCHBACK → next phase
```

### DIAGNOSE-FIX-RETRY Escalation

| Attempt | Strategy | Context Given |
|---------|----------|--------------|
| 1 | Inline fix by orchestrator | Error output only |
| 2 | Debug agent (implementation-specialist) | Error + failed attempt 1 + constraint list |
| 3 | Expanded debug agent | All errors + full phase spec + reference files + permission to refactor |
| HALT | Document blocker, mark BLOCKED | All 3 error outputs + hypothesis + next steps |

### Constraint Validation (Every Phase)

After every successful verification cascade, before TOUCHBACK:
```bash
git diff --name-only | grep -E "([CONSTRAINT_PATTERN])" && echo "CONSTRAINT VIOLATION" && exit 1
```
If violation detected: revert phase → re-launch agent with constraint reminder → counts as 1 retry.

### Implementation Agent Footer

Append to every implementation agent prompt:
```
AUTONOMOUS EXECUTION RULES:
1. Write ALL code AND tests in a single run
2. Run STATIC verification YOURSELF before returning:
   - [typecheck command] (must exit 0)
   - [build command] (must exit 0)
   - [test command] (all tests must pass)
3. Run RUNTIME REASONING verification — for each interactive feature you wrote:
   - Trace user interactions: "user drags slider" → what fires per tick? → expensive ops?
   - Trace state priority: if multiple sources set the same state, which wins? Can the user override?
   - Trace async lifecycle: what if component unmounts mid-load? What refs go stale?
   - Trace cleanup: does dispose/unmount properly release all resources?
   - If Chrome MCP is available: read console for errors after the page loads
   - Report any runtime concerns found (even if build passes)
4. If verification fails: read error, fix, re-run (up to 3 self-attempts)
5. Return PASS only if BOTH static AND runtime verification pass
6. Return FAIL with exact error output if stuck after 3 attempts
7. NEVER modify files listed in CONSTRAINTS
```

**CRITICAL**: `typecheck + build = PASS` is NOT sufficient to claim verification passes. Runtime bugs (state races, disposed references, interaction flow breaks) are invisible to the compiler. The runtime reasoning step (rule 3) is MANDATORY.

### Phase Combination Strategy

Each phase = 1 implementation-specialist agent (code + tests + verification) → 1 TOUCHBACK → next phase.

````

---

## Autonomous Execution Model

This workflow is fully autonomous end-to-end. The orchestrator launches, executes, validates, self-heals, and produces a final working product without user intervention until the final visual sign-off phase. The user's only touchpoint is the final visual validation checklist.

### Self-Healing Verification Loop (Every Phase)

Every phase runs through this exact autonomous loop:

```
Implementation Agent completes code + tests
        ↓
┌─── VERIFICATION CASCADE ────────────────────────────────┐
│                                                          │
│  Tier 1: Build Gate                                      │
│  Run: npm run typecheck && npm run build                 │
│  ├── PASS → proceed to Tier 2                            │
│  └── FAIL → DIAGNOSE-FIX-RETRY (see below)              │
│                                                          │
│  Tier 2: Test Gate (cumulative)                          │
│  Run: unit + integration tests for this phase + all      │
│       prior phases                                       │
│  ├── PASS → proceed to Tier 3                            │
│  └── FAIL → DIAGNOSE-FIX-RETRY (see below)              │
│                                                          │
│  Tier 3: Integration Gate (cumulative)                   │
│  Run: existing E2E suite (regression check)              │
│  ├── PASS → proceed to phase-specific checks             │
│  └── FAIL → DIAGNOSE-FIX-RETRY (see below)              │
│                                                          │
│  Phase-specific checks                                   │
│  Run: grep/file existence checks per phase               │
│  ├── PASS → TOUCHBACK checkpoint                         │
│  └── FAIL → DIAGNOSE-FIX-RETRY (see below)              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### DIAGNOSE-FIX-RETRY Escalation (3 Attempts)

```
Attempt 1: INLINE FIX
├── Read the exact error output (stderr, test failure message, type error)
├── Identify root cause from error context
├── Apply targeted fix (minimal change to resolve the specific error)
├── Re-run the FULL verification cascade from Tier 1
└── If ALL tiers pass → continue to TOUCHBACK

Attempt 2: DEBUG AGENT
├── Launch implementation-specialist with error context:
│   - Full error output from failed tier
│   - File(s) that caused the failure
│   - What was attempted in Attempt 1
│   - Constraint: fix must not break prior phases
├── Agent reads error, applies fix, runs verification
└── If ALL tiers pass → continue to TOUCHBACK

Attempt 3: EXPANDED DEBUG AGENT
├── Launch implementation-specialist with broader context:
│   - All error outputs from Attempts 1-2
│   - Full phase specification from the plan
│   - Related source/reference files
│   - Permission to refactor approach if needed
├── Agent applies fix, runs verification
└── If ALL tiers pass → continue to TOUCHBACK

HALT (after 3 failed attempts):
├── Document blocker in progress.md with:
│   - All 3 error outputs
│   - What was attempted
│   - Hypothesis for root cause
│   - Suggested next steps
├── Mark phase task as BLOCKED
└── Present blocker summary to user for guidance
```

**Key principle**: The orchestrator exhausts 3 fix attempts autonomously before ever involving the user. Most issues (type errors, import paths, test assertion mismatches) resolve on Attempt 1.

### Constraint Validation (Every Phase)

After EVERY successful verification cascade, before TOUCHBACK:

```bash
# Verify MUST NOT TOUCH files are unchanged
git diff --name-only | grep -E "(ConstrainedFile1|ConstrainedFile2)" && echo "CONSTRAINT VIOLATION" && exit 1
```

Adapt the grep pattern to the plan's specific CONSTRAINTS list. If constraint violation detected:
1. Revert the phase changes
2. Re-launch implementation agent with explicit constraint reminder
3. Count as one retry attempt

### Implementation Agent Autonomous Footer

Every implementation agent receives this footer appended to its prompt:

```
AUTONOMOUS EXECUTION RULES:
1. Write ALL code AND tests in a single run
2. Run verification YOURSELF before returning:
   - npm run typecheck (must exit 0)
   - npm run build (must exit 0)
   - [project-specific test command] (all tests must pass)
3. If verification fails: read error, fix, re-run (up to 3 self-attempts)
4. Return PASS only if ALL verification passes
5. Return FAIL with exact error output if stuck after 3 attempts
6. NEVER modify files listed in CONSTRAINTS
```

Adapt verification commands to the project's tooling. The structure (write code + tests → self-verify → self-heal) is fixed; the commands are project-specific.

### Phase Combination Strategy

To maximize efficiency, implementation + tests for each phase are combined into a single agent run. The agent writes both the source file(s) and the corresponding test cases, then runs the full verification cascade before returning. This eliminates round-trip overhead between separate "implement" and "test" agents.

```
Per phase: 1 implementation-specialist agent (code + tests + verification)
         → 1 orchestrator TOUCHBACK (progress.md update)
         → next phase
```

### Scaling Guide Integration

| Section | Small (3-5 steps) | Medium (5-15) | Large (15-50) | Mega (50+) |
|---|---|---|---|---|
| Autonomous Execution | N/A (direct) | Self-healing loop | Full loop + debug agents | Full loop + debug agents + expanded context |
| Constraint Validation | Inline check | Automated grep | Automated grep + revert | Automated grep + revert + constraint agent |
| Phase Combination | Single run | Combined (code+tests) | Combined (code+tests) | Combined (code+tests) per sub-phase |

---

## Scaling Guide

Sections marked "Required" may be marked N/A with justification based on task TYPE (not just complexity). E.g., a Large backend-only task may skip E2E-specific sections. The guide sets defaults; the planner may deviate with documented reasoning.

| Section | Small (3-5 steps) | Medium (5-15) | Large (15-50) | Mega (50+) |
|---|---|---|---|---|
| 0. Intent | 1-2 sentences | Paragraph | Full section | Full section + project intent doc reference |
| 1. Context | 1-2 sentences | Paragraph | Full with stats | Full with stats |
| 2. Options Considered | Skip | Brief | Full table | Full table |
| 3. Worktree Setup | Skip | Optional | Required | Required |
| 4. Constraints | Inline | Short list | Full table | Full table |
| 5. Current Inventory | Inline | Structured | Full tables | Full tables + line refs |
| 6a. Per-phase file tables | Inline | Structured | Full tables | Full tables + line refs |
| 6b. Implementation specification | Skip | Brief for HIGH-risk only | All MEDIUM+ risk phases | All phases |
| 6c. Agent prompt requirements | Skip | Brief | Risk-level table per phase | Risk-level table + full spec inline |
| 6d. Phase-specific verification | Build gate only | Three-tier | Three-tier + grep + constraint check + common failures | Three-tier + grep + constraint + common failures + independent verify agent |
| 6e. Per-tier failure modes | Skip | Skip | Listed per tier per phase | Listed per tier per phase |
| 7. Test Inventory | Skip | Brief | Full table | Full table |
| 8. Task List | 3-5 items inline | Triplet pattern (Phase/VERIFY/TOUCH) | Full T0-TN with dep graph + execution model | Full with dep graph + parallel batch analysis |
| 9. Agent Architecture | Skip | Brief (orchestration level + return format) | Full autonomous pipeline + TOUCHBACK + session recovery + context budget | Full + multi-session recovery plan |
| 10. Final Validation | Skip | Manual checklist | Automated (all gates) + Visual (user sign-off) + failure recovery | Automated + Visual + failure recovery + regression suite |
| 11. Edge Cases table | Skip | Brief notes | Full table with phase mapping | Full table with phase mapping + mitigations |
| 12. Execution Order table | Skip | Phase list | Full with estimates | Full with parallel batches |
| 13. Key References | Inline | Brief | Full table | Full table |
| 14. Exploration Findings | Skip | Brief | Full section | Full section |
| 15. Plan File Location | N/A | Standard | Standard | Standard + multi-session plan |
| 16. Autonomous Execution | N/A (direct) | Self-healing loop | Full loop + debug agents | Full loop + debug agents + expanded context |

---

## Plan Self-Validation Checklist (MANDATORY)

Run this checklist BEFORE presenting the plan. For Medium tasks, self-validation is sufficient. For Large+ tasks, ALSO launch an independent validation agent that did NOT write the plan.

```
Before presenting plan, verify ALL applicable items:
- [ ] Section 0 (Intent) populated with user's own words (not paraphrased generically)
- [ ] Intent reflected in agent prompt templates (INTENT CONTEXT block populated)
- [ ] Context section explains WHY (not just what)
- [ ] Scope boundaries explicit (what's IN and OUT)
- [ ] Every phase has three-tier verification gates with exact commands
- [ ] Task list follows Phase/VERIFY/TOUCHBACK triplet pattern for each code phase
- [ ] Task list includes T0 (setup), smoke test, visual validation, and USER GATE tasks
- [ ] Task dependencies are set (addBlockedBy) -- strictly sequential chain
- [ ] Each 🔒 VERIFY task annotated with DIAGNOSE-FIX-RETRY
- [ ] Constraints (MUST NOT TOUCH) documented if applicable
- [ ] Agent assignment per phase specified (for Large+)
- [ ] Agent return format includes per-tier PASS/FAIL + self-fix attempts count (for Large+)
- [ ] Session recovery protocol included with exact progress file path (for Large+)
- [ ] TOUCHBACK protocol specifies all 7 checkpoint fields (for Large+)
- [ ] Orchestrator context budget documented (summaries only, no full file reads)
- [ ] End-to-end autonomous pipeline diagram included (for Large+)
- [ ] Final validation split into Automated + Visual sections with failure recovery
- [ ] Phase-specific verification checks (grep patterns, file existence) included
- [ ] Test inventory table with cumulative totals included
- [ ] No open questions remain (all resolved during planning)
- [ ] Worktree setup specified if multi-file changes
- [ ] Edge cases identified and mitigated
- [ ] File paths are specific (file:line, not just "update X")
- [ ] Plan file location follows standard (not thoughts/shared/plans/)
- [ ] Autonomous execution model section included with project-specific commands (for Large+)
- [ ] Implementation agent footer specifies exact verification commands
- [ ] Constraint validation grep pattern matches CONSTRAINTS table entries
```

---

## Trimming Policy: Inline for Agents, Reference for Orchestrator

Rules files may use references to canonical sources (the ORCHESTRATOR has all rules loaded). When constructing SUB-AGENT prompts, the orchestrator MUST inline relevant definitions -- do NOT pass file references and expect sub-agents to self-serve.

For Three-Tier Verification, the agent-ready inline version is:
> "Run [typecheck + build] (Tier 1) -> [unit tests] (Tier 2) -> [E2E tests] (Tier 3). All three must pass. If any fails, fix and retry up to 3 times."

---

## Relationship to Other Standards

### Relationship to /create_plan_generic

This standard applies regardless of how plan creation is triggered:
- **Autonomous**: Keyword detection -> EnterPlanMode -> this standard
- **Manual**: User invokes `/create_plan_generic` -> that command references this standard

Both paths produce plans that comply with this standard at the appropriate scale.

### Relationship to Worktree Implementation Workflow

For tasks requiring worktree isolation (Medium+ multi-file changes), the plan template includes worktree setup (Section 3) and constraints (Section 4). The detailed worktree execution patterns are in `worktree-implementation-workflow.md`.

### Relationship to Sub-Agent Orchestration

The plan template's Agent Architecture section (Section 9) and Task List (Section 8) implement the patterns from `sub-agent-orchestration.md`. Three-tier verification gates implement the acceptance criteria model defined there.

### Hook Synchronization Note

The UserPromptSubmit hook performs initial scope assessment. This standard refines that assessment. The hook's implementation keyword list should match this standard's keyword list.
