---
allowed-tools: Task, Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, Bash, TodoWrite, AskUserQuestion
description: Multi-round orchestrated feature research with internal codebase analysis, external web research, and synthesis — produces a comprehensive research artifact for /plan
argument-hint: <feature description> [--quick] [--internal-only] [--project-root=PATH]
---

# /research — Orchestrated Feature Research

## Purpose

Produce a **comprehensive, citation-rich research artifact** for a feature, capability, or system change by orchestrating multiple sub-agent rounds. Output feeds directly into `/plan`.

This is the **rigorous** counterpart to `commands/research/research_codebase_generic.md` — use that for quick single-pass research, use this when you need:

- Deep internal codebase mapping (locations, behavior, patterns, history, risks, architecture)
- External web research across multiple domains (official docs, ecosystem, community, industry examples)
- Cross-validation, gap-filling, and synthesis
- A finished artifact that `/plan` can consume mechanically

**Philosophy**: LEAN TOWARD MORE AGENTS. When in doubt, research more thoroughly. The goal is a complete 360° view with verified facts from multiple sources.

---

## Multi-Round Architecture (MANDATORY)

| Round | Agents | Focus | Output |
|-------|--------|-------|--------|
| Round 1 | 8–10 (2 batches) | Internal codebase & prior context | `round-1-<slug>-consolidation.md` |
| Round 2 | 4–10 (parallel) | External web research (6 domains) | `round-2-<slug>-consolidation.md` |
| Round 3 | 2–4 (parallel) | Cross-validation, gap-filling, synthesis | Integrated into final |

**Round 1 batching** (max 3 concurrent sub-agents — hard limit):
- **Batch 1**: 5 core agents in parallel (locator, analyzer, pattern-finder, history, risks)
- **Batch 2**: 2 more (architect, consolidation-writer) + 0–2 optional expansion agents

**All rounds run by default.** `--quick` forces 4 agents/round minimum. `--internal-only` skips Round 2.

---

## Configuration: workflow-config.json

This command (and the rest of the orchestrated trio) reads `.claude/workflow-config.json` from the project root for project-specific settings. Example:

```json
{
  "project_root": ".",
  "research_output_dir": "thoughts/research",
  "plan_output_dir": "thoughts/plans",
  "implementation_output_dir": "thoughts/implementation",
  "test_commands": {
    "typecheck": "npm run typecheck",
    "lint": "npm run lint",
    "build": "npm run build",
    "test_unit": "npm run test:unit",
    "test_e2e": "npm run test:e2e",
    "test_e2e_full": "npm run test:e2e:full",
    "test_full": "npm test"
  },
  "skill_tree_paths": [
    ".claude/skills/software-development"
  ],
  "external_research_domains": {
    "official_docs": ["https://example.com/docs"],
    "ecosystem_repos": ["https://github.com/example/example"]
  }
}
```

**If `.claude/workflow-config.json` is absent**: defaults apply (output to `thoughts/`, `npm` test commands, no extra skill tree). Commands run fine; users with non-Node projects should create the config file before first use.

---

## Step-by-step Instructions

### 1. Parse arguments and load config

```
/research <feature description> [--quick] [--internal-only] [--project-root=PATH]
```

- Extract feature description from `$ARGUMENTS`
- Check for `--quick` (force 4 agents/round) and `--internal-only` (skip Round 2)
- Resolve `--project-root` (default: current working directory)
- Load `.claude/workflow-config.json` from project root if present; fall back to defaults

### 2. Complexity analysis (determine agent count)

**LEAN TOWARD MORE AGENTS. When in doubt, use more.**

| Complexity Indicator | Agent Increase |
|----------------------|----------------|
| Multiple systems involved | +2 |
| Cross-cutting concerns (networking, persistence, UI) | +2 |
| Novel/unfamiliar domain | +1 |
| Performance-critical feature | +1 |
| User-facing feature requiring UX research | +1 |
| Integration with external services | +1 |

**Formula**: base 4 + indicators, max 10. Default bias: 6–8 for moderate complexity. `--quick` forces 4.

State your complexity analysis explicitly before launching agents.

### 3. Create output directory

```bash
SLUG="<feature-slug>"  # lowercase-hyphenated from feature description
DATE=$(date +%Y-%m-%d)
mkdir -p "<research_output_dir>/${DATE}-${SLUG}/round-1"
mkdir -p "<research_output_dir>/${DATE}-${SLUG}/round-2"
mkdir -p "<research_output_dir>/${DATE}-${SLUG}/round-3"
```

`<research_output_dir>` comes from workflow-config.json (default: `thoughts/research`).

### 4. Initialize TaskCreate tracking

Create one task per agent + one per consolidation step + one for the final artifact. Use the Phase/VERIFY/TOUCHBACK pattern from `rules/sub-agent-orchestration.md`.

```
- Complexity analysis: [N] agents per round
- Round 1 Batch 1: R1-Codebase-Locator
- Round 1 Batch 1: R1-Codebase-Analyzer
- Round 1 Batch 1: R1-Codebase-Pattern-Finder
- Round 1 Batch 1: R1-History-Context
- Round 1 Batch 1: R1-Risks-Gotchas
- Round 1 Batch 2: R1-Architecture-Analyst
- Round 1 Batch 2: R1-Consolidation-Writer
- Round 1 Batch 2: [0-2 expansion agents]
- Round 2: [4-10 external domain agents]
- Round 2: R2-Consolidation-Writer
- Round 3: R3-Cross-Validator
- Round 3: R3-Gap-Analyst
- Round 3: R3-Synthesizer
- Final: Comprehensive research artifact
```

---

## Naming Convention (MANDATORY)

All agents use `R[round]-[Agent-Name]` format. Examples: `R1-Codebase-Locator`, `R2-Ecosystem-Deep-Dive`, `R3-Cross-Validator`.

All output files use `R[round]-<slug>-<agent-name>.md` format inside the round directory.

---

## Research Initiative Protocol

**CRITICAL FOR ALL RESEARCH AGENTS**: Every agent must:

1. **Start with recommended files** — read what's specified first
2. **Take initiative** — based on gathered context, explore additional relevant sources
3. **Go deeper** — don't stop at surface-level
4. **Document discoveries** — note unexpected connections or insights
5. **Complete the picture** — comprehensive understanding, not checkbox completion

**Include in every agent prompt**: *"Beyond the specified files, take initiative to explore additional relevant sources based on what you discover. Your goal is a COMPLETE picture, not just the minimum."*

---

## Round 1: Internal Research (8–10 agents in 2 batches)

**Batch 1**: launch 5 agents in parallel (3 concurrent + 2 queued — respect the orchestration `MAX 3 concurrent` limit).
**Batch 2**: after Batch 1 completes, launch architect + consolidation-writer + 0–2 expansion agents.

### Batch 1 — Core agents

#### Agent: R1-Codebase-Locator (`codebase-locator`)

```
**AGENT ID**: R1-Codebase-Locator

Find WHERE files and components live for feature: [FEATURE DESCRIPTION]

**YOUR ROLE**: Documentarian. Find and document file locations WITHOUT suggesting improvements.

**TASKS**:
1. Locate all files related to this feature in the project root: [PROJECT_ROOT]
2. Map directory structure relevant to implementation
3. Find component locations and their relationships
4. Document file organization patterns
5. Identify where new files should be placed based on existing structure

**RESEARCH INITIATIVE**: Beyond obvious locations, take initiative to explore the full codebase. Follow imports, trace module relationships, and map ALL relevant file locations.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-codebase-locator.md` using this format:

```markdown
# R1-Codebase-Locator: File & Component Locations

## Feature Context
[Feature being researched]

## Directory Structure Map
[Relevant directories and their purposes]

## Key File Locations
| File | Path | Purpose |

## Component Locations
## Module Relationships
## Recommended Placement
## File References
- `path/to/file.ts`
```

**RETURN FORMAT** (mandatory):
**AGENT COMPLETE**: R1-Codebase-Locator
**OUTPUT FILE**: [absolute path]
**SUMMARY**: [2-3 sentences of key findings]
**KEY FINDING**: [single most important insight]

Do NOT include full content in your response.
```

#### Agent: R1-Codebase-Analyzer (`codebase-analyzer`)

```
**AGENT ID**: R1-Codebase-Analyzer

Understand HOW code works for feature: [FEATURE DESCRIPTION]

**YOUR ROLE**: Documentarian. Document how code works WITHOUT suggesting improvements.

**TASKS**:
1. Trace code execution flows relevant to this feature
2. Document function/method behavior
3. Map data transformations through the system
4. Explain component interactions
5. Document the current implementation details

**RESEARCH INITIATIVE**: Beyond surface-level, dig deep into implementation. Trace function calls, understand state management, document ALL relevant code behavior.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-codebase-analyzer.md` using sections: Feature Context, Execution Flows, Function/Method Documentation, Data Flow, State Management, Component Interactions, File References.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

#### Agent: R1-Codebase-Pattern-Finder (`codebase-pattern-finder`)

```
**AGENT ID**: R1-Codebase-Pattern-Finder

Find existing patterns for feature: [FEATURE DESCRIPTION]

**YOUR ROLE**: Documentarian. Find and document patterns WITHOUT evaluating or suggesting improvements.

**TASKS**:
1. Find similar implementations in the codebase
2. Document existing patterns and conventions
3. Locate reusable code examples
4. Map pattern usage across files
5. Identify code that could serve as a template

**RESEARCH INITIATIVE**: Search for subtle conventions and implicit patterns. Look at how similar problems are solved throughout the codebase.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-codebase-pattern-finder.md` using sections: Feature Context, Similar Implementations, Code Conventions, Reusable Examples, Pattern Usage Map, Template Code, File References.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

#### Agent: R1-History-Context (`research-specialist`)

```
**AGENT ID**: R1-History-Context

Research project history for feature: [FEATURE DESCRIPTION]

**YOUR SCOPE**: Search project history for relevant context, decisions, and prior work.

**TASKS**:
1. Search the project's documentation directories (e.g., `thoughts/`, `docs/`, `CHANGELOG.md`, `decisions/`) for related content
2. Search git history for related commits (`git log --oneline -S "<keyword>"`)
3. Search for any prior research or planning documents
4. Document architectural decisions that affect this feature

**RESEARCH INITIATIVE**: Beyond specified locations, explore additional history sources. Search for related discussions, prior implementations, or relevant context.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-history-context.md` using sections: Feature Context, Related Documentation, Prior Architecture Decisions, Git History, Related Research, Initiative Discoveries, Lessons from Prior Work, Source References.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

#### Agent: R1-Risks-Gotchas (`research-specialist`)

```
**AGENT ID**: R1-Risks-Gotchas

Scout potential risks and gotchas for feature: [FEATURE DESCRIPTION]

**YOUR SCOPE**: Search for known issues, gotchas, and potential pitfalls.

**TASKS**:
1. Read any `gotchas.md`, `known-issues.md`, or `bug-log.md` files in the project
2. Search project documentation for "TODO", "FIXME", "HACK", "XXX" annotations near relevant code
3. Grep for "bug", "issue", "error" + feature-relevant keywords in docs/comments
4. Identify potential pitfalls based on feature requirements

**RESEARCH INITIATIVE**: Beyond the specified searches, explore additional sources of potential issues.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-risks-gotchas.md` using sections: Feature Context, Known Gotchas, Known Bugs, Annotations Found, Predicted Pitfalls, Mitigation Strategies, Source References.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

### Batch 2 — Architecture + consolidation + optional expansion

#### Agent: R1-Architecture-Analyst (`research-specialist`)

```
**AGENT ID**: R1-Architecture-Analyst

You are a **Software Architect** analyzing the project's architecture for feature: [FEATURE DESCRIPTION]

**YOUR ROLE**: Comprehensive architectural analysis from the perspective of a senior software architect. Understand how all pieces fit together.

**MANDATORY FILES TO READ**:
1. Project entry point files (e.g., `src/index.ts`, `main.go`, `__main__.py`, `Cargo.toml`)
2. Architecture documentation (`ARCHITECTURE.md`, `docs/architecture/`, etc.) if present
3. Skill tree architecture files (from `skill_tree_paths` in workflow-config.json)
4. Existing Batch 1 outputs: codebase-locator, codebase-analyzer, codebase-pattern-finder findings

**ARCHITECTURAL ANALYSIS TASKS**:
1. **Component Mapping**: Map architectural components and their responsibilities
2. **Data Flow Analysis**: Trace how data flows through the system (input → processing → output)
3. **System Interconnections**: Document how systems connect and depend on each other
4. **Module Dependencies**: Map module imports and dependencies
5. **State Flow**: How state transitions and propagates
6. **Resource Flow**: How assets/resources are loaded and accessed
7. **Event Flow**: How events propagate through the system

**RESEARCH INITIATIVE**: Go beyond listed files. Explore every architectural connection you discover. Follow imports, trace data paths.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1/R1-<slug>-architecture-analyst.md` using sections: Feature Context, Architecture Foundation Applied, Current Architecture Overview, Component Map, Data Flow Analysis, System Interconnections, Recommendations for This Feature, Architecture Risks, Initiative Discoveries, Source Files Referenced.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

#### Agent: R1-Consolidation-Writer (`research-specialist`) — ALWAYS LAUNCH

```
**AGENT ID**: R1-Consolidation-Writer

Synthesize all Round 1 Batch 1 findings into a formatted consolidation document for: [FEATURE DESCRIPTION]

**YOUR ROLE**: Final synthesizer for Round 1. Read ALL prior agent outputs and create a unified consolidation document.

**INPUT**: Read ALL files in `<research_output_dir>/<date>-<slug>/round-1/`:
- R1-<slug>-codebase-locator.md
- R1-<slug>-codebase-analyzer.md
- R1-<slug>-codebase-pattern-finder.md
- R1-<slug>-history-context.md
- R1-<slug>-risks-gotchas.md
- R1-<slug>-architecture-analyst.md
- Any expansion agent outputs

**TASKS**:
1. Read ALL Round 1 agent outputs
2. Synthesize findings into a unified document
3. Create proper file references (relative path)
4. Identify key insights across all agents
5. Note any conflicts or gaps between agent findings
6. Write formatted consolidation document

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-1-<slug>-consolidation.md` using format:

```markdown
# Round 1 Consolidation: [Feature Name]

## Date
YYYY-MM-DD

## Agents Completed

| Agent ID | File | Key Findings |
|----------|------|--------------|

## Synthesized Findings

### File Locations & Structure
### Code Behavior & Flows
### Existing Patterns
### Historical Context
### Risks & Gotchas
### Architecture Analysis

## Key Insights
## Conflicts or Gaps
## Ready for Round 2
```

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

### Expansion Agent Pool (pick 0–2 for Batch 2)

Based on complexity, optionally launch 0–2 of:

| Agent | When to Use |
|-------|-------------|
| R1-Framework-Deep-Dive | Feature heavily uses a specific framework |
| R1-Related-Features | Similar features exist elsewhere in codebase |
| R1-Testing-Patterns | Complex test requirements |
| R1-Performance-Scout | Performance-critical feature |
| R1-Security-Scout | Security-sensitive feature |

---

## Round 2: External Research (4–10 agents — DEFAULT)

**Skip with `--internal-only`.**

Launch agents in batches of ≤3 concurrent. Use `R2-[Domain-Name]` format.

### Domain 1: R2-Official-Docs (`research-specialist`)

```
**AGENT ID**: R2-Official-Docs

Deep dive into official documentation for the technologies relevant to: [FEATURE DESCRIPTION]

**SOURCES** (derive from workflow-config.json `external_research_domains.official_docs`, falling back to:
- The project's framework/library official docs
- Language standard library docs

**FOCUS**: Official patterns, recommended approaches, common pitfalls, version-specific considerations.

**RESEARCH INITIATIVE**: Beyond specified sources, follow leads to other relevant official resources.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-official-docs.md`. Include actual code examples, cite all sources with URLs, note any version-specific considerations.

**RETURN FORMAT** (mandatory): see R1-Codebase-Locator template.
```

### Domain 2: R2-Ecosystem-Packages (`research-specialist`)

```
**AGENT ID**: R2-Ecosystem-Packages

Research third-party packages/libraries relevant to: [FEATURE DESCRIPTION]

**SOURCES**:
- Language package repository (npm, PyPI, crates.io, Maven Central, etc.)
- GitHub repositories of relevant packages
- Bundle size / install size analyzers if applicable

**TASKS**:
1. Identify packages commonly used for this type of feature
2. Compare alternatives if multiple exist
3. Check compatibility with project's existing stack
4. Document API patterns and usage examples

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-ecosystem-packages.md`. Include dependency declarations, feature flags, integration patterns.

**RETURN FORMAT** (mandatory).
```

### Domain 3: R2-Industry-Examples (`research-specialist`)

```
**AGENT ID**: R2-Industry-Examples

Find industry examples of: [FEATURE DESCRIPTION]

**SOURCES**:
- Open source projects on GitHub implementing similar features
- Engineering blog posts and postmortems
- Conference talks (search YouTube, GDC Vault, etc.)

**SEARCH QUERIES**:
- "[feature] implementation" + (project's framework/language)
- "how we built [feature]"
- "[feature] tutorial"

**RESEARCH INITIATIVE**: Dig deep into repositories. Don't just skim — understand implementation details.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-industry-examples.md`. Include repo links, code snippets, lessons learned.

**RETURN FORMAT** (mandatory).
```

### Domain 4: R2-Community-Solutions (`research-specialist`)

```
**AGENT ID**: R2-Community-Solutions

Research community solutions for: [FEATURE DESCRIPTION]

**SOURCES**:
- Stack Overflow
- Reddit (relevant subreddits)
- GitHub Issues and Discussions
- Dev.to, Medium, hashnode articles
- Language/framework-specific forums (Discourse, Discord archives where indexed)

**RESEARCH INITIATIVE**: Follow threads, explore related topics.

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-community-solutions.md`. Include discussion links, community consensus, working code solutions.

**RETURN FORMAT** (mandatory).
```

### Domain 5: R2-Patterns-And-Theory (`research-specialist`)

```
**AGENT ID**: R2-Patterns-And-Theory

Research design patterns and theoretical foundations for: [FEATURE DESCRIPTION]

**SOURCES**:
- Design pattern catalogs (Refactoring Guru, GoF, language-specific pattern catalogs)
- Academic papers (Google Scholar, arXiv) if applicable
- Authoritative books and references
- Domain-specific pattern collections

**FOCUS**:
- Patterns that complement the project's existing architecture
- Identify approaches that could improve the project
- Note conflicts between external advice and established patterns

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-patterns-and-theory.md`.

**RETURN FORMAT** (mandatory).
```

### Domain 6: R2-Performance-Security (`research-specialist`) — IF APPLICABLE

```
**AGENT ID**: R2-Performance-Security

Research performance characteristics and security considerations for: [FEATURE DESCRIPTION]

**FOCUS**:
- Known performance pitfalls
- Security vulnerabilities (OWASP top 10 if user-facing, language-specific CVE patterns)
- Benchmarks where available
- Mitigation strategies

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-2/R2-<slug>-performance-security.md`.

**RETURN FORMAT** (mandatory).
```

### After Round 2 — R2-Consolidation-Writer

Same pattern as R1-Consolidation-Writer: read all `round-2/R2-*.md` files, synthesize into `round-2-<slug>-consolidation.md`.

---

## Round 3: Synthesis & Gap Filling (2–4 agents — MANDATORY)

### Agent: R3-Cross-Validator (`research-specialist`)

```
**AGENT ID**: R3-Cross-Validator

Cross-validate Round 1 and Round 2 findings for: [FEATURE DESCRIPTION]

**INPUT**:
- `round-1-<slug>-consolidation.md`
- `round-2-<slug>-consolidation.md` (if Round 2 ran)
- Any individual round files needing deeper inspection

**TASKS**:
1. Cross-check claims between internal codebase findings and external best practices
2. Identify contradictions
3. Verify external claims with second sources (web search)
4. Flag any low-confidence claims

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-3/R3-<slug>-cross-validator.md` with sections: Validated Claims, Contradictions Found, Low-Confidence Claims Flagged, Recommended Verification Actions.

**RETURN FORMAT** (mandatory).
```

### Agent: R3-Gap-Analyst (`research-specialist`)

```
**AGENT ID**: R3-Gap-Analyst

Identify gaps in research coverage for: [FEATURE DESCRIPTION]

**INPUT**: All Round 1 and Round 2 outputs.

**TASKS**:
1. List explicit and implicit questions raised by the feature description
2. For each question, determine if it was answered in research
3. Identify gaps where no agent investigated
4. Recommend follow-up research (which could be a fourth round or punted to /plan)

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-3/R3-<slug>-gap-analyst.md`.

**RETURN FORMAT** (mandatory).
```

### Agent: R3-Synthesizer (`research-specialist`)

```
**AGENT ID**: R3-Synthesizer

Final synthesis for: [FEATURE DESCRIPTION]

**INPUT**: All prior round outputs + R3 cross-validator + R3 gap analyst.

**TASKS**:
1. Produce the FINAL comprehensive research artifact
2. Include all key findings, cited
3. Include "Recommended Approach" with options/trade-offs
4. Include risk assessment
5. Include explicit gaps and unknowns

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/<date>-<slug>-comprehensive-research.md`.

**RETURN FORMAT** (mandatory).
```

### Optional Agent: R3-Risk-Assessor — launch if base agent count ≥ 8

```
**AGENT ID**: R3-Risk-Assessor

Independent risk assessment for: [FEATURE DESCRIPTION]

**INPUT**: All prior round outputs.

**TASKS**:
1. List all risks identified across all rounds
2. Rate each by likelihood × impact
3. Recommend mitigations
4. Flag risks that should block /plan

**OUTPUT**: Write to `<research_output_dir>/<date>-<slug>/round-3/R3-<slug>-risk-assessor.md`.

**RETURN FORMAT** (mandatory).
```

---

## Final Output

The comprehensive research artifact at `<research_output_dir>/<date>-<slug>/<date>-<slug>-comprehensive-research.md` should contain:

1. **Executive Summary** — the feature, the proposed approach, the key risks
2. **Feature Definition** — exactly what's being researched
3. **Internal Findings** — file locations, code flows, patterns, history, gotchas, architecture
4. **External Findings** — official guidance, ecosystem options, industry examples, community solutions, patterns/theory, performance/security
5. **Recommended Approach** — 1–3 viable paths with trade-offs
6. **Architecture & Integration** — where this fits, what it touches
7. **Risks & Mitigations** — table with likelihood, impact, mitigation, evidence
8. **Open Questions / Gaps** — explicit unknowns
9. **Citations** — every external claim cited; every internal claim references a file path
10. **Ready-for-Plan checklist** — proves the artifact is consumable by `/plan`

---

## Reference Format

All documents use:

```markdown
See analysis in `round-1/R1-<slug>-codebase-locator.md`
```

Relative paths from the research directory root. Optionally augment with `[[wiki-links]]` if the project uses Obsidian (auto-detected by presence of `.obsidian/` in project root).

---

## Error Handling

- If an agent hits token limits: spawn 2–3 continuation agents per the Token Limit Recovery Protocol in `rules/sub-agent-orchestration.md`
- If files are missing: note the gap and proceed with available sources
- If a search yields no results: document the negative finding
- If the feature description is ambiguous: ask clarifying questions before proceeding (via `AskUserQuestion`)

---

## Expected Output

Default run (no flags):

1. Complexity analysis documented
2. TaskCreate entries for all agents and consolidation steps
3. Directory structure under `<research_output_dir>/<date>-<slug>/`
4. **Round 1 Batch 1**: 5 core research documents
5. **Round 1 Batch 2**: 2 more (architecture + consolidation) + 0–2 optional expansion
6. **Round 1 consolidation document**
7. **Round 2**: 4–10 external research documents
8. **Round 2 consolidation document**
9. **Round 3**: 2–4 synthesis documents
10. **Final comprehensive research artifact**
11. **Output path printed** — ready for `/plan <path-to-comprehensive-research.md>`

---

## Companion Commands

- **`/plan <research-path>`** — turn this research artifact into a phased implementation plan
- **`/implement <plan-path>`** — execute the plan with independent verification at every phase

These three commands form the **orchestrated trio**. Each can run standalone, but they're designed to chain.
