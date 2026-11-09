# MAW North Star

This document captures the motivations, inspirations, and guiding decisions behind Mitch's Agent Workflow (MAW). It is the reference for why MAW exists and what principles it follows.

## Motivation

OpenCode is already good at the basic `plan -> implement` flow. MAW is not trying to replace that. Instead, it adds structure for cases where that flow is not enough:

- Before building, the human and the agent need a shared understanding of what to build and why.
- Work should be tracked so team members can claim, review, and close tasks.
- Complex changes benefit from an orchestrator that plans, delegates, and keeps context — rather than a single agent trying to hold everything in one context.
- Simple changes should stay lightweight: one focused implementer delegation, not an autonomous multi-agent loop.
- Sometimes a plan-mode session is not enough to capture large-scale features; the plan needs to be persisted, broken into tasks, and carried across multiple sessions or team members.

MAW exists to provide that structure inside OpenCode.

## Inspirations

### Matt Pocock's `/grill-me`

The [`grill-me`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) skill runs a relentless interview to sharpen a plan or design before any code is written. MAW adopts grilling as its front door.

Adopted pattern:

- **`/grill`** — a relentless interview that reaches shared understanding before any work begins. The conclusion is only persisted if the human asks for it, as either a project-context doc or a GitHub plan: an epic with labeled tasks, or a single labeled task when the work is self-contained.

### Jarred Sumner's Bun dynamic workflows

Jarred Sumner's [Bun rewrite post](https://bun.sh/blog/bun-in-rust) describes a workflow with:

- A powerful orchestrator that holds the main context and decisions.
- Specialized sub-agents that receive only the context they need.
- Adversarial review and bounded review/fix/test loops.

MAW adapts this into OpenCode:

- **`orchestrator`** — thin human↔subagent router: owns the plan, ensures a side branch, keeps context, and delegates. Never edits directly.
- **`implementer`** — writes code from a focused brief and leaves changes uncommitted for human review.
- **`reviewer`** — opt-in single-pass adversarial review, run only when the human asks for it.

## Guiding decisions

### Entry points

| Command / Skill | Purpose |
|-----------------|---------|
| `/grill` | Grill an idea; optionally persist as a doc, a GitHub epic + tasks, or a single task |
| `/orchestrate #123` | Run the workflow on an existing issue (side branch + implementer) |
| `/orchestrate <description>` | Start workflow-managed work from a description |
| `/orchestrate` | Start a grilling session, then workflow-managed work |
| `/maw-setup` | Configure/reconfigure MAW (global or project scope); detects existing config and asks which parts to redo |

### Labels

Use a minimal label set:

- `<label_prefix>:epic` — high-level initiative.
- `<label_prefix>:task` — actionable work item.
- `<label_prefix>:human-in-the-loop` — requires a human step before automation can continue.

Default `label_prefix` is `maw`. It is configurable during setup.

Task lifecycle is driven by assignment, not additional labels. A task is claimed by self-assigning in GitHub (`gh issue edit #123 --add-assignee @me`), then `/orchestrate #123` starts the workflow.

### Configuration

Workflow-specific config lives in `.maw/config.json` (project) or `~/.config/maw/config.json` (global):

```json
{
  "label_prefix": "maw",
  "overview_path": "docs/project-context"
}
```

The GitHub repo is not stored in config. Agents determine it from the current project's git remote.

### Models

Agent templates intentionally omit the `model` field. In OpenCode, an agent without a `model` uses the user's default model. `/maw-setup` runs `opencode models` and recommends per-agent models based on the user's available models; selected models are written as overrides into `opencode.json` under the `agent` key. This lets a global MAW install fall back to the default model while still allowing per-project overrides.

### Short vs. full loop

There are no explicit `/quick` or `/fix` commands, and no standalone shortcut path. The orchestrator classifies each request and always runs the same loop:

- Ensure a side branch, then run a light task check: confirm the goal, files and relevance, constraints, and acceptance criteria with the human, writing answers back into the task body.
- Delegate to `@implementer` with a focused brief.
- At a natural ending point, offer an optional single-pass `@reviewer`. It runs only when the human asks, and returns actionable items without auto-looping.

Every round is human-driven. Simple, localized work stays in one implementer delegation until the human is satisfied; complex or unclear work may take several rounds. The orchestrator never commits, pushes, or runs an autonomous review/fix/test loop.

### Installer behavior

- The installer uses explicit flags and defaults to a **global** install (`--global`).
- Use `--project [path]` to install into a git repository (defaults to the current directory).
- By default it fetches a versioned release from GitHub and installs the workflow files from the release's `template/` directory.
- `--version <tag>` installs a specific MAW version (e.g. `--version v0.6.0`); it defaults to `latest`.
- `--local` copies from the `template/` directory next to the script instead of fetching from GitHub; this is intended for MAW development.
- `--symlink` is only allowed with `--local` and symlinks the workflow files instead of copying.
- It never modifies the project's `README.md` or other documentation files.

### Safety

- MAW does not commit, push, or create PRs unless explicitly asked.
- `subagent_depth` is left at the opencode default of 1.
- The orchestrator does not commandeer the default OpenCode agent; it is invoked via `/orchestrate` or `@orchestrator`.

## Project conventions

- Keep changes minimal and focused.
- Follow existing code style and patterns.
- Add tests when the change affects behavior.
- Update `template/.opencode/maw/CONVENTIONS.md` and this document if the workflow or conventions change.
