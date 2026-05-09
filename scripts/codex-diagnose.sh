#!/usr/bin/env bash
# codex-diagnose.sh
# Heavy diagnostic checks for the Codex CLI environment used by /second-opinion.
# Opt-in only (invoked via `/second-opinion --diagnose`). Never runs in the hot path.
#
# Usage:
#   .claude/scripts/codex-diagnose.sh           # full diagnostics including model probes (slow)
#   .claude/scripts/codex-diagnose.sh --quick   # skip model probes (faster)
#
# Exit codes:
#   0  all checks PASS or only WARN (informational)
#   1  one or more FAIL conditions
#   2  setup is broken (codex not installed)

set -u

QUICK=0
[[ "${1:-}" == "--quick" ]] && QUICK=1

CONFIG="${HOME}/.codex/config.toml"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/codex-preflight"

OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

ok()   { printf '  ✓ %s\n' "$1"; OK_COUNT=$((OK_COUNT + 1)); }
warn() { printf '  ⚠ %s\n' "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { printf '  ✗ %s\n' "$1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

section() { printf '\n─── %s ───\n' "$1"; }

printf 'codex-diagnose: %s\n' "$(date '+%Y-%m-%d %H:%M %Z')"
printf '═══════════════════════════════════════════\n'

# --- CLI presence ---
section "CLI"
if ! command -v codex >/dev/null 2>&1; then
  fail "codex not on PATH"
  echo
  echo "status: setup broken — install codex first"
  exit 2
fi
CODEX_VER="$(codex --version 2>/dev/null | awk '{print $NF}' | head -1)"
ok "codex --version → $CODEX_VER"

CODEX_PATH="$(command -v codex)"
ok "codex path → $CODEX_PATH"

# --- Config ---
section "Config"
if [[ -r "$CONFIG" ]]; then
  ok "$CONFIG → readable"

  # Quick TOML smoke test (very loose — full validation requires a TOML parser)
  if grep -qE '^\[' "$CONFIG" && grep -qE '^[a-z_]+[[:space:]]*=' "$CONFIG"; then
    ok "config syntax → looks well-formed"
  else
    warn "config syntax → no sections or top-level keys detected"
  fi

  # Profile presence
  if grep -qE '^\[profiles\.analyst\]' "$CONFIG"; then
    ok "profile [profiles.analyst] → present"
  else
    fail "profile [profiles.analyst] → MISSING (used by /second-opinion)"
  fi

  # Multi-agent feature flag
  if grep -qE '^[[:space:]]*multi_agent[[:space:]]*=[[:space:]]*true' "$CONFIG"; then
    ok "multi_agent → enabled"
  else
    warn "multi_agent → not enabled (Codex won't orchestrate sub-agents)"
  fi
else
  fail "$CONFIG → not readable"
fi

# --- Cache writability ---
section "Cache"
if mkdir -p "$CACHE_DIR" 2>/dev/null && touch "$CACHE_DIR/.write-test" 2>/dev/null; then
  rm -f "$CACHE_DIR/.write-test"
  ok "cache dir writable → $CACHE_DIR"
else
  warn "cache dir not writable → $CACHE_DIR (sandbox?)"
fi

# --- Network ---
section "Network"
if curl -fsS --max-time 3 -o /dev/null https://registry.npmjs.org/ 2>/dev/null; then
  ok "registry.npmjs.org → reachable"
else
  warn "registry.npmjs.org → unreachable (DNS/firewall/sandbox)"
fi

# OpenAI API returns 401 unauthenticated; -f would treat that as failure.
# Use -o /dev/null + -w to capture status code; any HTTP response = reachable.
API_STATUS="$(curl -sS -o /dev/null --max-time 3 -w '%{http_code}' https://api.openai.com/ 2>/dev/null)"
if [[ "$API_STATUS" =~ ^[1-5][0-9][0-9]$ ]]; then
  ok "api.openai.com → reachable (HTTP $API_STATUS)"
else
  warn "api.openai.com → unreachable (no HTTP response)"
fi

# --- npm latest (only if npm + network available) ---
section "Update Check"
if command -v npm >/dev/null 2>&1; then
  NPM_LATEST="$(npm view @openai/codex version 2>/dev/null | tr -d '[:space:]')"
  if [[ -n "$NPM_LATEST" ]]; then
    if [[ "$NPM_LATEST" == "$CODEX_VER" ]]; then
      ok "@openai/codex npm → $NPM_LATEST (current)"
    else
      warn "@openai/codex npm → $NPM_LATEST available (installed: $CODEX_VER) — run: npm install -g @openai/codex@latest"
    fi
  else
    warn "npm view @openai/codex → no response (network/registry issue)"
  fi
else
  warn "npm not on PATH — cannot check for updates"
fi

# --- Model probes (slow; opt-out via --quick) ---
if [[ "$QUICK" -eq 0 ]]; then
  section "Model Probes (slow)"
  echo "  (probing each takes ~5-15s; pass --quick to skip)"

  # Currently-configured model
  CONFIGURED_MODEL="$(awk '/^\[/{exit} /^model[[:space:]]*=/{sub(/^[^=]*=[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$CONFIG" 2>/dev/null)"

  probe_model() {
    local m="$1" label="$2" out
    out=$(printf 'reply: ok\n' | codex exec -c model="\"$m\"" -s read-only --skip-git-repo-check - 2>&1)
    if echo "$out" | grep -q "ERROR:.*requires a newer version of Codex"; then
      # CLI is stale — model exists upstream but local CLI doesn't know it
      warn "$m → CLI is stale; upgrade with: npm install -g @openai/codex@latest ($label)"
    elif echo "$out" | grep -q "ERROR:.*not supported when using Codex with a ChatGPT account"; then
      # Generic ChatGPT-account error: returned for BOTH non-existent models AND real-but-unavailable
      # ones. Cannot disambiguate, so report as inconclusive rather than asserting unavailability.
      printf '  – %s → not available to ChatGPT account (model may not exist or require a different plan) [%s]\n' "$m" "$label"
    elif echo "$out" | grep -qE "^model: $m"; then
      ok "$m → accepted ($label)"
    else
      warn "$m → unknown response ($label)"
    fi
  }

  [[ -n "${CONFIGURED_MODEL:-}" ]] && probe_model "$CONFIGURED_MODEL" "currently configured"
  # Probe likely-next identifiers — purely informational; brittle by nature.
  # The ChatGPT-account error is generic, so a "not available" result here is INCONCLUSIVE.
  # The signal that actually matters: a "requires a newer version of Codex" response means
  # a new model has shipped that your CLI doesn't recognize → upgrade.
  probe_model "gpt-5.6" "next minor"
  probe_model "gpt-6" "next major"
fi

# --- Summary ---
echo
echo "═══════════════════════════════════════════"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf 'status: %d FAIL · %d WARN · %d OK — needs attention\n' "$FAIL_COUNT" "$WARN_COUNT" "$OK_COUNT"
  exit 1
elif [[ "$WARN_COUNT" -gt 0 ]]; then
  printf 'status: %d WARN · %d OK — operational, with caveats\n' "$WARN_COUNT" "$OK_COUNT"
  exit 0
else
  printf 'status: %d OK — all checks pass\n' "$OK_COUNT"
  exit 0
fi
