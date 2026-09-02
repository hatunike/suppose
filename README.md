# Suppose

Suppose is a free, ad-free, offline iOS app for running personal financial what-if scenarios.

Suppose ships with two tools:

- **Investment calculator** — starting value, monthly contribution, annual interest rate, and current age, projected as an annual balance over a 40-year horizon.
- **Mortgage calculator** — current principal, interest rate, monthly principal-and-interest payment, and an optional additional monthly payment, projected as a year-by-year payoff schedule that also reports the interest and time the extra payment saves.

## Product Principles

- Free of cost.
- No ads.
- Offline-first with local-only data.
- No account, syncing, cloud dependency, or telemetry requirement.
- Designed for fast, understandable financial scenario exploration.

## Architecture

- `SupposeApp.swift` is the SwiftUI app entry point.
- `ContentView.swift` owns the top-level navigation and tool directory.
- `FinancialTool.swift` is the registry of tools shown in navigation.
- `InvestmentScenario.swift` / `InvestmentProjection.swift` are the investment input model and pure projection logic.
- `InvestmentCalculatorView.swift` is the investment calculator screen.
- `MortgageScenario.swift` / `MortgageAmortization.swift` are the mortgage input model and pure amortization logic.
- `MortgageCalculatorView.swift` is the mortgage calculator screen.
- `SupposeTests.swift` covers both calculators' model logic.

Keep financial calculations in testable model/calculator types instead of embedding them directly in SwiftUI views. Each calculator screen persists its inputs with `@AppStorage` (per-tool key prefix) so the last-entered values survive navigation and relaunch.

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
