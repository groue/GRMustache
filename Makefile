all: lib/libGRMustache7-iOS.a lib/libGRMustache7-MacOS.a include/GRMustache.h Reference

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

build/GRMustache7-iOS/Release-iphoneos/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           build SYMROOT=../build/GRMustache7-iOS

build/GRMustache7-iphonesimulator/Release-iphonesimulator/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "i386" \
	           build SYMROOT=../build/GRMustache7-iphonesimulator

build/GRMustache7-iphonesimulator-x86_64/Release-iphonesimulator/libGRMustache7-iOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-iOS \
	           -configuration Release \
	           -sdk iphonesimulator \
	           -arch "x86_64" \
	           build SYMROOT=../build/GRMustache7-iphonesimulator-x86_64
                                                                                                                                    
build/MacOS/Release/libGRMustache7-MacOS.a:
	xcodebuild -project src/GRMustache.xcodeproj \
	           -target GRMustache7-MacOS \
	           -configuration Release \
	           build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/libGRMustache7-MacOS.a
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

