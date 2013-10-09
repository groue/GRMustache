all: lib/libGRMustache6-iOS.a lib/libGRMustache6-MacOS.a include/GRMustache.h Reference

lib/libGRMustache6-iOS.a: build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a build/GRMustache6-iOS-simulator/Release-iphonesimulator/libGRMustache6-iOS.a
	mkdir -p lib
	lipo -create \
	  "build/GRMustache6-iOS-simulator/Release-iphonesimulator/libGRMustache6-iOS.a" \
	  "build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a" \
	  "build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a" \
	  -output "lib/libGRMustache6-iOS.a"

lib/libGRMustache6-MacOS.a: build/MacOS/Release
	mkdir -p lib
	cp build/MacOS/Release/libGRMustache6-MacOS.a lib/libGRMustache6-MacOS.a

build/GRMustache6-iOS/Release-iphoneos/libGRMustache6-iOS.a: build/GRMustache6-iOS/Release-iphoneos

build/GRMustache6-iOS-arm64/Release-iphoneos/libGRMustache6-iOS-arm64.a: build/GRMustache6-iOS-arm64/Release-iphoneos

build/GRMustache6-iOS-simulator/Release-iphonesimulator/libGRMustache6-iOS.a: build/GRMustache6-iOS-simulator/Release-iphonesimulator

build/GRMustache6-iOS/Release-iphoneos:                                                                                                  
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache6-iOS   -configuration Release                                   build SYMROOT=../build/GRMustache6-iOS
                                                                                                                                    
build/GRMustache6-iOS-arm64/Release-iphoneos:                                                                                                  
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache6-iOS-arm64 -configuration Release                               build SYMROOT=../build/GRMustache6-iOS-arm64
                                                                                                                                    
build/GRMustache6-iOS-simulator/Release-iphonesimulator:                                                                                        
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache6-iOS   -configuration Release -sdk iphonesimulator -arch "i386" build SYMROOT=../build/GRMustache6-iOS-simulator
                                                                                                                                    
build/MacOS/Release:                                                                                                                
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache6-MacOS -configuration Release                                   build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/usr/local/include
	cp -R build/MacOS/Release/usr/local/include .

build/MacOS/Release/usr/local/include: build/MacOS/Release

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

