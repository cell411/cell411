
# set default shell
SHELL=/bin/bash -o pipefail -o errexit


SCHEME = cell411
XCODE_BUILD = xcrun xcodebuild -workspace $(SCHEME).xcworkspace -allowProvisioningUpdates -scheme $(SCHEME) -sdk iphonesimulator

.PHONY: build test retest clean dependencies

dependencies:
	# This doesnt do what you think it does
	# pod update

build: dependencies
	$(XCODE_BUILD) build

clean:
	$(XCODE_BUILD) clean 
