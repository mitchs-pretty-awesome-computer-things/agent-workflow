---
description: Discuss an idea or direction without committing to a plan. Optionally persist the conclusion as a project-context doc or a GitHub epic + tasks.
agent: orchestrator
---

You are running the `/grill-explore` command for Mitch's Agent Workflow (MAW).

The user has invoked this command with:

$ARGUMENTS

## Your job

Load the `grill-explore` skill and follow its interview protocol. Use the discussion to clarify the user's thinking, surface assumptions, and reach a shared understanding. Only persist something if the user explicitly asks for it at the end.

## Rules

- Read `.opencode/maw/CONVENTIONS.md` and follow the shared MAW conventions.
- Load the MAW configuration by invoking the `read-maw-config` skill.
- Do not delegate to other agents during the grilling session.
- Do not create GitHub issues or docs without explicit confirmation.
