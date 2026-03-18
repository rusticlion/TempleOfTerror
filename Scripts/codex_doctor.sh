#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/xcode_common.sh"

ensure_xcode_available

ACTIVE_DEVELOPER_DIR="$(xcode-select -p 2>/dev/null || true)"
DEVICE_ID="$(find_simulator_device_id || true)"
APP_PATH="$(app_bundle_path)"
XCTESTRUN_PATH="$(find_xctestrun_path || true)"

echo "Temple Of Terror Codex doctor"
echo
echo "xcode-select:"
echo "  ${ACTIVE_DEVELOPER_DIR:-<unavailable>}"
echo "repo DEVELOPER_DIR:"
echo "  $DEVELOPER_DIR"
echo
echo "Xcode:"
DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -version
echo
echo "default simulator:"
echo "  $SIMULATOR_NAME"

if [[ -n "$DEVICE_ID" ]]; then
  echo "resolved simulator id:"
  echo "  $DEVICE_ID"
else
  echo "resolved simulator id:"
  echo "  <not found>"
fi

echo
echo "derived data:"
echo "  $DERIVED_DATA_PATH"
echo "built app:"
if [[ -d "$APP_PATH" ]]; then
  echo "  $APP_PATH"
else
  echo "  <not built>"
fi

echo "xctestrun metadata:"
if [[ -n "$XCTESTRUN_PATH" ]]; then
  echo "  $XCTESTRUN_PATH"
else
  echo "  <not built-for-testing>"
fi

echo
echo "recommended commands:"
echo "  Scripts/check_authored_scenarios.sh"
echo "  Scripts/build_app.sh"
echo "  Scripts/launch_app.sh --state pressure"
echo "  Scripts/run_tests.sh unit"
echo "  Scripts/run_tests.sh ui"

if [[ -n "$ACTIVE_DEVELOPER_DIR" && "$ACTIVE_DEVELOPER_DIR" != "$DEVELOPER_DIR" ]]; then
  echo
  echo "note:"
  echo "  The machine is not globally pointed at full Xcode."
  echo "  Use the repo scripts above instead of raw xcodebuild/simctl."
fi
