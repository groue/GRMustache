all: lib/libGRMustache4-iOS.a lib/libGRMustache4-MacOS.a include/GRMustache.h

lib/libGRMustache4-iOS.a: build/iOS-device/Release-iphoneos/libGRMustache4-iOS.a build/iOS-simulator/Release-iphonesimulator/libGRMustache4-iOS.a
	mkdir -p lib
	lipo -create \
	  "build/iOS-simulator/Release-iphonesimulator/libGRMustache4-iOS.a" \
	  "build/iOS-device/Release-iphoneos/libGRMustache4-iOS.a" \
	  -output "lib/libGRMustache4-iOS.a"

lib/libGRMustache4-MacOS.a: build/MacOS/Release
	mkdir -p lib
	cp build/MacOS/Release/libGRMustache4-MacOS.a lib/libGRMustache4-MacOS.a

build/iOS-device/Release-iphoneos/libGRMustache4-iOS.a: build/iOS-device/Release-iphoneos

build/iOS-simulator/Release-iphonesimulator/libGRMustache4-iOS.a: build/iOS-simulator/Release-iphonesimulator

build/iOS-device/Release-iphoneos:                                                                                                  
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache4-iOS   -configuration Release                                   build SYMROOT=../build/iOS-device
                                                                                                                                    
build/iOS-simulator/Release-iphonesimulator:                                                                                        
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache4-iOS   -configuration Release -sdk iphonesimulator -arch "i386" build SYMROOT=../build/iOS-simulator
                                                                                                                                    
build/MacOS/Release:                                                                                                                
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache4-MacOS -configuration Release                                   build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/usr/local/include
	cp -R build/MacOS/Release/usr/local/include .

build/MacOS/Release/usr/local/include: build/MacOS/Release

clean:
	rm -rf build
	rm -rf include
	rm -rf lib

