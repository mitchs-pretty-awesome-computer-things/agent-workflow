---
description: Set up or reconfigure Mitch's Agent Workflow (MAW). Choose global or project scope, then configure per-agent models, GitHub labels, and workflow settings. MAW agent files intentionally omit `model`, so they use the user's default model unless overridden here.
agent: orchestrator
---

You are running the `/maw-setup` command for Mitch's Agent Workflow (MAW).

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
   - **Write MAW settings.**
     - **Global scope:** write `~/.config/maw/config.json`.
     - **Project scope:** write `.maw/config.json`.
   - **Write OpenCode agent model overrides and MAW permissions.**
     - Discover the existing OpenCode config in this precedence order. Check for both `.json` and `.jsonc` at each location:
       1. Project root `opencode.json`
       2. Project root `opencode.jsonc`
       3. `OPENCODE_CONFIG` environment variable (if set)
       4. `~/.config/opencode/opencode.json`
       5. `~/.config/opencode/opencode.jsonc`
     - Merge the MAW `agent` block into whichever config is found.
     - Merge a `permission.external_directory` block that allows MAW global paths (`~/.config/maw/**` and `~/.config/opencode/maw/**`) so MAW agents can read global config without permission prompts.
       - If the config already has a `permission.external_directory` block, add the MAW paths without removing existing entries.
       - If it has no `permission` block, create one with only the MAW external-directory entries.
     - If no existing config is found, create one at the highest-precedence location appropriate for the scope:
       - **Global scope:** create `~/.config/opencode/opencode.jsonc`.
       - **Project scope:** create `opencode.json` in the project root.
   - Do not overwrite unrelated fields in existing config files; merge them.
   - Because MAW agent files omit `model`, any agent not listed in the override block will use the user's default model.

8. **Create labels.**
   - For project scope, use the project repo discovered in step 3.
   - For global scope, ask which repo to create labels in (or skip if the user only wants defaults).
   - Use `gh label create <prefix>:epic --color "6f42c1" --description "MAW epic"` if it does not exist.
   - Use `gh label create <prefix>:task --color "0366d6" --description "MAW task"` if it does not exist.
   - Use `gh label create <prefix>:human-in-the-loop --color "d93f0b" --description "Requires human action before automation can continue"` if it does not exist.

9. **Report.**
   - Summarize the scope, repo, models, and settings that were configured.
   - Tell the user to restart OpenCode for the changes to take effect.

## Rules

- Do not delete existing OpenCode config.
- Do not create labels that already exist.
- Ask before writing to files outside the expected config locations.
- Always confirm the scope with the user before writing anything.
