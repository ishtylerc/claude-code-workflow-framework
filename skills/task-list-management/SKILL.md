---
name: task-list-management
description: |
  MANDATORY task tracking for every conversation involving work.
  INVOKE THIS SKILL at the start of any conversation where work occurs (file edits,
  research, troubleshooting, planning, commands, investigations, debugging, orchestration).
  Decomposes user requests into tracked tasks using TaskCreate/TaskUpdate, captures user
  action items, maintains dependencies. Foundational layer for all other skills.
  Triggers: any work request, implement, research, debug, plan, fix, build, create, edit,
  investigate, configure, set up, analyze, compare, file changes, multi-step task.
allowed-tools: TaskCreate, TaskUpdate, TaskList, TaskGet, TaskOutput, TaskStop, Read, Grep, Glob
---

# Task List Management

## Purpose

Automatically maintain a living task list throughout every conversation where work occurs. This skill makes Claude behave like a meticulous project manager standing next to the user — capturing everything that needs doing, tracking progress in real-time, and surfacing what's next.

**INVOKE THIS SKILL at the start of any work conversation.** The behavioral rule at `.claude/rules/task-list-management.md` provides the detailed protocol reference. This skill activates that protocol.

## First Action on Invocation

1. Use ToolSearch to load TaskCreate, TaskUpdate, TaskList if not already available
2. Analyze the user's request — what work is implied?
3. Decompose into discrete tasks via TaskCreate
4. Mark the first task `in_progress` and begin working

## Core Protocol

### On First Real Work Message

When the user's message implies work (not pure greetings/questions):

1. **Parse intent** — What does the user want? What's implied but unstated?
2. **Decompose** — Break into discrete, actionable tasks
3. **Create tasks** — Use TaskCreate for each item:
   - Clear, action-oriented descriptions
   - Dependencies via `addBlockedBy` where order matters
   - `activeForm` for in-progress descriptions (present-tense verb form)
4. **Start first task** — Mark `in_progress`, begin working

**Do this silently.** Don't announce "I'm creating a task list." Just do it and start working.

### During Work

- **Complete a task** → `TaskUpdate(taskId, status: "completed")` immediately
- **Start next task** → `TaskUpdate(taskId, status: "in_progress")`
- **New work item appears** → `TaskCreate` immediately
- **User says "I need to X"** → `TaskCreate("USER ACTION: X")`
- **Discover something needs doing** → `TaskCreate` with clear description
- **Task blocked** → Note in description, move to next unblocked task

### Task Types

**Claude Tasks** (things Claude will do):
```
"Search vault for tax-related documents"
"Pre-fill P&L header with business information"
"Create 2025 Tax Filing Checklist document"
```

**User Action Items** (things the user needs to do):
```
"USER ACTION: Measure office room square footage"
"USER ACTION: Locate 1099-NEC from Black Cat Security"
"USER ACTION: Confirm with John whether S-Corp extension was filed"
```

**Pending/Deferred** (identified but not yet actionable):
```
"DEFERRED: Walk through expense categories (after income verified)"
"PENDING USER INPUT: Home office expense amounts"
```

### Naming Convention

| Pattern | Example |
|---------|---------|
| Action verb + specific object | "Read CP575 notice for EIN number" |
| USER ACTION: + what they need to do | "USER ACTION: Send updated address to John" |
| DEFERRED: + reason | "DEFERRED: Fill auto section (confirmed N/A)" |
| Phase N: + description (orchestrated work) | "Phase 1: Port store module (3 files)" |

### Dependency Management

Use `addBlockedBy` when task order matters:

```
Task A: "Verify exact 1099 income amount"
Task B: "Fill income line on P&L" → addBlockedBy: [Task A]
Task C: "Calculate total expenses" → addBlockedBy: [Task B]
```

Don't over-constrain — only add dependencies when a task genuinely can't start without another completing.

### Topic Shifts

When the user changes topics mid-conversation:
1. **Don't delete existing tasks** — they persist
2. **Create new tasks** for the new topic
3. Both coexist — the task list reflects all active work streams
4. When the user returns to the prior topic, those tasks are still there

### Granularity Scaling

Automatically scale task detail to match the work:

**Trivial work** (1-2 steps): 2-3 tasks max. Don't over-decompose.
```
"Read the file"
"Apply the edit"
```

**Standard work** (multiple steps): 5-15 tasks with logical grouping.
```
"Find P&L template in downloads"
"Read CP575 for EIN"
"Search vault for Secureda address"
"Pre-fill P&L business header"
"Pre-fill known expense categories from invoices"
"Create P&L working document"
"Walk through remaining expense categories with user"
"Fill home office section"
```

**Complex/orchestrated work**: 15-30+ tasks following the Phase/VERIFY/TOUCHBACK pattern from orchestration rules.

### Status Reporting

When the user asks "where are we?" or "what's left?":
1. Run `TaskList`
2. Summarize: X completed, Y in progress, Z pending
3. Call out any blocked items and why
4. Identify next actionable task

## Integration Points

This skill is the **foundational task tracking layer**. Other skills and rules build on it:

| Skill/Rule | Integration |
|------------|-------------|
| **daily-note-management** | Completed tasks inform what gets logged in daily notes |
| **sub-agent-orchestration** | All Phase/VERIFY/TOUCHBACK tasks follow this skill's conventions |
| **orchestration-quality-standard** | Pillar 3 explicitly uses TaskCreate as the navigation system |
| **implementation-plan-standard** | Plan task lists (T0-TN) follow this skill's naming and dependency patterns |
| **fact-checking-workflow** | Session tracking tasks follow this skill |
| **continuous-improvement** | Detected improvement opportunities become tasks |
| **proactive-reading** | Research/implementation triggers create tasks per this skill |
| **All /commands** | Commands that produce work decompose via this skill |

**When any rule says "use TaskCreate"** → follow the conventions defined HERE.

## Gotchas & Known Pitfalls

*This section grows over time. After every invocation that hits unexpected behavior, add the lesson here immediately.*

**Flywheel Protocol**: When this skill encounters an unexpected failure, workaround, or edge case during execution, proactively append it below using the format: `[GOTCHA-NNN]: Symptom | Cause | Fix`.

[GOTCHA-001]: TaskCreate/TaskUpdate tools may not be loaded at conversation start | Deferred tools need ToolSearch first | Use ToolSearch to load Task tools before first use
[GOTCHA-002]: Task list doesn't persist across CLI sessions | TaskCreate is session-scoped | For multi-session work, also maintain progress.md as durable ground truth
[GOTCHA-003]: Over-decomposing trivial work annoys users | 15 tasks for a typo fix | Scale granularity to actual complexity — 2-3 tasks for trivial work

## When NOT to Create Tasks

- Pure greetings ("hello", "hey")
- Simple factual questions answered from memory ("what's the capital of France?")
- Meta-questions about Claude itself ("can you do X?")
- The act of creating the task list itself (avoid recursion)
- Clarifying questions before scope is understood (create tasks AFTER you understand the work)

## Success Criteria

- [ ] Every piece of work has a corresponding task
- [ ] Tasks are marked completed as soon as they're done (not batched)
- [ ] User action items are captured when mentioned
- [ ] Dependencies reflect actual ordering requirements
- [ ] Task list stays current — no stale in_progress or missing items
- [ ] New work items are captured immediately, not retroactively
- [ ] User can ask "what's left?" at any point and get an accurate answer
