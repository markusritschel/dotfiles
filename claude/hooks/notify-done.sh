#!/bin/bash
# Stop hook — sends a KDE desktop notification when Claude finishes responding.
# Matcher: (empty — fires on every Stop event)
#
# ntfy support is prepared but commented out.
# To enable: set NTFY_URL in your shell profile, e.g.:
#   export NTFY_URL="https://ntfy.yourdomain.com/claude-code"
# then uncomment the ntfy block below.

# Derive a short project name from the git root or working directory
PROJECT=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
[ -z "$PROJECT" ] && PROJECT=$(basename "$PWD")

TITLE="Claude Code — Done ✅"
BODY="$PROJECT"

# ── KDE desktop notification ──────────────────────────────────────────────────
if command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$BODY" \
    --icon=dialog-information \
    --app-name="Claude Code" \
    --expire-time=4000
fi

# ── ntfy (uncomment to enable) ────────────────────────────────────────────────
# if [ -n "$NTFY_URL" ] && command -v curl &>/dev/null; then
#   curl -s -X POST "$NTFY_URL" \
#     -H "Title: $TITLE" \
#     -H "Tags: white_check_mark" \
#     -H "Priority: low" \
#     -d "$BODY" &>/dev/null &
# fi

exit 0
