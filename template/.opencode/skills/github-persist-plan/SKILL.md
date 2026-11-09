---
name: github-persist-plan
description: Persist a confirmed plan to GitHub as an epic with sub-tasks and blockers, or as a single standalone task when the plan is one self-contained piece of work. Use after any confirmed plan, not only grilling.
---

# github-persist-plan

Persist the confirmed plan in the current conversation to GitHub. The plan may come from grilling, the orchestrator, or an ad-hoc request. Choose the mode from the shape of the plan:

- **Mode A — epic with tasks:** work that needs shared context and more than one ordered task.
- **Mode B — single task:** one self-contained piece of work with no parent epic and no blockers.

Do not force a single self-contained task into an epic.

## Inputs

The following must already be established in the conversation.

### Mode A: epic with tasks

- Epic title and body.
- A numbered list of tasks in dependency order. Each task has:
  - title
  - body
  - optional `blocked_by` list of **earlier task numbers** (1-based index in the list, e.g. `1` or `2,4`).

Tasks must be ordered so that every blocker is created before the task that depends on it.

### Mode B: single task

- Task title and body.
- No epic.
- No `blocked_by` list.

Use Mode B only when the plan contains exactly one task and a fresh agent can act from that task body alone. If the work needs shared context that belongs in an epic, or splits into more than one task, use Mode A.

## Body content

Follow the grilling breakdown format. A fresh agent must be able to act from a task plus its epic in Mode A, or from the single task alone in Mode B.

Use file paths; add code snippets only when the exact content matters. Do not list work as out of scope.

## Validation

Before creating any issue, validate body sufficiency. In Mode A, also validate the blocker graph.

### Mode A validation

- The plan contains at least one task. A plan with zero tasks is invalid.
- Every task has a unique title.
- Every `blocked_by` reference is an integer >= 1 and less than the task's own position.
- Every blocker appears earlier in the list than the task that references it.
- Every task body states its goal, the files or directories it touches, and its acceptance criteria.
- No task body defers required detail to the epic with phrases like "see epic for details" or leaves required detail as `TBD`, `TODO`, or `TBC` (case-insensitive).

### Mode B validation

- The plan contains exactly one task. A plan with zero tasks is invalid, and a plan with more than one task must use Mode A.
- The task body states its goal, the files or directories it touches, and its acceptance criteria.
- The body is self-contained: it does not defer detail to an epic with phrases like "see epic for details" and does not leave required detail as `TBD`, `TODO`, or `TBC` (case-insensitive).
- The body does not reference a parent epic, a blocker, or context that lives outside the task (for example, "see epic for details", "blocked by #123", or "as described in the epic"). Mode B has no epic to hold shared context.
- The plan has no `blocked_by` list, and the creation command passes neither `--parent` nor `--blocked-by`.
- If the work depends on shared context that belongs in an epic, reject the plan and use Mode A. The only exception is explicit user confirmation of "no shared context needed"; in that case, fold the required context into the task body and note the confirmation.

If any check fails, do **not** create any issue, make no `gh` calls, and leave no side effects. Fail closed rather than dropping a flag, blocker, or context. Return to planning (grilling if that's the source) or ask the user until the plan is correct.

## Steps

1. Load the MAW configuration by invoking the `read-maw-config` skill to get the `label_prefix`.
2. Choose the mode and validate as described above.
3. **Mode A: create the epic, then the tasks in order.**
   - Create the epic:
     ```bash
     gh issue create --title "<epic title>" --body "<epic body>" --label "<label_prefix>:epic"
     ```
     Capture the epic issue number from the returned URL.
   - Keep a mapping of task index → issue number as tasks are created.
   - Create each task in order. For each task at index `i`:
     - Look up its `blocked_by` indices in the task index → issue number mapping to get blocker issue numbers.
     - Create the task:
       ```bash
       gh issue create --title "<task title>" --body "<task body>" --label "<label_prefix>:task" --parent <epic_number> [--blocked-by <blocker_numbers>]
       ```
       - `<blocker_numbers>` is a comma-separated list of issue numbers (e.g. `3,5`).
     - Capture the new task number from the returned URL and store it under index `i`.
   - If a call fails because the repo does not support a feature, retry with only the unsupported flag removed and add that relationship as text instead:
     - `--parent` unavailable: create the task without `--parent`, then append it to the epic body. Fetch the current epic body first so existing content is preserved, then edit it with the task appended:
       ```bash
       epic_body=$(gh issue view <epic_number> --json body --jq .body)
       gh issue edit <epic_number> --body "$epic_body

       - [ ] #<task_number>"
       ```
     - `--blocked-by` unavailable: create the task without `--blocked-by`, then add the line at the top of the task body by editing it with `gh issue edit <task_number> --body "Blocked by: #<blocker_number>\n\n<original body>"`:
       ```markdown
       Blocked by: #<blocker_number>[, #<blocker_number>]
       ```
4. **Mode B: create the single task.**
   ```bash
   gh issue create --title "<task title>" --body "<task body>" --label "<label_prefix>:task"
   ```
   - Do not pass `--parent` or `--blocked-by`. Mode B has no epic and no blockers.
5. Report the created issue numbers back to the user. In Mode A, report the epic and task numbers; in Mode B, report the task number.

## Partial failure

If a `gh issue create` or follow-up `gh issue edit` fails partway through a sequence, stop. Do not retry the whole plan, and do not delete, close, or otherwise clean up issues that were already created.

Report:
- every issue created so far, as epic and task numbers plus the task index each number maps to
- the step that failed and its error
- the first task index that has no issue number yet

To resume, start at that first uncreated task index, reuse the existing epic and the index → issue number mapping, and create only the remaining tasks. Never recreate an issue that already exists to recover.

A failure caused by an unsupported flag is not a partial failure: retry that single task with only the unsupported flag removed, as described above.

## Do not

- Create issues without the user having already confirmed the plan.
- Force a single self-contained task into an epic. Use Mode B instead.
- Create tasks out of dependency order. If the order is unclear, return to planning until it is clear.
- Assign anyone by default.
