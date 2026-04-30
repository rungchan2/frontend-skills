#!/usr/bin/env bash
# Database Schema Query CLI (Pure Bash — no tsx/node required)
#
# Extracts table schemas, views, functions (RPC), and enums from
# database.types.ts without loading the entire file into context.
#
# Usage:
#   bash scripts/db-schema.sh tables                  - List all table names
#   bash scripts/db-schema.sh table <name>            - Show specific table schema
#   bash scripts/db-schema.sh views                   - List all view names
#   bash scripts/db-schema.sh view <name>             - Show specific view schema
#   bash scripts/db-schema.sh functions               - List all RPC function signatures
#   bash scripts/db-schema.sh function <name>         - Show specific function details
#   bash scripts/db-schema.sh enums                   - List all enum names
#   bash scripts/db-schema.sh enum <name>             - Show specific enum values
#   bash scripts/db-schema.sh search <keyword>        - Search across all categories

set -euo pipefail

# ── Colors ──────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
CYAN='\033[36m'
RED='\033[31m'
DIM='\033[2m'

# ── Find database.types.ts ──────────────────────────────
find_db_types() {
  local candidates=(
    "src/types/database.types.ts"
    "types/database.types.ts"
    "lib/types/database.types.ts"
    "src/lib/types/database.types.ts"
    "database.types.ts"
  )
  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

DB_TYPES_PATH="${DB_TYPES_PATH:-}"
if [[ -z "$DB_TYPES_PATH" ]]; then
  DB_TYPES_PATH=$(find_db_types) || {
    echo -e "${RED}Error: database.types.ts not found.${RESET}"
    echo "Searched: src/types/, types/, lib/types/, src/lib/types/, ./"
    echo "Set DB_TYPES_PATH env var to specify the location."
    exit 1
  }
fi

if [[ ! -f "$DB_TYPES_PATH" ]]; then
  echo -e "${RED}Error: File not found: ${DB_TYPES_PATH}${RESET}"
  exit 1
fi

# ── Generic section parser ──────────────────────────────
# Extracts top-level identifiers from a named section within public schema.
# Usage: list_section_names "Tables" "{" — items that end with ": {"
#        list_section_names "Enums" ":"  — items that end with ":"
list_section_names() {
  local section="$1"
  local suffix_pattern="$2"  # "{" for Tables/Views/Functions, ":" for Enums

  awk -v section="$section" -v suffix="$suffix_pattern" '
    /^  public: \{/ { in_public=1; next }
    in_public && !in_section && $0 ~ "^    " section ": \\{" {
      in_section=1; depth=1; next
    }
    in_section {
      for (i=1; i<=length($0); i++) {
        c = substr($0, i, 1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      # 6-space indented identifier (macOS awk compatible)
      if ($0 ~ /^      [a-z_][a-z0-9_]*:/) {
        name = $0
        sub(/^      /, "", name)
        sub(/:.*/, "", name)
        if (suffix == "{" && $0 ~ /: \{/) print name
        else if (suffix == ":") print name
      }
      if (depth <= 0) exit
    }
  ' "$DB_TYPES_PATH" | sort
}

# Extract a block by name from a section (brace-matched)
extract_block() {
  local section="$1"
  local name="$2"

  awk -v section="$section" -v name="$name" '
    /^  public: \{/ { in_public=1; next }
    in_public && !in_section && $0 ~ "^    " section ": \\{" {
      in_section=1; sec_depth=1; next
    }
    in_section && !found && $0 ~ "^      " name ": \\{" {
      found=1; depth=0
    }
    found {
      for (i=1; i<=length($0); i++) {
        c = substr($0, i, 1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      print $0
      if (depth <= 0) { exit }
    }
    in_section && !found {
      for (i=1; i<=length($0); i++) {
        c = substr($0, i, 1)
        if (c == "{") sec_depth++
        if (c == "}") sec_depth--
      }
      if (sec_depth <= 0) exit
    }
  ' "$DB_TYPES_PATH"
}

# ── Helpers ─────────────────────────────────────────────
list_table_names()    { list_section_names "Tables" "{"; }
list_view_names()     { list_section_names "Views" "{"; }
list_enum_names()     { list_section_names "Enums" ":"; }
list_function_names() { list_section_names "Functions" "{"; }

print_header() {
  local label="$1" name="$2"
  echo -e "\n${BOLD}${BLUE}${label}: ${name}${RESET}"
  echo -e "${CYAN}$(printf '=%.0s' {1..60})${RESET}\n"
}

print_list_header() {
  local label="$1" count="$2"
  echo -e "\n${BOLD}${BLUE}${label} (${count})${RESET}"
  echo -e "${CYAN}$(printf '=%.0s' {1..60})${RESET}\n"
}

print_items() {
  local arr=("$@")
  for item in "${arr[@]}"; do
    echo -e "  ${GREEN}•${RESET} ${item}"
  done
  echo
}

# ── Commands: Tables ────────────────────────────────────

cmd_tables() {
  local items=()
  while IFS= read -r t; do [[ -n "$t" ]] && items+=("$t"); done < <(list_table_names)
  print_list_header "Available Tables" "${#items[@]}"
  print_items "${items[@]}"
}

cmd_table() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Please specify a table name${RESET}"
    echo "Usage: $0 table <table-name>"
    exit 1
  fi

  local result
  result=$(extract_block "Tables" "$name")

  if [[ -z "$result" ]]; then
    echo -e "${RED}Error: Table \"${name}\" not found${RESET}"
    echo -e "\nTip: Run \"$0 tables\" to see all available tables"
    exit 1
  fi

  print_header "Table" "$name"
  echo "$result"
  echo
}

# ── Commands: Views ─────────────────────────────────────

cmd_views() {
  local items=()
  while IFS= read -r v; do [[ -n "$v" ]] && items+=("$v"); done < <(list_view_names)

  if [[ ${#items[@]} -eq 0 ]]; then
    echo -e "\n${YELLOW}No views defined${RESET}\n"
    return
  fi

  print_list_header "Available Views" "${#items[@]}"
  print_items "${items[@]}"
}

cmd_view() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Please specify a view name${RESET}"
    echo "Usage: $0 view <view-name>"
    exit 1
  fi

  local result
  result=$(extract_block "Views" "$name")

  if [[ -z "$result" ]]; then
    echo -e "${RED}Error: View \"${name}\" not found${RESET}"
    echo -e "\nTip: Run \"$0 views\" to see all available views"
    exit 1
  fi

  print_header "View" "$name"
  echo "$result"
  echo
}

# ── Commands: Functions (RPC) ───────────────────────────

cmd_functions() {
  local items=()
  while IFS= read -r f; do [[ -n "$f" ]] && items+=("$f"); done < <(list_function_names)

  if [[ ${#items[@]} -eq 0 ]]; then
    echo -e "\n${YELLOW}No functions defined${RESET}\n"
    return
  fi

  print_list_header "Available Functions / RPC" "${#items[@]}"

  # Show each function with its signature (Args → Returns)
  for fn in "${items[@]}"; do
    local sig
    sig=$(awk -v fname="$fn" '
      /^  public: \{/ { in_public=1; next }
      in_public && !in_fns && /^    Functions: \{/ { in_fns=1; depth=1; next }
      in_fns && !found && $0 ~ "^      " fname ": \\{" { found=1; fdepth=0 }
      found {
        for (i=1; i<=length($0); i++) {
          c = substr($0,i,1)
          if (c=="{") fdepth++
          if (c=="}") fdepth--
        }
        # Capture Args line
        if ($0 ~ /Args:/) {
          gsub(/^[[:space:]]*Args:[[:space:]]*/, "", $0)
          args = $0
        }
        # Capture Returns line
        if ($0 ~ /Returns:/) {
          gsub(/^[[:space:]]*Returns:[[:space:]]*/, "", $0)
          returns = $0
        }
        if (fdepth <= 0) {
          if (args == "") args = "none"
          if (returns == "") returns = "void"
          printf "%s → %s", args, returns
          exit
        }
      }
    ' "$DB_TYPES_PATH")
    echo -e "  ${GREEN}•${RESET} ${BOLD}${fn}${RESET}${DIM}  ${sig}${RESET}"
  done
  echo
}

cmd_function() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Please specify a function name${RESET}"
    echo "Usage: $0 function <function-name>"
    exit 1
  fi

  local result
  result=$(extract_block "Functions" "$name")

  if [[ -z "$result" ]]; then
    echo -e "${RED}Error: Function \"${name}\" not found${RESET}"
    echo -e "\nTip: Run \"$0 functions\" to see all available functions"
    exit 1
  fi

  print_header "Function (RPC)" "$name"
  echo "$result"
  echo
}

# ── Commands: Enums ─────────────────────────────────────

cmd_enums() {
  local items=()
  while IFS= read -r e; do [[ -n "$e" ]] && items+=("$e"); done < <(list_enum_names)
  print_list_header "Available Enums" "${#items[@]}"
  print_items "${items[@]}"
}

cmd_enum() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Please specify an enum name${RESET}"
    echo "Usage: $0 enum <enum-name>"
    exit 1
  fi

  # Extract enum definition (single-line or multi-line)
  local result
  result=$(awk -v ename="$name" '
    BEGIN { found=0 }
    found==0 && $0 ~ "^      " ename ":" {
      found=1
      print $0
      if ($0 ~ /"/) { found=2 }
      next
    }
    found==1 && /^[[:space:]]+\|/ { print $0; next }
    found==1 { found=2 }
    found==2 { exit }
  ' "$DB_TYPES_PATH")

  if [[ -z "$result" ]]; then
    echo -e "${RED}Error: Enum \"${name}\" not found${RESET}"
    echo -e "\nTip: Run \"$0 enums\" to see all available enums"
    exit 1
  fi

  print_header "Enum" "$name"

  # Parse and display values (macOS-compatible)
  local values
  values=$(echo "$result" | awk -F'"' '{ for(i=2; i<=NF; i+=2) if($i!="") print $i }')
  while IFS= read -r val; do
    [[ -n "$val" ]] && echo -e "  ${GREEN}•${RESET} ${YELLOW}\"${val}\"${RESET}"
  done <<< "$values"
  echo
}

# ── Commands: Search ────────────────────────────────────

cmd_search() {
  local keyword="${1:-}"
  if [[ -z "$keyword" ]]; then
    echo -e "${RED}Error: Please specify a search keyword${RESET}"
    echo "Usage: $0 search <keyword>"
    exit 1
  fi

  local keyword_lower
  keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')

  echo -e "\n${BOLD}${BLUE}Search Results for \"${keyword}\"${RESET}"
  echo -e "${CYAN}$(printf '=%.0s' {1..60})${RESET}\n"

  local found_any=0

  # Helper: filter and print matches
  filter_and_print() {
    local label="$1"
    shift
    local matches=()
    for item in "$@"; do
      local lower_item
      lower_item=$(echo "$item" | tr '[:upper:]' '[:lower:]')
      if [[ "$lower_item" == *"$keyword_lower"* ]]; then
        matches+=("$item")
      fi
    done
    if [[ ${#matches[@]} -gt 0 ]]; then
      found_any=1
      echo -e "${BOLD}${label} (${#matches[@]}):${RESET}"
      for m in "${matches[@]}"; do
        echo -e "  ${GREEN}•${RESET} $m"
      done
      echo
    fi
  }

  # Collect all names
  local tables=() views=() functions=() enums=()
  while IFS= read -r t; do [[ -n "$t" ]] && tables+=("$t"); done < <(list_table_names)
  while IFS= read -r v; do [[ -n "$v" ]] && views+=("$v"); done < <(list_view_names)
  while IFS= read -r f; do [[ -n "$f" ]] && functions+=("$f"); done < <(list_function_names)
  while IFS= read -r e; do [[ -n "$e" ]] && enums+=("$e"); done < <(list_enum_names)

  filter_and_print "Tables" "${tables[@]}"
  filter_and_print "Views" "${views[@]}"
  filter_and_print "Functions" "${functions[@]}"
  filter_and_print "Enums" "${enums[@]}"

  if [[ $found_any -eq 0 ]]; then
    echo -e "${YELLOW}No results found${RESET}\n"
  fi
}

# ── Help ────────────────────────────────────────────────

cmd_help() {
  echo -e "
${BOLD}${BLUE}Database Schema Query CLI${RESET}

${BOLD}Usage:${RESET}
  $0 tables                  List all table names
  $0 table <name>            Show table schema (Row/Insert/Update)
  $0 views                   List all view names
  $0 view <name>             Show view schema (Row)
  $0 functions               List all RPC functions with signatures
  $0 function <name>         Show function details (Args/Returns)
  $0 enums                   List all enum names
  $0 enum <name>             Show enum values
  $0 search <keyword>        Search tables/views/functions/enums

${BOLD}Examples:${RESET}
  $0 table receipts          Show receipts table schema
  $0 view dashboard_stats    Show dashboard view
  $0 function can_access     Show RPC function details
  $0 enum settlement_status  Show settlement_status values
  $0 search quote            Find everything matching \"quote\"

${BOLD}Environment:${RESET}
  DB_TYPES_PATH              Override database.types.ts location
                             (auto-detected: src/types/, types/, etc.)
"
}

# ── Main ────────────────────────────────────────────────

case "${1:-help}" in
  table)     cmd_table "${2:-}" ;;
  tables)    cmd_tables ;;
  view)      cmd_view "${2:-}" ;;
  views)     cmd_views ;;
  function)  cmd_function "${2:-}" ;;
  functions) cmd_functions ;;
  enum)      cmd_enum "${2:-}" ;;
  enums)     cmd_enums ;;
  search)    cmd_search "${2:-}" ;;
  help|--help|-h) cmd_help ;;
  *)
    echo -e "${RED}Error: Unknown command \"$1\"${RESET}"
    echo "Run \"$0 help\" to see available commands"
    exit 1
    ;;
esac
