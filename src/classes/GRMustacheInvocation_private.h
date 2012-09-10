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

@class GRMustacheToken;

// Documented in GRMustacheInvocation.h
@interface GRMustacheInvocation : NSObject {
@private
    id _returnValue;
    GRMustacheToken *_token;
}

/**
 * The getter of this property is documented in GRMustacheInvocation.h.
 *
 * The setter allow GRMustacheExpression objects to prepare invocations.
 *
 * @see GRMustacheExpression
 */
@property (nonatomic, retain) id returnValue GRMUSTACHE_API_PUBLIC;

/**
 * The debugging token of an invocation allows an invocation to build a
 * meaningful description like "`{{ foo }}` at line 12 of /path/to/template".
 */
@property (nonatomic, retain) GRMustacheToken *token GRMUSTACHE_API_INTERNAL;

@end
