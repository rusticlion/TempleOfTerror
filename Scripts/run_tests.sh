#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/xcode_common.sh"

TEST_MODE="${1:-unit}"
ensure_xcode_available
DEVICE_ID="$(require_simulator_device_id)"

ensure_derived_data_dir
shutdown_simulator "$DEVICE_ID"
boot_simulator "$DEVICE_ID"
populate_common_xcodebuild_args "$DEVICE_ID"

run_xcodebuild build-for-testing "${COMMON_XCODEBUILD_ARGS[@]}"

XCTESTRUN_PATH="$(find_xctestrun_path)"

if [[ -z "$XCTESTRUN_PATH" ]]; then
  echo "Expected an .xctestrun file under $DERIVED_DATA_PATH/Build/Products, but none was found." >&2
  exit 1
fi

TEST_ARGS=()

case "$TEST_MODE" in
  unit)
    TEST_ARGS+=("-only-testing:CardGameTests")
    ;;
  ui)
    TEST_ARGS+=("-only-testing:CardGameUITests")
    ;;
  all)
    ;;
  *)
    echo "Usage: $(basename "$0") [unit|ui|all]" >&2
    exit 2
    ;;
esac

boot_simulator "$DEVICE_ID"
if [[ "${#TEST_ARGS[@]}" -gt 0 ]]; then
  run_xcodebuild test-without-building \
    -xctestrun "$XCTESTRUN_PATH" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -parallel-testing-enabled NO \
    "${TEST_ARGS[@]}"
else
  run_xcodebuild test-without-building \
    -xctestrun "$XCTESTRUN_PATH" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -parallel-testing-enabled NO
fi
