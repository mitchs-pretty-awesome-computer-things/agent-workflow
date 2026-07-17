# Agent instructions for Mitch's Agent Workflow (MAW)

This file is included in OpenCode's context via `instructions: ["AGENTS.md"]`.

## What is MAW?

Mitch's Agent Workflow is a structured way to use OpenCode for both solo and team development. It uses:

1. **Grilling** to clarify intent before building.
2. **GitHub issues** (`maw:epic`, `maw:task`) to track work.
3. **Orchestrated multi-agent loops** for complex changes.
4. **A short-loop `solo` agent** for small, localized changes.

## How to start work

### Explore an idea

```
/grill-explore
```

Use this when you are not ready to commit to a plan. The agent will interview you and optionally save a project-context doc.

### Plan a feature

```
/grill-plan
```

Use this when you know what you want to build. The agent will interview you, then create a GitHub epic and tasks.

### Do workflow-managed work

```
/orchestrate #123
/orchestrate add OAuth login
/orchestrate
```

The orchestrator decides whether to use the short loop (`solo`) or the full multi-agent loop.

### Reconfigure

```
/maw-setup
```

Run this after installation or when you want to change models, labels, or other settings. It will ask whether to configure global or project scope.

## Claiming work

In a team, claim a task by self-assigning the GitHub issue:

```bash
gh issue edit 123 --add-assignee @me
```

Then run `/orchestrate #123` to start the workflow.

## Project conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Add tests when the change affects behavior.
- Do not commit, push, or open PRs unless explicitly asked.
- Update this file if the workflow or conventions change.

## Configuration reference

See `.maw/config.json` and `maw.schema.json` for the workflow configuration schema.
