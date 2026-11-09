# MAW Agent Conventions

This file is the single source of truth for shared conventions in Mitch's Agent Workflow (MAW). Agents load it at the start of every invocation and follow the rules below.

## Project conventions

- Add or update tests only when the change affects behavior and existing tests do not cover it. Do not add tests for trivial changes.
- Do all work on a side branch following Conventional Branch naming (`<type>/<kebab-case-slug>`, e.g. `feat/add-auth`, `fix/123-token-expiry`). Never work directly on `main`/`master`.
- Do not run `git commit`, `git push`, or create PRs unless the human explicitly asks. Leave changes uncommitted for human review. When you do commit, follow Conventional Commits (`<type>(<optional scope>): <description>`, e.g. `feat(auth): add login`).
- Ask before destructive bash commands.
- Update this file if the conventions change.

## Communication conventions

Write for the reader: plain words, active voice, consistent terms, no filler.

Preserve nuance: keep assumptions, uncertainty, tradeoffs, conditions, and exceptions attached to what they modify, and use more words when fewer would change the meaning.

Ask when it matters: when ambiguity or a missing fact changes the outcome, ask and include your recommendation. Never guess silently or hide an open question to stay brief.

Keep persistent artifacts (issues, epics, docs) concise and skimmable; direct conversation can be more conversational.

## Code style conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Write self-explanatory code. Use clear names that show intent for variables, functions, and files.
- Avoid comments. Prefer self-explanatory code over explanation.
- Add a comment only when the code is complex and rewriting cannot make it clear. Keep it short and explain why, not what.
- Prefer small functions and explicit logic over clever shortcuts.

## Workflow conventions

- At the start of every MAW invocation, load the workflow configuration by invoking the `read-maw-config` skill. Use the resulting `label_prefix` and `overview_path`.
- Use the configured `label_prefix` when creating or matching MAW labels (e.g. `<label_prefix>:epic`, `<label_prefix>:task`, and `<label_prefix>:human-in-the-loop`).
- Prefer small, reviewable changes. If a task is too large, split it into multiple epics or tasks.
- Keep context with the work: shared context in the epic when one exists, task detail in the task. A standalone task holds all its context because there is no epic. Do not split work if a task would lose the context needed to complete it.
- Treat plans as working drafts. Update scope and success signals when implementation shows a better shape.

## Human-in-the-loop

Use the `<label_prefix>:human-in-the-loop` label for tasks that require a human to complete a step before automation can safely continue. Examples include database migrations, third-party integration setup, provisioning infrastructure, or obtaining human approval.

When an agent encounters a task with this label, it must stop and ask the human for the required action before proceeding. Do not attempt to perform the human-required step autonomously.

## Claiming work

In a team, a task is claimed by self-assigning the GitHub issue, then starting the workflow on it:

```bash
gh issue edit <number> --add-assignee @me
```

Then run `/orchestrate #<number>`.

Agents looking for work query open, unassigned `<label_prefix>:task` issues.
