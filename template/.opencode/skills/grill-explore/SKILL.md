---
name: grill-explore
description: Explore an idea or direction by running an open-ended grilling interview. Optionally persist the conclusion as a project-context doc or a GitHub epic + tasks.
---

# grill-explore

Run an open-ended grilling interview to explore a topic, idea, problem, or direction.

This is not a planning session. The goal is to clarify thinking, surface assumptions, and reach a shared understanding.

## Interview

1. Load the MAW configuration by invoking the `read-maw-config` skill.
2. Run the `/grilling` skill to explore the topic.

## Wrap-up

Once the discussion has reached a shared understanding, summarize the conclusions and ask the user what they want to do next:

- **Persist as overview** → write the summary to `<overview_path>/<topic>.md` (path from `read-maw-config`).
- **Persist as plan** → run `/grill-plan` (or invoke `/github-persist-plan` if the plan is already confirmed).
- **End here** → no persistence.

## Do not

- Commit to a plan before the user asks.
- Create GitHub issues or docs without explicit confirmation.
- Delegate to other agents during the grilling session.
- Maintain a todo list for individual questions.
