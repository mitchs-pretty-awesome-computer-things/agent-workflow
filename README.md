# Mitch's Agent Workflow (MAW)

MAW is a custom, opinionated, OpenCode workflow for individual and team-based development. It keeps the human in the loop rather than running autonomously.

It combines:

- **Grilling sessions** (inspired by [Matt Pocock's `/grill-me`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)) for exploring ideas. `/grill` uses an internal `grilling` skill that outputs a task breakdown; confirmed plans persist via `github-persist-plan`.
- **GitHub issue tracking** with a minimal label convention (`maw:epic`, `maw:task`).
- **Thin orchestrator + implementer** for work: the human plans (native Plan mode), then `/orchestrate` routes to `@implementer` with the human in the loop. Optional single-pass `@reviewer`.

## Installation

### Quick install (latest)

```bash
curl -fsSL https://maw.mpact.llc/install.sh | bash
```

The installer defaults to a **global** install. Use `--project [path]` to install into a specific git repository instead (defaults to the current directory).

### Install a specific version

```bash
curl -fsSL https://maw.mpact.llc/install.sh | bash -s -- --version v0.5.2
```

### Project-level install

```bash
curl -fsSL https://maw.mpact.llc/install.sh | bash -s -- --project /path/to/project
```

### Local install for development

If you are working on MAW itself and have a local clone, use `--local` so the installer copies from the `template/` directory next to the script instead of fetching from GitHub:

```bash
./install.sh --local --project .
```

To symlink files instead of copying (development only):

```bash
./install.sh --local --project . --symlink
```

### Next step

After installation, start OpenCode in a project directory and run:

```
/maw-setup
```

`/maw-setup` will ask whether to configure global (`~/.config/...`) or project (`./.maw/`) scope.

### Agent conventions

Agent-facing shared conventions live in `.opencode/maw/CONVENTIONS.md`. Humans can read it too, but it is written for agents and is installed by MAW.

## Usage

| Entry point | Purpose |
|-------------|---------|
| `/grill` | Grill an idea; optionally persist as a doc or GitHub epic + tasks |
| `/orchestrate #123` | Run the workflow on an existing issue (side branch + implementer) |
| `/orchestrate <description>` | Start workflow-managed work from a description |
| `/orchestrate` | Start a grilling session and then workflow-managed work |
| `/maw-setup` | Configure or reconfigure MAW; detects existing config and asks which parts to redo |

## Configuration

Workflow-specific configuration lives in `.maw/config.json` (project) or `~/.config/maw/config.json` (global).

```json
{
  "label_prefix": "maw",
  "overview_path": "docs/project-context"
}
```

- `label_prefix` — prefix for GitHub labels created by MAW.
- `overview_path` — where project-context documents from `/grill` are saved.

## Labels

MAW uses these labels by default:

- `maw:epic` — high-level feature or initiative.
- `maw:task` — actionable piece of work that can be claimed and completed.
- `maw:human-in-the-loop` — requires a human step (e.g., DB migration, third-party setup) before automation continues.

Tasks are claimed by self-assigning in GitHub. Agents looking for work query open, unassigned `maw:task` issues.

When an agent encounters a `maw:human-in-the-loop` issue, it stops and asks the human for the required action before proceeding.

## Claiming work

In a team, claim a task by self-assigning the GitHub issue:

```bash
gh issue edit <number> --add-assignee @me
```

Then run `/orchestrate #<number>` to start the workflow. If you are not working from an existing issue, use `/orchestrate <description>` instead.

## Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Thin human↔subagent router; ensures side branch, delegates, owns context. Never edits directly |
| `implementer` | Writes code from a spec; leaves changes uncommitted for human review |
| `reviewer` | Opt-in single-pass adversarial review (human must request it) |

## Git workflow

- MAW does all work on side branches following Conventional Branch naming (`<type>/<kebab-slug>`). It never works directly on `main`/`master`.
- MAW does **not** commit, push, or create PRs unless explicitly asked. Changes are left uncommitted for human review. Commits follow Conventional Commits.
- A task is considered complete when its associated PR is reviewed and merged, and the issue is closed.

## Reloading OpenCode

OpenCode watches config files and reloads agents, commands, skills, and plugins after a save. If changes do not appear, run `/reload`.

## Developing MAW

This repository is the MAW template. The distributable workflow files live in `template/`:

- `template/.opencode/` — agents, commands, skills, and shared conventions.
- `template/.maw/config.json` — default configuration installed by `install.sh`.

To use MAW while working on MAW itself, install it into this repo like any other project:

```bash
./install.sh --local --project .
```

Then run `/maw-setup` in OpenCode and configure it for this project. Your local `.opencode/` and `.maw/config.json` are ignored by git so they stay separate from the template.
