# Development Tooling

This repo already supports simulator-backed unit tests and UI tests from the terminal, but there is one easy trap: the machine may have `xcode-select` pointed at Command Line Tools instead of full Xcode. In that state, plain `xcodebuild` and `xcrun simctl` commands can fail even though `/Applications/Xcode.app` is installed.

The scripts in `/Scripts` handle that repo-specific setup for you. Prefer them over raw Xcode CLI commands.

They also default derived data to `.build/codex-derived` so normal build and test runs do not churn the tracked legacy `.codex-derived` directory.

## Codex Entry Points

### Inspect the environment

```bash
Scripts/codex_doctor.sh
```

This prints:

- the active `xcode-select` path
- the repo’s effective `DEVELOPER_DIR`
- the default simulator name and resolved device id
- whether a simulator app build already exists in `.build/codex-derived`

### Build the app for Simulator

```bash
Scripts/build_app.sh
```

Useful options:

- `--for-testing`: produce the `.xctestrun` metadata used by test runs
- `--sync-authored-content`: compile and validate authored YAML content before the build

Environment overrides:

- `TOT_SIMULATOR_NAME`: pick a different simulator, such as `iPhone 17 Pro`
- `TOT_DERIVED_DATA_PATH`: change the derived data location
- `TOT_CLEAN_DERIVED_DATA=1`: force a clean rebuild
- `TOT_VERBOSE_XCODEBUILD=1`: show full `xcodebuild` output

### Launch a debug scenario in Simulator

```bash
Scripts/launch_app.sh --state pressure
```

Useful options:

- `--screen content`
- `--screen map`
- `--state fresh`
- `--state pressure`
- `--state solo`
- `--state split`
- `--scenario temple_of_terror`
- `--fixed-dice 1,6`
- `--no-build`: reuse the current `.build/codex-derived` app bundle
- `--sync-authored-content`: rebuild authored scenario content first

The launch script installs the app into the selected simulator and uses the existing `CODEX_DEBUG_*` app hooks to jump directly into a test-friendly state.

### Run tests

```bash
Scripts/run_tests.sh unit
Scripts/run_tests.sh ui
Scripts/run_tests.sh all
```

`unit` builds-for-testing and runs `CardGameTests`.

`ui` builds-for-testing and runs `CardGameUITests`, including the simulator-driven flows.

`all` runs both test targets.

### Validate authored scenarios

```bash
Scripts/check_authored_scenarios.sh
```

This compiles authored YAML into packaged JSON, validates the generated scenarios, and writes map previews to `Authoring/Previews`.

## Recommended Codex Workflow

When changing core Swift code:

```bash
Scripts/run_tests.sh unit
```

When changing UI or interaction flows:

```bash
Scripts/run_tests.sh ui
```

When changing authored scenario content:

```bash
Scripts/check_authored_scenarios.sh
Scripts/build_app.sh --sync-authored-content
```

When you want a live app window for manual inspection:

```bash
Scripts/launch_app.sh --state split
```
