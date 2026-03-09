#!/bin/zsh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

SIMULATOR_NAME="${TOT_SIMULATOR_NAME:-iPhone 17}"
DERIVED_DATA_PATH="${TOT_DERIVED_DATA_PATH:-$PROJECT_ROOT/.codex-derived}"
CLEAN_DERIVED_DATA="${TOT_CLEAN_DERIVED_DATA:-0}"
VERBOSE_XCODEBUILD="${TOT_VERBOSE_XCODEBUILD:-0}"
TEST_MODE="${1:-unit}"

find_device_id() {
  local line

  line="$(
    DEVELOPER_DIR="$DEVELOPER_DIR" xcrun simctl list devices available |
      grep -F "$SIMULATOR_NAME (" |
      head -n 1 || true
  )"

  if [[ -n "$line" ]]; then
    printf '%s\n' "$line" | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/'
  fi
}

filter_xcodebuild_noise() {
  local line

  while IFS= read -r line; do
    case "$line" in
      *'DVTDeviceOperation: Encountered a build number "" that is incompatible with DVTBuildVersion.'*)
        continue
        ;;
      *'[MT] IDERunDestination: Supported platforms for the buildables in the current scheme is empty.'*)
        continue
        ;;
      *'appintentsmetadataprocessor['*'Starting appintentsmetadataprocessor export'*)
        continue
        ;;
      *'warning: Metadata extraction skipped. No AppIntents.framework dependency found.'*)
        continue
        ;;
      *'[MT] IDETestOperationsObserverDebug:'*)
        continue
        ;;
      *'Failed to send CA Event for app launch measurements'*)
        continue
        ;;
      *)
        print -r -- "$line"
        ;;
    esac
  done
}

run_xcodebuild() {
  local -a args
  local -a statuses

  args=("$@")

  if [[ "$VERBOSE_XCODEBUILD" != "1" ]]; then
    if [[ "${args[1]}" == "build-for-testing" ]]; then
      args=(-quiet "${args[@]}")
    fi

    DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild "${args[@]}" 2>&1 | filter_xcodebuild_noise
    statuses=("${pipestatus[@]}")
    return "${statuses[1]}"
  fi

  DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild "${args[@]}"
}

DEVICE_ID="$(find_device_id)"

if [[ -z "$DEVICE_ID" ]]; then
  print -u2 "Unable to find an available simulator named '$SIMULATOR_NAME'."
  print -u2 "Set TOT_SIMULATOR_NAME to an available device and retry."
  DEVELOPER_DIR="$DEVELOPER_DIR" xcrun simctl list devices available
  exit 1
fi

if [[ "$CLEAN_DERIVED_DATA" == "1" ]]; then
  rm -rf "$DERIVED_DATA_PATH"
fi

mkdir -p "$DERIVED_DATA_PATH"

DEVELOPER_DIR="$DEVELOPER_DIR" xcrun simctl shutdown "$DEVICE_ID" >/dev/null 2>&1 || true
DEVELOPER_DIR="$DEVELOPER_DIR" xcrun simctl bootstatus "$DEVICE_ID" -b

COMMON_XCODEBUILD_ARGS=(
  -project "$PROJECT_ROOT/CardGame.xcodeproj"
  -scheme CardGame
  -derivedDataPath "$DERIVED_DATA_PATH"
  -destination "platform=iOS Simulator,id=$DEVICE_ID"
  -parallel-testing-enabled NO
)

run_xcodebuild build-for-testing "${COMMON_XCODEBUILD_ARGS[@]}"

XCTESTRUN_PATH="$(find "$DERIVED_DATA_PATH/Build/Products" -maxdepth 1 -name 'CardGame_iphonesimulator*.xctestrun' | head -n 1)"

if [[ -z "$XCTESTRUN_PATH" ]]; then
  print -u2 "Expected an .xctestrun file under $DERIVED_DATA_PATH/Build/Products, but none was found."
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
    print -u2 "Usage: $(basename "$0") [unit|ui|all]"
    exit 2
    ;;
esac

DEVELOPER_DIR="$DEVELOPER_DIR" xcrun simctl bootstatus "$DEVICE_ID" -b
run_xcodebuild test-without-building \
  -xctestrun "$XCTESTRUN_PATH" \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -parallel-testing-enabled NO \
  "${TEST_ARGS[@]}"
