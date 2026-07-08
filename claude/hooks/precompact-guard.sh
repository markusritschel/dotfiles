#!/bin/bash
# PreCompact hook — blocks automatic compaction so the agent runs /precompact
# first (it prioritizes what to keep using the live conversation, which this
# script has no access to) and then re-issues /compact manually with that
# output.
# Matcher: "auto" — only fires on context-triggered auto-compact, never on a
# manual /compact. So once /precompact's output is pasted into /compact, that
# invocation is manual and this hook does not re-trigger.

echo '{"decision":"block","reason":"Auto-compaction was about to run. Run /precompact first to prioritize what matters in this session, then paste its output line into /compact to compact using that guidance."}'
