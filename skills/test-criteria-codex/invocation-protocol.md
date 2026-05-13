# Invocation Protocol — test-criteria-codex

Step-by-step protocol for invoking the skill. Read by the orchestrator (Claude) at the moment `/plan` Phase 1.5 calls `Skill(test-criteria-codex)`.

## When to invoke

EXACTLY ONCE per `/plan` run, at the inflection point between Round 3 SME Synthesis and "Final: Create Implementation Plan".

Do NOT invoke:
- During `/implement` (contract is consumed there, not regenerated)
- For research, debug, or other workflows

## Inputs to the skill

The caller provides:

| Input | Description |
|---|---|
| `SPEC_PATH` | Absolute path to the spec file the plan is being built FROM (typically the comprehensive-research artifact from `/research`) |
| `DRAFT_PLAN_PATH` | Absolute path to the draft plan document produced by Round 3 SME Synthesis (`round-3-synthesis.md`) |
| `PLAN_DIRECTORY` | Absolute path to the plan directory under `<plan_output_dir>/<date>-<slug>/` |
| `PROJECT_ROOT` | Absolute path to the project root (from `workflow-config.json` or current working directory) |

## Configuration loaded

Read `<PROJECT_ROOT>/.claude/workflow-config.json` and extract:

- `codex.enabled` (default: `true` — skill is opt-in via skill invocation; this flag lets the project default to disabled)
- `codex.profile` (default: `analyst`)
- `codex.sandbox` (default: `read-only`)
- `codex.timeout_seconds` (default: `300`)
- `codex.min_version` (default: `0.130.0`)
- `test_tree_paths` (default: `["tests/unit", "tests/integration", "tests/e2e", "tests/performance"]`)
- `test_commands.test_unit` / `.test_e2e` (used in inventory generation)

If `codex.enabled` is `false`, return `unavailable` to the caller with reason "codex disabled in workflow-config.json".

## Prerequisites check (BLOCKING)

Before running Codex, verify:

1. `codex --version` exits 0 and version parses as ≥ `codex.min_version`:
   ```bash
   codex --version 2>&1 | awk '{print $NF}'
   ```
   If not present or too old → Failure Handling §A.

2. `~/.codex/config.toml` is readable AND contains `[profiles.<profile>]` with `sandbox_mode = "<sandbox>"`:
   ```bash
   test -r "${HOME}/.codex/config.toml" && grep -q "^\[profiles\.${PROFILE}\]" "${HOME}/.codex/config.toml"
   ```
   If missing → Failure Handling §B.

3. `SPEC_PATH` exists and is readable. If missing → Failure Handling §D.

4. `DRAFT_PLAN_PATH` exists and is readable. If missing → Failure Handling §D.

5. `PLAN_DIRECTORY` exists and is writable. If not, `mkdir -p`.

## Step 1 — Build the Codex prompt

Read `codex-prompt-template.md` (sibling file). Substitute placeholders:

| Placeholder | Substituted with |
|---|---|
| `{SPEC_PATH}` | Verbatim value of input |
| `{SPEC_BODY}` | Full contents of `SPEC_PATH` (truncated to ~30KB if larger — head + tail with marker) |
| `{DRAFT_PLAN_PATH}` | Verbatim value of input |
| `{DRAFT_PLAN_BODY}` | Full contents of `DRAFT_PLAN_PATH` (truncated to ~30KB if larger) |
| `{EXISTING_TEST_INVENTORY}` | Output of the inventory command (see below) |
| `{PROJECT_ROOT}` | Verbatim value of input |
| `{TEST_TREE_PATHS}` | Comma-separated `test_tree_paths` from config |
| `{TIMESTAMP_ISO}` | Current UTC timestamp in ISO 8601 format |

### Building `{EXISTING_TEST_INVENTORY}`

Generate by running (substituting `${PROJECT_ROOT}` literal and adapting test patterns to detected language):

```bash
cd "${PROJECT_ROOT}" && {
  echo "=== package.json / Cargo.toml / pyproject.toml test scripts ==="
  if [ -f package.json ]; then
    grep -E '"(test|typecheck|lint|build)[^"]*":' package.json | sed 's/^[[:space:]]*//'
  fi
  if [ -f Cargo.toml ]; then
    echo "(cargo build / cargo test / cargo clippy assumed)"
  fi
  if [ -f pyproject.toml ]; then
    grep -E '^\[tool\.(pytest|ruff|mypy|black)\]' pyproject.toml
  fi
  echo ""
  echo "=== test tree structure ==="
  for path in {TEST_TREE_PATHS_SPACE_SEPARATED}; do
    [ -d "$path" ] && find "$path" -maxdepth 2 -type d | sort
  done
  echo ""
  echo "=== test files by category ==="
  for path in {TEST_TREE_PATHS_SPACE_SEPARATED}; do
    [ -d "$path" ] || continue
    echo "--- $path ---"
    # Adapt extensions to language: .test.ts | .spec.ts | _test.go | _test.py | .test.rs
    find "$path" -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' \) 2>/dev/null | sort
  done
  echo ""
  echo "=== inline tests (src/**/__tests__/, mod_test.*, etc.) ==="
  find src -path '*/__tests__/*' -o -name '*_test.*' -type f 2>/dev/null | head -50 | sort
}
```

Capture the combined output as the `{EXISTING_TEST_INVENTORY}` placeholder body.

### Truncation Policy

If `SPEC_BODY` or `DRAFT_PLAN_BODY` would exceed ~30KB raw, truncate using head + tail with explicit marker:

```
<first ~20KB of file>

[... TRUNCATED — original file is N bytes, NN lines. Showing first 20KB and last 8KB ...]

<last ~8KB of file>
```

The marker tells Codex it is operating on a partial view so it can flag uncovered sections in the `gaps` block.

### Write the prompt to a temp file

```bash
PROMPT_FILE="/tmp/test-criteria-codex-prompt-$(date +%s).md"
```

## Step 2 — Execute Codex

Run Codex from the project root (so its read-only sandbox sees the actual repo):

```bash
OUTPUT_FILE="/tmp/test-criteria-codex-output-$(date +%s).md"
cd "${PROJECT_ROOT}" && \
  codex exec -p "${PROFILE}" -s "${SANDBOX}" -o "${OUTPUT_FILE}" - < "${PROMPT_FILE}"
```

- `-p <profile>` — uses the configured profile (default `analyst`: high reasoning, read-only)
- `-s <sandbox>` — explicit sandbox mode (default `read-only`)
- `-o "${OUTPUT_FILE}"` — capture response to file (avoids stdout truncation)
- `- < "${PROMPT_FILE}"` — read prompt from stdin

**Timeout**: Use orchestrator's Bash timeout = `codex.timeout_seconds * 1000` ms (default 300000 / 5 min).

**Error handling**:
- Codex returns auth error → Failure Handling §F
- Codex returns sandbox/permission error → Failure Handling §G
- Codex exits 0 but `${OUTPUT_FILE}` is empty or <500 bytes → treat as malformed (Step 3 will fail and trigger retry)

## Step 3 — Parse and validate Codex output

Read `${OUTPUT_FILE}`. Validate against `output-schema.md` rules.

### Required-field checks

1. YAML frontmatter present at top, parses as YAML, contains all 6 required keys: `generated_at`, `codex_version`, `spec_path`, `plan_path`, `total_criteria`, `coverage_pct`
2. At least one criterion section exists (level-2 heading matching `## Phase <N>: <Name>`)
3. Each criterion under a phase is a level-3 heading `### CRIT-NNN: <one-line>` with all 9 required fields: `id`, `tier`, `requirement_id_from_spec`, `assertion_text`, `target_file_path`, `suggested_test_name`, `traceability_quote`, `category`, `plan_phase`
4. Coverage matrix section `## Coverage Matrix` exists with at least one row
5. Gaps section `## Gaps` exists (may be empty body; heading required)
6. Self-attestation block exists at bottom with all 3 attestation checkboxes

### Sanity checks

1. `total_criteria` in frontmatter == count of `### CRIT-NNN:` headings in body
2. Every `target_file_path` starts with one of the configured `test_tree_paths` (or `src/` for inline tests)
3. Every `tier` is one of: `unit`, `integration`, `e2e`, `performance`, `manual`
4. Every `category` is one of: `critical`, `supplementary`
5. Every `plan_phase` matches a phase that exists in the draft plan

### Retry path (ONE retry only)

If validation fails:

1. Save malformed output to `${PLAN_DIRECTORY}/test-criteria-malformed-attempt-1.md`
2. Build NEW prompt with this preface prepended before substitution:
   ```
   PRIOR ATTEMPT WAS NON-COMPLIANT. Your previous output did not conform to the required schema. Re-read the OUTPUT SCHEMA section below carefully and produce output that EXACTLY matches the schema. Specifically, the prior attempt had these issues:
   - <list specific schema violations>
   Do not skip required fields, do not deviate from heading format, do not omit the self-attestation block.
   ```
3. Re-run Codex (Step 2)
4. Validate the new output
5. If STILL malformed → Failure Handling §H

## Step 4 — Inject criteria summary into the plan's Section 7.5

The orchestrator (running /plan) injects a `### 7.5 Codex-Authored Test Criteria (LOCKED AC)` subsection into the Final Implementation Plan being assembled. See `integration-points.md` §1 for the canonical template.

## Step 5 — Write the standalone test-criteria.md artifact

Write the validated Codex output verbatim to:

```
${PLAN_DIRECTORY}/test-criteria.md
```

Verify the write by reading back the first 50 lines and confirming the YAML frontmatter is intact.

## Step 6 — Cleanup

```bash
rm -f "${PROMPT_FILE}" "${OUTPUT_FILE}"
```

KEEP any `test-criteria-malformed-attempt-*.md` sidecars in the plan directory for debugging.

## Step 7 — Return result to caller

Return one of three signals to the caller:

- **`success`** — `test-criteria.md` written; orchestrator should inject §7.5 summary and continue to Final-Plan-Write
- **`unavailable`** — Codex unavailable AND user opted to proceed without (§7.5 marked `codex-coverage:unavailable`)
- **`abort`** — User opted to halt /plan at this step

Return payload format (when returning from the skill):

```
**SKILL COMPLETE**: test-criteria-codex
**RESULT**: success | unavailable | abort
**ARTIFACT**: <absolute path to test-criteria.md, OR "n/a" if unavailable/abort>
**SUMMARY_BLOCK**: <the §7.5 summary block as a markdown string, ready for injection into the plan, OR a stub if unavailable>
**TOTAL_CRITERIA**: <integer count, OR 0>
**COVERAGE_PCT**: <integer percent, OR null>
**GAPS_COUNT**: <integer, OR null>
```

---

## Failure Handling

### §A — Codex CLI missing or too old

1. Report:
   ```
   ❌ Codex CLI prerequisite check failed.
      Detected: <version or "not installed">
      Required: codex >= <min_version>
      Install: https://developers.openai.com/codex/
   ```
2. AskUserQuestion:
   - A) Install/upgrade Codex now (user does this manually outside session)
   - B) Proceed with /plan without Codex criteria — mark `codex-coverage:unavailable` (record reason)
   - C) Abort /plan and resume later
3. Honor choice. If B, write stub §7.5 and return `unavailable`. If C, return `abort`.

### §B — Profile missing in config.toml

```
❌ Codex profile not configured.
   Expected: [profiles.<profile>] with sandbox_mode = "<sandbox>" and model_reasoning_effort = "high"
   Config: ~/.codex/config.toml
```
Same A/B/C choice as §A.

### §D — SPEC_PATH or DRAFT_PLAN_PATH missing

BLOCKING. Cannot run without spec + draft plan:
```
❌ Required input file missing: <path>
   The skill needs the comprehensive-research/spec file and the Round 3 SME synthesis file.
```
Escalate via AskUserQuestion — user provides correct path or aborts.

### §E — Codex timeout

```
⚠️ Codex execution timed out after <timeout> seconds.
   The spec or draft plan may be too large, or Codex is having a slow day.
```
AskUserQuestion:
- A) Retry with shorter spec body (force truncation to 15KB)
- B) Mark `codex-coverage:unavailable` and proceed
- C) Abort /plan

### §F — Auth error

```
❌ Codex authentication failed.
   Set OPENAI_API_KEY in your environment or ~/.codex/config.toml
```
Same A/B/C choice as §A.

### §G — Sandbox/permission error

```
❌ Codex sandbox error: <error>
   The sandbox configuration may not match the profile.
```
Same A/B/C choice as §A.

### §H — Validation still failing after retry

BLOCKING. Both attempts saved as sidecars:
```
❌ Codex produced non-compliant output on both attempts.
   Attempts saved to:
   - <plan-directory>/test-criteria-malformed-attempt-1.md
   - <plan-directory>/test-criteria-malformed-attempt-2.md
   Inspect for patterns; may indicate a prompt template issue or a spec that exceeds Codex's context handling.
```
AskUserQuestion:
- A) Skip this gate — mark `codex-coverage:unavailable`
- B) Abort /plan

There is no third "retry again" option — two attempts is the limit.
