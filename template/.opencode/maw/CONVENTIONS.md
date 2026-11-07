# MAW Agent Conventions

This file is the single source of truth for shared conventions in Mitch's Agent Workflow (MAW). Agents load it at the start of every invocation and follow the rules below.

## Project conventions

- Add or update tests only when the change affects behavior and existing tests do not cover it. Do not add tests for trivial changes.
- Do all work on a side branch following Conventional Branch naming (`<type>/<kebab-case-slug>`, e.g. `feat/add-auth`, `fix/123-token-expiry`). Never work directly on `main`/`master`.
- Do not run `git commit`, `git push`, or create PRs unless the human explicitly asks. Leave changes uncommitted for human review. When you do commit, follow Conventional Commits (`<type>(<optional scope>): <description>`, e.g. `feat(auth): add login`).
- Ask before destructive bash commands.
- Update this file if the conventions change.

## Communication conventions

Before you write any direct response, apply ASD-STE100 Simplified Technical English:
- Use active voice only.
- Keep sentences short (maximum 20 words for instructions, 25 words for descriptions).
- Express only one idea per sentence.
- Use simple, direct words (e.g. use "use" instead of "utilize", "make sure" instead of "ensure").
- Do not use jargon, metaphors, slang, or conversational filler.
- Use the same word consistently for the same object or action.

## Code style conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Write self-explanatory code. Use clear names that show intent for variables, functions, and files.
- Avoid comments. Prefer self-explanatory code over explanation.
- Add a comment only when the code is complex and rewriting cannot make it clear. Keep it short and explain why, not what.
- Prefer small functions and explicit logic over clever shortcuts.

## Workflow conventions

- At the start of every MAW invocation, load the workflow configuration by invoking the `read-maw-config` skill. Use the resulting `label_prefix` and `overview_path`.
- Use the configured `label_prefix` when creating or matching MAW labels (e.g. `<prefix>:epic`, `<prefix>:task`, and `<prefix>:human-in-the-loop`).
- Prefer small, reviewable changes. If a task is too large, split it into multiple epics or tasks.
- Keep context with the work: shared context in the epic, task detail in the task. Do not split work if a task would lose the context needed to complete it.
- Treat plans as working drafts. Update scope and success signals when implementation shows a better shape.

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
