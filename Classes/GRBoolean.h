// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"

/**
 The GRYes class provides with a singleton which you can use as a true value
 when controlling Mustache boolean sections.
 
 This singleton object is safer and less ambiguous than [NSNumber numberWithBool:YES],
 which GRMustache essentially considers as the integer 1.
 
 @see GRYes#yes
 @see GRMustache#strictBooleanMode
 @see GRNo
 @since v1.0.0
 */
@interface GRYes : NSObject <NSCopying>
/**
 @deprecated Use `[NSNumber numberWithBool:YES]` instead.
 @returns the GRYes singleton.
 @since v1.0.0
 */
+ (GRYes *)yes AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_2;

/**
 @returns YES
 @since v1.1.0
 */
- (BOOL)boolValue AVAILABLE_GRMUSTACHE_VERSION_1_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_2;
@end


/**
 The GRNo class provides with a singleton which you can use as a false value
 when controlling Mustache boolean sections.
 
 This singleton object is safer and less ambiguous than [NSNumber numberWithBool:NO],
 which GRMustache essentially considers as the integer 0, and not as a false
 value.
 
 @see GRNo#no
 @see GRMustache#strictBooleanMode
 @see GRYes
 @since v1.0.0
 */
@interface GRNo : NSObject <NSCopying>
/**
 @deprecated Use `[NSNumber numberWithBool:NO]` instead.
 @returns the GRNo singleton.
 @since v1.0.0
 */
+ (GRNo *)no AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_2;

/**
 @returns NO
 @since v1.1.0
 */
- (BOOL)boolValue AVAILABLE_GRMUSTACHE_VERSION_1_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_2;
@end
