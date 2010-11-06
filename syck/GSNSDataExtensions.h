/*!
    @header	GSNSDataExtensions.h
    @discussion	These methods are extensions to the standard NSData object to handle Base 64 encoding.
                NSData objects can be created from Base 64 encoded NSStrings and can generate Base 64
                encoded NSStrings.

                This code is based on a C coder/decoder originally written by Dave Winer.  See the top of
                the .m file for his original comments.

				This code includes an AltiVec implementation.  The AltiVec implementation can be turned off
				by commenting out the COMPILE_FOR_ALTIVEC definition at the top of the .m file.

				If the AltiVec implementation is not turned off, you'll need to compile with the "-faltivec"
				option enabled.  In the current version of Xcode (1.5) to enable this, select the target in
				the "Groups & Files" list, then show the info for that target.  In the "Build" tab, show the
				GNU C/C++ Compiler Language options and turn on "Enable AltiVec extensions".

    Copyright (c) 2001, 2005 Kyle Hammond. All rights reserved.
*/

#import <Foundation/Foundation.h>

@interface NSData (Base64Encoding)

/*!	@method		+isCharacterPartOfBase64Encoding:
    @discussion	This method returns YES or NO depending on whether the given character is a part of the
				Base64 encoding table.
    @param	inChar	An character in ASCII encoding.
    @result	YES if the character is a part of the Base64 encoding table.
*/
+ (BOOL)isCharacterPartOfBase64Encoding:(char)inChar;

/*!	@method		+dataWithBase64EncodedString:
    @discussion	This method returns an autoreleased NSData object.  The NSData object is initialized with the
                contents of the Base 64 encoded string.  This is a convenience function for
                -initWithBase64EncodedString:.
    @param	inBase64String	An NSString object that contains only Base 64 encoded data.
    @result	The NSData object.
*/
+ (NSData *)dataWithBase64EncodedString:(NSString *)inBase64String;

/*!	@method		-initWithBase64EncodedString:
    @discussion	The NSData object is initialized with the contents of the Base 64 encoded string.
                This method returns self as a convenience.
    @param	inBase64String	An NSString object that contains only Base 64 encoded data.
    @result	This method returns self.
*/
- (id)initWithBase64EncodedString:(NSString *)inBase64String;

/*!	@method		-base64EncodingWithLineLength:
    @discussion	This method returns a Base 64 encoded string representation of the data object.
    @param	inLineLength	A value of zero means no line breaks.  This is crunched to a multiple of 4 (the next
                            one greater than inLineLength).
    @result	The base 64 encoded data.
*/
- (NSString *)base64EncodingWithLineLength:(unsigned int)inLineLength;

@end
