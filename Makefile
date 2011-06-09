SYMROOTROOT=build
DSTROOT=.
CONFIGURATION=Release
IOS3_SDK_PATH="/XCode4.2/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneOS3.1.3.sdk"

default:
	# build for iOS3+ device
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration ${CONFIGURATION}                         -arch "armv6 armv7" build SYMROOT=${SYMROOTROOT}/iphoneos3
	# build for iOS3+ simulator
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1-ios3 -configuration ${CONFIGURATION} -sdk iphonesimulator4.3 -arch "i386"        build SYMROOT=${SYMROOTROOT}/iphonesimulator3
	# build for iOS4+ device
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration ${CONFIGURATION}                         -arch "armv6 armv7" build SYMROOT=${SYMROOTROOT}/iphoneos4
	# build for iOS4+ simulator
	xcodebuild -project GRMustache1-ios.xcodeproj    -target GRMustache1      -configuration ${CONFIGURATION} -sdk iphonesimulator4.3 -arch "i386"        build SYMROOT=${SYMROOTROOT}/iphonesimulator4
	# build for MacOSX
	xcodebuild -project GRMustache1-macosx.xcodeproj -target GRMustache1      -configuration ${CONFIGURATION} -sdk macosx             -arch "i386 x86_64" build SYMROOT=${SYMROOTROOT}/macosx10.6
	mkdir -p ${DSTROOT}/lib
	lipo -create \
		"${SYMROOTROOT}/iphonesimulator4/${CONFIGURATION}-iphonesimulator/libGRMustache1.a" \
		"${SYMROOTROOT}/iphoneos4/${CONFIGURATION}-iphoneos/libGRMustache1.a" \
		-output "${DSTROOT}/lib/libGRMustache1-ios4.a"
	lipo -create \
		"${SYMROOTROOT}/iphonesimulator3/${CONFIGURATION}-iphonesimulator/libGRMustache1-ios3.a" \
		"${SYMROOTROOT}/iphoneos3/${CONFIGURATION}-iphoneos/libGRMustache1-ios3.a" \
		-output "${DSTROOT}/lib/libGRMustache1-ios3.a"
	mv ${SYMROOTROOT}/macosx10.6/${CONFIGURATION}/libGRMustache1.a ${DSTROOT}/lib/libGRMustache1-macosx10.6.a
	rm -rf ${DSTROOT}/include
	mkdir -p ${DSTROOT}/include
	mv ${SYMROOTROOT}/iphoneos4/${CONFIGURATION}-iphoneos/include/* ${DSTROOT}/include
