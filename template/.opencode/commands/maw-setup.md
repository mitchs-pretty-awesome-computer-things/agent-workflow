---
description: Set up or reconfigure Mitch's Agent Workflow (MAW). Detects existing global or project configuration and asks which parts to update, so reruns after an install/upgrade are incremental.
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

4. **Detect existing configuration.**
   - Read the MAW config for the selected scope if it exists:
     - Global scope: `~/.config/maw/config.json`
     - Project scope: `.maw/config.json` in the current working directory
   - Discover the existing OpenCode config in this precedence order. Check for both `.json` and `.jsonc` at each location:
     1. Project root `opencode.json`
     2. Project root `opencode.jsonc`
     3. `OPENCODE_CONFIG` environment variable (if set)
     4. `~/.config/opencode/opencode.json`
     5. `~/.config/opencode/opencode.jsonc`
   - If an OpenCode config is found, extract any existing MAW `agent` overrides and any existing `permission.external_directory` entries.
   - List existing labels in the target repo with `gh label list` and note which MAW labels (`<prefix>:epic`, `<prefix>:task`, `<prefix>:human-in-the-loop`) are already present, using the existing `label_prefix` if one is configured.
   - Present a concise summary of what is already configured and what is missing.

5. **Ask what to (re)configure.**
   - If no existing configuration is found, proceed with the full setup.
   - If existing configuration is found, ask the user which sections to **keep**, **update**, or **reset to defaults**:
     - **Workflow settings** (`label_prefix`, `overview_path`, `reviewer_count`, `max_review_rounds`)
     - **Agent model overrides** (per-agent `provider/model-id` entries in OpenCode config). For this section, the reset option is **use default model** (remove overrides so agents fall back to the user's default model).
     - **GitHub labels** (`<prefix>:epic`, `<prefix>:task`, `<prefix>:human-in-the-loop`)
   - Only proceed with the sections the user selects. Skip anything they choose to keep.
   - When updating workflow settings or model overrides, use the existing values as the defaults.
   - When resetting to defaults, use the MAW default values (`label_prefix: maw`, `overview_path: docs/project-context`, `reviewer_count: 1`, `max_review_rounds: 3`) for workflow settings.

6. **List available models** (only if configuring agent model overrides).
   - Run `opencode models`.
   - If that fails, read the existing `opencode.json` provider config and fetch `https://models.dev/model-schema.json` as a fallback.

7. **Recommend models per agent** (only if configuring agent model overrides).
   - For each agent (`orchestrator`, `implementer`, `reviewer`, `fixer`, `tester`, `explorer`, `solo`), analyze the model list and recommend a `provider/model-id`.
   - Use these heuristics:
     - `orchestrator`: high context window, reasoning capability, strong overall performance.
     - `implementer`/`reviewer`/`fixer`: strong coding performance, tool calling.
     - `tester`/`explorer`: low cost, adequate context, tool calling.
     - `solo`: strong coding performance, tool calling.
   - If an override already exists for an agent, use it as the recommendation instead of the heuristic default.
   - Present the recommendations with brief explanations.

8. **Ask the user** (only for selected sections).
   - For **workflow settings**, confirm or override each value, prefilling with the current value if one exists, otherwise the MAW default.
   - For **agent model overrides**, confirm or override each recommended model.
   - For **GitHub labels**, confirm whether to create any missing labels. Default to creating missing labels if this section was selected.

9. **Write config.**
   - **Write MAW settings** only if the workflow settings section was selected.
     - **Global scope:** write `~/.config/maw/config.json`.
     - **Project scope:** write `.maw/config.json`.
   - **Write OpenCode agent model overrides and MAW permissions** only if the agent model overrides section was selected.
     - Use the same OpenCode config location discovered in step 4, or, if no config was found, create one at the highest-precedence location appropriate for the scope:
       - **Global scope:** create `~/.config/opencode/opencode.jsonc`.
       - **Project scope:** create `opencode.json` in the project root.
     - Merge the MAW `agent` block into the config, updating only the agents the user confirmed. If the user chose to use the default model for agent overrides, remove the MAW agent entries (do not remove unrelated agents).
     - Merge a `permission.external_directory` block that allows MAW global paths (`~/.config/maw/**` and `~/.config/opencode/maw/**`) so MAW agents can read global config without permission prompts.
       - If the config already has a `permission.external_directory` block, add the MAW paths without removing existing entries.
       - If it has no `permission` block, create one with only the MAW external-directory entries.
   - Do not overwrite unrelated fields in existing config files; merge them.
   - Because MAW agent files omit `model`, any agent not listed in the override block will use the user's default model.

10. **Create labels** (only if the GitHub labels section was selected).
    - For project scope, use the project repo discovered in step 3.
    - For global scope, ask which repo to create labels in (or skip if the user only wants defaults).
    - Use `gh label create <prefix>:epic --color "6f42c1" --description "MAW epic"` if it does not exist.
    - Use `gh label create <prefix>:task --color "0366d6" --description "MAW task"` if it does not exist.
    - Use `gh label create <prefix>:human-in-the-loop --color "d93f0b" --description "Requires human action before automation can continue"` if it does not exist.

11. **Report.**
    - Summarize the scope, repo, and which sections were kept, updated, reset to defaults, or set to use the default model.
    - List the final workflow settings and any model overrides that were written.
    - Note which labels exist or were created.
    - Tell the user to restart OpenCode for the changes to take effect.

## Rules

- Do not delete existing OpenCode config.
- Do not create labels that already exist.
- Ask before writing to files outside the expected config locations.
- Always confirm the scope with the user before reading or writing anything.
- Preserve existing configuration that the user chooses to keep; do not rewrite files for sections that were skipped.
