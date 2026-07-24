---
name: github-persist-plan
description: Persist a confirmed plan to GitHub as an epic, sub-tasks, and blocker relationships. Used by /grill-plan and /grill-explore.
---

# github-persist-plan

Persist the confirmed plan in the current conversation to GitHub as an epic with sub-tasks and inferred blocker relationships.

## Inputs

The following must already be established in the conversation:

- Epic title and body (a concise plan summary).
- A numbered list of tasks in dependency order. Each task has:
  - title
  - body
  - optional `blocked_by` list of **earlier task numbers** (1-based index in the list, e.g. `1` or `2,4`).

Tasks must be ordered so that every blocker is created before the task that depends on it.

## Validation

Before creating any issue, validate the entire blocker graph:

- Every task has a unique title.
- Every `blocked_by` reference is an integer >= 1 and less than the task's own position.
- Every blocker appears earlier in the list than the task that references it.

If any check fails, do **not** create the epic or any tasks. Return to `/grilling` until the plan is correct. No side effects should be left behind.

## Steps

1. Load the MAW configuration by invoking the `read-maw-config` skill to get the `label_prefix`.
2. Validate the blocker graph as described above.
3. Create the epic:
   ```bash
   gh issue create --title "<epic title>" --body "<epic body>" --label "<prefix>:epic"
   ```
   Capture the epic issue number from the returned URL.
4. Keep a mapping of task index → issue number as tasks are created.
5. Create each task in order. For each task at index `i`:
   - Look up its `blocked_by` indices in the task index → issue number mapping to get blocker issue numbers.
   - Create the task:
     ```bash
     gh issue create --title "<task title>" --body "<task body>" --label "<prefix>:task" --parent <epic_number> [--blocked-by <blocker_numbers>]
     ```
     - `<blocker_numbers>` is a comma-separated list of issue numbers (e.g. `3,5`).
   - Capture the new task number from the returned URL and store it under index `i`.
6. If a call fails because the repo does not support a feature, retry with only the unsupported flag removed and add that relationship as text instead:
   - `--parent` unavailable: create the task without `--parent`, then append it to the epic body as a task list item (e.g., by editing the epic with `gh issue edit <epic_number> --body "<updated body>"`):
     ```markdown
     - [ ] #<task_number>
     ```
   - `--blocked-by` unavailable: create the task without `--blocked-by`, then add the line at the top of the task body by editing it with `gh issue edit <task_number> --body "Blocked by: #<blocker_number>\n\n<original body>"`:
     ```markdown
     Blocked by: #<blocker_number>[, #<blocker_number>]
     ```
7. Report the epic and task issue numbers back to the user.

## Do not

- Create issues without the user having already confirmed the plan.
- Create tasks out of dependency order. If the order is unclear, return to `/grilling` until it is clear.
- Assign anyone by default.
