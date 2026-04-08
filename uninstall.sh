#!/usr/bin/env bash
# Integration Skills Uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/uninstall.sh | bash
#    or: ./uninstall.sh

set -uo pipefail

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
    key=""
    IFS= read -rsn1 key </dev/tty
    if [[ "$key" == $'\x1b' ]]; then
      local tmp=""
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
      IFS= read -rsn1 -t 0.1 tmp </dev/tty && key+="$tmp" || true
    fi

    case "$key" in
      $'\x1b[A')
        if [[ $cursor -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      $'\x1b[B')
        if [[ $cursor -lt $((n - 1)) ]]; then cursor=$((cursor + 1)); fi ;;
      ' ')
        if [[ "${checked[$cursor]}" == "true" ]]; then
          checked[$cursor]="false"
        else
          checked[$cursor]="true"
        fi ;;
      '')
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
  local box prefix

  [[ "$is_checked" == "true" ]] && box="${GREEN}[x]${NC}" || box="[ ]"
  [[ $idx -eq $cursor ]] && prefix="${BOLD}▶ ${NC}" || prefix="  "

  printf "  ${prefix}${box} ${label}\n"
}

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
      $'\x1b[A')
        if [[ $cursor -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      $'\x1b[B')
        if [[ $cursor -lt $((n - 1)) ]]; then cursor=$((cursor + 1)); fi ;;
      '')
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

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║    Integration Skills Uninstaller    ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Select AI tool(s) to uninstall from:${NC}"
checkbox_select "Claude Code" "Codex (OpenAI)"
echo ""

if [[ ${#CHECKBOX_RESULT[@]} -eq 0 ]]; then
  print_warn "No tool selected. Uninstall cancelled."
  exit 0
fi

remove_claude=false
remove_codex=false
for t in "${CHECKBOX_RESULT[@]}"; do
  [[ "$t" == "Claude Code"    ]] && remove_claude=true
  [[ "$t" == "Codex (OpenAI)" ]] && remove_codex=true
done

echo -e "${BOLD}Select uninstall scope:${NC}"
single_select \
  "Global — remove from ~/.claude/skills/ or ~/.codex/skills/" \
  "Project — remove from .claude/skills/ or .codex/skills/ in the current project"
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

print_info "Scanning installed skills..."

available_skills=()
declare -A seen_skills=()

_collect_installed_skills() {
  local base_dir="$1"

  [[ -d "$base_dir" ]] || return 0

  while IFS= read -r -d '' dir; do
    local name
    name="$(basename "$dir")"
    [[ -n "$name" && -z "${seen_skills[$name]:-}" ]] || continue
    seen_skills["$name"]=1
    available_skills+=("$name")
  done < <(find "$base_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
}

$remove_claude && _collect_installed_skills "$claude_dir"
$remove_codex && _collect_installed_skills "$codex_dir"

if [[ ${#available_skills[@]} -eq 0 ]]; then
  print_warn "No installed skills found for the selected tool and scope."
  exit 0
fi

echo -e "${BOLD}Select skills to uninstall:${NC}"
echo -e "${DIM}  (space to select, can pick multiple)${NC}"
echo ""

checkbox_select "${available_skills[@]}"
selected_skills=("${CHECKBOX_RESULT[@]}")
echo ""

if [[ ${#selected_skills[@]} -eq 0 ]]; then
  print_warn "No skill selected. Uninstall cancelled."
  exit 0
fi

echo -e "${BOLD}Confirm removal:${NC}"
single_select \
  "Yes — remove the selected skill folders" \
  "No — cancel"
confirm_choice="$SINGLE_RESULT"
echo ""

if [[ "$confirm_choice" != Yes* ]]; then
  print_warn "Uninstall cancelled."
  exit 0
fi

echo -e "${BOLD}Removing ${#selected_skills[@]} skill(s) [scope: $scope_label]...${NC}"
echo ""

_remove_skill_dir() {
  local base_dir="$1" skill="$2"
  local target="$base_dir/$skill"

  if [[ -d "$target" ]]; then
    rm -rf -- "$target"
    print_success "$target"
  else
    print_info "Not installed: $target"
  fi
}

for skill in "${selected_skills[@]}"; do
  echo -e "  ${BOLD}$skill${NC}"

  $remove_claude && _remove_skill_dir "$claude_dir" "$skill"
  $remove_codex && _remove_skill_dir "$codex_dir" "$skill"

  echo ""
done

echo -e "${BOLD}${GREEN}Uninstall complete!${NC}"
echo ""
