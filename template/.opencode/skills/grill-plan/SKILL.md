---
name: grill-plan
description: Feature planning skill. Run a grilling interview to formulate a concrete plan, then persist it as a GitHub epic with labeled sub-tasks.
---

# grill-plan

Run a structured grilling interview to turn a vague idea into a concrete plan.

## Interview protocol

Ask one question at a time. Wait for the user's answer before asking the next. Do not present walls of questions.

1. Ask the user what they want to build.
2. Ask a clarifying question about **what** the feature or change is.
3. Ask **why** it matters (motivation, user value).
4. Ask **who** it is for.
5. Ask about **scope** — what is in and what is out?
6. Ask about **constraints** — performance, security, compatibility, deadlines.
7. Ask about **success criteria** — how will we know it works?
8. Ask about **risks** — what could go wrong?
9. Identify the smallest useful slice to ship first.
10. Propose a set of tasks.
11. Confirm the plan with the user before persisting.

## Persistence

After confirmation:

1. Load the MAW configuration by invoking the `read-maw-config` skill to get the `label_prefix`.
2. Create an epic issue on GitHub labeled `<prefix>:epic` with the plan summary in the body.
3. Create sub-task issues labeled `<prefix>:task` linked to the epic.
   - Use the epic issue number in each task body (e.g., `Epic: #123`).
   - Do not assign anyone by default.
4. Report the epic and task issue numbers back to the user.

## Task sizing

- Tasks should be small enough to complete in a single focused session or PR.
- If a task is too large, split it further.
- Prefer tasks that are independently testable and reviewable.

## Do not

- Create issues without user confirmation.
- Edit code during the planning session.
- Delegate to other agents during the grilling session.
