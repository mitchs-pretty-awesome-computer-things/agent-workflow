#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Repository coordinates for remote installs
REPO_OWNER="mitchs-pretty-awesome-computer-things"
REPO_NAME="agent-workflow"

# Default values
SCOPE=""
TARGET_DIR=""
COPY_OR_SYMLINK="copy"
VERSION="latest"
LOCAL=false

usage() {
  cat <<EOF
Usage: install.sh [-g|--global] [-p|--project <path>] [-v|--version <version>] [-l|--local] [-s|--symlink] [-h|--help]

Install Mitch's Agent Workflow (MAW) into OpenCode.

Options:
  -g, --global        Install into ~/.config/opencode/ (global config)
  -p, --project PATH  Install into <path>/.opencode/ (project config)
  -v, --version VER   Install a specific MAW version (default: latest)
  -l, --local         Use the local template/ directory instead of fetching from GitHub
  -s, --symlink       Symlink workflow files instead of copying (only valid with --local)
  -h, --help          Show this help message

If no scope flag is passed, the script will prompt interactively.

After installation, run /maw-setup inside OpenCode to configure models and labels.

Examples:
  Install latest globally:
    curl -fsSL https://maw.mpact.llc/install.sh | bash -s -- -g

  Install a specific version into a project:
    curl -fsSL https://maw.mpact.llc/install.sh | bash -s -- -v v0.1.0 -p /path/to/project

  Local development (from a clone):
    ./install.sh -l -p .
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global)
      SCOPE="global"
      shift
      ;;
    -p|--project)
      SCOPE="project"
      if [[ -z "${2:-}" ]]; then
        echo "Error: --project requires a path" >&2
        usage
      fi
      TARGET_DIR="$2"
      shift 2
      ;;
    -v|--version)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --version requires a value" >&2
        usage
      fi
      VERSION="$2"
      shift 2
      ;;
    -l|--local)
      LOCAL=true
      shift
      ;;
    -s|--symlink)
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

if [[ "$COPY_OR_SYMLINK" == "symlink" && "$LOCAL" != true ]]; then
  echo "Error: -s/--symlink is only valid with -l/--local" >&2
  exit 1
fi

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

# Resolve a URL to stdout using curl or wget
fetch_url() {
  local url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
  else
    echo "Error: curl or wget is required for remote installs" >&2
    exit 1
  fi
}

# Resolve "latest" to the newest tag via the GitHub API
resolve_latest_version() {
  local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tags?per_page=1"
  local response
  response=$(fetch_url "$api_url") || {
    echo "Error: failed to fetch latest version from ${api_url}" >&2
    exit 1
  }
  local tag
  tag=$(printf '%s\n' "$response" | grep -o '"name": "[^"]*"' | head -n1 | cut -d'"' -f4)
  if [[ -z "$tag" ]]; then
    echo "Error: could not determine latest version from GitHub API" >&2
    exit 1
  fi
  echo "$tag"
}

# Download the template directory for the requested version
fetch_remote_template() {
  local version="$1"
  local tag="$version"
  if [[ "$version" == "latest" ]]; then
    tag=$(resolve_latest_version)
    echo "Resolved latest version: ${tag}"
  fi

  local tarball_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${tag}.tar.gz"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  local tarball="${tmp_dir}/maw-${tag}.tar.gz"

  echo "Fetching ${tarball_url}..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$tarball_url" -o "$tarball" || {
      echo "Error: failed to download ${tarball_url}" >&2
      rm -rf "$tmp_dir"
      exit 1
    }
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$tarball_url" -O "$tarball" || {
      echo "Error: failed to download ${tarball_url}" >&2
      rm -rf "$tmp_dir"
      exit 1
    }
  else
    echo "Error: curl or wget is required for remote installs" >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  tar -xzf "$tarball" -C "$tmp_dir"
  local extracted_dir
  extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n1)
  if [[ -z "$extracted_dir" ]]; then
    echo "Error: could not find extracted directory in tarball" >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  local template_dir="${extracted_dir}/template"
  if [[ ! -d "$template_dir" ]]; then
    echo "Error: tarball does not contain a template directory" >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  echo "$template_dir"
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
    echo "Warning: ${TARGET_DIR} is not a git repository. MAW will still install, but /maw-setup may need help identifying the GitHub repo." >&2
  fi
fi

if [[ "$SCOPE" == "global" ]]; then
  OPENCODE_DIR="${HOME}/.config/opencode"
  MAW_DIR="${HOME}/.config/maw"
  INSTALL_DIR="$OPENCODE_DIR"
elif [[ "$SCOPE" == "project" ]]; then
  OPENCODE_DIR="${TARGET_DIR}/.opencode"
  MAW_DIR="${TARGET_DIR}/.maw"
  INSTALL_DIR="$TARGET_DIR"
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

# Determine the template directory
if [[ "$LOCAL" == true ]]; then
  TEMPLATE_DIR="${SCRIPT_DIR}/template"
  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Error: local template directory not found at ${TEMPLATE_DIR}" >&2
    exit 1
  fi
else
  TEMPLATE_DIR=$(fetch_remote_template "$VERSION")
  CLEANUP_TEMPLATE_DIR="$TEMPLATE_DIR"
fi

for agent in orchestrator solo implementer reviewer fixer tester explorer; do
  install_file "${TEMPLATE_DIR}/.opencode/agents/${agent}.md" "${OPENCODE_DIR}/agents/${agent}.md"
done

for skill in grill-explore grill-plan; do
  install_file "${TEMPLATE_DIR}/.opencode/skills/${skill}/SKILL.md" "${OPENCODE_DIR}/skills/${skill}/SKILL.md"
done

for command in maw-setup orchestrate; do
  install_file "${TEMPLATE_DIR}/.opencode/commands/${command}.md" "${OPENCODE_DIR}/commands/${command}.md"
done

# Install MAW shared conventions
install_file "${TEMPLATE_DIR}/.opencode/maw/CONVENTIONS.md" "${OPENCODE_DIR}/maw/CONVENTIONS.md"

# Install MAW config
if [[ ! -f "${MAW_DIR}/config.json" ]]; then
  install_file "${TEMPLATE_DIR}/.maw/config.json" "${MAW_DIR}/config.json"
  echo "Created ${MAW_DIR}/config.json"
else
  echo "Skipped overwriting existing ${MAW_DIR}/config.json"
fi

# Clean up remote template download if needed
if [[ -n "${CLEANUP_TEMPLATE_DIR:-}" ]]; then
  rm -rf "$(dirname "$CLEANUP_TEMPLATE_DIR")"
fi

echo ""
echo "MAW installed successfully (${SCOPE})."
if [[ "$LOCAL" != true ]]; then
  echo "Version: ${VERSION}"
fi
echo ""
echo "Next step: open OpenCode in a project directory and run:"
echo "  /maw-setup"
echo ""
echo "This will ask whether to configure global or project scope, then set up models, labels, and settings."
