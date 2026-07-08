#!/bin/bash
# Stop hook — sends a KDE desktop notification when Claude finishes responding.
# Matcher: (empty — fires on every Stop event)
#
# ntfy support is prepared but commented out.
# To enable: set NTFY_URL in your shell profile, e.g.:
#   export NTFY_URL="https://ntfy.yourdomain.com/claude-code"
# then uncomment the ntfy block below.

# Read the hook payload once so we can inspect it.
INPUT=$(cat)

# TEMP DIAGNOSTIC (remove after confirming the tmp-label bug): log what the
# Stop hook actually receives for a background job, since $PWD / CLAUDE_PROJECT_DIR
# at Stop time can differ from the payload's cwd.
{
  echo "--- $(date -Iseconds 2>/dev/null) ---"
  echo "payload.cwd=$(printf '%s' "$INPUT" | jq -r '.cwd // "<none>"' 2>/dev/null)"
  echo "PWD=$PWD"
  echo "CLAUDE_PROJECT_DIR=${CLAUDE_PROJECT_DIR:-<unset>}"
  echo "CLAUDE_JOB_DIR=${CLAUDE_JOB_DIR:-<unset>}"
} >> "$HOME/.claude/hooks/notify-done.debug.log" 2>/dev/null

# Resolve ONE working directory and use it for BOTH the noise check and the
# project name — otherwise they can disagree (the guard passing on the real
# cwd while the name falls back to the scratchpad basename "tmp"). The payload's
# cwd reliably holds the real project, even for background jobs; only fall back
# when it is absent.
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$CWD" ] && CWD="${CLAUDE_PROJECT_DIR:-$PWD}"

# True if PATH is a temp-dir root OR anything beneath one. Background
# tasks/subagents whose real cwd is a scratchpad are redundant noise. Note the
# bare roots: "/tmp/*" alone does NOT match "/tmp" itself.
is_tmp_path() {
  local p="${1%/}"
  local t="${TMPDIR:-/nonexistent}"; t="${t%/}"
  case "$p" in
    /tmp|/tmp/*|/var/tmp|/var/tmp/*|"$t"|"$t"/*) return 0 ;;
  esac
  return 1
}
is_tmp_path "$CWD" && exit 0

# Derive a short project name from the SAME dir the guard approved.
PROJECT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
[ -z "$PROJECT" ] && PROJECT=$(basename "$CWD")

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
