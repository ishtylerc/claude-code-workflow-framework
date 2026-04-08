# Comprehensive Fact-Checking Workflow

**Purpose**: Rigorous validation of comprehensive documents, research artifacts, or technical claims through multi-session, multi-round fact-checking with research-specialist sub-agents.

## When to Use

- Validating technical documentation before publication
- Fact-checking research artifacts or study guides
- Verifying claims in guides, tutorials, or playbooks
- Quality assurance on comprehensive deliverables
- Validating AI-generated content for accuracy
- **Validating execution plans before launch** (adapted workflow: agents check feasibility, dependencies, and context budgets instead of factual accuracy)

## Process Structure

**Multi-Session Approach**: 2-3 specialized sessions, each covering different aspects/sections of the document

**Each Session Has 3 Rounds**:
- **Round 1**: Internal Context Gathering (2-3 agents)
- **Round 2**: External Validation (3-4 agents)
- **Round 3**: Synthesis (1 agent)

## Configuration Parameters

**MANDATORY**: Use **AskUserQuestion** to gather requirements before starting:

1. **Session Structure**:
   - **Specialized sessions** (Recommended): Each session covers different sections (e.g., Session 1: Technical Architecture, Session 2: Implementation Details, Session 3: Workflows)
   - **Comprehensive sessions**: Each session covers entire document from start to finish

2. **Thoroughness Level**:
   - **Quick** (~15-20 min/session, 6-9 agents total): High-level sanity check
   - **Deep** (~30-45 min/session, 15-20 agents total) [Recommended]: Comprehensive fact-checking with source verification
   - **Ultra-thorough** (~60+ min/session, 20-30 agents total): Leave no stone unturned

3. **Fact-Check Priority**:
   - Factual accuracy only: Verify technical claims against official documentation
   - Assumption validation: Check if inferences and logical leaps are sound
   - Completeness check: Identify missing capabilities or limitations
   - **All of the above** [Recommended]: Comprehensive validation

4. **Error Tolerance**:
   - Flag everything: Report minor wording issues, ambiguities, improvements
   - **Critical issues only** [Recommended]: Report only factual errors, missing limitations, incorrect technical claims

## Execution Pattern

```
For each Session:

  Round 1: Internal Context Gathering (2-3 agents)
  ├── Agent 1: Analyze document + relevant internal documentation
  ├── Agent 2: Review codebase/test infrastructure/related systems
  └── Agent 3: Validate pattern assumptions and design decisions

  Round 2: External Validation (3-4 agents)
  ├── Agent 1: Verify technical claims against official documentation
  ├── Agent 2: Validate API/platform capabilities and limitations
  ├── Agent 3: Cross-check best practices and industry standards
  └── Agent 4: Research recent updates, changes, deprecations

  Round 3: Synthesis (1 agent)
  └── Agent 1: Consolidate findings → Session fact-check document
```

## TaskCreate Integration (MANDATORY)

**Use TaskCreate (not TodoWrite) for fact-checking orchestration**:

```
# At workflow start
TaskCreate: "Session 1: Technical Architecture fact-check (3 rounds)"
TaskCreate: "Session 2: Implementation Details fact-check (3 rounds)"
TaskCreate: "Session 3: Workflows fact-check (3 rounds)"

# Set dependencies for sequential sessions
TaskUpdate: taskId="session-2", addBlockedBy=["session-1"]
TaskUpdate: taskId="session-3", addBlockedBy=["session-2"]
```

**Update task status** as each session completes.

## Agent Return Protocol (MANDATORY)

**Add to EVERY fact-check agent prompt**:

```
**RETURN FORMAT** (MANDATORY):
When complete, end your response with EXACTLY this format:

**AGENT COMPLETE**: [Session N Round N Agent N: Focus]
**OUTPUT FILE**: [Full path to your findings file]
**ISSUES FOUND**: [Count of critical/recommendation/observation]
**SUMMARY**: [2-3 sentences of key findings]

Do NOT include full findings in your response.
The synthesis agent will read your file directly.
```

## Checkpoint Protocol (MANDATORY)

**Write checkpoint after EACH session completes**:

```markdown
### Checkpoint - [timestamp]
**Session Completed**: Session [N]: [Focus Area]
**Artifacts Created**:
- Session-N-Round-1-findings.md
- Session-N-Round-2-findings.md
- Session-N-[Section-Name]-Fact-Check.md
**Issues Found**: [X] critical, [Y] recommendations, [Z] observations
**Next Session**: Session [N+1]: [Focus Area]
```

Store checkpoints in: `thoughts/validation/YYYY-MM-DD-[doc-name]/progress.md`

## Output Artifacts

Each session produces: `Session-N-[Section-Name]-Fact-Check.md`

**Document Structure**:
- **Executive Summary**: High-level findings overview
- **Critical Issues** (MUST FIX): Factual errors, incorrect claims, dangerous misinformation
- **Recommendations** (SHOULD FIX): Missing context, incomplete information, potential improvements
- **Observations** (CONSIDER): Minor inconsistencies, style issues, optimization opportunities
- **Validation Summary**: What was checked, sources consulted, confidence level
- **Source Citations**: Links to official documentation, authoritative sources

## Example Invocation

```
User: "Orchestrate comprehensive fact-checking of [document-path]"

Step 1: Use AskUserQuestion to gather configuration:
├── Session structure (specialized vs comprehensive)
├── Thoroughness level (quick/deep/ultra-thorough)
├── Priority areas (factual/assumptions/completeness/all)
└── Error tolerance (flag everything vs critical only)

Step 2: Execute sessions sequentially:
├── Session 1: [Section A focus]
│   ├── Round 1: Internal context (2-3 agents)
│   ├── Round 2: External validation (3-4 agents)
│   └── Round 3: Synthesis (1 agent) → Document
├── Session 2: [Section B focus]
│   └── [Same 3-round structure]
└── Session 3: [Section C focus]
    └── [Same 3-round structure]

Step 3: Deliver fact-check documents to user
└── User can review findings and decide on fixes
```

## Naming Conventions (STANDARDIZED)

**MANDATORY**: Use these standardized naming patterns for all fact-checking workflows:

| Category | Format | Example |
|----------|--------|---------|
| **Session** | `Session [N]: [Section Focus]` | `Session 1: Technical Architecture & Platform Capabilities` |
| **Round** (fixed) | Round 1: Internal Context Gathering, Round 2: External Validation, Round 3: Synthesis | — |
| **Agent** | `Session [N] Round [N] Agent [N]: [Focus] Fact-Check` | `Session 1 Round 1 Agent 1: Claude Code Documentation Analysis Fact-Check` |
| **TaskCreate** | `Session [N]: [Focus] - Round [N]` | `Session 1: Technical Architecture - Round 1 (Internal Context)` |
| **Output File** | `Session-[N]-[Section-Name]-Fact-Check.md` | `Session-1-Technical-Architecture-Fact-Check.md` |
| **Daily Note** | Same as Agent format | `Session 3 Round 1 Agent 1: K-Town Test Infrastructure Fact-Check` |

**Rules**: Session names 3-7 words, capitalize major words. Output files use kebab-case. Agent designations end with "Fact-Check". Use TaskCreate (not TodoWrite) for orchestration tracking with `addBlockedBy` dependencies between rounds.

## Best Practices

1. **Document Input Clarity**: Provide clear file path to document being fact-checked
2. **Specialized Sessions Work Better**: Dividing document into logical sections (architecture, implementation, workflows) produces higher quality validation
3. **Balance Thoroughness with Time**: Deep validation (recommended) provides excellent coverage without excessive time investment
4. **Trust the Process**: Multiple rounds with different agent perspectives catch issues individual agents miss
5. **Synthesis is Critical**: Round 3 synthesis agent must consolidate ALL findings from previous rounds, not just summarize
6. **Follow Naming Conventions**: Use standardized naming patterns above for consistency across sessions

## When NOT to Use

- Quick spot-checks (single fact verification)
- Documents with < 3 major sections
- Content that doesn't contain verifiable claims (creative writing, opinion pieces)
- Time-sensitive quick reviews (use single agent analysis instead)
