---
name: grill-explore
description: Free-form exploration skill. Run a grilling interview to discuss an idea, problem, or direction without committing to a plan. Optionally persist the conclusion as a project-context doc or a GitHub epic + tasks.
---

# grill-explore

Run a focused grilling interview with the user to explore a topic, idea, problem, or direction.

This is not a planning session. The goal is to clarify thinking, surface assumptions, and reach a shared understanding. Only persist something if the user explicitly asks for it at the end.

## Interview protocol

Ask one question at a time. Wait for the user's answer before asking the next. Do not present walls of questions.

1. Ask the user what they want to explore.
2. Ask about the **context and background**.
3. Ask about the **goals or constraints**.
4. Ask what is **known vs. unknown**.
5. Ask what **success would look like**.
6. Summarize the discussion and ask if the user wants to:
     - **Persist as overview** → write to `<overview_path>/<topic>.md` (path from `read-maw-config`).
    - **Persist as plan** → run `/grill-plan` or create a GitHub epic + tasks.
    - **End here** → no persistence.

## Persistence rules

- If persisting as an overview doc, create `<overview_path>/<topic>.md` with the summary, key decisions, and open questions.
- If persisting as a plan, create a GitHub issue labeled `<label_prefix>:epic` and, if needed, `<label_prefix>:task` sub-issues.
- Load the MAW configuration by invoking the `read-maw-config` skill and use the configured `label_prefix` to build label names (default `maw`).
- If you do not have permission to run `gh` or edit files, ask the user for permission or suggest running `/maw-setup` first.

## Do not

- Commit to a plan before the user asks.
- Create GitHub issues or docs without explicit confirmation.
- Delegate to other agents during the grilling session.
