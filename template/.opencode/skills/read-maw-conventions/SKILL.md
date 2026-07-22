---
name: read-maw-conventions
description: Locate the active MAW conventions file and load its shared rules. Prefers the project-level copy; falls back to the global installation.
---

# read-maw-conventions

Determine which MAW conventions file is active for the current invocation and load its contents.

## Precedence

1. **Project-level:** `.opencode/maw/CONVENTIONS.md` in the current working directory.
2. **Global fallback:** `~/.config/opencode/maw/CONVENTIONS.md`.

## Steps

1. Check whether `.opencode/maw/CONVENTIONS.md` exists.
2. If it exists, read it. That is the active conventions file for this invocation.
3. If it does not exist, read `~/.config/opencode/maw/CONVENTIONS.md`.

## Output

Use the contents of the active conventions file as the shared MAW conventions for the current invocation. Follow the rules it contains exactly as you would follow a project-level `.opencode/maw/CONVENTIONS.md`.
