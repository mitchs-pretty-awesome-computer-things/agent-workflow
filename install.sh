#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_OWNER="mitchs-pretty-awesome-computer-things"
REPO_NAME="agent-workflow"

DIM='\033[2m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}$1${NC}"; }
dim() { echo -e "${DIM}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}" >&2; }
error() { echo -e "${RED}$1${NC}" >&2; }

usage() {
  cat <<EOF
MAW Installer

Usage: install.sh [options]

Options:
  -g, --global          Install into ~/.config/opencode/ (default)
  -p, --project [PATH]  Install into <path>/.opencode/ (defaults to current directory)
  -v, --version <ver>   Install a specific MAW version (default: latest)
  -l, --local           Use the local template/ directory instead of fetching from GitHub
  -s, --symlink         Symlink workflow files instead of copying (only valid with --local)
  -h, --help            Show this help message

Examples:
  curl -fsSL https://maw.mpact.llc/install.sh | bash
  curl -fsSL https://maw.mpact.llc/install.sh | bash -s -- -p /path/to/project
  ./install.sh -l -p .
EOF
}

SCOPE="global"
TARGET_DIR=""
COPY_OR_SYMLINK="copy"
VERSION="latest"
LOCAL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global)
      SCOPE="global"
      shift
      ;;
    -p|--project)
      SCOPE="project"
      if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
        TARGET_DIR="$2"
        shift 2
      else
        TARGET_DIR=""
        shift
      fi
      ;;
    -v|--version)
      if [[ -z "${2:-}" ]]; then
        error "Error: --version requires a value"
        exit 1
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
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "$COPY_OR_SYMLINK" == "symlink" && "$LOCAL" != true ]]; then
  error "Error: --symlink is only valid with --local"
  exit 1
fi

if [[ "$SCOPE" == "project" ]]; then
  if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$(pwd)"
  fi
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
  if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "Error: --project requires a git repository."
    exit 1
  fi
fi

if [[ "$SCOPE" == "global" ]]; then
  OPENCODE_DIR="${HOME}/.config/opencode"
  MAW_DIR="${HOME}/.config/maw"
  INSTALL_DIR="${HOME}/.config"
else
  OPENCODE_DIR="${TARGET_DIR}/.opencode"
  MAW_DIR="${TARGET_DIR}/.maw"
  INSTALL_DIR="$TARGET_DIR"
fi

mkdir -p "$OPENCODE_DIR" "$MAW_DIR"

fetch_url() {
  local url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
  else
    error "Error: curl or wget is required for remote installs"
    exit 1
  fi
}

resolve_latest_version() {
  local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tags?per_page=1"
  local response
  response=$(fetch_url "$api_url") || {
    error "Error: failed to fetch latest version from ${api_url}"
    exit 1
  }
  local tag
  tag=$(printf '%s\n' "$response" | grep -o '"name": "[^"]*"' | head -n1 | cut -d'"' -f4)
  if [[ -z "$tag" ]]; then
    error "Error: could not determine latest version from GitHub API"
    exit 1
  fi
  echo "$tag"
}

fetch_remote_template() {
  local version="$1"
  local tag="$version"
  if [[ "$version" == "latest" ]]; then
    tag=$(resolve_latest_version)
    dim "Resolved latest version: ${tag}"
  fi

  local tarball_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${tag}.tar.gz"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  local tarball="${tmp_dir}/maw-${tag}.tar.gz"

  dim "Fetching ${tarball_url}"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$tarball_url" -o "$tarball" || {
      error "Error: failed to download ${tarball_url}"
      rm -rf "$tmp_dir"
      exit 1
    }
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$tarball_url" -O "$tarball" || {
      error "Error: failed to download ${tarball_url}"
      rm -rf "$tmp_dir"
      exit 1
    }
  else
    error "Error: curl or wget is required for remote installs"
    rm -rf "$tmp_dir"
    exit 1
  fi

  tar -xzf "$tarball" -C "$tmp_dir"
  local extracted_dir
  extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n1)
  if [[ -z "$extracted_dir" ]]; then
    error "Error: could not find extracted directory in tarball"
    rm -rf "$tmp_dir"
    exit 1
  fi

  local template_dir="${extracted_dir}/template"
  if [[ ! -d "$template_dir" ]]; then
    error "Error: tarball does not contain a template directory"
    rm -rf "$tmp_dir"
    exit 1
  fi

  echo "$template_dir"
}

install_tree() {
  local src="$1"
  local dst="$2"
  if [[ "$COPY_OR_SYMLINK" == "symlink" ]]; then
    mkdir -p "$dst"
    for entry in "$src"/*; do
      [[ -e "$entry" ]] || continue
      ln -sfn "$entry" "${dst}/$(basename "$entry")"
    done
  else
    mkdir -p "$dst"
    cp -R "${src}/." "$dst"
  fi
}

install_file() {
  local src="$1"
  local dst="$2"
  if [[ "$COPY_OR_SYMLINK" == "symlink" ]]; then
    ln -sfn "$src" "$dst"
  else
    cp -R "$src" "$dst"
  fi
}

if [[ "$LOCAL" == true ]]; then
  TEMPLATE_DIR="${SCRIPT_DIR}/template"
  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    error "Error: local template directory not found at ${TEMPLATE_DIR}"
    exit 1
  fi
else
  TEMPLATE_DIR=$(fetch_remote_template "$VERSION")
  CLEANUP_TEMPLATE_DIR="$TEMPLATE_DIR"
fi

info "Installing MAW (${SCOPE}) into ${INSTALL_DIR}"

install_tree "${TEMPLATE_DIR}/.opencode" "$OPENCODE_DIR"

if [[ ! -f "${MAW_DIR}/config.json" ]]; then
  install_file "${TEMPLATE_DIR}/.maw/config.json" "${MAW_DIR}/config.json"
  dim "Created ${MAW_DIR}/config.json"
else
  warn "Skipped overwriting existing ${MAW_DIR}/config.json"
fi

if [[ -n "${CLEANUP_TEMPLATE_DIR:-}" ]]; then
  rm -rf "$(dirname "$CLEANUP_TEMPLATE_DIR")"
fi

echo ""
info "MAW installed successfully (${SCOPE})."
dim "Next step: open OpenCode in a project directory and run:"
dim "  /maw-setup"
