#!/usr/bin/env bash
# Claude Code status line – mirrors key Powerlevel10k prompt elements

# Force C numeric locale so printf %f and awk parse "42.5" (dot) regardless of
# the user's LC_NUMERIC (e.g. de_DE uses a comma and would error otherwise).
export LC_NUMERIC=C

input=$(cat)

# Numeric helper: "is a >= b?" as an exit status, no dependency on `bc`.
pct_ge() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a >= b) }'; }

cwd=$(echo "$input"       | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"     | jq -r '.model.display_name // empty')
effort=$(echo "$input"    | jq -r '.effort.level // empty')
used=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')

# Subscription (Pro/Max) rate-limit usage. Present only for Claude.ai
# subscribers, only after the first API response, each window independently.
rl5_pct=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl5_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl7_pct=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl7_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# user@host
user=$(whoami)
host=$(hostname -s)

# Shorten cwd: replace $HOME with ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/\~}"

# Git branch (skip optional locks)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null \
                 || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
fi

# Build status line with ANSI colors (dimmed-friendly)
# Colors: cyan for user@host, yellow for dir, magenta for git, blue for model, green for ctx
#printf "\033[36m%s@%s\033[0m" "$user" "$host"
printf " \033[33m%s\033[0m" "$short_cwd"

if [ -n "$git_branch" ]; then
    printf " \033[35m(%s)\033[0m" "$git_branch"
fi

if [ -n "$model" ]; then
    if [ -n "$effort" ]; then
        printf " \033[34m[%s | %s]\033[0m" "$model" "$effort"
    else
        printf " \033[34m[%s]\033[0m" "$model"
    fi
fi

if [ -n "$used" ]; then
    bar_width=20
    filled=$(( (${used%.*} * bar_width + 50) / 100 ))
    empty=$((bar_width - filled))
    bar=$(printf '%0.s█' $(seq 1 $filled))$(printf '%0.s░' $(seq 1 $empty))
    if   pct_ge "$used" 90; then color="\033[31m"
    elif pct_ge "$used" 70; then color="\033[33m"
    else color="\033[32m"
    fi
    printf " ${color}[%s] %.0f%%\033[0m" "$bar" "$used"
fi

# Subscription usage windows. For each window with data, show the used %
# and the actual reset time reported by Anthropic (rate_limits.*.resets_at).
# A burn-rate projection is computed internally only to decide whether to add
# a warning flag (⚠) — the displayed time is always the real reset time.
render_window() {
    local label="$1" pct="$2" reset="$3" window="$4"
    [ -z "$pct" ] && return

    # Colour by how full the window is.
    local color
    if   pct_ge "$pct" 80; then color="\033[31m"   # red
    elif pct_ge "$pct" 50; then color="\033[33m"   # yellow
    else color="\033[32m"                          # green
    fi

    local suffix=""
    if [ -n "$reset" ]; then
        local now start elapsed
        now=$(date +%s)
        start=$((reset - window))
        elapsed=$((now - start))
        local reset_hhmm
        reset_hhmm=$(date -d "@$reset" +%H:%M 2>/dev/null)

        # Always display the actual reset time reported by Anthropic via
        # the resets_at field in the stdin JSON.  A burn-rate projection
        # is used only to decide whether to show a warning flag (⚠) — the
        # time shown is always the real reset time, never a computed guess.
        if [ "$elapsed" -gt 60 ] && pct_ge "$pct" 0.01; then
            local exhaust
            exhaust=$(awk -v p="$pct" -v e="$elapsed" -v n="$now" \
                'BEGIN { printf "%d", n + (100 - p) * e / p }')
            if [ "$exhaust" -lt "$reset" ]; then
                # On track to exhaust before reset — warn, but always show
                # the real reset time (resets_at from Anthropic).
                suffix=" ⚠↺${reset_hhmm}"
            else
                suffix=" ↺${reset_hhmm}"
            fi
        else
            suffix=" ↺${reset_hhmm}"
        fi
    fi

    printf " ${color}%s %.0f%%%s\033[0m" "$label" "$pct" "$suffix"
}

# Dim divider + "plan" label so the per-conversation context % and the
# subscription plan windows read as two separate, self-documenting groups
# (only shown when usage data exists).
if [ -n "$rl5_pct" ] || [ -n "$rl7_pct" ]; then
    printf " \033[90m│ plan\033[0m"
fi

render_window "5h" "$rl5_pct" "$rl5_reset" 18000
# Dim middot between the two windows, only when both are present.
if [ -n "$rl5_pct" ] && [ -n "$rl7_pct" ]; then
    printf " \033[90m·\033[0m"
fi
render_window "7d" "$rl7_pct" "$rl7_reset" 604800
