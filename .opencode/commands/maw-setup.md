---
description: Set up or reconfigure Mitch's Agent Workflow (MAW). Choose global or project scope, then configure models, GitHub labels, and workflow settings.
agent: orchestrator
---

You are running the `/maw-setup` command for Mitch's Agent Workflow (MAW).

Read `.opencode/maw/CONVENTIONS.md` and follow the shared MAW conventions.

Your job is to guide the user through setup and write the configuration files. This command always runs from an OpenCode project session, but it can configure either global defaults or the current project.

## Steps

1. **Choose scope.**
   - Ask the user whether they want to configure **global** (`~/.config/...`) or **project** (`.maw/`, `.opencode/` in the current working directory) settings.
   - Explain that global settings apply everywhere, while project settings override global ones.

2. **Check prerequisites.**
   - Verify `gh` is installed and authenticated.
   - Verify `opencode` is installed and configured.

3. **Discover the GitHub repo.**
   - Determine the project repo from the current directory's git remote.
   - If ambiguous or no remote, ask the user.
   - For global scope, this is used as the default repo to prefill; for project scope, it is the project repo.

4. **List available models.**
   - Run `opencode models`.
   - If that fails, read the existing `opencode.json` provider config and fetch `https://models.dev/model-schema.json` as a fallback.

5. **Recommend models per agent.**
   - For each agent (`orchestrator`, `implementer`, `reviewer`, `fixer`, `tester`, `explorer`, `solo`), analyze the model list and recommend a `provider/model-id`.
   - Use these heuristics:
     - `orchestrator`: high context window, reasoning capability, strong overall performance.
     - `implementer`/`reviewer`/`fixer`: strong coding performance, tool calling.
     - `tester`/`explorer`: low cost, adequate context, tool calling.
     - `solo`: strong coding performance, tool calling.
   - Present the recommendations with brief explanations.

6. **Ask the user.**
   - Confirm or override each recommended model.
   - Confirm the label prefix (default `maw`).
   - Confirm the overview path (default `docs/project-context`).
   - Confirm reviewer count (default 1) and max review rounds (default 3).

7. **Write config.**
   - **Global scope:** write `~/.config/maw/config.json` and update `~/.config/opencode/opencode.json` with an `agent` block overriding default models for MAW agents.
   - **Project scope:** write `.maw/config.json` and update `.opencode/opencode.json` with an `agent` block overriding default models for MAW agents.
   - Do not overwrite unrelated fields in existing config files; merge them.

8. **Create labels.**
   - For project scope, use the project repo discovered in step 3.
   - For global scope, ask which repo to create labels in (or skip if the user only wants defaults).
   - Use `gh label create <prefix>:epic --color "#0366d6" --description "MAW epic"` if it does not exist.
   - Use `gh label create <prefix>:task --color "#0e8a16" --description "MAW task"` if it does not exist.

9. **Report.**
   - Summarize the scope, repo, models, and settings that were configured.
   - Tell the user to restart OpenCode for the changes to take effect.

## Rules

- Do not delete existing OpenCode config.
- Do not create labels that already exist.
- Ask before writing to files outside the expected config locations.
- Always confirm the scope with the user before writing anything.
