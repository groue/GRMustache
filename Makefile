TEST_TARGET=GRMustacheTest
APP_TARGET=GRMustacheTest
COMMAND=xcodebuild

default:
	$(COMMAND) -target $(APP_TARGET) -configuration Debug build
