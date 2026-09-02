# Suppose

SwiftUI iOS project for the `Suppose` app.

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
