#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SCOPE=""
TARGET_DIR=""
COPY_OR_SYMLINK="copy"

usage() {
  cat <<EOF
Usage: install.sh [--global | --project <path>] [--symlink]

Install Mitch's Agent Workflow (MAW) into OpenCode.

Options:
  --global          Install into ~/.config/opencode/ (global config)
  --project <path>  Install into <path>/.opencode/ (project config)
  --symlink         Symlink workflow files instead of copying

If no scope flag is passed, the script will prompt interactively.

After installation, run /maw-setup inside OpenCode to configure models and labels.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      SCOPE="global"
      shift
      ;;
    --project)
      SCOPE="project"
      if [[ -z "${2:-}" ]]; then
        echo "Error: --project requires a path" >&2
        usage
      fi
      TARGET_DIR="$2"
      shift 2
      ;;
    --symlink)
      COPY_OR_SYMLINK="symlink"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

# Interactive helpers
is_interactive() {
  [[ -t 0 ]]
}

choose() {
  local prompt="$1"
  shift
  local options=("$@")

  if is_interactive; then
    if command -v fzf >/dev/null 2>&1; then
      printf '%s\n' "${options[@]}" | fzf --prompt="${prompt} " --height=10 --layout=reverse
      return
    elif command -v whiptail >/dev/null 2>&1; then
      local args=()
      local opt
      for opt in "${options[@]}"; do
        args+=("$opt" "")
      done
      whiptail --title "MAW Installer" --menu "$prompt" 15 60 6 "${args[@]}" 3>&1 1>&2 2>&3
      return
    elif command -v dialog >/dev/null 2>&1; then
      local args=()
      local opt
      for opt in "${options[@]}"; do
        args+=("$opt" "")
      done
      dialog --title "MAW Installer" --menu "$prompt" 15 60 6 "${args[@]}" 3>&1 1>&2 2>&3
      return
    else
      echo "$prompt"
      local i=1
      for opt in "${options[@]}"; do
        echo "  $i) $opt"
        ((i++))
      done
      local choice
      read -rp "Choose [1-${#options[@]}]: " choice
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
        echo "${options[$((choice-1))]}"
        return
      else
        echo "Invalid choice." >&2
        return 1
      fi
    fi
  else
    echo "Error: running non-interactively. Specify --global or --project <path>." >&2
    return 1
  fi
}

confirm() {
  local prompt="$1"
  if is_interactive; then
    read -rp "$prompt [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]]
  else
    return 1
  fi
}

# Interactive scope selection if not provided
if [[ -z "$SCOPE" ]]; then
  if is_interactive || command -v fzf >/dev/null 2>&1 || command -v whiptail >/dev/null 2>&1 || command -v dialog >/dev/null 2>&1; then
    selected="$(choose "Where do you want to install MAW?" \
      "Global (~/.config/opencode/)" \
      "Project ($(pwd))")" || exit 1
    case "$selected" in
      Global*) SCOPE="global" ;;
      Project*) SCOPE="project" ;;
      *) echo "Invalid choice. Exiting." >&2; exit 1 ;;
    esac
  else
    echo "Error: running non-interactively. Specify --global or --project <path>." >&2
    usage
  fi
fi

# Resolve project target directory
if [[ "$SCOPE" == "project" ]]; then
  if [[ -z "$TARGET_DIR" ]]; then
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      TARGET_DIR="$(pwd)"
      echo "Detected git repo at ${TARGET_DIR}"
    else
      if is_interactive; then
        read -rp "Project path (current directory if empty): " input
        TARGET_DIR="${input:-$(pwd)}"
      else
        TARGET_DIR="$(pwd)"
      fi
    fi
  fi

  # Resolve relative paths
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

  if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Warning: ${TARGET_DIR} is not a git repository. MAW will still install, but /maw-setup may need help discovering the GitHub repo." >&2
  fi
fi

if [[ "$SCOPE" == "global" ]]; then
  OPENCODE_DIR="${HOME}/.config/opencode"
  MAW_DIR="${HOME}/.config/maw"
  INSTALL_DIR="$OPENCODE_DIR"
  AGENTS_ROOT="${HOME}"
elif [[ "$SCOPE" == "project" ]]; then
  OPENCODE_DIR="${TARGET_DIR}/.opencode"
  MAW_DIR="${TARGET_DIR}/.maw"
  INSTALL_DIR="$TARGET_DIR"
  AGENTS_ROOT="$TARGET_DIR"
fi

mkdir -p "$OPENCODE_DIR"/agents
mkdir -p "$OPENCODE_DIR"/skills
mkdir -p "$OPENCODE_DIR"/commands
mkdir -p "$MAW_DIR"

install_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ "$COPY_OR_SYMLINK" == "symlink" ]]; then
    ln -sfn "$src" "$dst"
  else
    cp -R "$src" "$dst"
  fi
}

merge_opencode_config() {
  local template="$1"
  local target="$2"

  # Always copy opencode.json (never symlink) so user customizations stay local
  if [[ ! -f "$target" ]]; then
    cp "$template" "$target"
    echo "Created ${target}"
    return
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$template" "$target" <<'PY'
import json, sys
template_path, target_path = sys.argv[1], sys.argv[2]

with open(template_path) as f:
    template = json.load(f)

with open(target_path) as f:
    existing = json.load(f)

# Merge template values only if missing in existing
for key, value in template.items():
    if key == '$schema':
        existing.setdefault('$schema', value)
    elif key == 'instructions':
        existing.setdefault('instructions', [])
        existing_instructions = existing['instructions']
        for item in value:
            if item not in existing_instructions:
                existing_instructions.append(item)
    elif key not in existing:
        existing[key] = value

with open(target_path, 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
PY
    echo "Merged MAW settings into ${target}"
  else
    echo "Warning: ${target} already exists and python3 is not available to merge config. Skipping opencode.json update." >&2
    echo "You may want to add these settings manually:" >&2
    cat "$template" >&2
  fi
}

# Install/merge OpenCode config
merge_opencode_config "${SCRIPT_DIR}/.opencode/opencode.json" "${OPENCODE_DIR}/opencode.json"

for agent in orchestrator solo implementer reviewer fixer tester explorer; do
  install_file "${SCRIPT_DIR}/.opencode/agents/${agent}.md" "${OPENCODE_DIR}/agents/${agent}.md"
done

for skill in grill-explore grill-plan; do
  install_file "${SCRIPT_DIR}/.opencode/skills/${skill}/SKILL.md" "${OPENCODE_DIR}/skills/${skill}/SKILL.md"
done

for command in maw-setup orchestrate; do
  install_file "${SCRIPT_DIR}/.opencode/commands/${command}.md" "${OPENCODE_DIR}/commands/${command}.md"
done

# Install MAW config
if [[ ! -f "${MAW_DIR}/config.json" ]]; then
  install_file "${SCRIPT_DIR}/.maw/config.json" "${MAW_DIR}/config.json"
  echo "Created ${MAW_DIR}/config.json"
else
  echo "Skipped overwriting existing ${MAW_DIR}/config.json"
fi

# For project installs, also copy AGENTS.md to project root
if [[ "$SCOPE" == "project" ]]; then
  if [[ -f "${AGENTS_ROOT}/AGENTS.md" ]]; then
    if confirm "AGENTS.md already exists in ${AGENTS_ROOT}. Overwrite?"; then
      install_file "${SCRIPT_DIR}/AGENTS.md" "${AGENTS_ROOT}/AGENTS.md"
      echo "Overwrote ${AGENTS_ROOT}/AGENTS.md"
    else
      echo "Skipped overwriting ${AGENTS_ROOT}/AGENTS.md"
    fi
  else
    install_file "${SCRIPT_DIR}/AGENTS.md" "${AGENTS_ROOT}/AGENTS.md"
    echo "Created ${AGENTS_ROOT}/AGENTS.md"
  fi
fi

echo ""
echo "MAW installed successfully (${SCOPE})."
echo ""
echo "Next step: open OpenCode in a project directory and run:"
echo "  /maw-setup"
echo ""
echo "This will ask whether to configure global or project scope, then set up models, labels, and settings."
