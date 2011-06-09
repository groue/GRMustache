SYMROOTROOT=build
DSTROOT=.
CONFIGURATION=Release

default:
	xcodebuild -project GRMustache1-ios.xcodeproj   -target GRMustache1 -configuration ${CONFIGURATION}                         -arch "armv6 armv7" build SYMROOT=${SYMROOTROOT}/iphoneos
	xcodebuild -project GRMustache1-ios.xcodeproj   -target GRMustache1 -configuration ${CONFIGURATION} -sdk iphonesimulator4.3 -arch "i386"        build SYMROOT=${SYMROOTROOT}/iphonesimulator
	xcodebuild -project GRMustache1-macos.xcodeproj -target GRMustache1 -configuration ${CONFIGURATION} -sdk macosx             -arch "i386 x86_64" build SYMROOT=${SYMROOTROOT}/macosx
	lipo -create \
		"${SYMROOTROOT}/iphonesimulator/${CONFIGURATION}-iphonesimulator/libGRMustache1.a" \
		"${SYMROOTROOT}/iphoneos/${CONFIGURATION}-iphoneos/libGRMustache1.a" \
		-output "${SYMROOTROOT}/iphoneos/${CONFIGURATION}-iphoneos/libGRMustache1-ios.a"
	mkdir -p ${DSTROOT}/lib
	mv ${SYMROOTROOT}/iphoneos/${CONFIGURATION}-iphoneos/libGRMustache1-ios.a ${DSTROOT}/lib
	mv ${SYMROOTROOT}/iphoneos/${CONFIGURATION}-macosx/libGRMustache1-macosx.a ${DSTROOT}/lib
	rm -rf ${DSTROOT}/include
	mkdir -p ${DSTROOT}/include
	mv ${SYMROOTROOT}/iphoneos/${CONFIGURATION}-iphoneos/include/* ${DSTROOT}/include
