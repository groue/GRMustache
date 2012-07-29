// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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


// =============================================================================
#pragma mark - <GRMustacheFilter>

/**
 * TODO
 */
extern NSString * const GRMustacheFilterException;

/**
 * TODO
 */
@protocol GRMustacheFilter <NSObject>
@required

/**
 * TODO
 */
- (id)transformedValue:(id)object AVAILABLE_GRMUSTACHE_VERSION_4_3_AND_LATER;

@end



// =============================================================================
#pragma mark - GRMustacheFilter

/**
 * TODO
 */
@interface GRMustacheFilter : NSObject<GRMustacheFilter>

#if NS_BLOCKS_AVAILABLE

/**
 * TODO
 */
+ (id)filterWithBlock:(id(^)(id value))block AVAILABLE_GRMUSTACHE_VERSION_4_3_AND_LATER;

#endif /* if NS_BLOCKS_AVAILABLE */

@end
