#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/xcode_common.sh"

ACTION="build"
SYNC_AUTHORED_CONTENT=0

usage() {
  cat <<'EOF'
Usage: Scripts/build_app.sh [--for-testing] [--sync-authored-content]

Options:
  --for-testing            Build test products and emit the generated .xctestrun path.
  --sync-authored-content  Compile and validate authored scenarios before building.

Environment:
  TOT_SIMULATOR_NAME       Simulator name to target (default: iPhone 17)
  TOT_DERIVED_DATA_PATH    Derived data path (default: .build/codex-derived)
  TOT_CLEAN_DERIVED_DATA   Set to 1 to remove derived data before building
  TOT_VERBOSE_XCODEBUILD   Set to 1 to disable output filtering
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --for-testing)
      ACTION="build-for-testing"
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

ensure_xcode_available

if [[ "$SYNC_AUTHORED_CONTENT" == "1" ]]; then
  "$PROJECT_ROOT/Scripts/check_authored_scenarios.sh"
fi

DEVICE_ID="$(require_simulator_device_id)"
ensure_derived_data_dir
boot_simulator "$DEVICE_ID"
populate_common_xcodebuild_args "$DEVICE_ID"

run_xcodebuild "$ACTION" "${COMMON_XCODEBUILD_ARGS[@]}"

APP_PATH="$(app_bundle_path)"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected built app at $APP_PATH, but it was not found." >&2
  exit 1
fi

echo "Built app:"
echo "  $APP_PATH"

if [[ "$ACTION" == "build-for-testing" ]]; then
  XCTESTRUN_PATH="$(find_xctestrun_path)"
  if [[ -z "$XCTESTRUN_PATH" ]]; then
    echo "Expected an .xctestrun file under $DERIVED_DATA_PATH/Build/Products, but none was found." >&2
    exit 1
  fi

  echo "Test metadata:"
  echo "  $XCTESTRUN_PATH"
fi
