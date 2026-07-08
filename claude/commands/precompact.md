---
description: Prioritize what matters, then emit a ready-to-paste /compact instruction string.
argument-hint: "[optional: focus area to prioritize, e.g. 'the auth bug']"
---

Before compacting, don't just summarize — prioritize. Work through the following questions about this session, in order, and use your answers to build a `/compact` instruction string.

If a focus area was given ($ARGUMENTS), weight the whole pass toward that thread: make sure it is captured in full detail in steps 1–6, and be more willing to file competing material under step 7 (safe to drop). If no focus area was given, prioritize evenly across the session.

## 1. Task & success criteria
What was actually asked for, in one or two sentences? Has it been fully completed, partially completed, or is it still in progress? If there were constraints or clarifications given along the way, note them.

## 2. Decisions and their rationale
What choices were made that would be expensive or risky to re-derive from scratch — architecture, approach, library/tool choices, naming conventions, trade-offs explicitly accepted or rejected? For each, capture the decision AND the reason, not just the decision (the reason is what prevents it from being silently re-litigated later).

## 3. Open loops
Anything unresolved: bugs being tracked down, errors seen but not yet fixed, hypotheses being tested, questions the user hasn't answered yet, blockers. If you're mid-debug on something, state exactly what's broken and what's been ruled out already — this is the detail most likely to evaporate in a generic summary. Also note any uncommitted or staged changes sitting in the working tree — work that exists but hasn't been committed is an open loop too.

## 4. Scope map
Which files/areas were touched, and how. Which files/areas were deliberately left alone (and why, if there's a reason — e.g. "out of scope" vs "intentionally not touching legacy code"). Also note which branch this work is on and which commits (if any) it landed in — this prevents future-you from re-exploring ground already covered or losing track of where the work actually lives.

## 5. Corrections
Anything the user corrected you on, or any approach that was tried and explicitly abandoned. These are worth keeping because a summary optimized for "what's true now" tends to drop them — and then the same mistake gets a second try.

## 6. Next steps
Concrete next actions, in priority order if there's more than one. Not vague ("continue implementation") but specific ("run the migration script, then update the three callers in `x.py`").

## 7. Safe to drop
Explicitly name what does NOT need to survive compaction — exploratory dead ends, verbose tool output, anything easily re-derived by reading the repo/docs again. Naming this out loud is what keeps step 1–6 from ballooning back into "just summarize everything."

---

After working through 1–7, output a single ready-to-paste line in this exact format, so it can be copied straight into the compact command:

```
/compact Preserve: [2-3 sentence synthesis of 1-4]. Open loops: [synthesis of 3]. Next: [synthesis of 6]. Drop: [synthesis of 7].
```

Keep the whole `/compact` line under ~120 words — if it's longer, you haven't prioritized, you've just restructured the summary.
