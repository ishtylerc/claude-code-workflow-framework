---
allowed-tools: Task, Read, Write, Edit, MultiEdit, Glob, Grep, Bash, TodoWrite, AskUserQuestion
description: Execute an implementation plan with code+test increments, three-tier verification, cumulative regression, and independent verification sub-agents at every phase boundary
argument-hint: <plan-path> [--phase=N] [--continue] [--verify-only] [--fast-verify] [--skip-verify]
---

# /implement — Orchestrated Implementation Execution

## Purpose

Execute a `/plan` artifact with:

- **Small code+test increments** (write unit → test unit → verify → repeat)
- **Three-tier cumulative verification** (Build Gate → Test Gate → Integration Gate) at every phase boundary
- **Independent verification sub-agents** at per-task, per-phase, and pre-commit granularities — preventing "graded your own homework" failures
- **Optional Codex Criterion Gate** (LOCKED AC) when the plan includes §7.5 from `test-criteria-codex`
- **Mismatch protocol** for ambiguous test failures (stash-revert disambiguation)
- **Regression mismatch protocol** for previously-passing tests that now fail
- **Progress file** with checkpoints for session recovery

This is the **rigorous** counterpart to `commands/implementation/implement_plan.md` — use that for quick informal implementation, use this when the plan came from `/plan` or when failures-on-first-attempt are unacceptable.

---

## 🚨 INDEPENDENT VERIFICATION IS MANDATORY 🚨

**You MUST invoke the `Task` tool with `subagent_type='verification'` at every phase boundary** (per-task by default; per-phase always; pre-commit always). A separate sub-agent re-runs the tests/builds/checks against the worktree and produces a CLAIMED-vs-ACTUAL report.

**Inline self-verification does NOT satisfy this requirement.** If you run `npx vitest run`, `npm test`, `npm run build`, or any other check in your OWN Bash tool and read the output yourself, that is **self-grading** — the exact failure mode this whole verification system exists to prevent. The output you saw may be accurate, but the report cannot be trusted because the agent that wrote the code is also the agent claiming it passed.

**Symptoms of the anti-pattern to watch for in yourself**:
- You wrote a test file and ran the test inline and saw all green
- You report "X/Y tests passing" based on what your own Bash output showed
- You completed a phase without seeing the literal string `INDEPENDENT VERIFICATION RESULTS` (or equivalent) in a sub-agent's return message
- You think "I just ran the tests; that's the verification"

**The correct pattern**:
1. Implementation agent does code + tests + inline check (allowed — for your own feedback loop)
2. Implementation agent invokes `Task(subagent_type='verification', prompt='...')` with claimed results
3. Sub-agent re-runs everything in isolation and returns CLAIMED-vs-ACTUAL report
4. ONLY when sub-agent returns VERIFIED ✅ can the phase advance

See "Independent Verification Sub-Agent" section below for the full protocol. If you find yourself rationalizing why you can skip the sub-agent "this once" — STOP. That rationalization IS the anti-pattern.

---

## Configuration

Reads `.claude/workflow-config.json`. Used here:

- `project_root`
- `implementation_output_dir` (default: `thoughts/implementation`)
- `test_commands`:
  - `typecheck` → Tier 1
  - `lint` → Tier 1
  - `build` → Tier 1
  - `test_unit` → Tier 2 (cumulative unit tests)
  - `test_e2e` → Tier 3 (cumulative E2E)
  - `test_full` → pre-commit gate

If `.claude/workflow-config.json` is absent: defaults to `npm` script names.

---

## Strategy: code+test increments + cumulative regression

```
FOR each phase in plan:
    FOR each task in phase:
        1. Write code (small unit)
        2. Write unit test for that unit
        3. Run NEW unit test only (fast feedback)
        4. If FAIL → fix and retry (up to 3 attempts)
        5. If PASS → independent per-task verification (unless --fast-verify)
        6. Continue to next task

    ═══════════════════════════════════════════════
    PHASE COMPLETE: CUMULATIVE REGRESSION + GATES
    ═══════════════════════════════════════════════
    a. Tier 1 (Build Gate): typecheck + lint + build
    b. Tier 2 (Test Gate, cumulative): ALL unit tests (this phase + prior + pre-existing)
    c. Tier 3 (Integration Gate, cumulative): ALL E2E tests
    d. If REGRESSION → Regression Mismatch Protocol
    e. INDEPENDENT VERIFICATION sub-agent (BLOCKING)
    f. Codex Criterion Gate (if §7.5 present in plan, BLOCKING)
    g. Update progress.md (TOUCHBACK)
    h. Continue to next phase

PRE-COMMIT GATE (after final phase):
    - Full regression: typecheck + lint + build + test_full + test_e2e_full
    - INDEPENDENT VERIFICATION sub-agent (BLOCKING)
    - All must pass before completion
```

**CRITICAL**: Do NOT write all code then all tests. Write code → test → verify → repeat.

---

## Regression Testing Tiers

| Trigger | What Runs | Time Budget |
|---------|-----------|-------------|
| Per-task | New unit test only | < 10 seconds |
| Per-phase | ALL unit tests + E2E (cumulative) | < 5 minutes |
| Pre-commit | Full suite (unit + E2E full + build) | < 10 minutes |

**Cumulative Regression Principle**: Every phase completion runs ALL previous tests to ensure no existing functionality breaks.

---

## Independent Verification Sub-Agent

### When triggered (MANDATORY — verification ALWAYS fires)

- ✅ After EVERY individual task completion (default per-task granularity)
- ✅ After each phase's cumulative regression (per-phase granularity — BLOCKING gate)
- ✅ After the pre-commit gate (final verification before completion)

Verification is **NEVER optional**. The only flag that affects this is granularity, not whether verification runs.

### Granularity Modes

| Mode | Per-task | Per-phase | Pre-commit | When to use |
|------|----------|-----------|------------|-------------|
| **Default** (no flag) | ✅ MANDATORY | ✅ MANDATORY | ✅ MANDATORY | Production work — maximum paranoia |
| `--fast-verify` | ⏭️ Skip | ✅ MANDATORY | ✅ MANDATORY | Time-pressured work. Phase + pre-commit gates still run. |
| `--skip-verify` | ⏭️ Skip | ⏭️ Skip | ⏭️ Skip | DEBUGGING VERIFICATION ITSELF ONLY. NEVER use for production work. Requires user confirmation via AskUserQuestion before honoring. |

**Default behavior assumption**: if NO flag is passed, full default verification applies. Do NOT treat the absence of a flag as license to skip — treat it as "user opted into maximum verification."

### Verification Agent Characteristics

- **Read-only**: No write permissions to code files
- **Independent**: Fresh context, no knowledge of implementation agent's claims
- **Objective**: Parses actual command output, not self-reported results

### Detection: How to Know You Actually Verified

Before marking ANY task or phase complete, check internally:

- [ ] Did I invoke the `Task` tool with `subagent_type='verification'` since the work began?
- [ ] Did the sub-agent return a report containing `INDEPENDENT VERIFICATION RESULTS` (or similar marker)?
- [ ] Did the sub-agent's report contain a CLAIMED vs ACTUAL comparison table?
- [ ] Did the sub-agent report VERIFIED ✅ (not MISMATCH or ERROR)?

If ANY of the above is "no" — verification did NOT happen. Self-correction: invoke the sub-agent now, before advancing.

### Verification Sub-Agent Prompt Template

```
You are a VERIFICATION AGENT for this implementation.

YOUR TASK: Independently verify test results claimed by the implementation agent.

CONSTRAINTS:
- You have READ-ONLY access (Bash, Read, Grep, Glob only)
- Do NOT modify any files
- Do NOT trust any claimed results — verify everything yourself

CLAIMED RESULTS:
[Insert implementation agent's claimed results here]

VERIFICATION STEPS:
1. cd to the project root: [PROJECT_ROOT]
2. Run: [test_commands.test_unit] 2>&1 | tee /tmp/verification-test-output.log
3. Run: [test_commands.typecheck] 2>&1 | tee /tmp/verification-typecheck-output.log
4. Run: [test_commands.lint] 2>&1 | tee /tmp/verification-lint-output.log
5. (Per-phase only) Run: [test_commands.test_e2e] 2>&1 | tee /tmp/verification-e2e-output.log
6. Parse actual pass/fail counts from output
7. Compare to claimed results

OUTPUT FORMAT:
╔══════════════════════════════════════════════════════════════╗
║  INDEPENDENT VERIFICATION RESULTS                            ║
╠══════════════════════════════════════════════════════════════╣
║  CLAIMED                 │  ACTUAL                │ STATUS   ║
║──────────────────────────┼─────────────────────────┼──────────║
║  Unit Tests: [X/Y]       │  Unit Tests: [A/B]      │ [✅/❌]  ║
║  TypeCheck: [status]     │  TypeCheck: [status]    │ [✅/❌]  ║
║  Lint: [status]          │  Lint: [status]         │ [✅/❌]  ║
║  E2E Tests: [X/Y]        │  E2E Tests: [A/B]       │ [✅/❌]  ║
╠══════════════════════════════════════════════════════════════╣
║  OVERALL: [VERIFIED ✅ | MISMATCH DETECTED ❌]               ║
╚══════════════════════════════════════════════════════════════╝

If MISMATCH detected, list specific discrepancies.
```

---

## Step-by-step Instructions

### 1. Parse arguments

```
/implement <plan-path> [--phase=N] [--continue] [--verify-only] [--fast-verify] [--skip-verify]
```

- Required: path to implementation plan
- `--phase=N`: Start from specific phase
- `--continue`: Resume from last checkpoint in progress.md
- `--verify-only`: Run verification only, no code changes
- `--fast-verify`: Downgrade per-task verification (phase + pre-commit still MANDATORY)
- `--skip-verify`: Skip ALL independent verification (DEBUGGING ONLY — requires AskUserQuestion confirm)

**DEFAULT BEHAVIOR (no flag)**: Independent verification is **MANDATORY at all three tiers**. Inline self-verification by the implementation agent does NOT satisfy the requirement — a fresh `Task` sub-agent MUST run and return VERIFIED ✅ before any task or phase advances.

### 2. Read implementation plan (MANDATORY)

Read the entire plan. Note:
- Feature being implemented
- Phase breakdown and dependencies
- Files to create/modify per phase
- Code scaffolds provided
- Success criteria per phase (three-tier gates)
- Testing requirements
- §7 Test Inventory (existing + new per phase + regression risk prediction)
- §7.5 Codex-Authored Test Criteria — note the path to `test-criteria.md` in the plan directory (if §7.5 exists)

### 2.5 Load Codex-Authored Test Criteria (if §7.5 present)

If the plan has §7.5 and references `test-criteria.md`:

1. Read `<plan-directory>/test-criteria.md` ONCE at startup
2. Parse YAML frontmatter (`generated_at`, `total_criteria`, `coverage_pct`)
3. Parse all `### CRIT-NNN:` blocks
4. Cache parsed criteria for use in Step 4c (per-phase criterion-verification gate)

**If §7.5 marker is `codex-coverage:unavailable`**: Operate WITHOUT the criterion gate; log warning at every phase completion: "⚠️ Plan was approved without Codex criteria gate (reason: <documented reason>); per-phase criterion verification is SKIPPED."

**If §7.5 missing entirely AND no `test-criteria.md` exists**: ABORT with error suggesting user re-run `/plan` to generate criteria, OR confirm via AskUserQuestion that they want to proceed without the criterion gate.

**On `--continue`**: RE-READ `test-criteria.md` fresh (user may have manually edited it between sessions to add `REMOVED-BY-USER` markers).

### 3. Check for progress file (if `--continue`)

Look for: `<implementation_output_dir>/<feature>/progress.md`

If exists and `--continue` flag: read last checkpoint, resume from that point.

### 4. Create implementation directory

```bash
mkdir -p "<implementation_output_dir>/<feature>/test-results"
mkdir -p "<implementation_output_dir>/<feature>/screenshots"
```

### 5. Initialize progress.md

```markdown
# [Feature] Implementation Progress

## Status: In Progress
## Started: <timestamp>

## Plan Reference
- `<path-to-plan>`

## Phases
| Phase | Status | Started | Completed | Notes |
|-------|--------|---------|-----------|-------|
| 1 | Pending | - | - | |
| 2 | Pending | - | - | |

## Current Checkpoint
- Phase: 1
- Task: 1
- Last Action: Initialized

## Test Results
- Unit Tests: 0/0 passing
- E2E Tests: N/A

## Pre-Existing Failures (from stash-revert)
- (none yet)

## Session Log
- [<timestamp>] - Implementation started
```

### 6. Initialize TaskCreate

```
- Phase 1: [Phase name] (in_progress)
  - Task 1.1: [Description] (pending)
  - Task 1.2: [Description] (pending)
  - 🔒 VERIFY: Phase 1 cumulative regression + independent verification (pending)
  - 🔒 Codex Criteria Gate: Phase 1 (pending — skip if no §7.5)
  - 📍 TOUCHBACK: Update progress.md after Phase 1 (pending)
- Phase 2: [Phase name] (pending)
  ...
- Pre-commit gate: full regression suite + independent verification (pending)
- Final: implementation-complete report (pending)
```

The `🔒 Codex Criteria Gate` task is BLOCKING — stays `pending` until Step 4c passes for that phase. If §7.5 marked `codex-coverage:unavailable`, the gate task is created but resolved immediately with "skipped: codex-coverage:unavailable".

---

## Phase Execution Loop

### Step 1: Display phase start

```
╔══════════════════════════════════════════════════════════════╗
║  PHASE [N]: [Phase Name]                                     ║
╠══════════════════════════════════════════════════════════════╣
║  Objective: [From plan]                                      ║
║  Tasks: [X]                                                  ║
║  Files to Create: [X]                                        ║
║  Files to Modify: [X]                                        ║
╚══════════════════════════════════════════════════════════════╝
```

### Step 2: Read relevant context

Before writing code:
- Re-read this phase's section of the plan
- Read any project-specific convention files referenced
- Read relevant `gotchas.md` / `known-failures.md` entries that intersect this phase's blast radius

### Step 3: Execute tasks (code + test loop)

For each task in the phase:

#### 3a. Write code (small unit)

- Use code scaffold from plan as starting point
- Write ONE logical unit (function, class, module)
- Follow project conventions

#### 3b. Write unit test

Use the project's existing test framework and patterns. The plan's §7.4 should specify the framework (e.g., vitest, jest, pytest, go test, cargo test). Generic structure:

```
[Setup]
[Act on the unit under test]
[Assert expected behavior]
```

#### 3c. Run verification (inline — for own feedback loop only)

```bash
cd <project_root>
<test_commands.typecheck>
<test_commands.lint>
<test_commands.test_unit> -- --grep "[feature]"   # adapt to test runner
```

#### 3d. Handle results

**PASS**: Continue to 3e (per-task independent verification).
**FAIL**: Apply fix, retry (up to 3 attempts). If still failing after 3, trigger Mismatch Protocol.

#### 3e. Per-task independent verification (MANDATORY — skip only with `--fast-verify`)

Launch verification sub-agent for THIS task via the `Task` tool:

```
Use the Task tool with subagent_type='verification':

Prompt:
"""
TASK VERIFICATION - Task [N.M]

You are verifying the implementation agent's claimed test result for a SINGLE task.

CLAIMED RESULT:
- Task: [N.M] - [Description]
- Status: PASS
- Test: [test pattern]

YOUR TASK:
1. cd to project root: [PROJECT_ROOT]
2. Run the specific test: <test_commands.test_unit> -- --grep "[pattern]"
3. Run typecheck: <test_commands.typecheck>
4. Parse ACTUAL result from output
5. Compare to claimed PASS

REPORT:
┌─────────────────────────────────────────────────────┐
│  TASK VERIFICATION - [N.M]                          │
├─────────────────────────────────────────────────────┤
│  Claimed: PASS                                      │
│  Actual:  [PASS | FAIL]                             │
│  Status:  [VERIFIED ✅ | MISMATCH ❌]               │
└─────────────────────────────────────────────────────┘
"""
```

**Handle per-task verification result**:
- **VERIFIED ✅**: Update TaskList, continue to next task
- **MISMATCH ❌**: Treat as FAIL, apply fix and retry (do NOT proceed to next task)

If `--fast-verify` was set, skip this step — phase-level verification (Step 4) still runs and is BLOCKING.

### Step 4: Phase-level verification (CUMULATIVE REGRESSION)

After all tasks in a phase complete, run cumulative regression:

```bash
cd <project_root>

# 1. TypeScript / typecheck
<test_commands.typecheck>

# 2. Lint
<test_commands.lint>

# 3. Build
<test_commands.build>

# 4. ALL unit tests (cumulative — includes prior phases + pre-existing)
<test_commands.test_unit>

# 5. E2E tests (cumulative)
<test_commands.test_e2e>
```

Display self-reported results.

**If ANY test fails that was passing before this phase** → trigger Regression Mismatch Protocol.

### Step 4b: Independent verification (MANDATORY — BLOCKING)

Launch verification sub-agent via `Task` tool. This is BLOCKING — phase cannot advance without VERIFIED ✅.

If `--skip-verify` is set: AskUserQuestion confirming user accepts the self-grading risk. Honor only on explicit confirmation.

(Use the verification sub-agent prompt template above.)

**Handle phase verification result**:
- **VERIFIED ✅**: Continue to Step 4c
- **MISMATCH ❌**: Use AskUserQuestion to choose:
  - A) Re-run tests and update reported results
  - B) Investigate discrepancy (may indicate flakiness)
  - C) Abort and escalate to user

### Step 4c: Codex Criterion Verification (MANDATORY IF §7.5 PRESENT — LOCKED AC GATE)

**Purpose**: Verify every Codex-authored test criterion assigned to this phase has been satisfied. This gate enforces the AUTHORITATIVE + LOCKED contract from `test-criteria.md`. Runs AFTER the cumulative regression gate passes — the regression gate proves "existing tests still pass"; this gate proves "new tests required by the contract were actually written".

**Skip condition**: If §7.5 marked `codex-coverage:unavailable`, SKIP with one-line warning: "⚠️ Skipping Codex criterion gate: codex-coverage:unavailable (reason: <documented reason>)".

**Standard execution**:

1. From cached criteria (Step 2.5), filter to entries where `plan_phase == <current phase>` AND `status != REMOVED-BY-USER`.

2. For each filtered criterion, perform 3 mechanical checks:

   **Check 1: target_file_path exists**
   ```bash
   test -f "<PROJECT_ROOT>/<criterion.target_file_path>"
   ```

   **Check 2: suggested_test_name appears in the file**
   ```bash
   grep -i -F "<criterion.suggested_test_name>" "<PROJECT_ROOT>/<criterion.target_file_path>"
   ```
   (Case-insensitive substring match.)

   **Check 3: assertion_text key terms appear in the test body** (heuristic — flag-only)
   - Extract 3–5 distinguishing nouns/verbs from `criterion.assertion_text`
   - For each term, grep for it in the file body
   - Tally how many appear

3. Categorize each criterion:
   - **SATISFIED**: Check 1 ✅ + Check 2 ✅ + ≥ 50% of key terms appear
   - **PARTIAL**: Check 1 ✅ + Check 2 ✅ + < 50% of key terms appear (suspicious — may be placeholder test that doesn't actually assert what's required)
   - **MISSING**: Check 1 ❌ OR Check 2 ❌

4. Display verification block:
```
╔══════════════════════════════════════════════════════════════╗
║  CODEX CRITERIA VERIFICATION - Phase [N]                     ║
╠══════════════════════════════════════════════════════════════╣
║  Criteria for this phase: [total]                            ║
║  Satisfied:    [X]                                           ║
║  Partial:      [Y]  (review recommended)                     ║
║  Missing:      [Z]  (HARD FAIL if > 0)                       ║
╠══════════════════════════════════════════════════════════════╣
║  Source: <plan-directory>/test-criteria.md                   ║
║  Codex authority: AUTHORITATIVE + LOCKED                     ║
╚══════════════════════════════════════════════════════════════╝
```

**Handle results**:

- **SATISFIED == total** (Missing = 0, Partial = 0): ✅ Proceed to Step 5
- **PARTIAL > 0 AND MISSING == 0**: ⚠️ Display partials in detail; AskUserQuestion:
  - A) Confirm test genuinely covers assertion (proceed — record "User-confirmed partial: CRIT-NNN" in progress.md)
  - B) Return to task loop and add missing assertion logic
  - C) Mark CRIT-NNN as `REMOVED-BY-USER` in `test-criteria.md` (user manually edits; commit diff IS audit trail)
- **MISSING > 0** (HARD FAIL): Phase BLOCKED. AskUserQuestion:
  - A) Return to task loop and add missing test(s) (RECOMMENDED)
  - B) Mark specific criteria as `REMOVED-BY-USER` (user takes responsibility)
  - C) Halt implementation and re-plan

**Critical constraint**: Claude MUST NOT modify `test-criteria.md` programmatically. Only legitimate writes are user manual edits.

### Step 5: Convention enforcement

Before marking phase complete, verify project conventions hold (per plan's §7 or project's `conventions.md`).

### Step 6: Update progress.md (TOUCHBACK)

1. READ progress.md (refresh full state)
2. UPDATE with checkpoint:
   - Timestamp
   - Phase completed
   - Artifacts created
   - Verification results (all 3 tiers + Codex criterion if applicable)
   - Self-fix attempts count
   - Pre-existing failures encountered (with stash-revert results)
   - Next phase
   - Recovery action (exact steps to resume from this point)
3. Mark TOUCHBACK task complete
4. Immediately launch next phase (no pause)

### Step 7: Update plan checkboxes

Edit the plan to mark completed tasks: `- [ ]` → `- [x]`.

---

## Mismatch Handling Protocol

When verification fails after 3 fix attempts on a single task:

Use AskUserQuestion with options:
- A) Continue fixing (3 more attempts)
- B) Update plan to reflect reality
- C) Skip this criterion (requires justification documented in progress.md)
- D) Abort implementation (preserves state)

---

## Regression Mismatch Protocol (CRITICAL)

When a **previously passing test** fails during cumulative regression:

**Step 1: Stash-revert disambiguation** (MANDATORY before assuming regression):

```bash
git stash push -u -m "ambiguous-failure-investigation"
<re-run the failing test against unchanged codebase>
# Still fails → PRE-EXISTING; document in progress.md "Pre-Existing Failures" section; proceed
# Passes now → REGRESSION; fix before unstashing
git stash pop

# Verify pop actually restored tracked-modified files (silent pop failure mode):
grep -c "<known-string-from-your-edits>" <expected-modified-file>
# Expected: ≥1. If 0 → silent pop failure; recover via git stash apply stash@{0}
```

**Step 2: Categorize pre-existing failures** (document in progress.md):

| Category | Example | Handle |
|----------|---------|--------|
| Flaky perf test | Thresholds fail on slow CI | Note and proceed; suggest structural fix (NOT threshold raising) |
| Scene/config drift | Test assumes defaults that changed | Note and proceed; recommend fixing the spec in follow-up |
| Dead test | Test for removed feature | Note and proceed; recommend deleting the spec |
| Env-dependent | Needs manual dev server, specific viewport | Note and proceed; run out-of-band if critical |
| Parallel-worker flake | Passes in isolation, fails under N-worker load | Run spec 3× in `--workers=1` isolation; if 3/3 PASS → confirmed pre-existing flake |

**Step 3: If REGRESSION** (your change caused it), use AskUserQuestion:
- A) Fix new code to preserve existing behavior — new code is wrong, existing behavior correct
- B) Update existing test (behavior change accepted) — document in progress.md "BREAKING CHANGE: <test> updated because <reason>"
- C) Fix existing feature bug exposed by new code — new code revealed a latent bug; fix the existing code, add regression test for the bug
- D) Abort task and escalate to /debug — issue too complex, needs dedicated debugging session

---

## Pre-Commit Gate (final phase)

After all phases complete:

```bash
cd <project_root>

# Build gates
<test_commands.typecheck>
<test_commands.lint>
<test_commands.build>

# Cumulative tests — full suite
<test_commands.test_full>
<test_commands.test_e2e_full>   # includes nightly if separate

# Constraint check (if plan has §4 CONSTRAINTS)
git diff --name-only main | grep -E "<constraint-pattern-from-plan-§4>" && echo "CONSTRAINT VIOLATION" && exit 1
```

Launch FINAL independent verification sub-agent (BLOCKING). Pre-commit cannot complete without VERIFIED ✅.

---

## Visual Validation (if applicable)

If the plan has visual phases, after pre-commit gate:

1. Start dev server (`npm run dev` or equivalent from workflow-config.json)
2. Use Playwright MCP (or equivalent) to capture screenshots per the plan's visual checklist
3. Present visual checklist results to user for sign-off (the ONLY required user touchpoint after `/implement` begins)

---

## Final: Complete Implementation

After visual sign-off (or skip if no visual phases):

1. Update progress.md status to `COMPLETED`
2. Print summary: phases completed, tests passing, pre-existing failures documented, Codex criteria satisfied
3. Print path to plan with all checkboxes marked
4. Suggest next steps: commit, PR, deploy

**Do NOT auto-commit unless explicitly requested.** Per CLAUDE.md / common practice, NEVER push without user approval.

---

## Error Handling

- Plan path doesn't exist → ask for correct path
- Plan is incomplete (missing required sections) → halt with specific gap report
- Agent hits token limits → spawn continuation agents
- Mismatch unresolvable → save state to progress.md, exit
- Regression unresolvable → option D (escalate to /debug)
- Codex criterion gate fails → BLOCKING; cannot advance

---

## Expected Output

1. TaskCreate tracking all phases + VERIFY + TOUCHBACK + Codex gates
2. progress.md at `<implementation_output_dir>/<feature>/progress.md`
3. Per-phase three-tier verification results documented
4. Per-phase Codex criterion verification (if §7.5 present)
5. Pre-existing failures documented with stash-revert evidence
6. Final pre-commit gate with independent verification
7. Visual sign-off (if applicable)
8. progress.md marked COMPLETED
9. Summary report printed

---

## Companion Commands

- **`/research <feature>`** — produce research artifact
- **`/plan <research-path>`** — produce implementation plan this command consumes
