all: lib/libGRMustache1-ios3.a lib/libGRMustache1-ios4.a lib/libGRMustache1-macosx10.6.a include/GRMustache.h

lib/libGRMustache1-ios3.a: build/iosdevice3/Release-iphoneos/libGRMustache1-ios3.a build/iphonesimulator3/Release-iphonesimulator/libGRMustache1-ios3.a
	mkdir -p lib
	lipo -create \
		"build/iphonesimulator3/Release-iphonesimulator/libGRMustache1-ios3.a" \
		"build/iosdevice3/Release-iphoneos/libGRMustache1-ios3.a" \
		-output "lib/libGRMustache1-ios3.a"

lib/libGRMustache1-ios4.a: build/iosdevice/Release-iphoneos/libGRMustache1.a build/iphonesimulator/Release-iphonesimulator/libGRMustache1.a
	mkdir -p lib
	lipo -create \
		"build/iphonesimulator/Release-iphonesimulator/libGRMustache1.a" \
		"build/iosdevice/Release-iphoneos/libGRMustache1.a" \
		-output "lib/libGRMustache1-ios4.a"

lib/libGRMustache1-macosx10.6.a: build/macosx10.6/Release
	mkdir -p lib
	cp build/macosx10.6/Release/libGRMustache1.a lib/libGRMustache1-macosx10.6.a

build/iosdevice3/Release-iphoneos/libGRMustache1-ios3.a: build/iosdevice3/Release-iphoneos

build/iphonesimulator3/Release-iphonesimulator/libGRMustache1-ios3.a: build/iphonesimulator3/Release-iphonesimulator

build/iosdevice/Release-iphoneos/libGRMustache1.a: build/iosdevice/Release-iphoneos

build/iphonesimulator/Release-iphonesimulator/libGRMustache1.a: build/iphonesimulator/Release-iphonesimulator

build/iosdevice3/Release-iphoneos:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration Release                      -arch "armv6 armv7" build SYMROOT=build/iosdevice3

build/iphonesimulator3/Release-iphonesimulator:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration Release -sdk iphonesimulator -arch "i386"        build SYMROOT=build/iphonesimulator3

build/iosdevice/Release-iphoneos:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration Release                      -arch "armv6 armv7" build SYMROOT=build/iosdevice

build/iphonesimulator/Release-iphonesimulator:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration Release -sdk iphonesimulator -arch "i386"        build SYMROOT=build/iphonesimulator

build/macosx10.6/Release:
	xcodebuild -project GRMustache1-macosx.xcodeproj -target GRMustache1      -configuration Release                      -arch "i386 x86_64" build SYMROOT=build/macosx10.6

include/GRMustache.h: build/macosx10.6/Release/include
	cp -R build/macosx10.6/Release/include .

build/macosx10.6/Release/include: build/macosx10.6/Release

clean:
	rm -rf build
	rm -rf include
	rm -rf lib

