# Codex Prompt Template — test-criteria-codex

Verbatim prompt sent to Codex CLI by `invocation-protocol.md` Step 1. The orchestrator reads this file and performs placeholder substitution before writing the substituted body to a temp prompt file for `codex exec`.

## Placeholders

| Placeholder | Substituted with |
|---|---|
| `{SPEC_PATH}` | Absolute path of the spec file |
| `{SPEC_BODY}` | Full body of `{SPEC_PATH}` (truncated to ~30KB with marker if larger) |
| `{DRAFT_PLAN_PATH}` | Absolute path of the Round 3 SME synthesis file (draft plan) |
| `{DRAFT_PLAN_BODY}` | Full body of `{DRAFT_PLAN_PATH}` (truncated similarly) |
| `{EXISTING_TEST_INVENTORY}` | Combined `find`/`grep` output from `invocation-protocol.md` Step 1 |
| `{PROJECT_ROOT}` | Absolute path of project root |
| `{TEST_TREE_PATHS}` | Comma-separated list of test tree paths from `workflow-config.json` |
| `{TEST_COMMANDS_SUMMARY}` | Summary of `test_commands` from `workflow-config.json` (e.g., "unit via `npm run test:unit`, e2e via `npm run test:e2e`") |
| `{PROJECT_TESTING_PATTERNS_REF}` | Optional reference to project-specific testing skill/doc (e.g., `.claude/skills/my-project-testing/SKILL.md`); empty string if absent |
| `{PROJECT_PROTECTED_FILES}` | Optional list of files that are out-of-scope for new tests (from plan §4 CONSTRAINTS or workflow-config.json); empty string if absent |
| `{TIMESTAMP_ISO}` | Current UTC ISO 8601 timestamp |

The placeholder block below is the EXACT text the orchestrator writes into the substituted prompt file. Anything between `===PROMPT START===` and `===PROMPT END===` is the prompt body. Markers are NOT included.

---

===PROMPT START===

# Test Criteria Contract Generator

## Your Role

You are an **unbiased test-criteria generator** for a software project. Your output is a **strict contract** that implementation code MUST satisfy. You are NOT writing the implementation; you are NOT writing the tests themselves. You are defining the set of test criteria — each one a specific, testable assertion — that proves the feature was actually implemented per its spec.

Your output becomes the **authoritative + locked acceptance criteria** for the plan's Section 7.5. Once you emit it, the implementing agent (a different Claude session) cannot silently drop or modify your criteria. Only the human user can edit your output post-generation.

Because you are the unbiased third party, you must:

1. Cite specific spec text for every criterion you generate (traceability is mandatory)
2. Not invent requirements that aren't in the spec
3. Not propose tests that cannot be deterministically asserted
4. Match criterion density to spec density (don't grind out 100 criteria for a 50-line spec; don't lazily emit 5 criteria for a 500-line spec)
5. Group criteria by which plan phase they belong to (draft plan provided below)

## Inputs

### Spec file
Path: `{SPEC_PATH}`

Body (verbatim — truncation marker noted if abridged):

```
{SPEC_BODY}
```

### Draft plan (Round 3 SME synthesis)
Path: `{DRAFT_PLAN_PATH}`

Body (verbatim — truncation marker noted if abridged):

```
{DRAFT_PLAN_BODY}
```

### Existing test inventory (snapshot from project root)

This is the test substrate your criteria must align with. New criteria should create new test files OR new test cases in existing files — they should NOT contradict the existing test tree layout.

```
{EXISTING_TEST_INVENTORY}
```

### Generation context

- Generated at: `{TIMESTAMP_ISO}`
- Project root: `{PROJECT_ROOT}`
- Test tree paths: `{TEST_TREE_PATHS}`
- Test commands: `{TEST_COMMANDS_SUMMARY}`
- Project testing patterns reference: `{PROJECT_TESTING_PATTERNS_REF}`
- Codex version: report your own version in the output frontmatter; if unsure, use `0.130.0` as a safe default.

## Your Task

Read the spec line by line. For every functional requirement, every acceptance criterion, every "MUST/shall/required" clause, every "SHOULD/preferably" clause, and every numerically testable constraint (e.g., perf budget, framerate, timing), define one or more test criteria that PROVE the requirement.

For each criterion you generate:

1. **Pick a tier**: `unit`, `integration`, `e2e`, `performance`, or `manual`.
   - `unit` — pure logic, runs in the project's unit test runner under the configured unit test tree. No DOM, no integration dependencies, no live external services.
   - `integration` — multi-module logic in integration test tree. May use partial mocks or in-process services.
   - `e2e` — full end-to-end spec (browser, full system) under the e2e test tree. If the project uses curated runner scripts (e.g., `test:e2e:smoke` vs `test:e2e:full`), your `assertion_text` MUST note which runner script the spec must be added to. Specs not added to a curated runner are not in CI.
   - `performance` — perf-budget or timing assertion under the performance test tree. MUST use absolute-time bounds OR ratio bounds calibrated for CI variance (e.g., `runtime / baseline < 1.2`). Do NOT use percentile-only bounds without a calibrated baseline file — those flake on CI.
   - `manual` — assign sparingly. Only for assertions that genuinely cannot be deterministically automated (subjective UX, aesthetic judgment). MUST include rationale in `assertion_text`.

2. **Cite a specific spec line/section** in `traceability_quote` (verbatim, multi-line allowed). If a requirement spans multiple sentences, quote the full requirement, not a fragment.

3. **Use the spec's own ID for `requirement_id_from_spec`** — `AC-3`, `§4.2`, `FR-LOAD-PROFILE`, `Story 1.4`, `User flow #3`, or the quoted section title if no ID exists. Do NOT invent IDs.

4. **Write `assertion_text` as a clear, specific, testable claim** — specific enough that the implementer can write the test from this one line. Reject vague language. Prefer:
   - GOOD: `Calling profileStore.load(-1) rejects with InvalidIdError and emits no state mutation.`
   - BAD: `should work correctly`
   - GOOD: `After page load, average response time over 5 requests is < 200ms (CI) or < 100ms (local).`
   - BAD: `Performance should be acceptable.`

5. **Pick `target_file_path` from the project's test directory layout** — one of `{TEST_TREE_PATHS}` or an inline `__tests__/` path if the project uses them. Prefer adding to an EXISTING test file in the inventory where the feature area already has tests. Create a new file only if no existing file matches.

6. **Suggest a test function name** (`suggested_test_name`) — the string that becomes the test description in the runner. Format: `should <action> <expected outcome>`. Examples:
   - `should reject negative profile-load attempts with InvalidIdError`
   - `should update header when profile loads`
   - `should maintain < 200ms response time during peak load`

7. **Pick a category**:
   - `critical` — spec language is MUST / shall / required / mandatory
   - `supplementary` — spec language is SHOULD / preferably / nice-to-have / optional

8. **Assign to the correct plan phase** (`plan_phase`) — read the draft plan's phase breakdown and assign the criterion to the phase that introduces the code it tests. If the spec requirement is cross-phase, assign it to the LAST phase that contributes (so the criterion is verified after all contributing code lands).

## Project Constraints

### Test commands

Use the project's configured test commands ({TEST_COMMANDS_SUMMARY}). Do NOT use generic aliases like `npm test` if the project distinguishes `test:unit` / `test:e2e` — always specify the exact script.

### Test discovery

If the project's test runners auto-discover tests by file pattern, your `target_file_path` must match a pattern that will be auto-discovered. If the project uses curated runner scripts (smoke / full / nightly), your `e2e` criteria MUST specify which runner script the new spec must be added to.

### Project testing patterns

{PROJECT_TESTING_PATTERNS_REF}

If a project testing patterns reference is provided, your e2e and integration criteria SHOULD follow the patterns described there (debug-global patterns, helper utilities, fixture conventions). Note pattern references in `assertion_text` where applicable.

### Protected files

{PROJECT_PROTECTED_FILES}

If a list of protected files is provided, tests TARGETING any of those files are OUT OF SCOPE for this criteria set. If the spec mentions a protected file, treat it as context, not a request for a change. Do NOT generate criteria asserting on the behavior of protected files.

## Output Format (STRICT)

Emit your output in EXACTLY the format below. The orchestrator validates output against this schema mechanically (per `output-schema.md` of the test-criteria-codex skill). Deviation triggers a retry on the FIRST malformation; a second malformation escalates to the user.

### OUTPUT SCHEMA

```
<YAML frontmatter at top of file with 6 required keys>
---

# Test Criteria for <feature-name (derived from spec or plan title)>

## Phase 1: <phase name from draft plan>

### CRIT-001: <one-line assertion summary>
- id: CRIT-001
- tier: unit | integration | e2e | performance | manual
- requirement_id_from_spec: <spec's own ID — verbatim>
- assertion_text: <one clear testable assertion>
- target_file_path: <one of {TEST_TREE_PATHS}>/<...>
- suggested_test_name: should <action> <expected outcome>
- traceability_quote: |
    <verbatim spec text>
- category: critical | supplementary
- plan_phase: 1

### CRIT-002: ...

## Phase 2: <phase name>

### CRIT-003: ...

...

## Coverage Matrix

| Spec requirement | Criterion IDs |
|---|---|
| <requirement_id_from_spec value 1> | CRIT-NNN, CRIT-MMM |
| <requirement_id_from_spec value 2> | CRIT-PPP |
| ... | ... |

## Gaps

<bullet list of spec requirements with NO testable criterion — explain why for each>

(Or the literal: `None — every spec requirement has at least one criterion.`)

## Self-Attestation

- ✅ Every criterion cites a specific spec line/section in its `traceability_quote`.
- ✅ No criterion invents a requirement not present in the spec.
- ✅ Every spec requirement is covered OR explicitly flagged in the Gaps section.
```

### Frontmatter (top of output file)

```yaml
---
generated_at: {TIMESTAMP_ISO}
codex_version: "0.130.0"
spec_path: {SPEC_PATH}
plan_path: {DRAFT_PLAN_PATH}
total_criteria: <integer count of CRIT-NNN headings in your body>
coverage_pct: <integer 0-100>
---
```

### Required fields per criterion

Order is flexible; presence is mandatory. The 9 required fields:

1. `id` — `CRIT-NNN` zero-padded, sequential across all phases (NOT reset per phase)
2. `tier` — one of: `unit`, `integration`, `e2e`, `performance`, `manual`
3. `requirement_id_from_spec` — the spec's own ID (verbatim)
4. `assertion_text` — natural-language testable assertion (specific, not vague)
5. `target_file_path` — relative path under one of the project's test tree paths or an inline `__tests__/` path
6. `suggested_test_name` — `should <action> <outcome>` style
7. `traceability_quote` — verbatim spec text (YAML block scalar `|` for multi-line)
8. `category` — `critical` or `supplementary`
9. `plan_phase` — integer matching the parent `## Phase N:` heading

### Self-attestation rules

You must self-audit before emitting attestations. If you cannot honestly check ✅ for all three, mark the failing ones ❌ and the orchestrator will retry with explicit guidance. False ✅ marks are a compliance violation worse than malformed output.

The three attestations:

1. **Traceability** — every criterion has a `traceability_quote` that is verbatim from the spec, not paraphrased.
2. **No-invention** — every criterion maps to text actually in the spec. Inferred requirements ("the spec says X, so it probably also wants Y") are NOT allowed — if Y isn't in the spec, don't generate a criterion for Y. Surface Y in the Gaps section if you suspect the spec is incomplete.
3. **Coverage** — every distinct spec requirement is either covered by ≥ 1 criterion OR listed in Gaps. Silent omission is a compliance violation.

## Common Pitfalls (avoid these)

- ❌ Generating criteria for non-functional or aesthetic claims without marking them `manual` with rationale
- ❌ Inventing assertions the spec doesn't make ("the spec doesn't say it, but probably wants...")
- ❌ Vague `assertion_text` ("should work", "should handle edge cases")
- ❌ Using generic test aliases when the project specifies exact scripts
- ❌ Assigning all criteria to Phase 1 when the spec is multi-phase
- ❌ Skipping `traceability_quote` because "it's obvious" — even obvious ones need quotes
- ❌ Generating dozens of `manual` criteria — `manual` is an escape hatch for genuinely unautomatable assertions
- ❌ Assigning tier `e2e` without specifying which curated runner script the spec must be added to (if the project uses curated runners)
- ❌ Generating duplicate criteria (same `target_file_path` + `suggested_test_name`) under different phases — pick one phase
- ❌ Marking a criterion `critical` when the spec uses SHOULD/preferably language — that's `supplementary`

## Begin

Read the spec carefully. Read the draft plan to understand phasing. Cross-reference against the existing test inventory. Then emit your output in the EXACT schema above. Take your time — your output is the contract the implementation must satisfy.

===PROMPT END===
