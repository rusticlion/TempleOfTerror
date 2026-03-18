#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/xcode_common.sh"

SCREEN="${TOT_DEBUG_SCREEN:-content}"
STATE="${TOT_DEBUG_STATE:-fresh}"
SCENARIO_ID="${TOT_DEBUG_SCENARIO:-temple_of_terror}"
FIXED_DICE="${TOT_DEBUG_FIXED_DICE:-}"
RESET_GUIDANCE_HINTS="${TOT_RESET_GUIDANCE_HINTS:-1}"
BUILD_FIRST=1
SYNC_AUTHORED_CONTENT=0

usage() {
  cat <<'EOF'
Usage: Scripts/launch_app.sh [options]

Options:
  --screen <content|map>     Debug screen to launch.
  --state <fresh|pressure|solo|split>
                             Debug state to launch.
  --scenario <scenario-id>   Scenario id to load.
  --fixed-dice <csv>         Comma-separated dice values (for example: 1,6).
  --no-build                 Reuse the existing simulator build.
  --sync-authored-content    Compile and validate authored scenarios before building.

Environment:
  TOT_SIMULATOR_NAME         Simulator name to target (default: iPhone 17)
  TOT_DERIVED_DATA_PATH      Derived data path (default: .build/codex-derived)
  TOT_OPEN_SIMULATOR         Set to 0 to avoid forcing the Simulator app open
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --screen)
      SCREEN="${2:?Missing value for --screen}"
      shift 2
      ;;
    --state)
      STATE="${2:?Missing value for --state}"
      shift 2
      ;;
    --scenario)
      SCENARIO_ID="${2:?Missing value for --scenario}"
      shift 2
      ;;
    --fixed-dice)
      FIXED_DICE="${2:?Missing value for --fixed-dice}"
      shift 2
      ;;
    --no-build)
      BUILD_FIRST=0
      shift
      ;;
    --sync-authored-content)
      SYNC_AUTHORED_CONTENT=1
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

case "$SCREEN" in
  content|map)
    ;;
  *)
    echo "Unsupported debug screen: $SCREEN" >&2
    exit 2
    ;;
esac

case "$STATE" in
  fresh|pressure|solo|split)
    ;;
  *)
    echo "Unsupported debug state: $STATE" >&2
    exit 2
    ;;
esac

ensure_xcode_available

if [[ "$BUILD_FIRST" == "1" ]]; then
  if [[ "$SYNC_AUTHORED_CONTENT" == "1" ]]; then
    "$PROJECT_ROOT/Scripts/build_app.sh" --sync-authored-content >/dev/null
  else
    "$PROJECT_ROOT/Scripts/build_app.sh" >/dev/null
  fi
elif [[ "$SYNC_AUTHORED_CONTENT" == "1" ]]; then
  "$PROJECT_ROOT/Scripts/check_authored_scenarios.sh"
fi

DEVICE_ID="$(require_simulator_device_id)"
boot_simulator "$DEVICE_ID"

APP_PATH="$(app_bundle_path)"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected built app at $APP_PATH, but it was not found." >&2
  echo "Run Scripts/build_app.sh first or omit --no-build." >&2
  exit 1
fi

run_xcrun simctl install "$DEVICE_ID" "$APP_PATH" >/dev/null
run_xcrun simctl terminate "$DEVICE_ID" "$APP_BUNDLE_IDENTIFIER" >/dev/null 2>&1 || true

LAUNCH_ENV=(
  "SIMCTL_CHILD_CODEX_DEBUG_SCREEN=$SCREEN"
  "SIMCTL_CHILD_CODEX_DEBUG_SCENARIO=$SCENARIO_ID"
  "SIMCTL_CHILD_CODEX_DEBUG_STATE=$STATE"
  "SIMCTL_CHILD_CODEX_RESET_GUIDANCE_HINTS=$RESET_GUIDANCE_HINTS"
)

if [[ -n "$FIXED_DICE" ]]; then
  LAUNCH_ENV+=("SIMCTL_CHILD_CODEX_DEBUG_FIXED_DICE=$FIXED_DICE")
fi

(
  export "${LAUNCH_ENV[@]}"
  run_xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$APP_BUNDLE_IDENTIFIER" >/dev/null
)

echo "Launched $APP_BUNDLE_IDENTIFIER on $SIMULATOR_NAME"
echo "  screen: $SCREEN"
echo "  state: $STATE"
echo "  scenario: $SCENARIO_ID"

if [[ -n "$FIXED_DICE" ]]; then
  echo "  fixed dice: $FIXED_DICE"
fi
