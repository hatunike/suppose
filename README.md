# Suppose

Suppose is a free, ad-free, offline iOS app for running personal financial what-if scenarios.

The first tool is a basic investment calculator. It accepts a starting value, monthly contribution, annual interest rate, and current age, then projects the balance for each year over a 40-year horizon.

## Product Principles

- Free of cost.
- No ads.
- Offline-first with local-only data.
- No account, syncing, cloud dependency, or telemetry requirement.
- Designed for fast, understandable financial scenario exploration.

## Architecture

- `SupposeApp.swift` is the SwiftUI app entry point.
- `ContentView.swift` owns the top-level navigation structure and tool directory.
- `FinancialTool.swift` defines the tools available in the app navigation.
- `InvestmentCalculatorView.swift` owns the investment calculator screen and input state.
- `InvestmentScenario.swift` defines the local input model.
- `InvestmentProjection.swift` contains pure projection logic and annual output rows.
- `SupposeTests.swift` covers the calculator behavior.

Keep financial calculations in testable model/calculator types instead of embedding them directly in SwiftUI views.

## App Icon

The icon shows three curves fanning upward from a shared origin: one starting
point projected forward under different assumptions. Editable source art and a
regeneration script live in `Design/AppIcon/`; the rendered 1024x1024 light,
dark, and tinted variants live in `Suppose/Assets.xcassets/AppIcon.appiconset/`.

## Terminal Workflow

Use the command line instead of opening Xcode.

```sh
make destinations
make devices
make build-simulator
make run-simulator
make test-simulator
make build-device
make run-device
```

The default simulator is `iPhone 17` with the latest installed runtime. Override it when needed:

```sh
make run-simulator SIMULATOR_NAME="iPhone 17 Pro"
```

`make build-device` builds a signed iPhoneOS app without requiring the phone to be listed as an active build destination. `make run-device` then installs and launches that build on the configured device.

The default connected iPhone id for install and launch is:

```text
3948391A-B03C-5562-9E2D-B1495FC9574B
```

Override the device id or name if the phone changes:

```sh
make run-device DEVICE_ID=<device-udid>
```

If `make run-device` cannot install or launch, check whether the phone is reachable:

```sh
xcrun devicectl list devices
```
