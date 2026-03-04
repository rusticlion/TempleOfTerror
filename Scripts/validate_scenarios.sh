#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

swiftc \
  "$ROOT_DIR/CardGame/Models.swift" \
  "$ROOT_DIR/CardGame/ContentLoader.swift" \
  "$ROOT_DIR/CardGame/ScenarioValidator.swift" \
  "$ROOT_DIR/Scripts/run_scenario_validator.swift" \
  -o "$TMP_DIR/scenario-validator"

"$TMP_DIR/scenario-validator" "${1:-"$ROOT_DIR/Content/Scenarios"}"
