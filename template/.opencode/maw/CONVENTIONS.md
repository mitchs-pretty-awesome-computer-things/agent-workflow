# MAW Agent Conventions

This file is the single source of truth for shared conventions in Mitch's Agent Workflow (MAW). Agents read it at the start of every invocation and follow the rules below.

## Project conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Add tests when the change affects behavior.
- Do not run `git commit`, `git push`, `git reset`, `git rebase`, or create PRs unless explicitly asked.
- Ask before destructive bash commands.
- Update this file if the conventions change.

## Workflow conventions

- At the start of every MAW invocation, load the workflow configuration by invoking the `read-maw-config` skill. Use the resulting `label_prefix`, `overview_path`, `reviewer_count`, and `max_review_rounds`.
- Use the configured `label_prefix` when creating or matching MAW labels (e.g. `<prefix>:epic` and `<prefix>:task`).
- Prefer small, reviewable changes. If a task is too large, split it into multiple epics or tasks.
- Exit the implement/review/fix/test loop early if review and tests pass.
- Stop after `max_review_rounds` and ask the human how to proceed if the loop has not converged.

## Claiming work

In a team, a task is claimed by self-assigning the GitHub issue, then starting the workflow on it:

```bash
gh issue edit <number> --add-assignee @me
```

Then run `/orchestrate #<number>`.

Agents looking for work query open, unassigned `<prefix>:task` issues.
