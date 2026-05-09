#!/usr/bin/env bash
# codex-banner.sh
# Print a one-line status banner for the /second-opinion command.
# LOCAL-ONLY by design — no network calls, no claims about "latest".
# For heavy diagnostics (npm latest, network, model probes) use codex-diagnose.sh.
#
# Output format (success):
#   second-opinion: codex 0.130.0 | model gpt-5.5 configured | sandbox read-only | agents 4x depth 1
#
# Output format (degraded — codex missing or config unreadable):
#   second-opinion: codex <unavailable> | config ~/.codex/config.toml not readable
#
# Exit codes:
#   0  banner printed (even if some fields are <unknown>)
#   2  fatal — codex CLI not on PATH at all

set -u

CONFIG="${HOME}/.codex/config.toml"

# --- codex version ---
if command -v codex >/dev/null 2>&1; then
  CODEX_VER="$(codex --version 2>/dev/null | awk '{print $NF}' | head -1)"
  CODEX_VER="${CODEX_VER:-<unknown>}"
else
  echo "second-opinion: codex <not installed>"
  exit 2
fi

# --- parse config (best-effort, fail open) ---
parse_top_key() {
  # $1 = key name; reads only above the first [section] header
  local key="$1"
  awk -v k="$key" '
    /^\[/ { exit }
    $0 ~ "^"k"[[:space:]]*=" {
      sub(/^[^=]*=[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$CONFIG" 2>/dev/null
}

parse_section_key() {
  # $1 = section header (e.g. "[agents]"); $2 = key name
  local section="$1" key="$2"
  awk -v s="$section" -v k="$key" '
    $0 == s { in_section = 1; next }
    in_section && /^\[/ { exit }
    in_section && $0 ~ "^"k"[[:space:]]*=" {
      sub(/^[^=]*=[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$CONFIG" 2>/dev/null
}

if [[ -r "$CONFIG" ]]; then
  MODEL="$(parse_top_key model)"
  MODEL="${MODEL:-<unset>}"

  # Sandbox: prefer analyst profile (used by /second-opinion), fall back to top-level
  SANDBOX="$(parse_section_key '[profiles.analyst]' sandbox_mode)"
  if [[ -z "$SANDBOX" ]]; then
    SANDBOX="$(parse_top_key sandbox_mode)"
  fi
  SANDBOX="${SANDBOX:-<default>}"

  THREADS="$(parse_section_key '[agents]' max_threads)"
  THREADS="${THREADS:-?}"
  DEPTH="$(parse_section_key '[agents]' max_depth)"
  DEPTH="${DEPTH:-?}"

  printf 'second-opinion: codex %s | model %s configured | sandbox %s | agents %sx depth %s\n' \
    "$CODEX_VER" "$MODEL" "$SANDBOX" "$THREADS" "$DEPTH"
else
  printf 'second-opinion: codex %s | config %s not readable\n' "$CODEX_VER" "$CONFIG"
fi

exit 0
