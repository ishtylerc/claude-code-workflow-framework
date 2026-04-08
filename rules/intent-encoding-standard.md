# Intent Encoding Standard

**Purpose**: Canonical reference for capturing, storing, and protecting intent throughout all orchestration workflows. Intent is the *why* behind decisions, the desired experience, and the qualities that must survive optimization.

---

## Intent vs Requirements vs Specs

| Layer | What It Captures | Example | Vulnerability |
|-------|-----------------|---------|---------------|
| **Intent** | WHY — purpose, desired experience, qualities that define "right" | "The water should feel alive, not just animated" | Highest — invisible, untested, first thing optimized away |
| **Requirements** | WHAT — functional capabilities, constraints, acceptance criteria | "Water must have ripple effects on interaction" | Medium — measurable but can drift from intent |
| **Specs** | HOW — implementation details, APIs, data structures | "Use sine wave displacement with 0.3 amplitude" | Lowest — concrete and verifiable |

**Key insight**: Intent is the most vulnerable layer in AI-assisted development because it is invisible, untested, and the first thing optimized away. A system can meet all requirements and specs while completely losing the intent that motivated them.

---

## Universal Intent Discovery Questions (Phase 0, Step 1)

**MANDATORY** before ANY other Phase 0 question for Medium+ tasks. These must be asked FIRST, before scope/requirements questions.

1. **Purpose**: "What's the purpose behind this? Not what you want built, but why it matters."
2. **Experience**: "How should this feel when it's done? What experience should users have?"
3. **Preservation**: "Are there qualities or characteristics that must be preserved, even if they're not strictly functional?"

**Usage**: Ask via AskUserQuestion. These three questions establish the intent layer that all subsequent requirements and specs must serve.

---

## Workflow-Specific Intent Questions

After the universal questions, ask workflow-specific intent questions as appropriate:

### Implementation Tasks
- "Are there intentional design choices in current code that might look suboptimal but carry meaning?"
- "What's the experience you're optimizing for — speed, elegance, reliability, delight?"

### Research Tasks
- "What decision will this research enable? What confidence would let you act?"
- "Is there a hypothesis you're testing, or are you exploring openly?"

### Content Generation Tasks
- "What voice/tone/personality should this carry? What should it NOT sound like?"
- "Who is the audience, and what should they feel after reading this?"

### Bug Fixes / Debugging
- "Beyond fixing the bug, is there an experience or behavior that should be restored?"
- "Was the broken behavior ever intentional? Should we preserve anything about how it worked before?"

---

## Project-Level Intent Document

For projects with ongoing development, maintain an `intent.md` at the project root.

### Template

```markdown
# [Project Name] Intent Document

**Last Updated**: YYYY-MM-DD

## Core Intent
[Why this project exists. Not what it does, but why it matters.]

## Design Intent
[How this should feel. The experiential qualities that define "right".]

## Architecture Intent
[Why the architecture is shaped the way it is. Intentional trade-offs.]

## Brand/Voice Intent
[Personality, tone, aesthetic — the qualities that make this recognizably "this project".]

## Intent Log

| Date | Context | Intent Captured | Source |
|------|---------|----------------|--------|
| YYYY-MM-DD | [What prompted the capture] | [The intent statement] | [User quote / Phase 0 answer] |
```

### When to Create
- When a project has 3+ implementation sessions
- When the user articulates strong preferences about how something should feel
- When intent is at risk of being lost across sessions

### When to Update
- After every Phase 0 that captures new intent
- When the user corrects a drift from intent ("that's not what I meant")
- When a design decision is made that reflects intent

---

## Inline Intent Section Format

Every implementation plan (Section 0) and progress file (top section) must include:

```markdown
## 0. Intent

**Why this matters**: [The purpose — not what's being built, but why]
**Desired experience**: [How this should feel for the user when complete]
**Qualities to preserve**: [Existing characteristics that must survive this change]
**Anti-patterns**: [What this should NOT become, even if functionally "better"]
```

This section uses the user's own words wherever possible — not paraphrased generically.

---

## "Intent in the Path" Principle

Intent must be present at every level of the orchestration pipeline:

### 1. Agent Prompts (MANDATORY)
Every agent prompt must include an INTENT CONTEXT block:

```
INTENT CONTEXT (from user):
- Purpose: [why this matters]
- Desired experience: [how it should feel]
- Preserve: [qualities that must survive]
- Anti-patterns: [what this must NOT become]
```

### 2. Plan Documents (Section 0)
Intent section is Section 0 (top) in plans — positioned before Context/Problem Statement so it's impossible to miss.

### 3. Progress Files (Top Section)
Intent summary appears at the top of progress files, after metadata and before checkpoints.

### 4. Pre-Flight Checklist
"Intent captured?" is a blocking item in the pre-flight checklist. No agents launch without documented intent.

---

## Intent Log Protocol

After capturing intent via Phase 0 questions:

1. Record the intent in the plan's Section 0 (inline intent)
2. If a project-level `intent.md` exists, append to the Intent Log table
3. Use the user's exact words in quotes where possible
4. Tag the source: `[Phase 0]`, `[Mid-session correction]`, `[Design review]`

---

## Intent Protection During Iteration

Intent is most at risk during optimization and iteration. Protect it through:

### Drift Detection
- When an agent proposes changes that affect experiential qualities, flag them: `[INTENT CHECK: This change affects {quality}. Original intent: {quote}]`
- During synthesis/validation phases, verify that outputs still serve the stated intent

### Agent Return Protocol Addition
For content generation and implementation agents, include:
```
**INTENT ALIGNMENT**: [Brief statement on how output aligns with stated intent]
```

### Anti-Patterns
- Optimizing away "inefficient" code that was intentionally designed for clarity/readability
- Replacing a distinctive voice with generic professional tone
- Simplifying UX in ways that remove character or personality
- Treating all existing patterns as "technical debt" when some are intentional design choices

---

## Integration Points

| File | How Intent Integrates |
|------|----------------------|
| `orchestration-quality-standard.md` | Pillar 1 enhanced with intent discovery; Phase 0 questions updated |
| `sub-agent-orchestration.md` | Phase 0 enhanced; pre-flight checklist updated; agent prompt template updated |
| `implementation-plan-standard.md` | Section 0 (Intent) added to template; Phase 0 questions updated; self-validation checklist updated |
| `CLAUDE.md` | Core Principle 5 added; rule file table updated |
