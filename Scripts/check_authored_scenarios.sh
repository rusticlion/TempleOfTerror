#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTHORING_ROOT="$ROOT_DIR/Authoring/Scenarios"
CONTENT_ROOT="$ROOT_DIR/Content/Scenarios"

normalize_scenario_id() {
  local raw="$1"

  if [[ -d "$AUTHORING_ROOT/$raw" || -d "$CONTENT_ROOT/$raw" ]]; then
    printf '%s\n' "$raw"
    return 0
  fi

  local trimmed="${raw%/}"
  printf '%s\n' "${trimmed##*/}"
}

collect_authored_ids() {
  find "$AUTHORING_ROOT" -mindepth 1 -maxdepth 1 -type d -print |
    sort |
    while IFS= read -r path; do
      printf '%s\n' "${path##*/}"
    done
}

if [[ ! -d "$AUTHORING_ROOT" ]]; then
  echo "No authored scenarios directory found at $AUTHORING_ROOT" >&2
  exit 1
fi

if [[ "$#" -gt 0 ]]; then
  SCENARIO_IDS=()
  for raw in "$@"; do
    SCENARIO_IDS+=("$(normalize_scenario_id "$raw")")
  done
else
  SCENARIO_IDS=()
  while IFS= read -r scenario_id; do
    [[ -n "$scenario_id" ]] || continue
    SCENARIO_IDS+=("$scenario_id")
  done < <(collect_authored_ids)
fi

if [[ "${#SCENARIO_IDS[@]}" -eq 0 ]]; then
  echo "No authored scenarios found under $AUTHORING_ROOT" >&2
  exit 1
fi

"$ROOT_DIR/Scripts/compile_scenarios.sh" "${SCENARIO_IDS[@]}"

for scenario_id in "${SCENARIO_IDS[@]}"; do
  scenario_dir="$CONTENT_ROOT/$scenario_id"
  echo "Checking $scenario_id"
  "$ROOT_DIR/Scripts/validate_scenarios.sh" "$scenario_dir"

  if [[ -f "$AUTHORING_ROOT/$scenario_id/map.yaml" || -f "$AUTHORING_ROOT/$scenario_id/map.yml" ]]; then
    "$ROOT_DIR/Scripts/preview_authored_map.rb" "$scenario_id"
  else
    echo "No authored map found for $scenario_id; skipping map preview."
  fi
done
