#!/usr/bin/env bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/CardGame.xcodeproj"
SCHEME_NAME="${TOT_SCHEME_NAME:-CardGame}"
APP_BUNDLE_IDENTIFIER="${TOT_APP_BUNDLE_IDENTIFIER:-RoaringRobot.CardGame}"
SIMULATOR_NAME="${TOT_SIMULATOR_NAME:-iPhone 17}"
DERIVED_DATA_PATH="${TOT_DERIVED_DATA_PATH:-$PROJECT_ROOT/.build/codex-derived}"
BUILD_CONFIGURATION="${TOT_BUILD_CONFIGURATION:-Debug}"
VERBOSE_XCODEBUILD="${TOT_VERBOSE_XCODEBUILD:-0}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export PATH="$DEVELOPER_DIR/usr/bin:$PATH"

ensure_xcode_available() {
  if [[ ! -d "$DEVELOPER_DIR" ]]; then
    echo "Expected Xcode developer directory at $DEVELOPER_DIR" >&2
    echo "Install Xcode or export DEVELOPER_DIR to the correct location." >&2
    exit 1
  fi
}

run_xcrun() {
  DEVELOPER_DIR="$DEVELOPER_DIR" xcrun "$@"
}

filter_xcodebuild_noise() {
  local line
  local skip_next_line=0

  while IFS= read -r line; do
    if [[ "$skip_next_line" == "1" ]]; then
      skip_next_line=0
      continue
    fi

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
      *'[MT] IDETestOperationsObserverDebug:'*|*'IDETestOperationsObserverDebug:'*)
        skip_next_line=1
        continue
        ;;
      *'xcrun: error: unable to find utility "simctl", not a developer tool or in PATH'*)
        continue
        ;;
      *'Failed to send CA Event for app launch measurements'*)
        continue
        ;;
      *)
        printf '%s\n' "$line"
        ;;
    esac
  done
}

run_xcodebuild() {
  local -a args
  local -a statuses

  args=("$@")

  if [[ "$VERBOSE_XCODEBUILD" != "1" ]]; then
    case "${args[0]:-}" in
      build|build-for-testing)
        args=(-quiet "${args[@]}")
        ;;
    esac

    DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild "${args[@]}" 2>&1 | filter_xcodebuild_noise
    statuses=("${PIPESTATUS[@]}")
    return "${statuses[0]}"
  fi

  DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild "${args[@]}"
}

find_simulator_device_id() {
  local line

  line="$(
    run_xcrun simctl list devices available |
      grep -F "$SIMULATOR_NAME (" |
      head -n 1 || true
  )"

  if [[ -n "$line" ]]; then
    printf '%s\n' "$line" | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/'
  fi
}

require_simulator_device_id() {
  local device_id

  device_id="$(find_simulator_device_id)"
  if [[ -n "$device_id" ]]; then
    printf '%s\n' "$device_id"
    return 0
  fi

  echo "Unable to find an available simulator named '$SIMULATOR_NAME'." >&2
  echo "Set TOT_SIMULATOR_NAME to an available device and retry." >&2
  run_xcrun simctl list devices available >&2
  exit 1
}

shutdown_simulator() {
  local device_id="$1"

  run_xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true
}

boot_simulator() {
  local device_id="$1"

  if [[ "${TOT_OPEN_SIMULATOR:-1}" == "1" ]]; then
    open -a Simulator >/dev/null 2>&1 || true
  fi

  run_xcrun simctl bootstatus "$device_id" -b
}

ensure_derived_data_dir() {
  if [[ "${TOT_CLEAN_DERIVED_DATA:-0}" == "1" ]]; then
    rm -rf "$DERIVED_DATA_PATH"
  fi

  mkdir -p "$DERIVED_DATA_PATH"
}

populate_common_xcodebuild_args() {
  local device_id="$1"

  COMMON_XCODEBUILD_ARGS=(
    -project "$PROJECT_PATH"
    -scheme "$SCHEME_NAME"
    -configuration "$BUILD_CONFIGURATION"
    -derivedDataPath "$DERIVED_DATA_PATH"
    -destination "platform=iOS Simulator,id=$device_id"
    -parallel-testing-enabled NO
  )
}

app_bundle_path() {
  printf '%s\n' "$DERIVED_DATA_PATH/Build/Products/${BUILD_CONFIGURATION}-iphonesimulator/CardGame.app"
}

find_xctestrun_path() {
  find "$DERIVED_DATA_PATH/Build/Products" -maxdepth 1 -name 'CardGame_iphonesimulator*.xctestrun' | head -n 1
}

print_available_simulators() {
  run_xcrun simctl list devices available
}
