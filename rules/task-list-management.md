# Task List Management — Always-On Behavior

**STATUS: MANDATORY — applies to EVERY conversation where work occurs**

## Core Principle

You are a meticulous assistant standing right next to the user, keeping track of everything they say they want/need done, plus everything you identify that needs doing — in the correct order, with dependencies, updated in real-time.

**This is not optional. This is not triggered. This is always on.**

## When to Create a Task List

Create a task list the moment ANY of these occur:
- User describes something they want done (even casually)
- User asks a question that implies work (e.g., "what do I need for my taxes?")
- You identify work that needs to happen (research, file creation, edits, etc.)
- A skill or command produces work items
- Conversation shifts to a new topic that involves action

**The ONLY exception**: Pure greetings, simple factual questions from memory, or meta-conversation about how Claude works.

## How It Works

### 1. Initial Decomposition (first real work message)

When work begins, immediately:
1. **Analyze** what the user is asking for — both explicit and implied
2. **Decompose** into discrete, trackable tasks using TaskCreate
3. **Order** tasks logically with `addBlockedBy` dependencies where applicable
4. **Start working** — mark the first task `in_progress`

Do NOT ask permission to create the task list. Just do it. The user expects this to happen automatically.

### 2. Dynamic Updates (ongoing)

As the conversation progresses:
- **New work emerges** → TaskCreate immediately
- **Task completed** → TaskUpdate to `completed` immediately (don't batch)
- **Task starts** → TaskUpdate to `in_progress`
- **Priorities shift** → Reorder/update descriptions
- **User mentions something they need to do** → Capture it as a task even if it's not something Claude will do (mark description accordingly: "USER ACTION: ...")
- **Blocked** → Mark with reason

### 3. Task Granularity

**Right-size tasks to the conversation scope:**

| Conversation Type | Task Granularity | Example |
|---|---|---|
| Quick task (1-5 min) | 2-5 tasks | "Fix this typo" → Read file, Edit, Verify |
| Medium task (5-30 min) | 5-15 tasks | "Help with P&L" → Find template, Read docs, Pre-fill sections, Walk through expenses... |
| Large task (30+ min) | 15-30+ tasks | "Research and implement feature" → Full phased breakdown |
| Multi-topic conversation | Grouped by topic | Tax tasks + skill creation tasks in same list |

**Don't over-decompose trivial work. Don't under-decompose complex work.**

### 4. Capturing User Action Items

When the user mentions something THEY need to do (not Claude), still capture it:
```
TaskCreate: "USER ACTION: Measure office room square footage"
TaskCreate: "USER ACTION: Check 1099-NEC from Black Cat for exact amount"
TaskCreate: "USER ACTION: Confirm with John whether extension was filed"
```

These help the user see their full picture. Mark them `completed` only when the user confirms they've done it.

### 5. Task Naming Convention

Tasks should be clear, action-oriented, and scannable:
- **Good**: "Pre-fill P&L header with EIN and business address"
- **Bad**: "Do the P&L thing"
- **Good**: "USER ACTION: Measure office room for home office deduction"
- **Bad**: "User needs to measure"

### 6. When Topics Shift Mid-Conversation

If the user pivots to a new topic:
1. Keep existing tasks (don't delete them)
2. Create new tasks for the new topic
3. Both topic groups coexist in the task list
4. Resume prior topic tasks when the user returns to it

## Integration with Other Skills & Rules

**This rule is foundational.** Other skills and rules depend on it:

- **daily-note-management**: Completed tasks inform daily note entries
- **sub-agent-orchestration**: Orchestrated workflows use TaskCreate per this rule's conventions
- **orchestration-quality-standard**: Pillar 3 (Persistent Progress Tracking) uses TaskCreate as the navigation system
- **implementation-plan-standard**: Phase/VERIFY/TOUCHBACK task patterns follow this rule
- **fact-checking-workflow**: Session tracking uses TaskCreate
- **continuous-improvement**: Improvement opportunities can be captured as tasks
- **All slash commands**: Commands that produce work items feed into this task list

**When a skill or rule says "use TaskCreate"**, it means follow the conventions in THIS rule.

## What NOT to Track as Tasks

- Reading a file to answer a question (just answer it)
- Thinking/planning that doesn't produce output
- The act of creating the task list itself
- Clarifying questions before work starts (unless the clarification IS the work)

## Quick Reference

```
# Create task
TaskCreate: description, optional activeForm for in-progress description

# Update task
TaskUpdate: taskId, status (pending/in_progress/completed), optional new description

# Check status
TaskList: see all tasks and their states

# Dependencies
TaskCreate with addBlockedBy: [taskId1, taskId2]
```

## Recovery

If a task list gets stale or out of sync:
1. Run TaskList to see current state
2. Update statuses to match reality
3. Add any missing tasks
4. Continue from the first pending/in_progress task
