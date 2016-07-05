all: lib/libGRMustache7-iOS.a lib/libGRMustache7-tvOS.a lib/libGRMustache7-MacOS.a include/GRMustache.h Reference

lib/libGRMustache7-iOS.a: build/GRMustache7-iOS/Release-iphoneos/libGRMustache7-iOS.a build/GRMustache7-iphonesimulator/Release-iphonesimulator/libGRMustache7-iOS.a build/GRMustache7-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache7-iOS.a
	mkdir -p lib
	lipo -create \
	  "build/GRMustache7-iphonesimulator/Release-iphonesimulator/libGRMustache7-iOS.a" \
	  "build/GRMustache7-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache7-iOS.a" \
	  "build/GRMustache7-iOS/Release-iphoneos/libGRMustache7-iOS.a" \
	  -output "lib/libGRMustache7-iOS.a"

lib/libGRMustache7-MacOS.a: build/MacOS/Release/libGRMustache7-MacOS.a
	mkdir -p lib
	cp build/MacOS/Release/libGRMustache7-MacOS.a lib/libGRMustache7-MacOS.a

lib/libGRMustache7-tvOS.a: build/GRMustache7-tvOS/Release-appletvos/libGRMustache7-tvOS.a  build/GRMustache7-appletvsimulator-x86_64/Release-appletvsimulator/libGRMustache7-tvOS.a
	mkdir -p lib
	lipo -create \
	  "build/GRMustache7-appletvsimulator-x86_64/Release-appletvsimulator/libGRMustache7-tvOS.a" \
	  "build/GRMustache7-tvOS/Release-appletvos/libGRMustache7-tvOS.a" \
	  -output "lib/libGRMustache7-tvOS.a"

build/GRMustache7-iOS/Release-iphoneos/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           build SYMROOT=../build/GRMustache7-iOS \
						 OTHER_CFLAGS="-fembed-bitcode"

build/GRMustache7-iphonesimulator/Release-iphonesimulator/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "i386" \
	           build SYMROOT=../build/GRMustache7-iphonesimulator \
						 OTHER_CFLAGS="-fembed-bitcode"

build/GRMustache7-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "x86_64" \
	           build SYMROOT=../build/GRMustache7-iphonesimulator-x86_64 \
						 OTHER_CFLAGS="-fembed-bitcode"
						 
build/GRMustache7-tvOS/Release-appletvos/libGRMustache7-tvOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-tvOS \
	           -configuration Release \
	           build SYMROOT=../build/GRMustache7-tvOS \
						 OTHER_CFLAGS="-fembed-bitcode"

build/GRMustache7-appletvsimulator-x86_64/Release-appletvsimulator/libGRMustache7-tvOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-tvOS \
	           -configuration Release \
	           -sdk appletvsimulator \
	           -arch "x86_64" \
	           build SYMROOT=../build/GRMustache7-appletvsimulator-x86_64 \
						 OTHER_CFLAGS="-fembed-bitcode"

build/MacOS/Release/libGRMustache7-MacOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-MacOS \
	           -configuration Release \
	           build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/libGRMustache7-MacOS.a
	cp -R build/MacOS/Release/include/GRMustache include

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

