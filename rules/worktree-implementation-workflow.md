# Worktree-Based Implementation Workflow

**Purpose**: Standardized pattern for autonomous, phase-gated implementation workflows using git worktrees for isolation, progress tracking for recovery, and E2E test gates for validation.

## When to Use This Pattern

| Scenario | Use Worktree Pattern? | Why |
|----------|----------------------|-----|
| Feature integration from another branch/worktree | ✅ YES | Source → Target isolation prevents contamination |
| Multi-file refactoring with risk | ✅ YES | Worktree allows easy rollback |
| Autonomous implementation (minimal user involvement) | ✅ YES | Checkpoints enable recovery |
| Complex migration with multiple phases | ✅ YES | Phase gates catch issues early |
| Simple single-file changes | ❌ NO | Overhead not justified |
| Exploratory/research work | ❌ NO | No code changes to isolate |

---

## Core Concepts

### 1. Worktree Isolation

Git worktrees provide complete isolation for feature work:

```
REPOSITORY/
├── .auto-claude/worktrees/tasks/
│   ├── source-worktree/          ← Where code exists (reference)
│   └── target-worktree/          ← Where work happens (implementation)
└── main/                         ← Primary codebase (untouched during work)
```

**Key Principle**: ALL changes happen in the target worktree. The source worktree is READ-ONLY reference.

### 2. Progress File as North Star

Every implementation has a `progress.md` file that serves as ground truth:

- **Location**: `thoughts/plans/YYYY-MM-DD-[slug]/progress.md`
- **Purpose**: Enables session recovery, tracks state, documents constraints
- **Updates**: After EVERY phase completion (via TOUCHBACK tasks)

### 3. Phase-Gated Implementation

Work is divided into sequential phases as designed during **Phase 1.5 (Plan Mode)**. Each phase has:
- **Inputs**: Files/paths to read or copy
- **Outputs**: Files to create or modify
- **Verification**: Three-tier verification gates (Build + Test + Integration) at every phase boundary
- **Constraint**: Phase N must pass all three tiers before Phase N+1 starts

---

## TaskCreate + TOUCHBACK Loop Pattern

**MANDATORY**: Every implementation phase gets a task, followed by a TOUCHBACK checkpoint task.

### Task Structure

```
# At workflow start, create ALL tasks
TaskCreate: "Phase 0: Worktree setup"
TaskCreate: "📍 TOUCHBACK: Update progress.md after Phase 0"
TaskCreate: "Phase 1: Port [component-type] (N files)"
TaskCreate: "📍 TOUCHBACK: Update progress.md after Phase 1"
TaskCreate: "Phase 2: Port [component-type] (N files)"
TaskCreate: "📍 TOUCHBACK: Update progress.md after Phase 2"
...
TaskCreate: "Phase N: Final validation + commit"
TaskCreate: "📍 TOUCHBACK: Update progress.md with completion"

# Set sequential dependencies
TaskUpdate: taskId="phase-1", addBlockedBy=["touchback-0"]
TaskUpdate: taskId="touchback-1", addBlockedBy=["phase-1"]
TaskUpdate: taskId="phase-2", addBlockedBy=["touchback-1"]
# ... etc
```

### TOUCHBACK Protocol

See `sub-agent-orchestration.md` → "Checkpoint Protocol" for the full TOUCHBACK protocol.

**Worktree-specific addition**: During TOUCHBACK, also verify:
- Working in TARGET worktree (not source)
- CONSTRAINTS files remain unchanged
- Source worktree state matches expectations

---

## Progress File Template

Create at workflow start: `thoughts/plans/YYYY-MM-DD-[slug]/progress.md`

```markdown
# [Feature Name] Progress

**Started**: YYYY-MM-DD HH:MM AM/PM
**Status**: IN_PROGRESS | COMPLETED | BLOCKED
**Target Worktree**: `[path-to-target-worktree]`

## CRITICAL: Worktree Context
- **Source**: `[path-to-source-worktree]` (READ-ONLY)
- **Target**: `[path-to-target-worktree]` (ALL CHANGES HERE)

## CONSTRAINTS
**MUST NOT TOUCH**: [List critical files/components that must remain unchanged]
- [file1.tsx] - [reason]
- [file2.tsx] - [reason]

## Current State
**Last Completed Phase**: Phase [N]
**Status**: [status]
**Blocking Issues**: [None | description]

---

## Checkpoints

### Checkpoint 0 - [timestamp]
**Phase Completed**: Phase 0: Worktree Setup
**Artifacts Created**:
- Target worktree at `[path]`
- Branch: `feature/[branch-name]`
- This progress file
**Verification**: Worktree created, branch checked out
**Next Phase**: Phase 1: [description]
**Recovery Action**: [What to do if session resumes here]

### Checkpoint 1 - [timestamp]
**Phase Completed**: Phase 1: [description]
**Artifacts Created**:
- `[file-path-1]`
- `[file-path-2]`
**Verification**: [npm run build succeeds | typecheck passes | E2E passes]
**Next Phase**: Phase 2: [description]
**Recovery Action**: [What to do if session resumes here]

[Continue for each phase...]

---

## Files to Port (Summary)

### Phase 1: [Category] (N files)
- [ ] `src/path/to/file1.ts`
- [ ] `src/path/to/file2.ts`

### Phase 2: [Category] (N files)
- [ ] `src/path/to/file3.ts`
- [ ] `src/path/to/file4.ts`

[Continue for each phase...]

---

## E2E Test Strategy

**Debug Hook**: `window.__[feature]Debug = [state-object]`
**Test File**: `tests/e2e/[feature].spec.ts`

### Test Coverage
1. [Test case 1 description]
2. [Test case 2 description]
3. [Test case 3 description]
```

---

## Phase Structure Template

Each implementation phase follows this structure:

### Phase Definition

```markdown
## Phase N: [Phase Name]

**Objective**: [One-line description of what this phase accomplishes]

### Inputs
- **Source files**: [List of files to read/copy from source worktree]
- **Dependencies**: [Any artifacts from previous phases needed]

### Outputs
- **Files to create**: [List of new files]
- **Files to modify**: [List of existing files to update]

### Steps
1. [Step 1 description]
2. [Step 2 description]
3. [Step 3 description]

### Three-Tier Verification

#### Tier 1: Build Gate (BLOCKING)
- [ ] `[typecheck command]` exits 0
- [ ] `[lint command]` exits 0
- [ ] `[build command]` exits 0

#### Tier 2: Test Gate (BLOCKING — cumulative)
New tests this phase:
- [ ] `[test-file-path]` — [N] test cases
Regression check:
- [ ] `[full test command]` — [total] tests pass (includes all prior phases)

#### Tier 3: Integration Gate (BLOCKING — cumulative)
- [ ] `[E2E test command]` — [total] E2E tests pass (includes all prior phases)

#### Manual Verification (NON-BLOCKING)
- [ ] [Specific criterion with steps for user review]

### Rollback Plan
If verification fails: [What to do]
```

---

## Sub-Agent Prompt Templates

### Implementation Agent Prompt

**Type**: `implementation-specialist`

```
WORKTREE IMPLEMENTATION TASK

**PHASE**: Phase [N]: [Phase Name]
**WORKTREE**: [Full path to target worktree]

**OBJECTIVE**: [One-line description]

**CRITICAL CONSTRAINTS**:
- ALL changes MUST be in the target worktree
- DO NOT modify files in: [list of protected paths]
- [Any other constraints]

**FILES TO CREATE/COPY**:
1. FROM: [source-path]
   TO: [target-path]
   MODIFICATIONS: [Any changes needed during copy]

2. FROM: [source-path]
   TO: [target-path]
   MODIFICATIONS: [Any changes needed during copy]

**VERIFICATION STEPS**:
1. Run `npm run build` in target worktree
2. Run `npm run typecheck` in target worktree
3. [Any additional verification]

**ON SUCCESS**:
Summarize what files were created/modified

**ON FAILURE**:
1. Read the error message
2. Fix the issue
3. Re-run verification
4. If stuck after 3 attempts, document the blocker

**RETURN FORMAT** (MANDATORY):
**AGENT COMPLETE**: Phase [N]: [Phase Name]
**FILES CREATED**: [count]
**FILES MODIFIED**: [count]
**VERIFICATION**: PASS | FAIL
**SUMMARY**: [2-3 sentences describing what was done]
```

### Debug Agent Prompt

**Type**: `implementation-specialist`

```
WORKTREE DEBUG TASK

**PHASE**: Phase [N] Debug
**WORKTREE**: [Full path to target worktree]
**ERROR**: [Error message or symptom]

**OBJECTIVE**: Fix the issue blocking Phase [N]

**CONTEXT**:
- Previous verification failed with: [error details]
- Files involved: [list of files]
- Constraint: [any constraints to observe]

**APPROACH**:
1. Read the error carefully
2. Identify root cause
3. Make minimal fix (do NOT refactor unrelated code)
4. Re-run verification

**RETURN FORMAT** (MANDATORY):
**AGENT COMPLETE**: Phase [N] Debug
**FIX APPLIED**: [one-line description]
**VERIFICATION**: PASS | FAIL
**SUMMARY**: [What was wrong and how it was fixed]
```

---

## E2E Test Strategy

### Debug Hook Pattern

Add a debug hook to expose internal state for E2E testing:

```typescript
// In your main component or store
if (typeof window !== 'undefined') {
  (window as any).__[feature]Debug = {
    // Expose state needed for E2E assertions
    currentState: state.currentValue,
    isReady: state.initialized,
    // Methods for E2E manipulation
    setTestValue: (value: number) => { state.testValue = value; }
  };
}
```

### E2E Test Template

```typescript
// tests/e2e/[feature]-integration.spec.ts
import { test, expect } from '@playwright/test';

test.describe('[Feature] Integration', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // Wait for feature to initialize
    await page.waitForFunction(() => (window as any).__[feature]Debug?.isReady);
  });

  test('should render [feature] component', async ({ page }) => {
    // Test assertion
    const debugState = await page.evaluate(() => (window as any).__[feature]Debug);
    expect(debugState.currentState).toBeDefined();
  });

  test('should [behavior description]', async ({ page }) => {
    // Manipulate state via debug hook
    await page.evaluate(() => {
      (window as any).__[feature]Debug.setTestValue(42);
    });

    // Verify behavior
    const result = await page.evaluate(() => (window as any).__[feature]Debug.currentState);
    expect(result).toBe(expectedValue);
  });
});
```

### Three-Tier Verification Gates

See `sub-agent-orchestration.md` → "Acceptance Criteria for Implementation Plans" for the full three-tier model (Build Gate → Test Gate → Integration Gate).

**Worktree-specific addition**: Run all verification commands from within the target worktree:

```bash
WORKTREE="[path]"
cd "$WORKTREE" && npm run typecheck && npm run build   # Tier 1
cd "$WORKTREE" && npm test                              # Tier 2
cd "$WORKTREE" && npx playwright test                   # Tier 3
```

All tiers run cumulatively at every phase boundary. Fail at any tier → fix → retry (max 3) → HALT.

#### Phase-Level Verification Bash Template

Adapt verification commands to the project's tooling. The structure is fixed (Tier 1 → Tier 2 → Tier 3); the commands are project-specific. See `sub-agent-orchestration.md` for the cascade rules.

---

## Autonomous Recovery Protocol

When a phase fails, the workflow automatically attempts recovery:

```
Phase N fails verification
        ↓
Read error message
        ↓
Launch debug agent with error context
        ↓
Debug agent applies fix
        ↓
Re-run verification
        ↓
├── PASS → Proceed to TOUCHBACK → Phase N+1
└── FAIL → Retry (max 3 attempts)
            ↓
        Still FAIL → Document blocker in progress.md
                   → Ask user for guidance
```

### Recovery States in Progress File

```markdown
## Current State
**Last Completed Phase**: Phase 2
**Status**: BLOCKED
**Blocking Issues**:
- Error: "Cannot find module 'missing-dep'" in Phase 3 Step 2
- Attempted: 3 debug cycles
- Root cause: Missing dependency not in source worktree
**User Action Required**: Add missing dependency or provide alternative
```

---

## Constraints Documentation Template

### Critical Files Section

```markdown
## CONSTRAINTS

### MUST NOT TOUCH
These files are verified working and must NOT be modified:

| File | Reason | Last Verified |
|------|--------|---------------|
| `src/components/Water.tsx` | User's polished water system | 2026-01-24 |
| `src/shaders/water/*.glsl` | Custom water shaders | 2026-01-24 |

### Safe to Modify
These files are expected to change:

| File | Expected Changes |
|------|-----------------|
| `src/components/Scene.tsx` | Add new component imports |
| `src/components/ArenaScene.tsx` | Replace placeholder with feature |

### Dependencies to Add
These new dependencies are required:

| Package | Version | Reason |
|---------|---------|--------|
| `@react-three/drei` | ^9.0.0 | Sky component |
```

---

## Complete Example: Sky Integration

Reference implementation from K-Town sky integration:

### Workflow Setup

```markdown
# Sky Integration Progress

**Started**: 2026-01-24 02:45 AM
**Status**: COMPLETED
**Target Worktree**: `.auto-claude/worktrees/tasks/sky-box-integration-into-main/`

## CRITICAL: Worktree Context
- **Source**: `.auto-claude/worktrees/tasks/024-three-js-ocean-scene-full-integration-arenascene/`
- **Target**: `.auto-claude/worktrees/tasks/sky-box-integration-into-main/`

## CONSTRAINTS
**MUST NOT TOUCH**: Water.tsx, water shaders, WaterRipple*, WaterSplash
- User's water system is polished and unchanged
```

### Phase Breakdown

| Phase | Files | Verification | Duration |
|-------|-------|-------------|----------|
| Phase 0: Worktree Setup | 1 | Worktree exists | 5 min |
| Phase 1: Port Store | 1 | TypeScript compiles | 10 min |
| Phase 2: Port Shaders | 9 | Build succeeds | 5 min |
| Phase 3: Port Sky Components | 3 | Build succeeds | 7 min |
| Phase 4: Port Lighting | 6 | Build succeeds | 3 min |
| Phase 5: Scene Integration | 4 | Build succeeds | 10 min |
| Phase 6: E2E Tests | 2 | Tests defined | 10 min |
| Phase 7: Final Validation | 0 | All gates pass | 5 min |

### Final Outcome

```markdown
## Final Summary
- **Commit**: e1cd9fc - feat(sky): integrate procedural sky with day/night cycle
- **Branch**: feature/sky-box-integration
- **Files Changed**: 25 files (6586 insertions, 24 deletions)
- **Water System**: UNCHANGED (as required)
- **Next Steps for User**:
  1. Review commit in worktree
  2. Run E2E tests
  3. Create PR to merge into main
```

---

## Checklist for Implementation Workflows

### Before Starting

- [ ] Identify source and target worktrees
- [ ] Document critical constraints (MUST NOT TOUCH files)
- [ ] Create progress file at `thoughts/plans/YYYY-MM-DD-[slug]/progress.md`
- [ ] Create all TaskCreate entries with TOUCHBACK checkpoints
- [ ] Set task dependencies for sequential execution

### During Each Phase

- [ ] Verify working in TARGET worktree (not source)
- [ ] Run verification gate after changes
- [ ] On failure: launch debug agent (max 3 attempts)
- [ ] Update progress.md via TOUCHBACK task
- [ ] Check constraint files are unchanged

### After Completion

- [ ] All phases marked complete in progress.md
- [ ] Final verification passes (build + typecheck + E2E)
- [ ] Commit created on feature branch
- [ ] User instructions documented (review, test, PR)
- [ ] Progress file marked COMPLETED

### Recovery Checklist

If resuming after context loss:

- [ ] Read progress.md to find last checkpoint
- [ ] Identify current phase and recovery action
- [ ] Verify worktree state matches checkpoint
- [ ] Continue from recovery action (not from scratch)

---

## Integration with Existing Patterns

This workflow integrates with:

| Pattern | How It Applies |
|---------|---------------|
| **Sub-Agent Orchestration** | Implementation agents do code work |
| **Checkpoint Protocol** | TOUCHBACK tasks force progress updates |
| **TaskCreate Integration** | Tasks track phase progress |
| **Lean Orchestrator** | Agents return summaries only |

See: `.claude/rules/sub-agent-orchestration.md` for orchestration details.
