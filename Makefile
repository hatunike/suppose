PROJECT := Suppose.xcodeproj
SCHEME := Suppose
APP_BUNDLE_ID := Lernu.Suppose
CONFIGURATION ?= Debug
DERIVED_DATA := .DerivedData

# Current known local destinations. Override from the command line if needed:
#   make run-device DEVICE_ID=<device-id-or-name>
#   make build-simulator SIMULATOR_NAME="iPhone 17 Pro"
DEVICE_ID ?= 3948391A-B03C-5562-9E2D-B1495FC9574B
SIMULATOR_NAME ?= iPhone 17
SIMULATOR_OS ?= latest

XCODEBUILD := xcodebuild \
	-project "$(PROJECT)" \
	-scheme "$(SCHEME)" \
	-configuration "$(CONFIGURATION)" \
	-derivedDataPath "$(DERIVED_DATA)"

.PHONY: help destinations devices build-simulator run-simulator build-device run-device test-simulator clean

help:
	@printf "Suppose terminal commands\n"
	@printf "\n"
	@printf "  make destinations       List devices and simulators Xcode can target\n"
	@printf "  make devices            List devices visible to xcrun devicectl\n"
	@printf "  make build-simulator    Build for the iOS Simulator (%s, OS=%s)\n" "$(SIMULATOR_NAME)" "$(SIMULATOR_OS)"
	@printf "  make run-simulator      Build, install, and launch on the iOS Simulator\n"
	@printf "  make test-simulator     Run tests on the iOS Simulator (%s, OS=%s)\n" "$(SIMULATOR_NAME)" "$(SIMULATOR_OS)"
	@printf "  make build-device       Build for the connected iPhone (%s)\n" "$(DEVICE_ID)"
	@printf "  make run-device         Build, install, and launch on the connected iPhone\n"
	@printf "  make clean              Remove local build output\n"

destinations:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -showdestinations

devices:
	xcrun devicectl list devices

build-simulator:
	$(XCODEBUILD) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=$(SIMULATOR_OS)" build

run-simulator: build-simulator
	xcrun simctl boot "$(SIMULATOR_NAME)" || true
	xcrun simctl install booted "$(DERIVED_DATA)/Build/Products/$(CONFIGURATION)-iphonesimulator/$(SCHEME).app"
	xcrun simctl launch booted "$(APP_BUNDLE_ID)"

test-simulator:
	$(XCODEBUILD) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=$(SIMULATOR_OS)" test

build-device:
	$(XCODEBUILD) -destination "generic/platform=iOS" -allowProvisioningUpdates build

run-device: build-device
	xcrun devicectl device install app --device "$(DEVICE_ID)" "$(DERIVED_DATA)/Build/Products/$(CONFIGURATION)-iphoneos/$(SCHEME).app"
	xcrun devicectl device process launch --device "$(DEVICE_ID)" "$(APP_BUNDLE_ID)"

clean:
	rm -rf "$(DERIVED_DATA)" build
