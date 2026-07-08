#!/bin/bash
# UserPromptSubmit hook — deterministic reminder of the task-preamble gate.
# Fires on every prompt (~40 tokens injected). Rule: CLAUDE.md "Task preamble — the gate".
cat <<'EOF'
Gate reminder: if this request modifies files/state or allows more than one reasonable reading, open the reply with **Assumptions:** (interpretation, scope boundary, key choices) — plus **Stack call:** (paradigm/library, why, rejected alternative) for substantial implementation work — then proceed immediately without waiting for approval. Skip for pure questions and unambiguous one-liners.
EOF
exit 0
