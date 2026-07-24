---
name: grill-plan
description: Plan a feature by running an open-ended grilling interview, then persist the confirmed plan as a GitHub epic with sub-tasks and blocker relationships.
---

# grill-plan

Run an open-ended grilling interview to turn a vague idea into a concrete plan, then persist it to GitHub.

## Interview

1. Load the MAW configuration by invoking the `read-maw-config` skill.
2. Run the `/grilling` skill to reach a shared understanding of the goal, scope, constraints, and success criteria.
3. Propose a concrete plan:
   - goal and motivation
   - scope boundaries
   - constraints and risks
   - success criteria
   - a sequenced set of tasks small enough to complete in a single focused session or PR
4. Confirm the plan with the user. Do not create issues until confirmed.

## Ordering and blockers

The task sequence must make dependencies obvious. If a task depends on another, order it after its blocker and record the relationship using the blocker task's 1-based index in the ordered list (e.g., `blocked_by: [1, 3]`).

If the ordering or blocker graph is unclear, the plan is not concrete enough — go back to `/grilling` until the dependencies are clear. Do not ask the user to figure out the order for you.

## Persistence

After the user confirms the plan, present the final plan clearly (epic title, epic body, and the ordered task list with any `blocked_by` references) and then invoke the `/github-persist-plan` skill to create the epic, sub-tasks, and blocker relationships.

## Task sizing

- Tasks should be small enough to complete in a single focused session or PR.
- If a task is too large, split it further.
- Prefer tasks that are independently testable and reviewable.

## Do not

- Create issues without user confirmation.
- Edit code during the planning session.
- Delegate to other agents during the grilling session.
- Maintain a todo list for individual questions.
