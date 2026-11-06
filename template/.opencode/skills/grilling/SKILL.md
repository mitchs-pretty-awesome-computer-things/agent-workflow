---
name: grilling
description: Interview the user relentlessly until shared understanding is reached. Use when the user asks to be grilled, interviewed, or challenged on an idea or plan. Works in Plan mode or via the orchestrator on vague requests. Outputs a task breakdown that github-persist-plan can consume.
---

# grilling

Interview the user relentlessly about the topic until you reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.

## Question style

Keep it cognitively simple:

- Ask a single question when the question is deep, ambiguous, or depends on the previous answer.
- Ask a small batch of tightly related, easy-to-answer questions in one turn when that feels natural.
- Never dump a wall of unrelated questions on the user.

For each decision that is genuinely the user's to make, provide your recommended answer, then ask what they want.

## State management

Do **not** create or update a todo list for this conversation. Keep your agenda internal. Only surface progress to the user when you move to a new topic or phase.

## Fact-finding

If a fact can be found by exploring the codebase or the environment, look it up rather than asking the user. The decisions are the user's — put each one to them and wait for an answer.

## Task breakdown format

When the topic is heading toward implementation, steer the conversation so the outcome is easy to split into GitHub issues:

- goal and motivation
- scope boundaries (what is explicitly out of scope)
- constraints and risks
- success criteria
- a sequenced set of tasks small enough to complete in a single focused session or PR

Tasks must be independently testable and reviewable. If a task depends on another, note the dependency so it can be recorded as `blocked_by` (1-based index into the ordered task list) by `github-persist-plan`.

If the ordering or blocker graph is unclear, keep grilling until the dependencies are clear. Do not ask the user to figure out the order for you — propose an order and confirm it.

## Wrap-up

Once a shared understanding is reached, summarize and ask what next:

- **Persist as plan** → invoke the `github-persist-plan` skill (only after explicit confirmation; never create issues unasked).
- **Persist as overview doc** → write the summary to `<overview_path>/<topic>.md` (load `overview_path` via the `read-maw-config` skill; only after explicit confirmation).
- **End here** → no persistence.

## Completion

Do not act on the topic (write code, create issues/docs, delegate to agents) until the user confirms that the two of you have reached a shared understanding.

## Do not

- Create issues or docs without explicit confirmation.
- Edit code during the grilling session.
- Delegate to other agents during the grilling session.
