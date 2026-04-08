# Parallel Document Building Pattern

**Purpose**: Standard approach for building large, comprehensive documents using multiple sub-agents working in parallel without write conflicts.

## The Problem

When multiple sub-agents need to contribute to a single large document, simultaneous edits cause:
- Write conflicts and race conditions
- Agents reading stale versions of the document
- Repeated re-reads adding latency
- Lost or overwritten content

## The Solution: Separate Files → Synthesis

**Each agent writes to a SEPARATE file**, then a synthesis step combines them.

## Execution Pattern

```
Phase 1: Create Skeleton
- Main agent creates outline/scaffold document
- Define all sections, subsections, placeholders

Phase 2: Parallel Content Population
- Create output directory for content files
- Launch agents in batches (max 3 concurrent)
- Each agent writes to uniquely named file
- File naming convention: {Tier}-{Section}-{Topic}.md

Phase 3: Synthesis
- After each batch completes, combine files into master document
- Use concatenation or structured merge
- Verify completeness against skeleton
```

## File Naming Convention

```
{OutputDir}/
├── T1-1.1-Topic-Name.md          (Agent 1)
├── T1-1.2-Topic-Name.md          (Agent 2)
├── T1-1.3-Topic-Name.md          (Agent 3)
└── ...etc
```

## Batching Strategy

- **Constraint**: Max 3 sub-agents concurrent (hard limit)
- **Approach**: Group related categories into batches of ≤3 agents
- **Sizing**: 1-3 agents per batch depending on complexity
- **Sequence**: Complete and synthesize one batch before starting next

## Context Brief Pre-Processing

**When to use**: When agents need to reference a large document (>20KB) that serves as background context rather than primary input.

**Protocol**:
1. Before launching content agents, create a "Context Brief" (~5-8KB) that condenses the large document
2. Include: key facts, current state, strategic decisions, and a STALE DATA WARNING if the source is >3 months old
3. All agents receive the Context Brief instead of the full document
4. Full document path provided for agents that need specific details (rare)

**Benefits**: Reduces per-agent context overhead from ~14K tokens to ~2K tokens, enabling more room for section-specific inputs.

## Example: Study Guide Build

| Batch | Categories | Agents | Output Files |
|-------|------------|--------|--------------|
| Batch 1 | MITRE + IAM | 1 + 5 = 6 | 6 files |
| Batch 2 | Endpoint + Email | 5 + 4 = 9 | 9 files |
| Batch 3 | Cloud Security | 4 | 4 files |

## Agent Prompt Template

Each content agent should receive:
1. **Section assignment**: Specific section(s) from the skeleton
2. **Output file path**: Where to write their content
3. **Format requirements**: Heading levels, structure expectations
4. **Depth expectations**: Level of detail required
5. **Cross-reference instructions**: How to link to other sections

### MANDATORY: Agent Return Protocol

**Add to EVERY agent prompt**:

```
**RETURN FORMAT** (MANDATORY):
When complete, end your response with EXACTLY this format:

**AGENT COMPLETE**: [Your section assignment]
**OUTPUT FILE**: [Full path where you wrote content]
**SUMMARY**: [2-3 sentences describing what you wrote]
**WORD COUNT**: [Approximate word count of content]

Do NOT include the full content in your response.
The synthesis step will read your file directly.
```

This enables the orchestrator to stay lean (~100 words per agent vs ~2,000+ words).

## TaskCreate Integration for Batches

**Use TaskCreate to track batch progress**:

```
# At workflow start
TaskCreate: "Batch 1: MITRE + IAM sections (6 agents)"
TaskCreate: "Batch 2: Endpoint + Email sections (9 agents)"
TaskCreate: "Batch 3: Cloud Security sections (4 agents)"
TaskCreate: "Synthesis: Combine all batches into master document"

# Set dependencies
TaskUpdate: taskId="batch-2", addBlockedBy=["batch-1"]
TaskUpdate: taskId="batch-3", addBlockedBy=["batch-2"]
TaskUpdate: taskId="synthesis", addBlockedBy=["batch-3"]
```

**Update task status** as each batch completes before starting next batch.

## Synthesis Process

After each batch:
1. Read all output files from the batch
2. Insert content into master document at appropriate locations
3. Verify no sections were missed
4. Clean up formatting inconsistencies
5. Update document metadata (version, last updated)

## When to Use This Pattern

- Documents with 10+ sections requiring deep content
- Research compilations with multiple domains
- Study guides, training materials, comprehensive documentation
- Any document too large for single-agent generation

## When NOT to Use

- Small documents (< 5 sections)
- Documents requiring tight cross-section coherence
- Real-time collaborative editing scenarios
