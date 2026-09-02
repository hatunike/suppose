PROJECT := Suppose.xcodeproj
SCHEME := Suppose
CONFIGURATION ?= Debug
DERIVED_DATA := .DerivedData

# Current known local destinations. Override from the command line if needed:
#   make build-device DEVICE_ID=<device-udid>
#   make build-simulator SIMULATOR_NAME="iPhone 17 Pro"
DEVICE_ID ?= 00008130-0001484A2604001C
SIMULATOR_NAME ?= iPhone 17
SIMULATOR_OS ?= latest

XCODEBUILD := xcodebuild \
	-project "$(PROJECT)" \
	-scheme "$(SCHEME)" \
	-configuration "$(CONFIGURATION)" \
	-derivedDataPath "$(DERIVED_DATA)"

.PHONY: help destinations build-simulator build-device test-simulator clean

help:
	@printf "Suppose terminal commands\n"
	@printf "\n"
	@printf "  make destinations       List devices and simulators Xcode can target\n"
	@printf "  make build-simulator    Build for the iOS Simulator (%s, OS=%s)\n" "$(SIMULATOR_NAME)" "$(SIMULATOR_OS)"
	@printf "  make test-simulator     Run tests on the iOS Simulator (%s, OS=%s)\n" "$(SIMULATOR_NAME)" "$(SIMULATOR_OS)"
	@printf "  make build-device       Build for the connected iPhone (%s)\n" "$(DEVICE_ID)"
	@printf "  make clean              Remove local build output\n"

destinations:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -showdestinations

build-simulator:
	$(XCODEBUILD) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=$(SIMULATOR_OS)" build

test-simulator:
	$(XCODEBUILD) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=$(SIMULATOR_OS)" test

build-device:
	$(XCODEBUILD) -destination "platform=iOS,id=$(DEVICE_ID)" -allowProvisioningUpdates build

clean:
	rm -rf "$(DERIVED_DATA)" build
