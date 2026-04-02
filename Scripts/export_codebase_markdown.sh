#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OUTPUT_PATH="$PROJECT_ROOT/codebase_export.md"
INCLUDE_CONFIG=0
INCLUDE_AUTHORING=0
INCLUDE_DOCS=0
TRACKED_ONLY=0

usage() {
  cat <<'EOF'
Usage: Scripts/export_codebase_markdown.sh [options]

Generate a single Markdown file containing the repo's human-readable source files,
organized for LLM ingestion.

Defaults:
  - Includes app Swift sources, unit/UI test Swift sources, and repo scripts.
  - Excludes assets, derived data, packaged content, and other noisy/generated files.

Options:
  --output PATH          Write the Markdown export to PATH.
  --include-config       Include Xcode/project config files like Info.plist,
                         LaunchScreen.storyboard, and project.pbxproj.
  --include-authoring    Include authoring schemas/source content and packaged
                         scenario JSON from Authoring/ and Content/.
  --include-docs         Include Docs/*.md plus AGENTS.md.
  --tracked-only         Only include files tracked by git.
  -h, --help             Show this help text.

Examples:
  Scripts/export_codebase_markdown.sh
  Scripts/export_codebase_markdown.sh --include-config
  Scripts/export_codebase_markdown.sh --include-authoring --include-docs \
    --output /tmp/temple-of-terror-codebase.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --output" >&2
        exit 2
      fi
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --include-config)
      INCLUDE_CONFIG=1
      shift
      ;;
    --include-authoring)
      INCLUDE_AUTHORING=1
      shift
      ;;
    --include-docs)
      INCLUDE_DOCS=1
      shift
      ;;
    --tracked-only)
      TRACKED_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$PROJECT_ROOT"

declare -a GROUP_TITLES=()
declare -a GROUP_PATHS=()
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local temp_file

  for temp_file in "${TEMP_FILES[@]:-}"; do
    [[ -n "$temp_file" && -e "$temp_file" ]] || continue
    rm -f "$temp_file"
  done
}

trap cleanup_temp_files EXIT

is_tracked_file() {
  local file="$1"

  git ls-files --error-unmatch -- "$file" >/dev/null 2>&1
}

list_matching_files() {
  local search_root="$1"
  shift
  local -a patterns=("$@")

  if [[ ! -e "$search_root" ]]; then
    return 0
  fi

  if [[ -f "$search_root" ]]; then
    printf '%s\n' "$search_root"
    return 0
  fi

  local -a find_args=("$search_root" -type f "(")
  local first_pattern=1
  local pattern

  for pattern in "${patterns[@]}"; do
    if [[ "$first_pattern" == "0" ]]; then
      find_args+=(-o)
    fi
    find_args+=(-name "$pattern")
    first_pattern=0
  done
  find_args+=(")")

  find "${find_args[@]}" | LC_ALL=C sort
}

add_group() {
  local title="$1"
  shift
  local -a candidates=("$@")
  local file
  local temp_file

  temp_file="$(mktemp "${TMPDIR:-/tmp}/codebase-group.XXXXXX")"
  TEMP_FILES+=("$temp_file")

  for file in "${candidates[@]}"; do
    [[ -n "$file" ]] || continue
    if [[ "$TRACKED_ONLY" == "1" ]] && ! is_tracked_file "$file"; then
      continue
    fi
    printf '%s\n' "$file" >> "$temp_file"
  done

  if [[ ! -s "$temp_file" ]]; then
    rm -f "$temp_file"
    return 0
  fi

  GROUP_TITLES+=("$title")
  GROUP_PATHS+=("$temp_file")
}

language_for_file() {
  local file="$1"

  case "$file" in
    *.swift) printf '%s\n' "swift" ;;
    *.sh) printf '%s\n' "bash" ;;
    *.rb) printf '%s\n' "ruby" ;;
    *.json) printf '%s\n' "json" ;;
    *.yaml|*.yml) printf '%s\n' "yaml" ;;
    *.md) printf '%s\n' "markdown" ;;
    *.plist|*.storyboard|*.xcscheme|*.xcworkspacedata) printf '%s\n' "xml" ;;
    *.pbxproj) printf '%s\n' "text" ;;
    *) printf '%s\n' "text" ;;
  esac
}

write_group_index() {
  local title="$1"
  local files_path="$2"
  local file_count=0
  local file

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    file_count=$((file_count + 1))
  done < "$files_path"

  printf '### %s (%d files)\n' "$title" "$file_count"
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    printf -- '- `%s`\n' "$file"
  done < "$files_path"
  printf '\n'
}

write_group_contents() {
  local title="$1"
  local files_path="$2"
  local file
  local language

  printf '## %s\n\n' "$title"
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    language="$(language_for_file "$file")"
    printf '### `%s`\n\n' "$file"
    printf '~~~~%s\n' "$language"
    cat "$file"
    if [[ -s "$file" ]]; then
      printf '\n'
    fi
    printf '~~~~\n\n'
  done < "$files_path"
}

app_source_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  app_source_files+=("$file")
done < <(list_matching_files "CardGame" "*.swift")

unit_test_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  unit_test_files+=("$file")
done < <(list_matching_files "CardGameTests" "*.swift")

ui_test_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  ui_test_files+=("$file")
done < <(list_matching_files "CardGameUITests" "*.swift")

repo_script_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  repo_script_files+=("$file")
done < <(list_matching_files "Scripts" "*.sh" "*.rb" "*.swift")

add_group "App Source" "${app_source_files[@]}"
add_group "Unit Tests" "${unit_test_files[@]}"
add_group "UI Tests" "${ui_test_files[@]}"
add_group "Repo Scripts" "${repo_script_files[@]}"

if [[ "$INCLUDE_CONFIG" == "1" ]]; then
  config_files=()
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    config_files+=("$file")
  done < <(
    {
      list_matching_files "CardGame/Info.plist"
      list_matching_files "CardGame/LaunchScreen.storyboard"
      list_matching_files "CardGame.xcodeproj/project.pbxproj"
      list_matching_files "CardGame.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
      list_matching_files "CardGame.xcodeproj/xcshareddata/xcschemes" "*.xcscheme"
    } | LC_ALL=C sort
  )
  add_group "Project Config" "${config_files[@]}"
fi

if [[ "$INCLUDE_AUTHORING" == "1" ]]; then
  authoring_files=()
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    authoring_files+=("$file")
  done < <(
    {
      list_matching_files "Authoring/Schemas" "*.json"
      list_matching_files "Authoring/Scenarios" "*.yaml" "*.yml"
      list_matching_files "Content/Scenarios" "*.json"
    } | LC_ALL=C sort
  )
  add_group "Authoring And Content" "${authoring_files[@]}"
fi

if [[ "$INCLUDE_DOCS" == "1" ]]; then
  docs_files=()
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    docs_files+=("$file")
  done < <(
    {
      list_matching_files "AGENTS.md"
      list_matching_files "Docs" "*.md"
    } | LC_ALL=C sort
  )
  add_group "Documentation" "${docs_files[@]}"
fi

if [[ "${#GROUP_TITLES[@]}" -eq 0 ]]; then
  echo "No files matched the current export settings." >&2
  exit 1
fi

total_files=0
total_bytes=0

for group_index in "${!GROUP_TITLES[@]}"; do
  group_path="${GROUP_PATHS[$group_index]}"
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    total_files=$((total_files + 1))
    total_bytes=$((total_bytes + $(wc -c < "$file")))
  done < "$group_path"
done

mkdir -p "$(dirname "$OUTPUT_PATH")"
TEMP_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/codebase-export.XXXXXX")"
TEMP_FILES+=("$TEMP_OUTPUT")

{
  printf '# Temple Of Terror Codebase Export\n\n'
  printf 'Generated: `%s`\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
  printf 'Repository root: `%s`\n' "$PROJECT_ROOT"
  printf 'Included files: `%d`\n' "$total_files"
  printf 'Included bytes: `%d`\n\n' "$total_bytes"

  printf '## Selection\n\n'
  printf -- '- Default source roots: `CardGame`, `CardGameTests`, `CardGameUITests`, `Scripts`\n'
  printf -- '- Optional project config: `%s`\n' "$([[ "$INCLUDE_CONFIG" == "1" ]] && printf 'included' || printf 'excluded')"
  printf -- '- Optional authoring/content: `%s`\n' "$([[ "$INCLUDE_AUTHORING" == "1" ]] && printf 'included' || printf 'excluded')"
  printf -- '- Optional docs: `%s`\n' "$([[ "$INCLUDE_DOCS" == "1" ]] && printf 'included' || printf 'excluded')"
  printf -- '- Git tracked only: `%s`\n\n' "$([[ "$TRACKED_ONLY" == "1" ]] && printf 'yes' || printf 'no')"

  printf '## File Index\n\n'
  for group_index in "${!GROUP_TITLES[@]}"; do
    write_group_index "${GROUP_TITLES[$group_index]}" "${GROUP_PATHS[$group_index]}"
  done

  for group_index in "${!GROUP_TITLES[@]}"; do
    write_group_contents "${GROUP_TITLES[$group_index]}" "${GROUP_PATHS[$group_index]}"
  done
} > "$TEMP_OUTPUT"

mv "$TEMP_OUTPUT" "$OUTPUT_PATH"

echo "Wrote Markdown export:"
echo "  $OUTPUT_PATH"
echo "Included files:"
echo "  $total_files"
