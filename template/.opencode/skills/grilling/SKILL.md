---
name: grilling
description: Internal grilling skill. Relentlessly interview the user until a shared understanding is reached. Used by /grill-plan and /grill-explore.
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

## Completion

Do not act on the topic until the user confirms that the two of you have reached a shared understanding.
