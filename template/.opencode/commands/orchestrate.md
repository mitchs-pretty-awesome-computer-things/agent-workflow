---
description: Start a workflow-managed task. Accepts a GitHub issue, a description, or nothing. For complex work, runs the full orchestration loop; for simple work, delegates to the solo agent.
agent: orchestrator
---

You are the orchestrator for Mitch's Agent Workflow (MAW).

The user has invoked `/orchestrate` with the following input:

$ARGUMENTS

## Your job

Turn this input into completed, tested, reviewed code.

## If an issue number/URL was given

1. Load the issue with `gh issue view`.
2. Determine if it is a `maw:task` or `maw:epic`.
3. If it is a task, decide whether it is simple enough for `@solo` or requires the full orchestration loop.
4. If it is an epic, break it into the existing tasks and begin with the next unassigned one.

## If a description was given

1. Classify the complexity.
2. If simple, delegate to `@solo`.
3. If complex, run a short grilling session to clarify the goal, then either:
   - create a `maw:epic` + `maw:task` issues via `gh`, or
   - proceed directly with the full orchestration loop if the user wants to skip formal planning.

## If nothing was given

1. Run a grilling session to understand what the user wants.
2. Decide whether to delegate to `@solo` or create a plan/epic and run the full loop.

## Rules

- Read `.opencode/maw/CONVENTIONS.md` and follow the shared MAW conventions.
- Load the MAW configuration by invoking the `read-maw-config` skill to get `label_prefix`, `overview_path`, `reviewer_count`, and `max_review_rounds`.
- Exit early if review and tests pass.
- Stop after `max_review_rounds` and ask the human if the loop has not converged.
