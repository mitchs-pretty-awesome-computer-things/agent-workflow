# MAW Agent Conventions

This file is the single source of truth for shared conventions in Mitch's Agent Workflow (MAW). Agents load it at the start of every invocation and follow the rules below.

The project-level copy at `.opencode/maw/CONVENTIONS.md` takes precedence. If it does not exist, load the global copy at `~/.config/opencode/maw/CONVENTIONS.md` by invoking the `read-maw-conventions` skill.

## Project conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Add tests when the change affects behavior.
- Do not run `git commit`, `git push`, `git reset`, `git rebase`, or create PRs unless explicitly asked.
- Ask before destructive bash commands.
- Update this file if the conventions change.

## Workflow conventions

- At the start of every MAW invocation, load the workflow configuration by invoking the `read-maw-config` skill. Use the resulting `label_prefix`, `overview_path`, `reviewer_count`, and `max_review_rounds`.
- Use the configured `label_prefix` when creating or matching MAW labels (e.g. `<prefix>:epic`, `<prefix>:task`, and `<prefix>:human-in-the-loop`).
- Prefer small, reviewable changes. If a task is too large, split it into multiple epics or tasks.
- Exit the implement/review/fix/test loop early if review and tests pass.
- Stop after `max_review_rounds` and ask the human how to proceed if the loop has not converged.

## Human-in-the-loop

Use the `<prefix>:human-in-the-loop` label for tasks that require a human to complete a step before automation can safely continue. Examples include database migrations, third-party integration setup, provisioning infrastructure, or obtaining human approval.

When an agent encounters a task with this label, it must stop and ask the human for the required action before proceeding. Do not attempt to perform the human-required step autonomously.

## Claiming work

In a team, a task is claimed by self-assigning the GitHub issue, then starting the workflow on it:

```bash
gh issue edit <number> --add-assignee @me
```

Then run `/orchestrate #<number>`.

Agents looking for work query open, unassigned `<prefix>:task` issues.
