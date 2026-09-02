# Agent Notes

This project should be driven from the terminal. Do not rely on opening Xcode for normal build, test, or device workflows.

## Product Context

Suppose is a free, ad-free, offline financial what-if app. The app should help Charles run clear personal finance scenarios without accounts, syncing, cloud services, ads, or paid features.

The first scenario tool is an investment calculator:

- Inputs: starting value, monthly contribution, annual interest rate, current age.
- Output: annual projected balances labeled by age.
- Current horizon: 40 years.
- Data model: local only.

The app is expected to grow into multiple tools. Keep the root navigation structure explicit and add new tools through the shared tool directory rather than replacing the first screen with a single-purpose calculator.

Maintain this product direction unless Charles explicitly changes it.

## Project

- Xcode project: `Suppose.xcodeproj`
- Scheme: `Suppose`
- App target: `Suppose`
- Unit test target: `SupposeTests`
- UI test target: `SupposeUITests`
- Local build output: `.DerivedData/`

## Architecture

- Keep calculation logic in small, pure Swift types that can be tested without UI.
- Keep SwiftUI views focused on input, layout, and presentation.
- Use `ContentView` as the top-level navigation shell and `FinancialTool` as the app's tool registry.
- Put tool-specific UI in dedicated views such as `InvestmentCalculatorView`.
- Document architectural changes in this file and human-facing project context in `README.md`.
- Add or update tests when changing calculator behavior.

## App Icon

- Source art: `Design/AppIcon/AppIcon-{light,dark,tinted}.svg`.
- Compiled assets: `Suppose/Assets.xcassets/AppIcon.appiconset/` (1024x1024 PNG
  per appearance, single-size format).
- To change the icon, edit the SVGs and regenerate the PNGs with the
  `rsvg-convert` loop documented in `Design/AppIcon/README.md`.

## Commands

Run these from the repository root:

```sh
make destinations
make devices
make build-simulator
make run-simulator
make test-simulator
make build-device
make run-device
```

Defaults currently target:

- Simulator: `iPhone 17`, `OS=latest`
- Connected iPhone: `3948391A-B03C-5562-9E2D-B1495FC9574B` (`Charles's iPhone (2)`)
- Device builds use `generic/platform=iOS`; install and launch use `DEVICE_ID`.

If the local simulator or phone changes, override the destination on the command line:

```sh
make run-simulator SIMULATOR_NAME="iPhone 17 Pro"
make run-device DEVICE_ID=<device-udid>
```

If `run-device` fails, inspect device availability with:

```sh
xcrun devicectl list devices
```

## Git Hygiene

- Keep the project under Git.
- Commit intentional changes with clear messages.
- Do not commit `.DerivedData/`, `build/`, `xcuserdata/`, or other local Xcode state.
- Before committing, inspect `git status --short` and verify the terminal build or explain why it was not run.
