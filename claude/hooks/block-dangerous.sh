#!/bin/bash
# PreToolUse hook — blocks destructive shell commands before they execute.
# Matcher: Bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Perl-compatible regexes, matched case-insensitively
PATTERNS=(
  # Forced recursive deletion of /, ~, or wildcards
  'rm\s+-[rRfF]{1,3}\s+[/~]'
  'rm\s+-[rRfF]{1,3}\s+\*'
  'rm\s+--no-preserve-root'

  # Writing directly to block devices
  'dd\s+.*of=/dev/[sh]d'
  '>\s*/dev/sd'
  'wipefs\b'
  'shred\b'

  # Drive formatting
  'mkfs\.'

  # Pipe-to-shell downloads (arbitrary remote code execution)
  'curl\b[^#]*\|\s*(ba)?sh'
  'wget\b[^#]*\|\s*(ba)?sh'

  # Fork bomb
  ':\(\)\s*\{.*:\s*&'

  # Force-push to protected branches
  'git\s+push\s+(-f|--force).*\b(main|master|production)\b'
  'git\s+push\s+.*\b(main|master|production)\b.*(-f|--force)'

  # Raw destructive SQL via CLI
  '\b(mysql|psql|sqlite3)\b.*\b(DROP\s+(TABLE|DATABASE)|TRUNCATE\s+TABLE)\b'
)

for pattern in "${PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiP "$pattern"; then
    echo "🚫 Blocked: command matches dangerous pattern." >&2
    echo "   Matched: $pattern" >&2
    echo "   Command: $COMMAND" >&2
    exit 2
  fi
done

exit 0
