TEST_TARGET=MacOSGRMustacheTest
APP_TARGET=MacOSGRMustacheTest
COMMAND=xcodebuild

default:
	$(COMMAND) -target $(APP_TARGET) -configuration Debug build
