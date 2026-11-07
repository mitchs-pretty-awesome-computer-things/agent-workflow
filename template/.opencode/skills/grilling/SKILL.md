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

When the topic heads toward implementation, shape the outcome so it can become GitHub issues. For the epic, capture:

- goal and motivation
- current scope, as a working assumption
- constraints and risks
- success signals, as a current hypothesis
- a sequenced set of tasks small enough for one focused session or PR

For each task, capture its goal and why it exists, the files and directories it touches with a note on relevance, constraints, and acceptance criteria. Keep shared context in the epic and task detail in the task. Do not split work if a task would lose the context needed to finish it.

Treat scope and success signals as working hypotheses. Do not list work as out of scope. Record a shift when it happens.

Tasks must be independently testable and reviewable. Note dependencies so `github-persist-plan` can record them as `blocked_by` (1-based index into the ordered list).

If the ordering or blocker graph is unclear, keep grilling until the dependencies are clear. Do not ask the user to figure out the order for you — propose an order and confirm it.

## Task-scoped pass

Before each delegation, the orchestrator runs a light pass on one task. Confirm only what its body leaves open: goal, files and relevance, constraints, acceptance. Ask in one or two small batches and stop once an implementer can start.

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
