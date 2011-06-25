libGRMustache1-io3-iphoneos="build/iphoneos3/Release-iphoneos/libGRMustache1-ios3.a"
libGRMustache1-io3-iphonesimulator="build/iphonesimulator3/Release-iphonesimulator/libGRMustache1-ios3.a"
libGRMustache1-io3="lib/libGRMustache1-ios3.a"
libGRMustache1-io4-iphoneos="build/iphoneos4/Release-iphoneos/libGRMustache1.a"
libGRMustache1-io4-iphonesimulator="build/iphonesimulator4/Release-iphonesimulator/libGRMustache1.a"
libGRMustache1-io4="lib/libGRMustache1-ios4.a"
libGRMustache1-macosx10.6="lib/libGRMustache1-macosx10.6.a"

all: libs includes

libs: libGRMustache1-io3 libGRMustache1-io4 libGRMustache1-macosx10.6

libGRMustache1-io3: libGRMustache1-io3-iphoneos libGRMustache1-io3-iphonesimulator
	mkdir -p lib
	lipo -create \
		"build/iphonesimulator3/Release-iphonesimulator/libGRMustache1-ios3.a" \
		"build/iphoneos3/Release-iphoneos/libGRMustache1-ios3.a" \
		-output "lib/libGRMustache1-ios3.a"

libGRMustache1-io3-iphoneos:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration Release                         -arch "armv6 armv7" build SYMROOT=build/iphoneos3

libGRMustache1-io3-iphonesimulator:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration Release -sdk iphonesimulator4.3 -arch "i386"        build SYMROOT=build/iphonesimulator3

libGRMustache1-io4: libGRMustache1-io4-iphoneos libGRMustache1-io4-iphonesimulator
	mkdir -p lib
	lipo -create \
		"build/iphonesimulator4/Release-iphonesimulator/libGRMustache1.a" \
		"build/iphoneos4/Release-iphoneos/libGRMustache1.a" \
		-output "lib/libGRMustache1-ios4.a"

libGRMustache1-io4-iphoneos:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration Release                         -arch "armv6 armv7" build SYMROOT=build/iphoneos4

libGRMustache1-io4-iphonesimulator:
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration Release -sdk iphonesimulator4.3 -arch "i386"        build SYMROOT=build/iphonesimulator4

libGRMustache1-macosx10.6:
	xcodebuild -project GRMustache1-macosx.xcodeproj -target GRMustache1      -configuration Release -sdk macosx             -arch "i386 x86_64" build SYMROOT=build/macosx10.6
	mkdir -p lib
	mv build/macosx10.6/Release/libGRMustache1.a lib/libGRMustache1-macosx10.6.a

includes: libGRMustache1-io4-iphoneos
	rm -rf include
	mv build/iphoneos4/Release-iphoneos/include .

clean:
	rm -rf build
	rm -rf include
	rm -rf lib

