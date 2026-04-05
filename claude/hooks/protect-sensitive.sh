#!/bin/bash
# PreToolUse hook — blocks writes/edits to sensitive files.
# Matcher: Write|Edit|MultiEdit

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

[ -z "$FILE" ] && exit 0

SENSITIVE_PATTERNS=(
  '(^|/)\.env$'                    # .env exactly
  '(^|/)\.env\.'                   # .env.local, .env.production, …
  '\.pem$'                         # TLS/SSL certs
  '\.key$'                         # Generic private keys
  '_rsa$'                          # SSH keys
  '_dsa$'
  '_ecdsa$'
  '_ed25519$'
  '(^|/)id_rsa'
  '(^|/)\.netrc$'                  # FTP/HTTP credentials
  '\.htpasswd$'
  'secrets?\.(json|yaml|yml|toml|env)$'
  'credentials?\.(json|yaml|yml|toml)$'
  'client_secret.*\.json$'         # OAuth client secrets
  'token(s)?\.json$'
  'authinfo$'
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$FILE" | grep -qiE "$pattern"; then
    echo "🔒 Blocked: '$FILE' matches a sensitive file pattern." >&2
    echo "   Edit this file manually if you really mean to change it." >&2
    exit 2
  fi
done

exit 0
