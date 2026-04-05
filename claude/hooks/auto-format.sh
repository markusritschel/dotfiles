#!/bin/bash
# PostToolUse hook — auto-formats Python and JS/TS files after writes/edits.
# Matcher: Write|Edit|MultiEdit
#
# Python:  ruff format + ruff check --fix via uv run (if in a uv project),
#          falling back to ruff directly (e.g. installed via mise).
#          ty check is run non-blocking if available (still alpha).
#
# JS/TS:   prettier via pnpm exec (if in a pnpm project), falling back
#          to the globally installed prettier.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Walk up from a directory to find the first ancestor containing a marker file.
find_project_root() {
  local dir marker
  dir="$(dirname "$(realpath "$FILE")")"
  marker="$1"
  while [ "$dir" != "/" ]; do
    [ -f "$dir/$marker" ] && echo "$dir" && return 0
    dir="$(dirname "$dir")"
  done
  return 1
}

case "$FILE" in

  # ── Python ──────────────────────────────────────────────────────────────────
  *.py)
    UV_ROOT=$(find_project_root "uv.lock" 2>/dev/null || find_project_root "pyproject.toml" 2>/dev/null || true)
    HAS_UV=$(command -v uv &>/dev/null && echo yes || echo no)

    # Run a tool with three-tier fallback:
    #   1. uv run <tool>  — project has it in deps (version-locked)
    #   2. uvx <tool>     — not in project, run ephemerally (no pyproject.toml modification)
    #   3. bare <tool>    — installed globally, e.g. via mise
    run_py_tool() {
      local tool="$1"; shift   # e.g. "ruff"
      local args=("$@")        # remaining args passed to the tool

      if [ "$HAS_UV" = yes ] && [ -n "$UV_ROOT" ] \
          && (cd "$UV_ROOT" && uv run --quiet "$tool" --version &>/dev/null 2>&1); then
        (cd "$UV_ROOT" && uv run --quiet "$tool" "${args[@]}" 2>/dev/null)
      elif [ "$HAS_UV" = yes ]; then
        uvx --quiet "$tool" "${args[@]}" 2>/dev/null
      elif command -v "$tool" &>/dev/null; then
        "$tool" "${args[@]}"
      fi
    }

    run_py_tool ruff format --quiet "$FILE"
    run_py_tool ruff check --fix --quiet "$FILE"

    # ty: non-blocking, output is advisory only (still alpha)
    TY_OUT=$(run_py_tool ty check "$FILE" 2>&1) || true
    if [ -n "$TY_OUT" ]; then
      echo "🔍 ty (type check) — $(basename "$FILE"):" >&2
      echo "$TY_OUT" >&2
    fi
    ;;

  # ── JavaScript / TypeScript / web assets ────────────────────────────────────
  *.js|*.jsx|*.ts|*.tsx|*.css|*.json|*.html)
    PNPM_ROOT=$(find_project_root "pnpm-lock.yaml" 2>/dev/null || true)

    if [ -n "$PNPM_ROOT" ] && command -v pnpm &>/dev/null; then
      # Prefer project-local prettier via pnpm exec
      (cd "$PNPM_ROOT" && pnpm exec prettier --write --log-level silent "$FILE" 2>/dev/null) \
        || prettier --write --log-level silent "$FILE" 2>/dev/null \
        || true
    elif command -v prettier &>/dev/null; then
      prettier --write --log-level silent "$FILE" 2>/dev/null
    fi
    ;;

esac

# Always exit 0 — formatting is never a reason to block Claude
exit 0
