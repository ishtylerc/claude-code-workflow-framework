# Orchestration Quality Standard

**Purpose**: Overarching standard for how Claude Code should approach any non-trivial multi-step task. This is the strategic "why and when" layer that governs all tactical orchestration patterns (sub-agent-orchestration.md, worktree-implementation-workflow.md, fact-checking-workflow.md, etc.).

**Why this exists**: Claude Code operates within inherent limitations — finite context windows, model reasoning constraints, and the multi-step agentic paradigm. Quality across multiple steps requires deliberate scaffolding. Without it, work degrades: assumptions go unchecked, progress is lost across sessions, context windows exhaust mid-task, and claims of success go unvalidated.

---

## When This Standard Applies

| Task Scope | Orchestration Level | Examples |
|-----------|---------------------|---------|
| **Trivial** (1-2 steps) | None — do directly | Typo fix, single-file edit, quick lookup |
| **Small** (3-5 steps) | Lightweight — progress tracking optional | Single function implementation, config change |
| **Medium** (5-15 steps) | Standard — all 5 pillars required | Feature implementation, multi-file refactor, research document |
| **Large** (15-50 steps) | Full — multi-agent with dedicated progress file | System redesign, comprehensive research, integration workflow |
| **Mega** (50+ steps) | Extended — phased execution with session recovery | Building a SaaS, full codebase migration, multi-week project |

**When scope is uncertain**: Do NOT silently assume a scope level. Instead, adopt a **curiosity mindset** — ask probing questions via AskUserQuestion until you clearly understand the boundaries of what the user is asking. Ask as many questions as needed to understand the TRUE ask, not just the surface request. Only default to a scope level when:
- The user explicitly signals it's quick/trivial ("just a quick fix", "simple change") → Trivial/Small
- The user uses scope-indicating language ("implement a feature", "comprehensive research", "build this system") → Medium/Large/Mega
- After thorough questioning, scope remains genuinely ambiguous → Default to Medium

**Key principle**: It is always better to ask one more clarifying question than to over- or under-scaffold. The cost of mis-scoped orchestration (wasted work, lost context, shallow results) far exceeds the cost of a brief clarifying exchange.

---

## Foundational Mindset: Curiosity-First Orchestration

**BEFORE the 5 pillars, adopt this mindset** — especially in the early stages of any orchestration:

**Be deeply curious about what the user is REALLY asking.** Surface-level requests often contain deeper intent. "Add a login button" might mean "implement authentication." "Research X" might mean "give me enough to make a decision about Y." The gap between the literal request and the true need is where quality failures originate. Probe for intent first — not just what the user wants, but why they want it, how it should feel, and what qualities define "right" vs merely "functional."

**Curiosity in practice:**
- Ask "why" before "how" — understand the goal behind the task
- Probe for unstated constraints, preferences, and quality expectations
- Don't assume you know what "done" looks like — ask
- When the user's answer raises new questions, ask those too
- Only stop questioning when you can confidently articulate: what the user wants, why they want it, what "good" looks like, and what's out of scope

**This mindset applies throughout orchestration**, but it is MOST CRITICAL at the start. Misunderstanding the ask at Phase 0 compounds into every subsequent phase.

### Quality Drives Process, Not the Reverse

**The number of rounds, agents, and phases is NOT pre-determined — it is discovered through execution.** Start with an estimated scope, but let the QUALITY OF RESULTS dictate whether more work is needed.

**The pattern in practice:**
1. **Estimate** rounds/phases upfront (e.g., "3 research rounds should suffice")
2. **Execute** the estimated work
3. **Evaluate** — are findings comprehensive, accurate, and validated to ≥95% confidence?
4. **Expand if needed** — if evaluation reveals gaps, uncertainties, blockers, dependency issues, or insufficient confidence, ADD more rounds/phases. Update the task list and progress file accordingly.
5. **Repeat** until the North Star is reached: a completed deliverable that is BOTH generated AND accurate/functional/high-quality

**This mirrors real-world projects**: You start with an estimate, but as you dig in, you discover mis-scoped areas, unexpected hurdles, technical dependencies, and quality gaps. The professional response is to expand scope to meet the quality bar — not to declare premature completion because the original estimate is exhausted.

**The North Star is NOT "something was generated"** — it is "something was generated that is ACCURATE (in facts) and/or FUNCTIONAL (in code) and meets the QUALITY bar the user expects."

**Anti-pattern**: Limiting yourself to 3 research rounds because "3 feels like enough." Stopping validation because "we already ran 5 agents." Declaring research complete when key questions remain unanswered. Shipping code that "compiles" but hasn't been verified to actually work correctly. The number of rounds is a FLOOR estimate, not a ceiling.

---

## The 5 Pillars

### Pillar 1: Comprehensive Problem Understanding

Before any execution, the problem/task MUST be fully understood. This is the most commonly skipped step and the root cause of most quality failures.

- **Core issue identification**: What exactly needs to be solved? Distinguish symptoms from root causes. For bugs, this means investigation before hypothesis. For features, this means understanding WHY not just WHAT.
- **Intent discovery (FIRST)**: Before asking what needs to be built, ask WHY. What purpose does this serve? How should it feel? What qualities must survive iteration? Intent is the most vulnerable layer because it's invisible, untested, and the first thing optimized away. See `intent-encoding-standard.md` for the full protocol.
- **What is the user REALLY asking?**: Go beyond the literal request. Probe for the underlying goal, the decision they're trying to make, the problem they're trying to solve. Use AskUserQuestion comprehensively until you understand the TRUE ask — not just the surface request.
- **Success criteria**: What does "done" look like in observable terms? Get explicit acceptance criteria from the user via AskUserQuestion. Don't proceed until you can articulate what success looks like. During Phase 1.5 (Plan Mode), these success criteria become formal acceptance criteria in the plan artifact. Every phase of the plan must have measurable, specific acceptance criteria appropriate to the task type.
- **Quality benchmarking**: What does "good" look like? Research external standards, existing codebase patterns, and best practices. For research tasks, this means understanding what a comprehensive answer looks like. For implementation, this means studying existing patterns before writing new code.
- **Scope boundaries**: What is IN scope and OUT of scope? Document explicitly. This prevents scope creep and focuses agent work.
- **Use AskUserQuestion proactively and comprehensively**: Ask as many clarifying questions as needed BEFORE starting work. It is far cheaper to ask 5 questions upfront than to course-correct mid-implementation. Don't ration questions — thoroughness here prevents waste everywhere downstream.
- **Understand what makes a good PLAN for the workflow type**: Different workflow types (research, implementation, content generation) have different quality characteristics. Before creating or executing a plan, understand the patterns that define quality for that specific workflow type. For content generation, this means voice profiles, source authority hierarchies, and decision tiering. For implementation, this means phase gates and verification commands. Study the relevant tactical rule files before planning.

**Anti-pattern**: Jumping into implementation before understanding what "success" means. Launching research agents before defining what questions need answering. Asking one surface-level question and assuming the rest. Creating a plan without understanding the quality patterns specific to the workflow type.

### Pillar 2: Right-Sized Orchestration & Context Bloat Prevention

Scale orchestration to match task complexity — neither over-engineer nor under-scaffold. Critically, PREVENT CONTEXT BLOAT throughout.

#### The Context Bloat Problem

**Context bloat is the #1 operational failure mode in multi-agent orchestration.** Sub-agents do deep work (research, implementation, analysis) and then dump ALL of their findings back to the orchestrator. The orchestrator's context window fills with agent output instead of being reserved for coordination, decision-making, and synthesis. This leads to: truncated later phases, lost checkpoint data, inability to launch more agents, and degraded orchestration quality.

**The solution is PIPING, not DUMPING:**

```
WRONG (Context Bloat):
Agent A1 → Returns 5,000 words to orchestrator
Agent A2 → Returns 8,000 words to orchestrator
Agent A3 → Returns 3,000 words to orchestrator
Orchestrator now has 16,000 words of agent output → context exhaustion

RIGHT (Piping Pattern):
Agent A1 → Writes findings to disk → Returns 200-word SUMMARY to orchestrator
Agent A2 → Writes findings to disk → Returns 200-word SUMMARY to orchestrator
Agent A3 → Writes findings to disk → Returns 200-word SUMMARY to orchestrator
Orchestrator has 600 words → launches next round
Agent B1 → Reads A1+A2 files DIRECTLY from disk (NOT via orchestrator)
Agent B2 → Reads A2+A3 files DIRECTLY from disk (NOT via orchestrator)
Agent C1 (validation) → Reads all previous files DIRECTLY from disk
```

The orchestrator's job is to COORDINATE (decide what agents to launch, what files they should read, and where their output goes) — NOT to be a message relay between agents.

#### Orchestration Principles

- **Agent count scales with scope**: 1-2 agents for medium tasks, 2-3 for large, 3 for mega. **HARD LIMIT: Never run more than 3 background agents concurrently.** Use more rounds instead of more concurrent agents.
- **Context engineering**: Each agent gets EXACTLY the context it needs via file paths — no more (wastes tokens), no less (produces shallow work). Provide specific file paths, line numbers, and focused instructions.
- **Lean orchestrator**: The orchestrator (you) receives SUMMARIES ONLY from agents — never read full agent output files into your context. Agents return ~200 words, not 15,000. The orchestrator should reserve its context for coordination decisions.
- **Agent-to-agent piping**: Sequential agents read previous agents' output files DIRECTLY from disk, not through orchestrator mediation. This is the PRIMARY mechanism for passing context between agents. Design the file path conventions upfront so agents know where to read and write.
- **Phase decomposition**: Break work into phases sized for individual agent context windows. Each phase should be completable by a single agent without context exhaustion, including verification.

#### Piping Architecture (Standardized)

```
Round 1: Agents A1, A2, A3 → Write to R1-01-*.md, R1-02-*.md, R1-03-*.md
                            → Return 200-word summaries to orchestrator
Round 2: Agents B1, B2     → READ R1-*.md files directly from disk
                            → Write to R2-01-*.md, R2-02-*.md
                            → Return 200-word summaries to orchestrator
Round 3: Agent C1 (synth)  → READ R1-*.md AND R2-*.md directly from disk
                            → Write to R3-synthesis.md
                            → Return 200-word summary to orchestrator
Validation: Agent V1        → READ R3-synthesis.md directly from disk
                            → Write to validation.md
                            → Return verdict summary to orchestrator
```

The orchestrator NEVER reads the full R1/R2/R3 files. It coordinates based on summaries and file paths only.

#### Scaling Guide

| Scope | Agents | Progress File | TaskCreate | Plan Mode | Validation |
|-------|--------|---------------|------------|-----------|------------|
| Small | 0-1 | Optional | Optional | Optional | Build Gate only at end |
| Medium | 1-2 | Yes | Yes | MANDATORY | Three-tier gates per phase (implementation) or quality thresholds per round (research) |
| Large | 2-3 | Yes + checkpoints | Yes + dependencies | MANDATORY | Three-tier gates + independent verification agent |
| Mega | 3 (max) | Yes + session recovery | Yes + full dependency chain | MANDATORY | Three-tier gates + verification agent + fact-checker + human review at milestones |

**Anti-pattern**: Launching 10 agents for a 3-file change. Having one agent try to do everything with no delegation. Reading full agent outputs into orchestrator context instead of using file-based piping.

#### Context Budget Framework

**MANDATORY for plans with 10+ agents**: Calculate token budgets per agent type.

**Rules of thumb** (calibrate with empirical measurement):
- 1KB of markdown text ~ 250 tokens
- Default agent input cap: 20,000 tokens (excluding prompt/instructions)
- Intensive agents (synthesis, cross-section analysis): Cap at 30,000 tokens
- Special-case agents (must read many inputs): Cap at 35,000 tokens, with explicit justification

**Per-agent budget template**:
| Input | Estimated Tokens | Source |
|-------|-----------------|--------|
| Shared context (voice profile, brief, etc.) | ~3,000-4,000 | Measured from actual files |
| Section-specific inputs | Varies | Measured or estimated |
| TOTAL | Must be < cap | |

**Condensation strategies** (when inputs exceed cap):
1. **Excerpt strategy**: Give agents only their relevant section of large documents
2. **Context Brief**: Condense large reference documents into 5-8KB briefs
3. **Dependency summaries**: 500-word summaries instead of full artifacts
4. **Fallback**: Create answer summaries (~2,000 tokens) to replace full questionnaires/artifacts

**Empirical measurement protocol**: For the first agent of each type, measure actual token usage. Correct estimates for all subsequent agents. Document corrections in progress.md.

### Pillar 3: Persistent Progress Tracking (Task List + Progress File)

Progress MUST be tracked through TWO symbiotic systems working together. Each serves a distinct purpose; neither is sufficient alone.

#### The Two Systems

**Task List (TaskCreate/TaskUpdate/TaskList/TaskGet)** — Your North Star and navigation system:
- **Purpose**: Immediate, dependable way to understand the big picture — milestones, required steps, current position, dependencies, and what's next
- **Granularity**: Comprehensive — include ALL tasks AND subtasks. Don't be afraid to make the task list thorough. Every phase, sub-phase, checkpoint, and verification step gets its own task
- **Navigation**: At any point during execution, reading the task list should immediately tell you: where you are, what's done, what's blocked, and what's next
- **Dependencies**: Use `addBlockedBy` to enforce execution order. This prevents accidentally skipping prerequisites
- **Status updates**: Mark tasks `in_progress` when starting, `completed` when done. This provides real-time visibility into workflow state
- **Persistence**: Task list survives context compaction — it's always accessible as a reliable anchor

**Progress File** (`thoughts/[type]/YYYY-MM-DD-[slug]/progress.md`) — Comprehensive detail-oriented record:
- **Purpose**: Full history of all past, present, and future progress — including the WHY behind decisions, detailed checkpoint data, accumulated learnings, constraints, and recovery instructions
- **Depth**: Contains everything a new agent (or a context-recovered session) would need to understand the FULL story — not just what happened, but why, what was learned, what failed, and how to resume
- **Checkpoints**: After every phase, records timestamp, artifacts, verification output, next steps, and recovery action
- **Constraints**: Documents what MUST NOT be touched, what's been ruled out, and accumulated learnings from failures
- **Recovery**: A new session reading ONLY the progress file should be able to resume without any other context

#### The Symbiotic Relationship

```
TASK LIST (TaskCreate/TaskUpdate)          PROGRESS FILE (progress.md)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━          ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"What needs to happen"                     "What has happened and why"

├── Big picture overview                   ├── Detailed checkpoint history
├── Current position at a glance           ├── Accumulated learnings
├── Dependencies between steps             ├── Constraints documentation
├── Blocked/unblocked status               ├── Recovery instructions
└── Milestone tracking                     └── Decision rationale

WHEN TO USE WHICH:
- "Where am I?" → TaskList
- "What's next?" → TaskList (find first unblocked pending task)
- "Why did we do X?" → Progress file
- "How do I resume?" → Progress file
- "What's blocked?" → TaskList (check blockedBy fields)
- "What did we learn from failure?" → Progress file (Accumulated Constraints)
```

**Both systems MUST be updated at every TOUCHBACK checkpoint.** The task list gets a status update; the progress file gets a detailed checkpoint entry.

#### TOUCHBACK Protocol (after EVERY phase)

1. **READ progress file** — refresh understanding of overall state
2. **UPDATE progress file** — timestamp, completed phase, artifacts created, verification results, next phase, recovery action
3. **UPDATE task status** — mark phase task `completed`, mark TOUCHBACK task `completed`
4. **CHECK task list** — confirm next task is unblocked and ready
5. **ONLY THEN** proceed to next phase

#### Task List Best Practices

- **Create ALL tasks upfront** at workflow start — the full roadmap should be visible from the beginning
- **Include subtasks** — don't just have "Phase 2: Implementation"; break it into "Phase 2a: Create function", "Phase 2b: Integrate", "Phase 2c: Verify"
- **Include TOUCHBACK tasks** — after every phase, a checkpoint task forces progress file update
- **Set dependencies** — use `addBlockedBy` liberally to enforce correct ordering
- **Use activeForm** — provide present-continuous descriptions for in-progress tasks (e.g., "Implementing monkey-patch...")
- **Use descriptions** — include enough detail that reading just the task gives you context for what to do
- **Check TaskList frequently** — before starting work, after completing work, during TOUCHBACK, whenever uncertain about state

#### Checkpoint Content (minimum per checkpoint in progress file)

```
### Checkpoint N — [timestamp]
**Phase Completed**: [Phase name]
**Artifacts Created**: [file paths]
**Verification**: [PASS/FAIL with details]
**Next Phase**: [What's next]
**Recovery Action**: [How to resume if context lost]
```

**Anti-pattern**: Completing 5 phases of work with no written record, then losing context on session exhaustion. Running 3 agents with no task list, then forgetting which completed. Having a task list but never checking it. Having a progress file but never updating it.

### Pillar 4: Context-Window-Efficient Decomposition

Break scope into sub-tasks that respect the fundamental constraint: each agent has a finite context window that must fit input + work + verification + output.

- **Each sub-task completable by one agent**: Including reading inputs, performing work, running verification, and returning structured results — all within a single agent's context window.
- **Budget room for verification**: Every implementation sub-task MUST include build/test verification within the same agent run. Don't split "implement" and "verify" into separate agents — the implementing agent needs the feedback loop.
- **File path conventions**: Use standardized naming patterns so agents find artifacts without searching. Define paths upfront in the progress file.
- **Recovery-first design**: Each checkpoint must contain enough information to resume from scratch if context is lost. A new agent reading only the progress file should be able to continue.
- **Incremental verification**: Build, typecheck, and test after EVERY phase. Never accumulate multiple phases of changes before first verification — errors compound and become harder to diagnose.
- **Runtime reasoning is MANDATORY**: Static verification (typecheck + build) catches ~40% of bugs. The other ~60% are runtime: state races, disposed references, interaction flow breaks, slider-driven reload loops, state priority overrides. After static verification passes, ALSO trace through user interactions mentally: "what happens when the user drags this slider every tick?", "what happens when state A overrides state B permanently?", "what if this async op races with unmount?". Report runtime concerns even if build passes.

**Anti-pattern**: Cramming 500 LOC of changes into one agent run with no verification until the end. Having an agent read 20 files before doing any work (context exhaustion before execution). Claiming "verified" because typecheck + build pass without checking runtime behavior.

### Pillar 5: Continuous Validation & Quality-Driven Expansion

Claims and assumptions MUST be validated throughout execution, not just at the end. This applies to BOTH research and implementation work. **Critically, validation results drive process scope** — if validation reveals gaps, the process EXPANDS to fill them.

**For Research:**
- Cross-reference claims with authoritative sources (official docs, not blog posts)
- Include fact-checker agents in research rounds (separate agent that challenges findings)
- Validate that research answers the ORIGINAL question, not a drifted version
- Mark claims with confidence levels when certainty varies
- **If confidence is below 95%**: Add more research rounds. The target is comprehensively verified findings, not "we did 3 rounds so we're done"

**For Implementation:**
- Build + typecheck + test after EVERY phase. Don't claim "passes" without running the actual command.
- Run the verification in the agent's own Bash call — don't defer to "the user will test"
- If verification fails, the agent fixes it within the same run (up to 3 attempts)
- Log exact verification output in progress file
- **If implementation reveals unexpected complexity**: Add phases to the task list. Update the progress file. Don't compress remaining work into fewer phases — expand the plan to match reality.

#### Three-Tier Verification Model (Implementation Tasks)

For implementation tasks, validation at every phase boundary follows a strict three-tier cascade:

See `sub-agent-orchestration.md` → "Acceptance Criteria for Implementation Plans" for the full Three-Tier Verification Model (Build Gate → Test Gate → Integration Gate). The key principle: ALL three tiers run cumulatively at EVERY phase boundary. Fail at any tier → fix → retry (max 3) → HALT.

**Key principles**:
- **Cumulative means cumulative**: Phase 3's Test Gate runs ALL tests from Phases 1, 2, AND 3. Not just the new ones.
- **"No tests yet" is still a gate**: Early phases with no new tests still run the full existing test suite as a regression check. The gate passes trivially if there are no tests, but it catches broken existing tests.
- **Test authoring is part of implementation**: Writing tests is not a separate step — it happens within each implementation phase, alongside the code it tests.
- **Strict tier ordering**: Build must pass before Test runs, Test must pass before Integration runs. No skipping tiers.
- **Fail = fix = retry (max 3) = HALT**: The cascade is all-or-nothing per phase. No "we'll fix it next phase."

#### Acceptance Criteria as Contracts

Acceptance criteria in plans are contracts between the planning phase and the execution phase. When an agent picks up a phase to implement, the AC tells it exactly what "done" means — no ambiguity, no judgment calls.

AC must be:
1. **Specific enough for autonomous verification** — an agent with no context beyond the plan can verify them
2. **Measurable with exact commands** (implementation) or **exact thresholds** (research)
3. **Complete** — if all criteria pass, the phase IS done. No hidden requirements.
4. **Cumulative** — each phase's criteria include regression checks from all prior phases

**Anti-pattern**: "Tests pass" (which tests? what command?). "Build works" (what build command? what exit code?). "Research is comprehensive" (what confidence threshold? how many sources?).

**For Assumptions:**
- When a hypothesis drives design decisions, validate it with skeptical agents BEFORE committing
- Document assumptions explicitly and mark which are verified vs. unverified
- Re-validate assumptions when new information arrives

**For Success Claims:**
- NEVER claim success without explicit user verification
- Use PENDING/AWAITING VERIFICATION status until user confirms
- End-of-task validation: independent verification agent confirms all claimed results

**Process Expansion Protocol:**
When validation or execution reveals that more work is needed than originally estimated:
1. **Acknowledge** the scope change explicitly in the progress file
2. **Add new tasks** to the task list (TaskCreate) with proper dependencies
3. **Update** the progress file's phase plan to reflect the expanded scope
4. **Continue** with the new tasks — don't artificially constrain to the original estimate
5. **Inform** the user of significant scope changes via brief status update

The number of rounds is a FLOOR, not a CEILING. The quality/accuracy bar determines when work is complete, not the round count.

**Anti-pattern**: Writing "build passes" in progress file without running the build. Marking a bug "resolved" before the user tests it. Accepting a research claim without checking the source. Stopping after 3 rounds because "3 seems like enough" when key questions remain unanswered. Declaring research complete at <90% confidence because the estimated rounds are exhausted.

#### Validate Plans Before Execution, Not Just During

Validation is not only for in-flight execution -- it applies to PLANS before they are executed. Any plan with 20+ tasks or 3+ phases should undergo pre-execution validation (see Plan Validation Pattern in `sub-agent-orchestration.md`). The same principles apply: high-confidence issues must be fixed, low-confidence flags documented. Plan validation catches context budget miscalculations, missing dependencies, incorrect task counts, and overloaded agents BEFORE they cause execution failures.

#### Provenance Tracking for Generated Content

**When to use**: Any workflow where agents generate content that simulates human decisions or preferences.

**Mandatory tags on every generated claim/answer**:
- `[SOURCED]` -- directly derivable from user statements, approved documents, or authoritative sources
- `[INFERRED]` -- logically derived from stated principles but not explicitly stated
- `[SIMULATED]` -- agent's best guess; no direct source authority

**Benefits**:
- Enables human reviewers to focus on `[SIMULATED]` content (highest risk)
- Reduces review burden from N items to the ~20% that are simulated
- Creates audit trail for how decisions were made

**Implementation**: Include tagging instructions in every content-generation agent prompt. Compile all `[SIMULATED]` items into a separate review list during the validation/assembly phase.

#### Decision Tiering for Human Review

**When to use**: Any workflow that generates 20+ decisions requiring human review.

**Tiers**:
- **Strategic** (affects 3+ sections/components): Present to user FIRST. Mark as `[DRAFT DECISION]`.
- **Tactical** (affects 1-2 sections/components): Present after strategic decisions resolved. Mark as `[DRAFT DECISION]`.
- **Detail** (local to one section): Agent picks reasonable default. Mark as `[DEFAULT DECISION -- chose X because Y]`. User reviews only if they disagree.

**Estimated reduction**: Typically reduces active review burden from 100% of decisions to ~20-25% (strategic tier only).

**Implementation**: Include tiering instructions in every content-generation agent prompt. During assembly/validation phase, compile all `[DRAFT DECISION]` markers into a decision tracker sorted by tier, with a cross-section dependency map.

---

## Human Review Gates

**When to use**: Any multi-phase workflow where errors in Phase N cascade into Phase N+1.

### Gate Types

**Critical Gate (first major output)**:
- Three outcomes: **GO** (quality >=80%), **ADJUST** (50-79%), **NO-GO** (<50%)
- GO: Continue with minor corrections fed back
- ADJUST: Pause, revise key artifacts, re-draft, then continue
- NO-GO: Abandon autonomous workflow, revert to human-driven approach

**Standard Gate (subsequent phases)**:
- Three outcomes: **CONTINUE**, **REVISE**, **HALT**
- CONTINUE: Output acceptable, proceed
- REVISE: Specific items need rework, re-draft flagged items only
- HALT: Fundamental issues, pause for discussion

### Gate Placement
- After the first phase that produces user-visible output (Critical Gate)
- After every subsequent phase (Standard Gate)
- Gates are BLOCKING -- execution does not proceed until user responds

### TaskCreate Integration
- Human gates are tasks with `blockedBy` on the preceding phase
- Next phase tasks have `blockedBy` on the gate task
- Gate tasks are marked `completed` only after user provides response

---

## Multi-Session Execution Planning

**When to use**: Any workflow estimated at 4+ hours of execution time or requiring human review between phases.

**Session boundary rules**:
1. Place session boundaries at natural pause points (human review gates, tier completions)
2. Each session should be self-contained: starts at a known state, ends at a gate
3. Document session-to-task mapping in the plan (which tasks belong to which session)
4. Estimate duration per session

**Session startup protocol** (for resuming in a new CLI session):
1. Read progress.md -- full history, constraints, task design
2. Check TaskList -- if empty, RECONSTRUCT from progress.md state
3. Mark previously-completed tasks as `completed` per progress.md checkpoints
4. Find first `pending` task with no unmet `blockedBy`
5. Resume execution

**Key insight**: TaskList may NOT persist across CLI sessions. The progress.md must contain enough information to fully reconstruct the task list.

---

## Quick Reference Checklist

**Before starting any medium+ task:**

- [ ] **Curiosity satisfied** — Asked probing questions until the TRUE ask is understood (Foundational Mindset)
- [ ] Problem fully understood — success criteria defined, scope boundaries documented (Pillar 1)
- [ ] Scope assessed via user dialogue — orchestration level selected based on user signals (Pillar 2)
- [ ] **Plan mode completed** (Phase 1.5) — plan artifact exists with task-appropriate AC per phase (Pillar 1+5)
- [ ] **AC quality-checked** — every criterion is executable/measurable, observable, deterministic, independent, and cumulative (Pillar 5)
- [ ] Progress file created with constraints, phase plan, and recovery instructions (Pillar 3)
- [ ] **Comprehensive TaskCreate entries** for ALL phases, sub-phases, VERIFY/VALIDATE gates, and TOUCHBACK checkpoints with dependencies set (Pillar 3)
- [ ] Sub-tasks sized for single-agent context windows with verification included (Pillar 4)
- [ ] Agent-to-agent piping designed — file paths defined for inter-agent communication (Pillar 2)
- [ ] Three-tier verification gates planned for every phase — implementation: Build+Test+Integration; research: confidence+sources+completeness (Pillar 5)
- [ ] Agent prompts include: file paths for inputs, mandatory summary-only return format, verification commands (Pillar 2+4)

**After completing any medium+ task with a final deliverable:**

- [ ] HTML presentation offered to user (present-report skill / `/present` command)

---

## Research Task Orchestration (MANDATORY)

Research tasks are the MOST COMMON source of orchestration violations because they feel self-explanatory. This section provides explicit guidance to prevent bypasses.

### Research Scope Detection Keywords

When the user's request contains ANY of these keywords, the orchestration framework is MANDATORY (not optional):
- "research", "investigate", "analyze", "compare", "evaluate"
- "comprehensive", "thorough", "deep-dive", "ultra"
- "study", "explore", "document"

### Minimum Research Orchestration

| User Signal | Minimum Agents | Minimum Rounds | Orchestration Level |
|-------------|---------------|----------------|---------------------|
| "quick research" | 2-3 | 1 | Medium |
| "research X" | 2-3 | 2-3 | Large |
| "comprehensive research" | 3 | 3-4 | Large |
| "ultra-research" | 3 | 4-5 | Mega |

### Research-Specific Phase 0 Questions (MANDATORY)

Before ANY research task, ask the user via AskUserQuestion:

0. **Intent**: "What decision or action will this research enable? What would make you confident enough to act on the findings?"
1. **Scope**: "What specific aspects of [topic] are most important to you? What would make this research 'done'?"
2. **Quality**: "Do you need a quick overview or comprehensive deep-dive?"
3. **Output**: "What format should the deliverable take? (Research document, comparison table, decision framework, etc.)"
4. **Priority**: "Are there specific sub-topics or angles that matter most?"
5. **Context**: "Is there existing research or knowledge I should build on?"

### Research Anti-Patterns (DO NOT)

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|-------------|------------------|
| Launch single `/ultra-research` agent | Bypasses Phases 0-2, no orchestrator control | Complete Phases 0-2 first, then launch 2-3 parallel agents per batch |
| Skip Phase 0 because "research X" seems clear | Miss scope, quality, format preferences | Always ask minimum 3 clarifying questions |
| Skip Phase 1 context gathering | Agent prompts lack specificity | Read relevant local files, check existing research |
| No TaskCreate for research workflows | No progress tracking, no recovery | Create tasks for each round + TOUCHBACK checkpoints |
| No progress file for research | Can't recover if session drops | Always create `thoughts/research/YYYY-MM-DD-[slug]/progress.md` |

---

## Implementation Task Orchestration (MANDATORY)

Implementation tasks are as common as research but historically lacked equivalent trigger mechanisms. This section mirrors the research orchestration section above.

### Implementation Scope Detection Keywords

**Auto-trigger keywords**: implement, build, create, develop, migrate, refactor, port, rewrite, integrate, add feature, redesign, overhaul, update (multi-file), setup/set up, configure, optimize, upgrade, deploy, scaffold, patch, extend, convert, extract, fix (multi-file)

**Two-step trigger**: Keywords activate scope assessment first. Only proceed to plan mode if the request involves code/system changes AND is Medium+ complexity. See `implementation-plan-standard.md` for the full plan template, scaling guide, and compliance checklist.

### Minimum Implementation Orchestration

| User Signal | Plan Depth | Agent Rounds | Orchestration Level |
|---|---|---|---|
| "quick fix" (multi-file) | Medium template | 1-2 | Medium |
| "implement X" | Full template | 2-3 | Large |
| "build/create system" | Gold standard | 3-5 | Large/Mega |
| "migrate/rewrite" | Gold standard | 4-6 | Mega |

### Implementation-Specific Phase 0 Questions (MANDATORY)

Before ANY implementation task, ask the user via AskUserQuestion:

0. **Intent**: "Beyond the functional requirements, what should this feel like when done? What qualities of the current system must be preserved?"
1. **Scope**: What exactly needs to change? What's the desired end state?
2. **Constraints**: What must NOT change? What's fragile?
3. **Testing**: What test infrastructure exists? What verification is possible?
4. **Architecture**: Worktree isolation needed? What branch strategy?
5. **Dependencies**: What blocks what? What can parallelize?

### Implementation Anti-Patterns (DO NOT)

| Anti-Pattern | Why It Fails | Correct Approach |
|---|---|---|
| Start coding without plan | No verification gates, no recovery | Enter plan mode, produce plan artifact |
| Plan without worktree | Changes in main, hard to rollback | Use worktree for Medium+ changes |
| Plan without task list | No progress tracking, no dependencies | TaskCreate for all phases + TOUCHBACK |
| Plan without verification agents | Impl agent marks own work "done" | Independent verification agent per phase |
| Skip plan self-validation | Plan missing sections, user must request | Run compliance checklist before presenting |

---

## Relationship to Other Rules

This standard is the OVERARCHING philosophy. The tactical rules implement it:

| Rule File | Implements Pillars |
|-----------|-------------------|
| `sub-agent-orchestration.md` | Pillar 2 (agent patterns), Pillar 3 (checkpoints, TaskCreate), Pillar 4 (lean orchestrator) |
| `worktree-implementation-workflow.md` | Pillar 3 (progress file, TOUCHBACK), Pillar 4 (phase decomposition), Pillar 5 (verification gates) |
| `fact-checking-workflow.md` | Pillar 5 (validation), Pillar 2 (multi-session structure) |
| `parallel-document-building.md` | Pillar 2 (batch sizing), Pillar 4 (context-efficient decomposition) |
| `implementation-plan-standard.md` | Pillar 1 (plan template, scaling guide), Pillar 5 (self-validation checklist, three-tier AC) |

When in doubt about HOW to orchestrate, consult the tactical rule files.
When in doubt about WHETHER or WHY to orchestrate, consult this standard.
