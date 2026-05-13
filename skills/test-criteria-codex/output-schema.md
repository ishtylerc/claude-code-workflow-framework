# Output Schema — test-criteria-codex

Strict schema Codex must produce in response to the prompt from `codex-prompt-template.md`. The orchestrator validates Codex's output against these rules mechanically in `invocation-protocol.md` Step 3.

## File structure

A single Markdown file with this top-level structure:

```
<YAML frontmatter>
---

# Test Criteria for <feature-name>

## Phase 1: <phase name>
### CRIT-001: ...
### CRIT-002: ...

## Phase 2: <phase name>
### CRIT-003: ...

... (one ## section per draft-plan phase, level-3 ### per criterion)

## Coverage Matrix
| Spec requirement | Criterion IDs |

## Gaps
<bullet list or "None — every spec requirement has at least one criterion.">

## Self-Attestation
- ✅/❌ Every criterion cites a specific spec line/section in its `traceability_quote`.
- ✅/❌ No criterion invents a requirement not present in the spec.
- ✅/❌ Every spec requirement is covered OR explicitly flagged in the Gaps section.
```

## YAML Frontmatter (6 required keys)

```yaml
---
generated_at: <ISO 8601 UTC timestamp>
codex_version: <string, e.g., "0.130.0">
spec_path: <absolute path to the spec used as input>
plan_path: <absolute path to the draft plan used as input>
total_criteria: <integer count of CRIT-NNN headings in the body>
coverage_pct: <integer 0-100 — Codex's self-reported coverage of spec requirements>
---
```

**Validation rules**:
- All 6 keys must be present
- `generated_at` must parse as ISO 8601
- `total_criteria` must equal the actual count of `### CRIT-NNN:` level-3 headings in the body
- `coverage_pct` must be 0–100

## Phase sections

Level-2 heading per draft-plan phase. Format:

```
## Phase <N>: <phase name>
```

Where `<N>` is the integer phase number and `<phase name>` matches a phase in the draft plan.

**Validation rules**:
- At least one `## Phase N:` heading required
- `<N>` must be a positive integer
- `<phase name>` should match a phase from the draft plan (orchestrator parses draft plan phase names and confirms overlap)

## Criterion blocks

Level-3 heading per criterion. Format:

```
### CRIT-NNN: <one-line assertion summary>
- id: CRIT-NNN
- tier: <one of: unit | integration | e2e | performance | manual>
- requirement_id_from_spec: <verbatim spec ID>
- assertion_text: <natural-language testable claim>
- target_file_path: <relative path under one of the project's test tree paths>
- suggested_test_name: should <action> <expected outcome>
- traceability_quote: |
    <verbatim spec text — YAML block scalar for multi-line>
- category: <one of: critical | supplementary>
- plan_phase: <integer matching parent ## Phase N: heading>
```

**Validation rules**:
- Heading format: exact regex `^### CRIT-\d{3}: .+$`
- `id` field value must equal the heading's `CRIT-NNN` segment
- All 9 fields required (order flexible; presence required)
- `tier` must be one of: `unit`, `integration`, `e2e`, `performance`, `manual`
- `category` must be one of: `critical`, `supplementary`
- `target_file_path` must start with one of the configured `test_tree_paths` OR `src/` (for inline `__tests__/` paths)
- `plan_phase` must equal the parent `## Phase N:` heading's `N`
- `suggested_test_name` should start with `should ` (heuristic — flag only, not blocking)
- `traceability_quote` must be non-empty

## Coverage Matrix

A markdown table mapping each spec requirement ID to the criterion IDs that cover it:

```
## Coverage Matrix

| Spec requirement | Criterion IDs |
|---|---|
| AC-1 | CRIT-001, CRIT-002 |
| AC-2 | CRIT-003 |
| §4.2 | CRIT-004, CRIT-005, CRIT-006 |
```

**Validation rules**:
- Heading `## Coverage Matrix` required
- At least one row required
- Every spec requirement listed must have ≥ 1 criterion ID
- Every criterion ID listed must exist in the body (cross-reference check)

## Gaps section

```
## Gaps

- <spec requirement that has no testable criterion> — <reason why>
- <another gap> — <reason>
```

Or the literal text:

```
## Gaps

None — every spec requirement has at least one criterion.
```

**Validation rules**:
- Heading `## Gaps` required (body may be empty bullet list or the "None" literal)
- If non-empty, each bullet must explain why no criterion was generated

## Self-Attestation block

Last section of the file:

```
## Self-Attestation

- ✅ Every criterion cites a specific spec line/section in its `traceability_quote`.
- ✅ No criterion invents a requirement not present in the spec.
- ✅ Every spec requirement is covered OR explicitly flagged in the Gaps section.
```

**Validation rules**:
- All 3 attestation lines required
- Each line must start with `- ✅ ` or `- ❌ ` (with the trailing space)
- If ANY line is ❌, Codex is declaring its own output non-compliant; orchestrator triggers the retry path in `invocation-protocol.md` §3 with the failing attestations as guidance

## Validation result categories

The orchestrator's Step 3 validation produces one of:

| Result | Meaning | Action |
|---|---|---|
| `VALID` | All checks pass | Proceed to Step 4 (inject summary), Step 5 (write artifact) |
| `MALFORMED` (first time) | Schema violation OR sanity-check failure | Save sidecar, retry with explicit guidance (Step 3 retry path) |
| `MALFORMED` (second time) | Same as above on second attempt | Failure Handling §H — escalate to user |
| `SELF-ATTESTED FAILURE` | Codex marked one or more attestations ❌ | Treat as malformed; retry with guidance asking Codex to fix the attested failures |

## Why these rules

- **Strict heading format** (`### CRIT-NNN: <text>`) — allows mechanical parsing in `/implement` Step 4c (criterion-verification gate)
- **9 required fields per criterion** — gives `/implement` enough metadata to mechanically verify (file existence, test name match, key term match) without needing to re-read the spec
- **Frontmatter `total_criteria` cross-check** — prevents truncated outputs from being accepted as complete
- **Self-attestation block** — gives Codex a structured way to flag its own non-compliance rather than silently producing wrong output

## Example (minimal valid output)

```markdown
---
generated_at: 2026-05-13T15:42:00Z
codex_version: "0.130.0"
spec_path: /Users/me/project/thoughts/research/2026-05-13-feature-x/2026-05-13-feature-x-comprehensive-research.md
plan_path: /Users/me/project/thoughts/plans/2026-05-13-feature-x/round-3-synthesis.md
total_criteria: 2
coverage_pct: 100
---

# Test Criteria for Feature X

## Phase 1: Add core API

### CRIT-001: Public load() method rejects negative IDs
- id: CRIT-001
- tier: unit
- requirement_id_from_spec: AC-1
- assertion_text: Calling profileStore.load(-1) rejects with InvalidIdError and emits no state mutation.
- target_file_path: tests/unit/stores/profileStore.test.ts
- suggested_test_name: should reject negative profile-load attempts with InvalidIdError
- traceability_quote: |
    AC-1: The load() method MUST reject any non-positive ID with InvalidIdError, and MUST NOT mutate state.
- category: critical
- plan_phase: 1

## Phase 2: Wire UI

### CRIT-002: Header updates when profile loads
- id: CRIT-002
- tier: e2e
- requirement_id_from_spec: AC-2
- assertion_text: After successful profile load via UI, header text updates to display profile name. Add to `test:e2e:smoke`.
- target_file_path: tests/e2e/profile-load.spec.ts
- suggested_test_name: should update header when profile loads
- traceability_quote: |
    AC-2: When a profile loads successfully, the header SHALL display the profile name.
- category: critical
- plan_phase: 2

## Coverage Matrix

| Spec requirement | Criterion IDs |
|---|---|
| AC-1 | CRIT-001 |
| AC-2 | CRIT-002 |

## Gaps

None — every spec requirement has at least one criterion.

## Self-Attestation

- ✅ Every criterion cites a specific spec line/section in its `traceability_quote`.
- ✅ No criterion invents a requirement not present in the spec.
- ✅ Every spec requirement is covered OR explicitly flagged in the Gaps section.
```
