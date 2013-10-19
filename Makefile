all: lib/libGRMustache6-iOS.a lib/libGRMustache6-MacOS.a include/GRMustache.h Reference

lib/libGRMustache6-iOS.a: build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a build/GRMustache6-iphonesimulator/Release-iphonesimulator/libGRMustache6-iOS.a build/GRMustache6-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache6-iOS-arm64.a
	mkdir -p lib
	lipo -create \
	  "build/GRMustache6-iphonesimulator/Release-iphonesimulator/libGRMustache6-iOS.a" \
	  "build/GRMustache6-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache6-iOS-arm64.a" \
	  "build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a" \
	  "build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a" \
	  -output "lib/libGRMustache6-iOS.a"

lib/libGRMustache6-MacOS.a: build/MacOS/Release/libGRMustache6-MacOS.a
	mkdir -p lib
	cp build/MacOS/Release/libGRMustache6-MacOS.a lib/libGRMustache6-MacOS.a

build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache6-iOS \
	           -configuration Release \
	           build SYMROOT=../build/GRMustache6-iOS

build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache6-iOS-arm64 \
	           -configuration Release \
	           build SYMROOT=../build/GRMustache6-iOS-arm64

build/GRMustache6-iphonesimulator/Release-iphonesimulator/libGRMustache6-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache6-iOS \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "i386" \
	           build SYMROOT=../build/GRMustache6-iphonesimulator

build/GRMustache6-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache6-iOS-arm64.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache6-iOS-arm64 \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "x86_64" \
	           build SYMROOT=../build/GRMustache6-iphonesimulator-x86_64
                                                                                                                                    
build/MacOS/Release/libGRMustache6-MacOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache6-MacOS \
	           -configuration Release \
	           build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/libGRMustache6-MacOS.a
	cp -R build/MacOS/Release/usr/local/include .

Reference: include/GRMustache.h
	# Appledoc does not parse availability macros: create a temporary directory
	# with "cleaned" GRMustache headers.
	rm -Rf /tmp/GRMustache_include
	cp -Rf include /tmp/GRMustache_include
	for f in /tmp/GRMustache_include/*; do \
	  cat $${f} | sed "s/AVAILABLE_[A-Za-z0-9_]*//g" > $${f}.tmp; \
	  mv -f $${f}.tmp $${f}; \
	done
	# Generate documentation
	mkdir Reference
	appledoc --output Reference AppledocSettings.plist /tmp/GRMustache_include || true
	# Cleanup
	rm -Rf /tmp/GRMustache_include

clean:
	rm -rf build
	rm -rf include
	rm -rf lib
	rm -rf Reference

