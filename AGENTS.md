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
make build-simulator
make run-simulator
make test-simulator
make build-device
make run-device
```

Defaults currently target:

- Simulator: `iPhone 17`, `OS=latest`
- Connected iPhone: `00008130-0001484A2604001C` (`Charles's iPhone (2)`)

If the local simulator or phone changes, override the destination on the command line:

```sh
make run-simulator SIMULATOR_NAME="iPhone 17 Pro"
make run-device DEVICE_ID=<device-udid>
```

## Git Hygiene

- Keep the project under Git.
- Commit intentional changes with clear messages.
- Do not commit `.DerivedData/`, `build/`, `xcuserdata/`, or other local Xcode state.
- Before committing, inspect `git status --short` and verify the terminal build or explain why it was not run.
