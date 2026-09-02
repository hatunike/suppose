# Agent Notes

This project should be driven from the terminal. Do not rely on opening Xcode for normal build, test, or device workflows.

## Project

- Xcode project: `Suppose.xcodeproj`
- Scheme: `Suppose`
- App target: `Suppose`
- Unit test target: `SupposeTests`
- UI test target: `SupposeUITests`
- Local build output: `.DerivedData/`

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
