TEST_TARGET=MacOSGRMustacheTest
PROJECT=MacOSGRMustache.xcodeproj
COMMAND=xcodebuild

default:
	$(COMMAND) -project $(PROJECT) -target $(TEST_TARGET) -configuration Debug build
