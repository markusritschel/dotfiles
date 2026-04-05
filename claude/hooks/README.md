# claude-hooks

Personal Claude Code hooks for daily development use.

<!--
## Installation

Requires `jq` (`sudo pacman -S jq`), then:

```bash
bash install.sh
```

The script copies all hook scripts to `~/.claude/hooks/`, makes them
executable, and merges the `hooks` key into `~/.claude/settings.json`
(creating it if it doesn't exist, backing it up with a timestamp if it does).

-->


## Hooks overview

### Safety — PreToolUse / Bash

#### `block-dangerous.sh`

Hard-blocks destructive shell commands before they execute. Claude receives
an error message explaining the block and cannot proceed without an explicit
override.

Blocked patterns:

| Pattern | Example |
|---|---|
| Recursive forced deletion of `/`, `~`, or `*` | `rm -rf /`, `rm -rf ~` |
| Writing to block devices | `dd of=/dev/sda`, `> /dev/sda` |
| Drive tools | `mkfs.*`, `wipefs`, `shred` |
| Pipe-to-shell downloads | `curl ... \| bash`, `wget ... \| sh` |
| Fork bomb | `:(){:|:&};:` |
| Force-push to protected branches | `git push --force origin main` |
| Raw destructive SQL via CLI | `psql ... DROP TABLE` |

#### `enforce-tools.sh`

Steers Claude toward the preferred toolchain: **uv** for Python,
**pnpm** for Node, **mise** for global tools.

Hard blocks (Claude cannot proceed):

| Blocked command | Preferred alternative |
|---|---|
| `pip install` / `pip3 install` | `uv add <pkg>` (in project) or `uv pip install <pkg>` (ad-hoc) |
| `python -m pip install` | `uv pip install <pkg>` |
| `npm install -g` | `mise use -g <tool>` |
| `python -m venv` / `virtualenv` | `uv venv` |
| `setup.py install` / `easy_install` | `uv pip install -e .` |
| `conda install` / `conda create` | `uv` |

The `pip install` block is context-aware: if a `pyproject.toml` or `uv.lock`
is present in the working directory, Claude is told to use `uv add`; otherwise
it is told to use `uv pip install`.

Soft suggestions (command proceeds, Claude sees an advisory note):

| Command | Suggestion |
|---|---|
| `npm install` | Use `pnpm install` |
| `npm run` | Use `pnpm run` |
| `npm ci` | Use `pnpm install --frozen-lockfile` |
| `npx` | Use `pnpm exec` or `mise x --` |

---

### Safety — PreToolUse / Write\|Edit\|MultiEdit

#### `protect-sensitive.sh`

Blocks writes and edits to files that match sensitive patterns. Claude must
be told explicitly to skip this check if the edit is genuinely intentional.

Blocked file patterns:

- `.env`, `.env.*`
- `*.pem`, `*.key`
- SSH keys: `*_rsa`, `*_dsa`, `*_ecdsa`, `*_ed25519`, `id_rsa*`
- `~/.netrc`, `*.htpasswd`
- `secrets.*`, `credentials.*`
- `client_secret*.json`, `tokens.json`, `authinfo`

---

### Code quality — PostToolUse / Write\|Edit\|MultiEdit

#### `auto-format.sh`

Automatically formats files after every write or edit.

**Python (`.py`)**

Runs `ruff format` followed by `ruff check --fix` (safe lint auto-fixes).
Also runs `ty check` non-blocking — output is advisory since `ty` is still
in alpha.

Tool resolution uses a three-tier fallback per tool:

1. `uv run <tool>` — project has the tool in its dependencies (version-locked)
2. `uvx <tool>` — tool not in project; runs ephemerally, no `pyproject.toml` modification
3. bare `<tool>` — globally installed (e.g. via mise)

**JavaScript / TypeScript / CSS / HTML / JSON**

Runs `prettier --write`.

Tool resolution:

1. `pnpm exec prettier` from the project root (if `pnpm-lock.yaml` is found)
2. Global `prettier`

---

### Notifications — Stop

#### `notify-done.sh`

Sends a KDE desktop notification when Claude finishes responding. Shows the
project name (from the git root, or `$PWD` basename as fallback). Expires
after 4 seconds.

---

### Notifications — Notification / idleprompt

#### `notify-input.sh`

Sends a KDE desktop notification when Claude is idle and waiting for user
input. Uses a question-mark icon and **does not expire** — since action is
required, the notification stays visible until dismissed.

---

## Enabling ntfy

Both notification hooks have an ntfy block that is commented out. To enable:

1. Uncomment the ntfy block in `~/.claude/hooks/notify-done.sh` and
   `~/.claude/hooks/notify-input.sh`.
2. Add to `~/.zshrc`:
   ```bash
   export NTFY_URL="https://ntfy.yourdomain.com/claude-code"
   ```

`notify-input.sh` uses `Priority: high` so it surfaces prominently on mobile.

---

## Extending

To add a new hook:

1. Write a script and make it executable.
2. Add it to the corresponding entry in `../settings.json`.

Useful references:
- [Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Permission rule syntax](https://code.claude.com/docs/en/permissions#permission-rule-syntax)
