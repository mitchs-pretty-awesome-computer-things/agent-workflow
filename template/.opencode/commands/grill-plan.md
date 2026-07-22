---
description: Plan a feature by running a structured grilling interview, then persist it as a GitHub epic with labeled sub-tasks.
---

You are running the `/grill-plan` command for Mitch's Agent Workflow (MAW).

The user has invoked this command with:

$ARGUMENTS

## Your job

Load the `grill-plan` skill and follow its interview protocol. Turn the user's vague idea into a concrete plan, confirm it with the user, and then create a GitHub epic and sub-tasks.

## Rules

- Load the MAW configuration by invoking the `read-maw-config` skill.
- Do not delegate to other agents during the grilling session.
- Do not create GitHub issues without user confirmation.
