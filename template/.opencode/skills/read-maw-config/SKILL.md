---
name: read-maw-config
description: Load and return the effective Mitch's Agent Workflow (MAW) configuration, merging project and global config files with project taking precedence.
---

# read-maw-config

Load the MAW configuration from the most appropriate source and return the resolved settings.

## Sources (in precedence order)

1. **Project config:** `.maw/config.json` in the current working directory (or nearest project root).
2. **Global config:** `~/.config/maw/config.json`.

## Merge behavior

- If only a global config exists, use it as-is.
- If only a project config exists, use it as-is.
- If both exist, merge them. **Project values override global values** for any overlapping keys.
- Ignore any extra keys that are not part of the MAW configuration; only `label_prefix`, `overview_path`, `reviewer_count`, and `max_review_rounds` are used.
- If neither exists, report the default values:
  - `label_prefix`: `maw`
  - `overview_path`: `docs/project-context`
  - `reviewer_count`: 1
  - `max_review_rounds`: 3

## Usage

When another agent needs MAW settings, invoke this skill and use the returned configuration for `label_prefix`, `overview_path`, `reviewer_count`, and `max_review_rounds`.

## Do not

- Do not write to either config file.
- Do not treat a missing config as an error unless the caller requires one.
