# MAW North Star

This document captures the motivations, inspirations, and guiding decisions behind Mitch's Agent Workflow (MAW). It is the reference for why MAW exists and what principles it follows.

## Motivation

OpenCode is already good at the basic `plan -> implement` flow. MAW is not trying to replace that. Instead, it adds structure for cases where that flow is not enough:

- Before building, the human and the agent need a shared understanding of what to build and why.
- Work should be tracked so team members can claim, review, and close tasks.
- Complex changes benefit from an orchestrator that plans, delegates, reviews, and tests — rather than a single agent trying to hold everything in one context.
- Simple changes should not pay the cost of a full orchestration loop.
- Sometimes a plan-mode session is not enough to capture large-scale features; the plan needs to be persisted, broken into tasks, and carried across multiple sessions or team members.

MAW exists to provide that structure inside OpenCode.

## Inspirations

### Matt Pocock's `/grill-me`

The [`grill-me`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) skill runs a relentless interview to sharpen a plan or design before any code is written. MAW adopts grilling as its front door.

Adopted pattern:

- **`grill-explore`** — free-form discussion of an idea, problem, or direction. The conclusion is only persisted if the human asks for it, as either a project-context doc or a GitHub epic + tasks.
- **`grill-plan`** — structured feature planning that produces a concrete plan and persists it as a GitHub epic with labeled sub-tasks.

### Jarred Sumner's Bun dynamic workflows

Jarred Sumner's [Bun rewrite post](https://bun.sh/blog/bun-in-rust) describes a workflow with:

- A powerful orchestrator that holds the main context and decisions.
- Specialized sub-agents (implementer, reviewer, fixer) that receive only the context they need.
- Adversarial review and bounded review/fix/test loops.

MAW adapts this into OpenCode:

- **`orchestrator`** — owns the plan, decides short vs. full loop, delegates to sub-agents.
- **`solo`** — short loop for simple, localized tasks.
- **`implementer`**, **`reviewer`**, **`fixer`**, **`tester`**, **`explorer`** — role-specific sub-agents for the full loop.

## Guiding decisions

### Entry points

| Command / Skill | Purpose |
|-----------------|---------|
| `/grill-explore` | Explore/discuss; optionally persist as doc or epic |
| `/grill-plan` | Plan a feature; persist as epic + tasks |
| `/orchestrate #123` | Run workflow on an existing issue |
| `/orchestrate <description>` | Start workflow-managed work from a description |
| `/orchestrate` | Start a grilling session, then workflow-managed work |
| `/maw-setup` | Configure/reconfigure MAW (global or project scope) |
| `@solo <task>` | Advanced: run a small task in one context |

### Labels

Use a minimal label set:

- `<prefix>:epic` — high-level initiative.
- `<prefix>:task` — actionable work item.

Default prefix is `maw`. The prefix is configurable during setup.

Task lifecycle is driven by assignment, not additional labels. A task is claimed by self-assigning in GitHub (`gh issue edit #123 --add-assignee @me`), then `/orchestrate #123` starts the workflow.

### Configuration

Workflow-specific config lives in `.maw/config.json` (project) or `~/.config/maw/config.json` (global):

```json
{
  "label_prefix": "maw",
  "overview_path": "docs/project-context",
  "reviewer_count": 1,
  "max_review_rounds": 3
}
```

The GitHub repo is not stored in config. Agents discover it from `git remote get-url origin`.

### Models

Default models are defined in the agent files, but `/maw-setup` runs `opencode models` and uses an AI agent to recommend per-agent models based on the user's actual available models. Selected models are written as overrides into `opencode.json` under the `agent` key.

### Short vs. full loop

There are no explicit `/quick` or `/fix` commands. The orchestrator classifies each request:

- Simple and localized → delegate to `solo`.
- Complex, multi-file, or unclear → run the full loop: plan → implement → review → fix → test.

The full loop exits early if review and tests pass. It stops after `max_review_rounds` and asks the human if it has not converged.

### Installer behavior

- The installer can run interactively or with explicit flags (`--global`, `--project <path>`).
- It copies agents, skills, and commands. It merges `opencode.json` rather than overwriting.
- It asks before overwriting an existing `AGENTS.md`.
- It supports symlink mode for development, but `opencode.json` is always copied (never symlinked) to protect local customizations.

### Safety

- MAW does not commit, push, or create PRs unless explicitly asked.
- `subagent_depth` is set to 1.
- The orchestrator does not commandeer the default OpenCode agent; it is invoked via `/orchestrate` or `@orchestrator`.

## Project conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Add tests when the change affects behavior.
- Update `AGENTS.md` and this document if the workflow or conventions change.
