# Mitch's Agent Workflow (MAW)

This repository contains a custom OpenCode workflow for individual and team-based development.

It combines:

- **Grilling sessions** (inspired by Matt Pocock's `/grill-me`) for exploring ideas and planning features.
- **GitHub issue tracking** with a minimal label convention (`maw:epic`, `maw:task`).
- **Orchestrator + sub-agents** (inspired by Jarred Sumner's dynamic workflows) for complex work.
- **A short-loop agent (`solo`)** for small, localized tasks.

## Installation

Run the installer interactively:

```bash
./install.sh
```

It will ask whether to install globally or to the current project. If the current directory is a git repo, it is used as the project target.

The installer copies MAW agents, skills, and commands from `template/` into `.opencode/`. It never modifies the project's `README.md` or any other documentation file.

### Global install

```bash
./install.sh --global
```

### Project install

```bash
./install.sh --project /path/to/project
```

If no path is given and the current directory is a git repo, it is used automatically.

### Symlink for development

```bash
./install.sh --global --symlink
```

### Next step

After installation, open OpenCode in a project directory and run:

```
/maw-setup
```

`/maw-setup` will ask whether to configure global (`~/.config/...`) or project (`./.maw/`) scope.

### Agent conventions

Agent-facing shared conventions live in `.opencode/maw/CONVENTIONS.md`. Humans can read it too, but it is written for agents and is installed by MAW.

## Usage

| Entry point | Purpose |
|-------------|---------|
| `/grill-explore` | Discuss an idea or direction; optionally persist as a doc or epic |
| `/grill-plan` | Plan a feature; persist as a GitHub epic + tasks |
| `/orchestrate #123` | Run the workflow on an existing issue |
| `/orchestrate <description>` | Start workflow-managed work from a description |
| `/orchestrate` | Start a grilling session and then workflow-managed work |
| `/maw-setup` | Configure or reconfigure MAW |
| `@solo <task>` | (Advanced) run a small task in a single context |

## Configuration

Workflow-specific configuration lives in `.maw/config.json` (project) or `~/.config/maw/config.json` (global).

```json
{
  "label_prefix": "maw",
  "overview_path": "docs/project-context",
  "reviewer_count": 1,
  "max_review_rounds": 3
}
```

- `label_prefix` — prefix for GitHub labels created by MAW.
- `overview_path` — where project-context documents from `/grill-explore` are saved.
- `reviewer_count` — number of adversarial reviewers in the full orchestration loop.
- `max_review_rounds` — maximum review/fix/test rounds before asking the human.

## Labels

MAW uses only two labels by default:

- `maw:epic` — high-level feature or initiative.
- `maw:task` — actionable piece of work that can be claimed and completed.

Tasks are claimed by self-assigning in GitHub. Agents looking for work query open, unassigned `maw:task` issues.

## Claiming work

In a team, claim a task by self-assigning the GitHub issue:

```bash
gh issue edit <number> --add-assignee @me
```

Then run `/orchestrate #<number>` to start the workflow. If you are not working from an existing issue, use `/orchestrate <description>` instead.

## Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Decides short vs. full loop, delegates, owns context |
| `solo` | Short loop for simple tasks |
| `implementer` | Writes code in the full loop |
| `reviewer` | Adversarial review |
| `fixer` | Applies review feedback |
| `tester` | Runs tests |
| `explorer` | Researches code and docs |

## Git workflow

- MAW does **not** commit, push, or create PRs unless explicitly asked.
- A task is considered complete when its associated PR is reviewed and merged, and the issue is closed.

## Restarting OpenCode

OpenCode loads config at startup and does not hot-reload. After running `/maw-setup` or changing agent files, restart OpenCode.

## Developing MAW

This repository is the MAW template. The distributable workflow files live in `template/`:

- `template/.opencode/` — agents, commands, skills, and shared conventions.
- `template/.maw/config.json` — default configuration installed by `install.sh`.

To use MAW while working on MAW itself, install it into this repo like any other project:

```bash
./install.sh --project .
```

Then run `/maw-setup` in OpenCode and configure it for this project. Your local `.opencode/` and `.maw/config.json` are ignored by git so they stay separate from the template.
