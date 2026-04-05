#!/bin/bash
# Notification hook — alerts when Claude is idle and waiting for user input.
# Matcher: idleprompt

PROJECT=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
[ -z "$PROJECT" ] && PROJECT=$(basename "$PWD")

TITLE="Claude Code — Needs input 💬"
BODY="$PROJECT"

# ── KDE desktop notification ──────────────────────────────────────────────────
if command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$BODY" \
    --icon=dialog-question \
    --app-name="Claude Code" \
    --expire-time=0   # stay until dismissed — action is required
fi

# ── ntfy (uncomment to enable) ────────────────────────────────────────────────
# if [ -n "$NTFY_URL" ] && command -v curl &>/dev/null; then
#   curl -s -X POST "$NTFY_URL" \
#     -H "Title: $TITLE" \
#     -H "Tags: speech_balloon" \
#     -H "Priority: high" \
#     -d "$BODY" &>/dev/null &
# fi

exit 0
