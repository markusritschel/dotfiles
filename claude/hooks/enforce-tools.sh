#!/bin/bash
# PreToolUse hook — enforces preferred toolchain (mise / pnpm / uv).
# Matcher: Bash
#
# Hard blocks (exit 2):  commands that should never be used
# Soft warnings (exit 0 + additionalContext): Claude sees the note and can self-correct

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# ── Hard blocks ───────────────────────────────────────────────────────────────
# These exit 2 so Claude cannot proceed without an explicit override.

hard_block() {
  local reason="$1"
  echo "🚫 Blocked by toolchain hook: $reason" >&2
  exit 2
}

# pip install / pip3 install / python -m pip install
if echo "$COMMAND" | grep -qiP '\bpip3?\s+install\b|python3?\s+-m\s+pip\s+install\b'; then
  # Suggest uv add if we're inside a project, uv pip install otherwise
  if [ -f "pyproject.toml" ] || [ -f "uv.lock" ]; then
    hard_block "Use 'uv add <pkg>' to add a project dependency (pyproject.toml detected)."
  else
    hard_block "Use 'uv pip install <pkg>' to install into the active virtualenv (no pyproject.toml found)."
  fi
fi

# npm install -g  (use mise instead for global tools)
if echo "$COMMAND" | grep -qiP '\bnpm\s+(install|i)\s+.*-g\b|\bnpm\s+(install|i)\s+-g\b'; then
  hard_block "Use 'mise use -g <tool>' instead of 'npm install -g'."
fi

# python -m venv / virtualenv  (use uv venv)
if echo "$COMMAND" | grep -qiP 'python3?\s+-m\s+venv\b|virtualenv\b'; then
  hard_block "Use 'uv venv' instead of python -m venv / virtualenv."
fi

# setup.py install / easy_install
if echo "$COMMAND" | grep -qiP 'setup\.py\s+install\b|easy_install\b'; then
  hard_block "Use 'uv pip install -e .' instead of setup.py install / easy_install."
fi

# conda install (not in the stack)
if echo "$COMMAND" | grep -qiP '\b(conda|mamba)\s+(install|create)\b'; then
  hard_block "Use 'uv' for Python environments, not conda."
fi

# ── Soft suggestions ──────────────────────────────────────────────────────────
# These allow the command but inject a note so Claude can self-correct.

suggest() {
  local msg="$1"
  echo "{\"additionalContext\": \"Toolchain note: $msg\"}"
  exit 0
}

# npm install / npm i (without -g) → pnpm install
if echo "$COMMAND" | grep -qiP '\bnpm\s+(install|i)\b' && ! echo "$COMMAND" | grep -qiP '\s-g\b'; then
  suggest "Prefer 'pnpm install' over 'npm install'."
fi

# npm run → pnpm run
if echo "$COMMAND" | grep -qiP '\bnpm\s+run\b'; then
  suggest "Prefer 'pnpm run <script>' over 'npm run'."
fi

# npm ci → pnpm install --frozen-lockfile
if echo "$COMMAND" | grep -qiP '\bnpm\s+ci\b'; then
  suggest "Prefer 'pnpm install --frozen-lockfile' over 'npm ci'."
fi

# npx → pnpm exec or mise x
if echo "$COMMAND" | grep -qiP '\bnpx\b'; then
  suggest "Prefer 'pnpm exec <cmd>' or 'mise x -- <cmd>' over 'npx'."
fi

# pip show / pip list are fine — read-only, no block
# uv is already preferred — no intervention needed

exit 0
