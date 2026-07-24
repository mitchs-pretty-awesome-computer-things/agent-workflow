---
name: github-persist-plan
description: Persist a confirmed plan to GitHub as an epic, sub-tasks, and blocker relationships. Used by /grill-plan and /grill-explore.
---

# github-persist-plan

Persist the confirmed plan in the current conversation to GitHub as an epic with sub-tasks and inferred blocker relationships.

## Inputs

The following must already be established in the conversation:

- Epic title and body (a concise plan summary).
- A list of tasks in dependency order. Each task has:
  - title
  - body
  - optional `blocked_by` list of earlier task issue numbers/URLs.

Tasks must be ordered so that every blocker is created before the task that depends on it.

## Steps

1. Load the MAW configuration by invoking the `read-maw-config` skill to get the `label_prefix`.
2. Create the epic:
   ```bash
   gh issue create --title "<epic title>" --body "<epic body>" --label "<prefix>:epic"
   ```
   Capture the epic issue number from the returned URL.
3. Create each task in order. For each task:
   ```bash
   gh issue create --title "<task title>" --body "<task body>" --label "<prefix>:task" --parent <epic_number> [--blocked-by <blocker_numbers>]
   ```
   - `<blocker_numbers>` is a comma-separated list of issue numbers (e.g. `3,5`).
   - Capture the new task number from the returned URL.
4. If a call fails because the repo does not support a feature, retry with only the unsupported flag removed and add that relationship as text instead:
   - `--parent` unavailable: create the task without `--parent`, then append it to the epic body as a task list item (e.g., by editing the epic with `gh issue edit <epic_number> --body "<updated body>"`):
     ```markdown
     - [ ] #<task_number>
     ```
   - `--blocked-by` unavailable: create the task without `--blocked-by`, then add the line at the top of the task body by editing it with `gh issue edit <task_number> --body "Blocked by: #<blocker_number>\n\n<original body>"`:
     ```markdown
     Blocked by: #<blocker_number>[, #<blocker_number>]
     ```
5. Report the epic and task issue numbers back to the user.

## Do not

- Create issues without the user having already confirmed the plan.
- Create tasks out of dependency order. If the order is unclear, return to `/grilling` until it is clear.
- Assign anyone by default.
