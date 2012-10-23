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
#import "GRMustacheAvailabilityMacros_private.h"


// Documented in GRMustacheFilter.h
@protocol GRMustacheFilter <NSObject>
@required

// Documented in GRMustacheFilter.h
- (id)transformedValue:(id)object GRMUSTACHE_API_PUBLIC;

@optional

/**
 * Applies some transformation to its input, and returns the transformed value.
 *
 * @param object         An object to be processed by the filter.
 * @param allowCurrying  If NO, curried filters such as
 *                       GRMustacheBlockVariadicFilter must returned a resolved
 *                       value, not another filter.
 *
 * @return A transformed value.

 */
- (id)transformedValue:(id)object allowCurrying:(BOOL)allowCurrying GRMUSTACHE_API_INTERNAL;
@end


// Documented in GRMustacheFilter.h
@interface GRMustacheFilter : NSObject<GRMustacheFilter>

// Documented in GRMustacheFilter.h
+ (id)filterWithBlock:(id(^)(id value))block GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheFilter.h
+ (id)variadicFilterWithBlock:(id(^)(NSArray *arguments))block GRMUSTACHE_API_PUBLIC;

@end
