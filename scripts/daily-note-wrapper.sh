#!/bin/bash
# Wrapper for daily note automation v2
# Handles: environment setup, non-interactive stdin, error capture

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/ishtyler/.local/bin"
export HOME="${HOME:-/Users/ishtyler}"

LOG_DIR="$HOME/.local/share/daily-notes-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/automation-$(date '+%Y-%m-%d').log"

/bin/bash "$HOME/.local/bin/daily-note-automation-v2.sh" < /dev/null 2>>"$LOG_DIR/launchd-stderr.log"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - WRAPPER: Script exited with code $EXIT_CODE" >> "$LOG_FILE"
fi

exit $EXIT_CODE
