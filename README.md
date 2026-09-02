# Suppose

SwiftUI iOS project for the `Suppose` app.

## Terminal Workflow

Use the command line instead of opening Xcode.

```sh
make destinations
make build-simulator
make test-simulator
make build-device
```

The default simulator is `iPhone 17` with the latest installed runtime. Override it when needed:

```sh
make build-simulator SIMULATOR_NAME="iPhone 17 Pro"
```

The default connected iPhone is `Charles's iPhone (2)`:

```text
00008130-0001484A2604001C
```

Override the device id if the phone changes:

```sh
make build-device DEVICE_ID=<device-udid>
```
