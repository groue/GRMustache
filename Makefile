all: lib/libGRMustache2-iOS3.a lib/libGRMustache2-iOS.a lib/libGRMustache2-MacOS.a include/GRMustache.h

lib/libGRMustache2-iOS3.a: build/iOS3-device/Release-iphoneos/libGRMustache2-iOS3.a build/iOS3-simulator/Release-iphonesimulator/libGRMustache2-iOS3.a
	mkdir -p lib
	lipo -create \
	  "build/iOS3-simulator/Release-iphonesimulator/libGRMustache2-iOS3.a" \
	  "build/iOS3-device/Release-iphoneos/libGRMustache2-iOS3.a" \
	  -output "lib/libGRMustache2-iOS3.a"

lib/libGRMustache2-iOS.a: build/iOS-device/Release-iphoneos/libGRMustache2-iOS.a build/iOS-simulator/Release-iphonesimulator/libGRMustache2-iOS.a
	mkdir -p lib
	lipo -create \
	  "build/iOS-simulator/Release-iphonesimulator/libGRMustache2-iOS.a" \
	  "build/iOS-device/Release-iphoneos/libGRMustache2-iOS.a" \
	  -output "lib/libGRMustache2-iOS.a"

lib/libGRMustache2-MacOS.a: build/MacOS/Release
	mkdir -p lib
	cp build/MacOS/Release/libGRMustache2-MacOS.a lib/libGRMustache2-MacOS.a

build/iOS3-device/Release-iphoneos/libGRMustache2-iOS3.a: build/iOS3-device/Release-iphoneos

build/iOS3-simulator/Release-iphonesimulator/libGRMustache2-iOS3.a: build/iOS3-simulator/Release-iphonesimulator

build/iOS-device/Release-iphoneos/libGRMustache2-iOS.a: build/iOS-device/Release-iphoneos

build/iOS-simulator/Release-iphonesimulator/libGRMustache2-iOS.a: build/iOS-simulator/Release-iphonesimulator

build/iOS3-device/Release-iphoneos:
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache2-iOS3  -configuration Release                                   build SYMROOT=../build/iOS3-device
                                                                                                                                    
build/iOS3-simulator/Release-iphonesimulator:                                                                                       
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache2-iOS3  -configuration Release -sdk iphonesimulator -arch "i386" build SYMROOT=../build/iOS3-simulator
                                                                                                                                    
build/iOS-device/Release-iphoneos:                                                                                                  
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache2-iOS   -configuration Release                                   build SYMROOT=../build/iOS-device
                                                                                                                                    
build/iOS-simulator/Release-iphonesimulator:                                                                                        
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache2-iOS   -configuration Release -sdk iphonesimulator -arch "i386" build SYMROOT=../build/iOS-simulator
                                                                                                                                    
build/MacOS/Release:                                                                                                                
	xcodebuild -project src/GRMustache.xcodeproj -target GRMustache2-MacOS -configuration Release                                   build SYMROOT=../build/MacOS

include/GRMustache.h: build/MacOS/Release/usr/local/include
	cp -R build/MacOS/Release/usr/local/include .

build/MacOS/Release/usr/local/include: build/MacOS/Release

clean:
	rm -rf build
	rm -rf include
	rm -rf lib

