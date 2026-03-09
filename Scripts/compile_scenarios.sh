#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ruby "$ROOT_DIR/Scripts/compile_scenarios.rb" "$@"
