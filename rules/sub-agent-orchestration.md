# Sub-Agent Orchestration Policy

**DEFAULT**: Use **2-3 sub-agents in parallel** for most tasks. **HARD LIMIT: Never run more than 3 background agents concurrently.**

## MANDATORY Pre-Flight Gate (BLOCKING)

**CRITICAL**: Before launching ANY sub-agent, skill invocation, or Task tool call, the orchestrator MUST verify ALL of the following. This is a BLOCKING requirement -- execution CANNOT proceed until all items are checked.

### Pre-Flight Checklist (MUST complete before ANY agent launch)

0. [ ] **Intent captured**: User's WHY, desired experience, and preservation requirements documented. If not asked yet -> STOP -> Ask via AskUserQuestion using intent discovery questions from `intent-encoding-standard.md`
1. [ ] **Phase 0 COMPLETE**: Clarifying questions asked AND answered by user (intent questions FIRST, then scope/requirements)
   - If no questions asked yet -> STOP -> Ask via AskUserQuestion
   - Minimum questions for research: intent, scope, quality, purpose, output format, priority areas
2. [ ] **Phase 1 COMPLETE**: Context gathered (1-5 tool calls by orchestrator)
   - Read relevant local files, quick grep/glob, web fetch as needed
   - Context should inform agent prompt design
3. [ ] **Phase 1.5 COMPLETE**: Plan artifact exists with task-appropriate acceptance criteria
   - Plan written to progress file or dedicated plan document
   - Implementation tasks: Three-tier AC (Build Gate + Test Gate + Integration Gate) + test inventory per phase
   - Research tasks: Confidence thresholds + source coverage + question completeness per round
   - Content tasks: Decision tiering + provenance tags + consistency criteria per section
4. [ ] **Phase 2 COMPLETE**: Agent prompts engineered with gathered context
   - Each agent has a specific, focused assignment
   - Each agent prompt includes file paths, return format, output location
5. [ ] **TaskCreate entries created** for all phases including TOUCHBACK checkpoints
6. [ ] **Progress file created** at `thoughts/[type]/YYYY-MM-DD-[slug]/progress.md`
7. [ ] **Pre-existing artifact inventory** completed (for content generation/document workflows)
   - Catalog what already exists (complete, partial, empty)
   - Determine per-artifact handling: SKIP (already done), REUSE (incorporate as-is), PRESERVE + extend, GENERATE (create from scratch)

### Anti-Pattern: Skill/Command Shortcut Bypass

**DO NOT** treat pre-built commands (`/ultra-research`, `/ktown-research`, etc.) as substitutes for orchestrator-level orchestration. Even when using these commands:
- The ORCHESTRATOR still performs Phases 0-2
- The ORCHESTRATOR still creates TaskCreate entries and progress file
- The command/skill is ONE AGENT in Phase 3, not the entire workflow
- Launch the command alongside other parallel agents, not as a standalone

**Violation Example**:
- User: "Research X comprehensively"
- WRONG: `Skill(skill: "ultra-research")` -> done
- RIGHT: Phase 0 (clarify) -> Phase 1 (context) -> Phase 2 (design prompts) -> Phase 3 (launch 2-3 agents per batch including research-specialists) -> Phase 4 (synthesize)

## Core Philosophy: Context-First Orchestration

**PRINCIPLE**: Gather high-level context to craft excellent prompts, then delegate deep work to sub-agents.

**Context Gathering ≠ Doing the Work**
- ✅ Reading files, quick grep, web fetch → Context gathering (orchestrator does this)
- ❌ Deep analysis, comprehensive research, implementation → Sub-agent work

### The 6-Phase Pattern

```
Phase 0: ASSESS & CLARIFY
├── Trivial? → Do directly
├── Complex? → DISCOVER INTENT FIRST:
│   ├── Why does this matter? What purpose does it serve?
│   ├── How should it feel? What experience matters?
│   └── What must be preserved even if "suboptimal"?
│   THEN ask scope/requirements questions:
│   └── Scope, quality level, purpose, priorities, format, constraints
└── ONLY proceed after understanding intent AND expectations

Phase 1: CONTEXT GATHERING (orchestrator: 1-5 tool calls)
├── Internal: Read key files, quick grep/glob
└── External: Web fetch job descriptions, company info

Phase 1.5: PLAN MODE (invoke EnterPlanMode tool for Medium+ tasks)
├── Follow implementation-plan-standard.md template (or task-type equivalent)
├── Scale depth to task complexity (see Scaling Guide)
├── Define acceptance criteria per phase (task-type-appropriate):
│   ├── Implementation: Three-tier verification (Build + Test + Integration gates)
│   ├── Research: Confidence thresholds, source coverage, question completeness
│   └── Content: Decision tiering, provenance tags, consistency criteria
├── Self-validate against compliance checklist
├── Propose artifact structure to user, get confirmation
├── Write plan artifact to progress file
└── Exit plan mode (ExitPlanMode) when plan is complete

Phase 2: PROMPT ENGINEERING (based on the plan)
├── Synthesize context, identify agent focus areas
└── Design parallel vs sequential execution

Phase 3: DELEGATION
├── Launch 2-3 agents IN PARALLEL with rich prompts (max 3 concurrent)
├── Include FACT-CHECKER agent at end of each round
└── Use research-specialist for ALL research work

Phase 4: SYNTHESIS & VALIDATION
├── Receive agent summaries (not full content)
├── Launch 1-3 additional rounds if gaps found
├── Run cumulative verification (implementation: full three-tier cascade)
└── Synthesize into final deliverable
```

## When to Use Sub-Agents

| Task Type | Agents | Rounds |
|-----------|--------|--------|
| Research | 2-3 | 2-4 |
| Codebase exploration | 2-3 | 1-2 |
| Implementation planning | 2-3 | 2-3 |
| Bug investigation/validation | 2-3 | 1-3 |
| Documentation creation | 2-3 | 2-4 |
| Large scope tasks | 2-3 | 3-5 |

**Skip sub-agents for**: Quick fact-checks, single-file reads, simple questions, tasks requesting "quick" responses.

## Plan-Mode Orchestration (Content Generation Workflows)

**When to use**: Workflows where agents generate content that simulates human decisions, voice, or preferences (game design documents, business plans, creative briefs, policy documents).

**Additional patterns required** (beyond standard orchestration):
1. **Voice Profile**: Create a multi-dimensional voice profile document from user's prior work and Phase 0 Q&A (business, creative, technical, anti-patterns, vocabulary)
2. **Source Authority Hierarchy**: Rank all reference documents; include in every agent prompt
3. **Answer Sourcing Tags**: Every generated answer tagged [SOURCED], [INFERRED], or [SIMULATED]
4. **Decision Tiering**: Classify decisions as Strategic/Tactical/Detail to reduce review burden
5. **Numbers Registry**: Shared state file for quantitative consistency
6. **Forward-Reference Markers**: Explicit placeholders for unresolved dependencies
7. **Consistency Passes**: Dedicated agents that resolve forward-reference markers after dependencies complete
8. **Human Review Gates**: Blocking gates after every phase with Go/Adjust/No-Go or Continue/Revise/Halt protocols

**Context engineering for content generation**:
- Default agent cap: 20K tokens input
- Synthesis agents: 30K cap
- Special-case agents: 35K cap (must justify)
- Use Context Briefs for large reference docs
- Use section excerpts instead of full documents
- Create dependency summaries (~500 words) for downstream agents

**Pre-execution validation**: Run 3 validation agents (feasibility, edge cases, dependencies) on the plan before execution. Fix high-confidence issues; document low-confidence flags.

## Agent Types

| Agent Type | Use For |
|------------|---------|
| `Explore` | Codebase exploration, file discovery |
| `Plan` | Implementation planning, architecture |
| `research-specialist` | **ALL research** - deep analysis, web research, multi-round workflows |
| `discovery-agent` | File/function location |
| `implementation-specialist` | Code writing, building |
| `web-search-researcher` | **QUICK LOOKUPS ONLY** - single fact checks |
| `codebase-analyzer` | Detailed implementation analysis |

**⚠️ CRITICAL**: Use `research-specialist` (not `web-search-researcher`) for any orchestrated/comprehensive research.

## Phase 2.5: Architecture Design Agents

**MANDATORY for 7+ research agents**. Delegate prompt design to Plan agents.

```
Phase 1: Explore agents (2-4) → Understand landscape
Phase 2: Orchestrator synthesizes explore findings
Phase 2.5: Plan agents (2-4) → Design research prompts
├── Each writes architecture/[domain]-prompts.md
└── Orchestrator receives SUMMARIES ONLY
Phase 3: Research agents → Execute designed prompts
Phase 4: Synthesis agent → Consolidate
```

## Plan Mode Protocol (Phase 1.5)

**Plan Mode is MANDATORY for ALL Medium+ tasks** after Phase 0 and Phase 1 are complete. No exceptions — even for "plan how to plan" tasks.

### Universal Trigger

Every Medium+ task must produce a **written plan artifact** before execution begins. The plan is the ground truth for all subsequent phases. Plan mode means: read-only exploration, design the plan, define acceptance criteria, write the plan to disk, then exit.

### How to Enter Plan Mode

When Phase 1.5 is triggered (Medium+ task detected after Phases 0 and 1):
1. **Invoke the EnterPlanMode tool** — this is the CLI mechanism for Phase 1.5
2. The system will restrict you to read-only operations + plan file writing
3. Follow the Implementation Plan Flow from `implementation-plan-standard.md`
4. When plan is complete and self-validated, invoke ExitPlanMode

**Guard clause**: If already in plan mode (system reminder indicates plan mode is active), skip EnterPlanMode invocation and proceed directly to Phase 0 clarification.

### What Plan Mode Produces

A plan artifact written to the standard progress file location (`thoughts/[type]/YYYY-MM-DD-[slug]/progress.md` or a dedicated plan document). The plan becomes the contract between planning and execution phases.

### Execution Sequence

```
Enter plan mode → Read relevant files → Design phased plan
→ Define task-appropriate AC per phase → Write plan to disk → Exit plan mode
→ Proceed to Phase 2 (prompt engineering based on the plan)
```

### Plan Content by Task Type

| Task Type | Plan Must Contain | Acceptance Criteria Type |
|-----------|------------------|------------------------|
| **Implementation** | Phase breakdown, file inventory, three-tier verification gates, test inventory | Automated: exact commands + expected outputs per tier |
| **Research** | Research questions, source strategy, round structure, quality thresholds | Confidence levels, source coverage, question completeness |
| **Content Generation** | Section breakdown, voice profile, source authority hierarchy | Decision tiering, provenance tags, consistency pass criteria |
| **Meta-Planning** | What to investigate, target plan structure, quality criteria for the plan itself | Completeness of coverage, specificity of AC, dependency correctness |

### Acceptance Criteria for Implementation Plans

The **Three-Tier Verification Model** applies to every phase of implementation plans:

#### Tier 1: Build Gate (BLOCKING)
- **What**: Typecheck, lint, build
- **When**: After every phase
- **Rule**: Must pass before Tier 2 runs

#### Tier 2: Test Gate (BLOCKING, cumulative)
- **What**: New unit tests for this phase + ALL prior unit tests (regression)
- **When**: After every phase
- **Rule**: Must pass before Tier 3 runs. Cumulative means Phase 3's Test Gate runs ALL tests from Phases 1-3.

#### Tier 3: Integration Gate (BLOCKING, cumulative)
- **What**: New E2E/Playwright tests for this phase + ALL prior E2E tests (regression)
- **When**: After every phase
- **Rule**: Must pass before TOUCHBACK. Even phases with no new E2E tests still run the full E2E suite as a regression check.

#### Manual Verification (non-blocking)
- **What**: User review items, visual checks, UX validation
- **When**: Documented per phase, reviewed at human review gates

#### Verification Cascade

```
Phase N complete
    ↓
Tier 1: Build Gate → FAIL → fix → retry (max 3) → HALT
    ↓ PASS
Tier 2: Test Gate → FAIL → fix → retry (max 3) → HALT
    ↓ PASS
Tier 3: Integration Gate → FAIL → fix → retry (max 3) → HALT
    ↓ PASS
TOUCHBACK → proceed to Phase N+1
```

The cascade is ALL-OR-NOTHING per phase. No "we'll fix it next phase."

#### AC Quality Rules

Every acceptance criterion must be:
1. **Executable** — an exact command to run or exact check to perform
2. **Observable** — what "pass" looks like is unambiguous
3. **Deterministic** — same inputs produce same pass/fail result
4. **Independent** — each criterion tests one thing
5. **Cumulative** — includes regression checks from all prior phases

#### Test Inventory Format

Plans must include a test inventory mapping phases to tests:

| Phase | Test File | Type | New Tests | Cumulative Total |
|-------|-----------|------|-----------|-----------------|
| Phase 1 | `tests/unit/store.test.ts` | Unit | 5 | 5 |
| Phase 2 | `tests/unit/component.test.ts` | Unit | 8 | 13 |
| Phase 2 | `tests/e2e/feature.spec.ts` | E2E | 3 | 3 |
| Phase 3 | `tests/unit/integration.test.ts` | Unit | 4 | 17 |
| Phase 3 | `tests/e2e/feature.spec.ts` | E2E | 2 | 5 |

#### Test Quality Principles (Unit Tests)

These principles are requirements for all implementation plan tests:

1. **Test behavior, not implementation** — assert on outputs and observable effects, not internal state or method calls
2. **Prefer real implementations over test doubles** — only mock external I/O (network, disk, time). Over-mocking tests mocks, not code
3. **AAA pattern with descriptive naming** — Arrange-Act-Assert. Names: `[Unit] [Scenario] [Expected Result]`
4. **Convert every bug to a regression test** — when a bug is found and fixed, a test MUST be written that would have caught it
5. **Coverage as floor, not ceiling** — 70-80% minimum, critical paths at 90%+. Focus on meaningful behavior over coverage %
6. **Test edge cases that cause production bugs** — null/undefined, empty collections, boundary values, async races, error paths
7. **Use Vitest for speed** — prefer over Jest for TypeScript (10-20x faster). Use `--changed` during dev, full suite at phase boundaries, `--bail` in CI
8. **Test isolation is non-negotiable** — no shared mutable state, no execution order dependencies

#### Test Quality Principles (E2E/Playwright)

1. **Testing Trophy: 15-25 E2E tests max** — cover critical user journeys only. Push everything else to unit/integration tests
2. **Web-first assertions, never waitForTimeout** — use auto-retrying assertions (`expect(locator).toBeVisible()`). NEVER use `waitForTimeout()`
3. **Debug state exposure for canvas/WebGL** — expose game state via `window.__[feature]Debug`. Playwright cannot interact with canvas content directly
4. **Fixtures + lightweight POM** — worker-scoped fixtures for server lifecycle, test-scoped for page/room setup
5. **Full test isolation enables parallelism** — each test creates and cleans its own state
6. **`--use-gl=swiftshader` for CI WebGL** — software rendering in headless CI. Chromium-only (Firefox headless lacks WebGL)
7. **Trace on first retry, screenshots on failure** — `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`. Upload as CI artifacts
8. **Under 5 minutes for full E2E suite** — if exceeded, shard with `--shard=x/y`

#### Test Quality Checklist (Per Phase)

```
#### Test Quality (applies to all phases with tests)
- [ ] Tests assert behavior, not implementation details
- [ ] No mocks except for external I/O (network, disk, time)
- [ ] Test names follow [Unit] [Scenario] [Expected] format
- [ ] Edge cases covered: null/undefined, empty, boundary, error paths
- [ ] E2E tests use web-first assertions (no waitForTimeout)
- [ ] E2E canvas tests use debug state exposure, not DOM scraping
- [ ] All tests are isolated (no shared mutable state, no ordering dependency)
```

### Acceptance Criteria for Research Plans

- **Confidence threshold** per finding: default >=95%
- **Source coverage**: minimum N authoritative sources per major claim (official docs, not blog posts)
- **Question completeness**: every question defined in the plan must be answered
- **Fact-check pass**: independent verification agent confirms claims

### Acceptance Criteria for Content Generation Plans

Content generation tasks use the patterns defined in the "Plan-Mode Orchestration" section above: Voice Profile, Source Authority Hierarchy, Answer Sourcing Tags, Decision Tiering, Numbers Registry, Forward-Reference Markers, Consistency Passes, and Human Review Gates. The plan must specify which of these patterns apply and define measurable criteria for each.

## Hypothesis Validation Pattern (PRE-FIX)

**Purpose**: Validate hypothesis completeness BEFORE applying any fix.

**Key Principles**:
- PRE-FIX timing (validate before code changes)
- Unbiased agents (don't share your reasoning)
- 3-5 parallel agents with different perspectives
- Scoring: Confidence, Completeness, Risk (1-10 each)

**Agent Perspectives**: Pattern Validator, Code Auditor, Root Cause Analyst, Framework Expert, Synthesis Agent

**Validation Flow**:
```
Hypothesis formed → Launch 3-5 unbiased agents → Score verdicts
├── All VALID (≥7) → Apply fix
└── Any gaps → Revise → Re-validate (max 2 rounds)
```

**🚨 USER CONFIRMATION RULE**: NEVER mark fix as "resolved" until user explicitly confirms. Use PENDING status until confirmation.

## Plan Validation Pattern (PRE-EXECUTION)

**Purpose**: Validate plan completeness and feasibility BEFORE execution begins.

**When to use**: Any plan with 20+ tasks or 3+ phases.

**Process**:
1. Draft the plan (v1)
2. Launch 3 validation agents in parallel:
   - **Feasibility Agent**: Can each agent complete its task within context limits? Are token budgets realistic?
   - **Edge Case Agent**: What happens when agents produce unexpected output? Are failure paths defined?
   - **Dependency Agent**: Are all inter-task dependencies correct? Are circular dependencies resolved?
3. Collect findings. Apply >95% confidence threshold:
   - High-confidence issues (>95%): FIX before execution
   - Low-confidence flags (<95%): DOCUMENT for monitoring during execution
4. Produce v2 with numbered amendments (Problem + Fix format)
5. OPTIONAL: Run a second validation round on v2 for critical plans
6. Version-track all amendments

**Agent Return Format**:
- Issue severity: Critical / Major / Minor
- Confidence: Percentage
- Location: Task ID or plan section
- Recommendation: Specific fix

## Lean Orchestrator Pipeline

### Core Principles
1. Use `research-specialist` for ALL research agents
2. Orchestrator receives **summaries only** - never read full artifacts
3. Agent-to-agent piping via **file paths**
4. Standardized artifact naming

### Source Authority Hierarchy

**When to use**: Any workflow with 3+ reference documents that may contain conflicting information.

**Protocol**:
1. During Phase 1 context gathering, identify ALL reference documents
2. Rank them by authority (highest to lowest)
3. Include the hierarchy in EVERY agent prompt
4. Rule: When sources conflict, defer to higher-authority source

**Ranking criteria**:
- Direct user statements > Approved prior work > Authoritative plans > Research/analysis > Codebase state > External references

**Example**:
| Rank | Source | Authority Basis |
|------|--------|----------------|
| 1 | User's Phase 0 answers | Direct from stakeholder |
| 2 | Previously approved deliverables | Human-reviewed and accepted |
| 3 | Project plans/outlines | Authoritative structure |
| 4 | Research documents | Analytical, may be dated |
| 5 | Codebase | Current state, not future intent |
| 6 | External references | Lowest -- rough context only |

### Agent Return Protocol (MANDATORY)

**Add to EVERY agent prompt**:
```
**RETURN FORMAT** (MANDATORY):
**AGENT COMPLETE**: [Your assigned focus]
**OUTPUT FILE**: [Full path where you wrote your artifact]
**SUMMARY**: [2-3 sentences of key findings]
**KEY FINDING**: [Most important single insight]

Do NOT include full content - only the summary.
```

**For content generation and implementation agents, add this field**:
```
**INTENT ALIGNMENT**: [Brief statement on how output aligns with stated intent]
```

**For content generation agents, also add these fields**:
```
**DRAFT DECISIONS**: [Count of [DRAFT DECISION] markers]
**DEFAULT DECISIONS**: [Count of [DEFAULT DECISION] markers]
**SIMULATED ANSWERS**: [Count of [SIMULATED] tags]
**NUMBERS ADDED TO REGISTRY**: [Count]
**PENDING MARKERS**: [Count and type of forward-reference markers]
```

### Agent Prompt Intent Block (MANDATORY)

**Add INTENT CONTEXT block to every agent prompt** (populated from Phase 0 intent capture):

```
INTENT CONTEXT (from user):
- Purpose: [why this matters]
- Desired experience: [how it should feel]
- Preserve: [qualities that must survive]
- Anti-patterns: [what this must NOT become]
```

If intent was not captured (e.g., trivial/small tasks), omit the block. For Medium+ tasks, this block is mandatory.

### Trimming Policy: Inline for Agents, Reference for Orchestrator

Rules files may use references to canonical sources (the ORCHESTRATOR has all rules loaded). When constructing SUB-AGENT prompts, the orchestrator MUST inline relevant definitions — do NOT pass file references and expect sub-agents to self-serve.

For Three-Tier Verification, the agent-ready inline version is:
> "Run [typecheck + build] (Tier 1) → [unit tests] (Tier 2) → [E2E tests] (Tier 3). All three must pass. If any fails, fix and retry up to 3 times."

### File Path Conventions

```
thoughts/[type]/YYYY-MM-DD-[slug]/
├── progress.md                    (ALWAYS create)
├── R1-01-[perspective].md         (Round 1)
├── R2-01-[task].md                (Round 2)
├── R3-synthesis.md                (Round 3)
└── FINAL-[Topic]-[Type].md        (Final)
```

| Type | Directory |
|------|-----------|
| Research | `thoughts/research/` |
| Plans | `thoughts/plans/` |
| Debug | `thoughts/debug/` |
| Project-specific | `[Project]/thoughts/[type]/` |

**Dependency Summary Artifacts**: For multi-tier/multi-phase workflows, create condensed summaries (~500 words each) of completed artifacts for downstream agent consumption. Store in a `Summaries/` subdirectory:
```
thoughts/[type]/YYYY-MM-DD-[slug]/
├── Summaries/
│   ├── Summary-Section-1-[Name].md
│   ├── Summary-Section-2-[Name].md
│   └── ...
```
Downstream agents read summaries by DEFAULT. Full artifacts are referenced only when specific detail is needed.

### Shared State Files

**When to use**: Any workflow where multiple agents must maintain quantitative or referential consistency (e.g., economic values, capacity numbers, feature names, API endpoints).

**Protocol**:
1. Create shared state file(s) during Phase 0
2. Initialize with known values from prior work
3. Every agent that PRODUCES quantitative decisions: READ registry before writing, APPEND new decisions after writing, FLAG conflicts with existing entries
4. Every agent that CONSUMES quantitative decisions: READ registry as input context
5. Format: `| Metric | Value | Defined In | Dependencies |`

**Example**: A Numbers Registry for a game design document tracks player counts, currency earning rates, item prices, and energy caps -- ensuring all sections reference the same values.

**Conflict resolution**: When an agent discovers a conflict between their output and the registry, they flag it as `[CONFLICT: Registry says X, this section implies Y]` and do NOT silently override.

### Forward-Reference Markers

**When to use**: Any workflow with circular or out-of-order dependencies where content must be drafted before its dependencies are complete.

**Protocol**:
1. During planning, identify sections with incomplete dependencies
2. In agent prompts, instruct agents to use explicit markers:
   - `[PENDING <TOPIC> -- will be updated after <Phase/Tier>]`
   - `[PENDING <SECTION> CONSISTENCY]`
3. Schedule consistency passes after the dependency becomes available
4. Consistency pass agents: grep for markers, resolve each one, remove marker

**Consistency Pass Schedule**: Document in the plan which markers get resolved after which phase. Example:
- After Tier 3: Resolve `[PENDING WORLD CONTEXT]` markers
- After Tier 5: Resolve `[PENDING ECONOMY/NFT]` markers

## Checkpoint Protocol

**Write checkpoints after EVERY phase/round** for session recovery.

### Checkpoint Format
```markdown
### Checkpoint - [YYYY-MM-DD HH:MM]
**Phase Completed**: [Phase/Round N: Name]
**Artifacts Created**: [file paths]
**Agent Summaries**: [key findings per agent]
**Next Phase**: [Phase/Round N+1]
**Recovery Action**: [What to do if resuming here]
```

### Progress File Template
Create at workflow start: `thoughts/[type]/YYYY-MM-DD-[slug]/progress.md`

```markdown
# [Workflow Name] Progress
**Started**: YYYY-MM-DD HH:MM
**Status**: IN_PROGRESS | COMPLETED | BLOCKED

## Checkpoints
[Add checkpoint after each phase/round]
```

### Agent Batch Verification (After Every Batch)

After each parallel agent batch completes, verify:
1. **File existence**: All expected output files exist and are non-empty
2. **Size validation**: File sizes within expected range for their type
3. **Marker presence**: Required markers/tags present (e.g., sourcing tags, decision markers)
4. **Retry protocol**: If any check fails, re-launch failed agent with same prompt (max 2 retries)
5. **Escalation**: If retry fails, document the failure in progress.md and flag for orchestrator intervention

## TaskCreate Integration

**Use TaskCreate (not TodoWrite) for multi-phase orchestration**.

### Task Pattern with Checkpoints

**For implementation tasks** — VERIFY tasks as first-class blocking dependencies:
```
TaskCreate: "Phase 0: Clarify requirements"
TaskCreate: "Phase 1: Gather context"
TaskCreate: "Phase 1.5: Plan mode — design plan with acceptance criteria"
TaskCreate: "📍 CHECKPOINT: Write plan to progress file"
TaskCreate: "Phase 3 R1: Implement plan Phase 1"
TaskCreate: "🔒 VERIFY: Three-tier gates for plan Phase 1"  ← BLOCKING
TaskCreate: "📍 CHECKPOINT: Update progress.md"
TaskCreate: "Phase 3 R2: Implement plan Phase 2"
TaskCreate: "🔒 VERIFY: Three-tier gates for plan Phase 2"  ← BLOCKING
TaskCreate: "📍 CHECKPOINT: Update progress.md"
[Continue pattern...]
```

**For research tasks** — VALIDATE tasks as first-class blocking dependencies:
```
TaskCreate: "Phase 0: Clarify requirements"
TaskCreate: "Phase 1: Gather context"
TaskCreate: "Phase 1.5: Plan mode — design research plan with quality criteria"
TaskCreate: "📍 CHECKPOINT: Write plan to progress file"
TaskCreate: "Phase 3 R1: Execute research round 1"
TaskCreate: "🔒 VALIDATE: Fact-check R1 findings against AC"  ← BLOCKING
TaskCreate: "📍 CHECKPOINT: Update progress.md"
[Continue pattern...]
```

VERIFY/VALIDATE tasks are NOT optional — the next phase is blocked by the previous phase's verification.

### Checkpoint Task Protocol
1. **READ progress.md** first
2. **UPDATE progress.md** with timestamp, completed phase, artifacts, next phase
3. **ONLY THEN** mark checkpoint complete

**Anti-Patterns**:
- ❌ Complete round without updating progress.md
- ❌ Mark checkpoint complete without reading progress.md
- ❌ Skip checkpoint tasks

## HTML Presentation Auto-Trigger

**When**: After ANY workflow writes a `FINAL-*.md` or completes a major deliverable document.

**Trigger sequence** (runs AFTER progress file update AND daily note entry):
1. Orchestrator detects a final deliverable was written (filename contains `FINAL-` or is a major synthesis document)
2. Ask user: "Would you like an HTML presentation of this report?"
3. **If YES**: Invoke the `present-report` skill with the document path. The skill reads the markdown, analyzes content structure, detects project styling (style.yaml/brand.json), and generates a self-contained HTML presentation in the same directory.
4. **If NO**: Skip. Log in progress file that presentation was declined.

**Standalone invocation**: Users can also run `/present <path-to-markdown>` to generate an HTML presentation from any existing markdown document at any time.

**Integration with orchestration phases**:
```
... → Final TOUCHBACK (update progress.md) → Daily note entry → HTML Presentation offer → WORKFLOW COMPLETE
```

## Token Limit Recovery

When agent hits token limit:
1. Detect (truncated output, incomplete analysis)
2. Launch 2-3 new agents to complete remaining work
3. Each gets: original scope, progress summary, specific portion, integration instructions
4. Synthesize outputs into unified deliverable

## Quick Reference

**Standard task**: Clarify → Context → **Plan mode (write plan with AC)** → Design prompts → Launch 2-3 agents + Fact-Checker → Synthesize

**Implementation task**: Clarify → Context → **Plan mode (three-tier AC + test inventory)** → Design prompts → Implement Phase 1 → **Three-tier verification** → TOUCHBACK → Phase 2 → ...

**Large task**: Add Phase 2.5 (Plan agents), use 3-5 rounds of 2-3 agents each, checkpoint after each

**Bug fix**: Form hypothesis → PRE-FIX validation (3-5 unbiased agents) → Apply only when VALID → PENDING until user confirms

**Golden Rules**:
- Clarify scope/quality before starting
- **Always plan before executing** (Phase 1.5 for ALL Medium+ tasks)
- Every round needs a fact-checker
- **Test as you go** — full cumulative test suite at every phase boundary
- Never apply fix without pre-validation
- Never claim "resolved" without user confirmation
- Orchestrator receives summaries only
- Always create progress.md
- Always use TaskCreate for orchestration

## Checklist

Before multi-agent workflow:
- [ ] TaskCreate for all phases
- [ ] 📍 Checkpoint tasks after every phase/round
- [ ] **Phase 1.5 plan artifact exists** with task-appropriate AC per phase
- [ ] Implementation plans: three-tier AC (Build + Test + Integration gates) + test inventory
- [ ] Research plans: confidence thresholds + source coverage + question completeness
- [ ] Progress file at `thoughts/[type]/YYYY-MM-DD-[slug]/progress.md`
- [ ] Phase 2.5 if 7+ research agents
- [ ] Agent prompts include summary-only return format
- [ ] Agent prompts specify exact output file path
- [ ] 🔒 VERIFY/VALIDATE tasks as blocking dependencies between phases
- [ ] Fact-checker in each round
- [ ] HTML presentation offered after final deliverable (present-report skill)
