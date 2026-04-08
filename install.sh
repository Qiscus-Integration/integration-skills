#!/usr/bin/env bash
# Integration Skills Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/integration-skills/main/install.sh | bash
#    or: ./install.sh
# Requirements: curl (pre-installed on Mac/Linux/WSL)

set -uo pipefail

OWNER="Qiscus-Integration"  # <-- CHANGE THIS to your GitHub username if using your own fork
REPO="integration-skills"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH"
API_BASE="https://api.github.com/repos/$OWNER/$REPO/contents/skills?ref=$BRANCH"
TREE_API="https://api.github.com/repos/$OWNER/$REPO/git/trees/$BRANCH?recursive=1"

# ─── Colors ───────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${BLUE}→${NC} $1"; }
print_warn()    { echo -e "${YELLOW}!${NC} $1"; }

# ─── Input Helper (works when piped via curl | bash) ─────────────────────────

# All input is read from /dev/tty so it works when stdin is a pipe
tty_read() {
  IFS= read -r "$@" </dev/tty
}

tty_read_silent() {
  IFS= read -rs "$@" </dev/tty
}

# ─── Checkbox Selector ────────────────────────────────────────────────────────
# Usage: checkbox_select "Label 1" "Label 2" "Label 3"
# Result stored in array CHECKBOX_RESULT

checkbox_select() {
  local items=("$@")
  local n=${#items[@]}
  local cursor=0
  local checked=()
  local key

  for _ in "${items[@]}"; do checked+=("false"); done

  tput civis 2>/dev/null || true
  echo -e "${DIM}  ↑↓ navigate   space select/deselect   enter confirm${NC}"
  for i in "${!items[@]}"; do
    _render_checkbox_row "$i" "$cursor" "${checked[$i]}" "${items[$i]}"
  done

  while true; do
    # Read full escape sequence at once (max 6 chars, 0.1s timeout between chars)
    key=""
    IFS= read -rsn1 key </dev/tty
    if [[ "$key" == $'\x1b' ]]; then
      local tmp=""
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
    fi

    case "$key" in
      $'\x1b[A')  # Up
        if [[ $cursor -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      $'\x1b[B')  # Down
        if [[ $cursor -lt $((n - 1)) ]]; then cursor=$((cursor + 1)); fi ;;
      ' ')         # Space — toggle selection
        if [[ "${checked[$cursor]}" == "true" ]]; then
          checked[$cursor]="false"
        else
          checked[$cursor]="true"
        fi ;;
      '')          # Enter
        break ;;
    esac

    tput cuu "$n" 2>/dev/null || true
    for i in "${!items[@]}"; do
      _render_checkbox_row "$i" "$cursor" "${checked[$i]}" "${items[$i]}"
    done
  done

  tput cnorm 2>/dev/null || true

  CHECKBOX_RESULT=()
  for i in "${!items[@]}"; do
    if [[ "${checked[$i]}" == "true" ]]; then
      CHECKBOX_RESULT+=("${items[$i]}")
    fi
  done
}

_render_checkbox_row() {
  local idx=$1 cursor=$2 is_checked=$3 label=$4
  local box mark prefix

  [[ "$is_checked" == "true" ]] && box="${GREEN}[x]${NC}" || box="[ ]"
  [[ $idx -eq $cursor ]] && prefix="${BOLD}▶ ${NC}" || prefix="  "

  printf "  ${prefix}${box} ${label}\n"
}

# ─── Single Choice Selector ───────────────────────────────────────────────────
# Usage: single_select "Label 1" "Label 2"
# Result stored in SINGLE_RESULT (string)

single_select() {
  local items=("$@")
  local n=${#items[@]}
  local cursor=0
  local key

  tput civis 2>/dev/null || true
  echo -e "${DIM}  ↑↓ navigate   enter select${NC}"
  for i in "${!items[@]}"; do
    _render_single_row "$i" "$cursor" "${items[$i]}"
  done

  while true; do
    key=""
    IFS= read -rsn1 key </dev/tty
    if [[ "$key" == $'\x1b' ]]; then
      local tmp=""
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
    fi

    case "$key" in
      $'\x1b[A')  # Up
        if [[ $cursor -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      $'\x1b[B')  # Down
        if [[ $cursor -lt $((n - 1)) ]]; then cursor=$((cursor + 1)); fi ;;
      '')          # Enter
        break ;;
    esac

    tput cuu "$n" 2>/dev/null || true
    for i in "${!items[@]}"; do
      _render_single_row "$i" "$cursor" "${items[$i]}"
    done
  done

  tput cnorm 2>/dev/null || true
  SINGLE_RESULT="${items[$cursor]}"
}

_render_single_row() {
  local idx=$1 cursor=$2 label=$3
  if [[ $idx -eq $cursor ]]; then
    printf "  ${BOLD}▶ ( ) ${label}${NC}\n"
  else
    printf "    ( ) ${label}\n"
  fi
}

# ─── Header ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     Integration Skills Installer     ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── Check curl is available ──────────────────────────────────────────────────

if ! command -v curl &>/dev/null; then
  print_error "curl not found. Please install curl first."
  exit 1
fi

# ─── Select Tool ──────────────────────────────────────────────────────────────

echo -e "${BOLD}Select AI tool(s) to install for:${NC}"
checkbox_select "Claude Code" "Codex (OpenAI)"
echo ""

if [[ ${#CHECKBOX_RESULT[@]} -eq 0 ]]; then
  print_warn "No tool selected. Installation cancelled."
  exit 0
fi

install_claude=false
install_codex=false
for t in "${CHECKBOX_RESULT[@]}"; do
  [[ "$t" == "Claude Code"    ]] && install_claude=true
  [[ "$t" == "Codex (OpenAI)" ]] && install_codex=true
done

# ─── Select Scope ─────────────────────────────────────────────────────────────

echo -e "${BOLD}Select installation scope:${NC}"
single_select \
  "Global — available in all projects (~/.claude/skills/ or ~/.codex/skills/)" \
  "Project — current project only (.claude/skills/ or .codex/skills/)"
scope_choice="$SINGLE_RESULT"
echo ""

if [[ "$scope_choice" == Global* ]]; then
  claude_dir="$HOME/.claude/skills"
  codex_dir="$HOME/.codex/skills"
  scope_label="global"
else
  claude_dir="$(pwd)/.claude/skills"
  codex_dir="$(pwd)/.codex/skills"
  scope_label="project ($(pwd))"
fi

# ─── Fetch Skill List ─────────────────────────────────────────────────────────

print_info "Fetching available skills..."

# Detect if the script is running from inside the cloned repo (local skills/ folder exists)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "$(pwd)")"
available_skills=()
tree_response=""

if [[ -d "$SCRIPT_DIR/skills" ]]; then
  # Running locally — read from filesystem
  while IFS= read -r -d '' dir; do
    name="$(basename "$dir")"
    [[ "$name" == "_template" ]] && continue
    available_skills+=("$name")
  done < <(find "$SCRIPT_DIR/skills" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  print_info "Using local skills."
else
  # Fetch from GitHub API
  api_response=$(curl -fsSL "$API_BASE" 2>/dev/null || true)
  tree_response=$(curl -fsSL "$TREE_API" 2>/dev/null || true)

  if [[ -n "$api_response" ]]; then
    while IFS= read -r name; do
      [[ "$name" == "_template" ]] && continue
      [[ -n "$name" ]] && available_skills+=("$name")
    done < <(
      printf '%s\n' "$api_response" \
        | awk 'BEGIN { RS="}," } /"type": "dir"/ { if (match($0, /"name": "[^"]+"/)) { value = substr($0, RSTART + 9, RLENGTH - 10); print value } }' \
        | sort
    )
  fi
fi

if [[ ${#available_skills[@]} -eq 0 ]]; then
  print_error "No skills found."
  print_warn "Make sure OWNER is set correctly in install.sh"
  exit 1
fi

# ─── Select Skills ────────────────────────────────────────────────────────────

echo -e "${BOLD}Select skills to install:${NC}"
echo -e "${DIM}  (space to select, can pick multiple)${NC}"
echo ""

checkbox_select "${available_skills[@]}"
selected_skills=("${CHECKBOX_RESULT[@]}")
echo ""

if [[ ${#selected_skills[@]} -eq 0 ]]; then
  print_warn "No skill selected. Installation cancelled."
  exit 0
fi

# ─── Download & Install Skills ────────────────────────────────────────────────

echo -e "${BOLD}Installing ${#selected_skills[@]} skill(s) [scope: $scope_label]...${NC}"
echo ""

_copy_local_skill_tree() {
  local skill="$1" dest_dir="$2"
  local source_dir="$SCRIPT_DIR/skills/$skill"

  [[ -d "$source_dir" ]] || return 1

  mkdir -p "$dest_dir"
  rm -rf -- "$dest_dir/$skill"
  cp -R "$source_dir" "$dest_dir/"
}

_list_remote_skill_files() {
  local skill="$1"

  [[ -n "$tree_response" ]] || return 1

  printf '%s\n' "$tree_response" \
    | awk -v prefix="skills/$skill/" -v skill_name="$skill" '
        BEGIN { RS="}," }
        index($0, "\"path\": \"" prefix) && index($0, "\"type\": \"blob\"") {
          if (match($0, /"path": "[^"]+"/)) {
            full = substr($0, RSTART + 9, RLENGTH - 10)
            sub("^skills/" skill_name "/", "", full)
            print full
          }
        }
      ' \
    | sort
}

_download_remote_skill_tree() {
  local skill="$1" dest_dir="$2"
  local rel_path dest
  local downloaded_any=false

  mkdir -p "$dest_dir/$skill"

  while IFS= read -r rel_path; do
    [[ -n "$rel_path" ]] || continue
    dest="$dest_dir/$skill/$rel_path"
    mkdir -p "$(dirname "$dest")"

    if curl -fsSL "$RAW_BASE/skills/$skill/$rel_path" -o "$dest" 2>/dev/null; then
      downloaded_any=true
    else
      return 1
    fi
  done < <(_list_remote_skill_files "$skill")

  $downloaded_any
}

_install_skill_tree() {
  local skill="$1" dest_dir="$2"

  if [[ -d "$SCRIPT_DIR/skills/$skill" ]]; then
    _copy_local_skill_tree "$skill" "$dest_dir"
  else
    _download_remote_skill_tree "$skill" "$dest_dir"
  fi
}

for skill in "${selected_skills[@]}"; do
  echo -e "  ${BOLD}$skill${NC}"

  if $install_claude; then
    if _install_skill_tree "$skill" "$claude_dir"; then
      print_success "Claude Code: $claude_dir/$skill"
    else
      print_error "Failed to install $skill for Claude Code"
    fi
  fi

  if $install_codex; then
    if _install_skill_tree "$skill" "$codex_dir"; then
      print_success "Codex: $codex_dir/$skill"
    else
      print_error "Failed to install $skill for Codex"
    fi
  fi

  echo ""
done

# ─── Summary ──────────────────────────────────────────────────────────────────

echo -e "${BOLD}${GREEN}Installation complete!${NC}"
echo ""

if $install_claude; then
  echo -e "${BOLD}Claude Code — how to use:${NC}"
  for skill in "${selected_skills[@]}"; do
    echo -e "  /${skill}"
  done
fi

if $install_codex; then
  echo ""
  echo -e "${BOLD}Codex — how to use:${NC}"
  for skill in "${selected_skills[@]}"; do
    echo -e "  \$${skill}"
  done
fi

echo ""
