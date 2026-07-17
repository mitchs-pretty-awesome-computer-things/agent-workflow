---
name: grill-plan
description: Feature planning skill. Run a grilling interview to formulate a concrete plan, then persist it as a GitHub epic with labeled sub-tasks.
---

# grill-plan

Run a structured grilling interview to turn a vague idea into a concrete plan.

## Interview protocol

1. Ask the user what they want to build.
2. Drill into:
   - **What** is the feature or change?
   - **Why** does it matter? (motivation, user value)
   - **Who** is it for?
   - **Scope** — what is in and out?
   - **Constraints** — performance, security, compatibility, deadlines.
   - **Success criteria** — how will we know it works?
   - **Risks** — what could go wrong?
3. Identify the smallest useful slice to ship first.
4. Propose a set of tasks.
5. Confirm the plan with the user before persisting.

## Persistence

After confirmation:

1. Discover the GitHub repo from `git remote get-url origin`.
2. Read `.maw/config.json` to get the `label_prefix`.
3. Create an epic issue labeled `<prefix>:epic` with the plan summary in the body.
4. Create sub-task issues labeled `<prefix>:task` linked to the epic.
   - Use the epic issue number in each task body (e.g., `Epic: #123`).
   - Do not assign anyone by default.
5. Report the epic and task issue numbers back to the user.

## Task sizing

- Tasks should be small enough to complete in a single focused session or PR.
- If a task is too large, split it further.
- Prefer tasks that are independently testable and reviewable.

## Do not

- Create issues without user confirmation.
- Edit code during the planning session.
- Delegate to other agents during the grilling session.
