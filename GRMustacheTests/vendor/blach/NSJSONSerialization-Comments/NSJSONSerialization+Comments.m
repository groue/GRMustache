//
//  NSJSONSerialization+Comments.m
//  ABCodeEditor
//
//  Created by Alexander Blach on 22.07.14.
//  Copyright (c) 2014 Alexander Blach. All rights reserved.
//

#import "NSJSONSerialization+Comments.h"


static const int EncLen_UTF8[256] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1};

static inline void copyUTF8CharacterAndAdvancePointers(UTF8Char **source, UTF8Char **target) {
    UTF8Char character = **source;
    if (__builtin_expect(character < 128, 1)) {
        // one byte UTF-8 character
        **target = **source;
        *source += 1;
        *target += 1;
    } else {
        int len = EncLen_UTF8[character];
        memcpy(*target, *source, len);
        *source += len;
        *target += len;
    }
}

static inline void skipUTF8Character(UTF8Char **source) { *source += EncLen_UTF8[**source]; }


@implementation NSJSONSerialization (Comments)

+ (NSData *)dataByStrippingJSONCommentsAndWhiteSpaceOfUTF8Data:(NSData *)data
                                                     skipBytes:(NSUInteger)bytesToSkip {
    UTF8Char *originalString = (UTF8Char *)[data bytes];
    NSUInteger length = [data length];

    UTF8Char *modifiedString = malloc(sizeof(UTF8Char) * length);

    UTF8Char *originalStringCurrent = originalString;
    UTF8Char *originalStringEnd = originalString + length;
    UTF8Char *modifiedStringCurrent = modifiedString;


    // skip bytes
    originalStringCurrent += bytesToSkip;

    while (originalStringCurrent < originalStringEnd) {
        UTF8Char currentChar = *originalStringCurrent;

        if (currentChar == '\t' || currentChar == ' ' || currentChar == '\r'
            || currentChar == '\n') {
            // skip whitespace

            // Ignore whitespace tokens. According to ES 5.1 section 15.12.1.1,
            // whitespace tokens include tabs, carriage returns, line feeds, and
            // space characters.
            originalStringCurrent++;
        } else if (currentChar == '"') {
            // we found a string! -> handle it
            *modifiedStringCurrent++ = currentChar;
            originalStringCurrent++;
					
            UTF8Char lastChar = 0;

            while (originalStringCurrent < originalStringEnd) {
                currentChar = *originalStringCurrent;

                if (currentChar == '"') {
                    *modifiedStringCurrent++ = currentChar;
                    originalStringCurrent++;

                    if (lastChar == '\\') {
                        // was escaped character -> not at string end
                    } else {
                        // arrived at end of string
                        break;
                    }
                } else if (currentChar == '\n' || currentChar == '\r') {
                    // line breaks should not happen in JSON strings!
                    *modifiedStringCurrent++ = currentChar;
                    originalStringCurrent++;
                    break;
                } else {
                    // still in string -> copy character
                    copyUTF8CharacterAndAdvancePointers(&originalStringCurrent,
                                                        &modifiedStringCurrent);
                }
                lastChar = currentChar;
            }
        } else if (currentChar == '/' && originalStringCurrent + 1 < originalStringEnd) {
            // maybe we have a single-line or multi-line comment
            UTF8Char nextChar = *(originalStringCurrent + 1);

            if (nextChar == '/') {
                // single line comment
                originalStringCurrent += 2;

                while (originalStringCurrent < originalStringEnd) {
                    char currentChar = *originalStringCurrent;

                    if (currentChar == '\r' || currentChar == '\n') {
                        // at end of line -> comment end
                        break;
                    } else {
                        // skip
                        skipUTF8Character(&originalStringCurrent);
                    }
                }
            } else if (nextChar == '*') {
                // multi line comment
                originalStringCurrent += 2;

                while (originalStringCurrent < originalStringEnd) {
                    char currentChar = *originalStringCurrent;

                    if (currentChar == '*') {
                        originalStringCurrent++;

                        if (originalStringCurrent < originalStringEnd) {
                            currentChar = *originalStringCurrent;
                            if (currentChar == '/') {
                                // comment end!
                                originalStringCurrent++;
                                break;
                            }
                        }
                    } else {
                        // skip
                        skipUTF8Character(&originalStringCurrent);
                    }
                }
            } else {
                // nope, no comment, just copy the character
                *modifiedStringCurrent++ = currentChar;
                originalStringCurrent++;
            }
        } else {
            // copy character as is
            copyUTF8CharacterAndAdvancePointers(&originalStringCurrent, &modifiedStringCurrent);
        }
    }

    NSUInteger modifiedStringLength = modifiedStringCurrent - modifiedString;

    if (modifiedStringLength != length) {
        modifiedString = realloc(modifiedString, sizeof(UTF8Char) * modifiedStringLength);
        return [NSData dataWithBytesNoCopy:modifiedString
                                    length:modifiedStringLength
                              freeWhenDone:YES];
    } else {
        free(modifiedString);
        return data;
    }
}


+ (id)JSONObjectWithCommentedUTF8Data:(NSData *)data
                              options:(NSJSONReadingOptions)opt
                                error:(NSError **)error {
    NSData *strippedData =
        [self dataByStrippingJSONCommentsAndWhiteSpaceOfUTF8Data:data skipBytes:0];

    // NSLog(@"before:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    // NSLog(@"after:\n%@", [[NSString alloc] initWithData:strippedData
    // encoding:NSUTF8StringEncoding]);

    return [self JSONObjectWithData:strippedData options:opt error:error];
}


+ (NSStringEncoding)stringEncodingFromData:(NSData *)data detectedBOMSize:(NSUInteger *)bomSize {
    NSStringEncoding encoding = 0;
    if (bomSize) {
        *bomSize = 0;
    }

    NSUInteger fileSize = [data length];

    // try to get from BOM
    if (fileSize >= 2) {
        UInt8 *bomBuffer = (UInt8 *)[data bytes];

        // go back to start of file
        if (fileSize >= 2 && fileSize % 2 == 0) {
            // even amount of bytes? could be UTF-16 or UTF-32
            if (bomBuffer[0] == 0xFE && bomBuffer[1] == 0xFF) {
                // Big Endian
                encoding = NSUTF16StringEncoding;
                if (bomSize) {
                    *bomSize = 2;
                }
            } else if (bomBuffer[0] == 0xFF && bomBuffer[1] == 0xFE) {
                // Little Endian
                encoding = NSUTF16StringEncoding;
                if (bomSize) {
                    *bomSize = 2;
                }
            } else if (fileSize >= 4) {
                if (bomBuffer[0] == 0x00 && bomBuffer[1] == 0x00 && bomBuffer[2] == 0xFE
                    && bomBuffer[3] == 0xFF) {
                    // Big Endian
                    encoding = NSUTF32StringEncoding;
                    if (bomSize) {
                        *bomSize = 4;
                    }
                } else if (bomBuffer[0] == 0xFF && bomBuffer[1] == 0xFE && bomBuffer[2] == 0x00
                           && bomBuffer[3] == 0x00) {
                    // Little Endian
                    encoding = NSUTF32StringEncoding;
                    if (bomSize) {
                        *bomSize = 4;
                    }
                }
            }
        }

        if (!encoding) {
            if (fileSize >= 3) {
                if (bomBuffer[0] == 0xEF && bomBuffer[1] == 0xBB && bomBuffer[2] == 0xBF) {
                    encoding = NSUTF8StringEncoding;
                    if (bomSize) {
                        *bomSize = 3;
                    }
                }
            }
        }
    }

    return encoding;
}

+ (id)JSONObjectWithCommentedData:(NSData *)data
                          options:(NSJSONReadingOptions)opt
                            error:(NSError **)error {
    if (data) {
        NSUInteger bomSize = 0;
        NSStringEncoding encoding = [self stringEncodingFromData:data detectedBOMSize:&bomSize];

        if (encoding == 0 || // assume UTF-8 if no BOM is detected
            encoding == NSUTF8StringEncoding) {
            // we can use the data as is, because it is already UTF-8
        } else {
            // convert to UTF-8 first
            NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
            if (!string) {
                if (error) {
                    // use the same error description, domain, and code as NSJSONSerialization
                    *error =
                        [NSError errorWithDomain:NSCocoaErrorDomain
                                            code:0xf00
                                        userInfo:@{
                                            (NSString *)kCFErrorDescriptionKey :
                                                @"Unable to convert data to a string using the "
                                            @"detected encoding. The data may be corrupt."
                                                }];
                }
				return nil;
            } else {
                data = [string dataUsingEncoding:NSUTF8StringEncoding];
                bomSize = 0;
            }
        }

        return [self JSONObjectWithCommentedUTF8Data:data options:opt error:error];
    } else {
        return nil;
    }
}


+ (id)JSONObjectWithCommentedContentsOfURL:(NSURL *)url
                                   options:(NSJSONReadingOptions)opt
                                     error:(NSError **)error {
    // load data from URL
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
    return [self JSONObjectWithCommentedData:data options:opt error:error];
}

+ (id)JSONObjectWithCommentedContentsOfFile:(NSString *)path
                                    options:(NSJSONReadingOptions)opt
                                      error:(NSError **)error {
    // load data from file
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:error];

    return [self JSONObjectWithCommentedData:data options:opt error:error];
}

+ (id)JSONObjectWithCommentedString:(NSString *)string
                            options:(NSJSONReadingOptions)opt
                              error:(NSError **)error {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self JSONObjectWithCommentedUTF8Data:data options:opt error:error];
}

+ (NSString *)stringWithJSONObject:(id)obj
                           options:(NSJSONWritingOptions)opt
                             error:(NSError **)error {
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    if (data) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        return string;
    } else {
        return nil;
    }
}

@end
