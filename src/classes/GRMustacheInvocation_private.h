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
#import "GRMustache_private.h"

@class GRMustacheContext;
@class GRMustacheToken;

/**
 * The GRMustacheInvocation class is the NSInvocation of GRMustache.
 *
 * Whenever Mustache has to render, say, a tag such as `{{foo.bar}}`, it has
 * to invoke the `foo` key in the current context stack, then the `bar` key, and
 * render the returned value.
 *
 * The GRMustacheInvocation encapsulates this whole process.
 * 
 * Instances are created by GRMustacheTemplateParser, and stored by rendering
 * elements that query the user data: GRMustacheVariableElement and
 * GRMustacheSection.
 *
 * A rendering element would send the `invokeWithContext:` message to its
 * invocation. The invocation would perform the key lookup in the context stack,
 * and set its return value. The rendering element would the process this return
 * value.
 *
 * Invocations are exposed to the template's delegate: library users can modify
 * the return value of invocations, and alter the template rendering.
 *
 * @see GRMustacheTemplateParser
 * @see GRMustacheVariableElement
 * @see GRMustacheSection
 * @see GRMustacheTemplateDelegate
 */
@interface GRMustacheInvocation : NSObject {
@private
    id _returnValue;
    GRMustacheToken *_token;
}

// Documented in GRMustacheInvocation.h
@property (nonatomic, readonly) NSString *key GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheInvocation.h
@property (nonatomic, retain) id returnValue GRMUSTACHE_API_PUBLIC;

/**
 * Builds an invocation from a token and an array of keys.
 *
 * For a token content @"foo", the keys would contain a single @"foo" string.
 *
 * For a token content @"foo.bar", the keys would contain @"foo" and "bar".
 *
 * For a token content @".", the keys would contain a single @"." string.
 *
 * For a token content @".foo", the keys would contain @"." and "foo".
 *
 * The _keys_ parameter fully determines the behavior of the
 * `invokeWithContext:` method.
 *
 * The _token_ argument is solely used by the `description` method of the
 * invocation, so that the library user can easily locate the source of an
 * invocation in his template delegate methods.
 *
 * @param token   A token
 * @param keys    An array of keys
 *
 * @return an invocation
 *
 * @see invokeWithContext:
 * @see GRMustacheToken
 * @see GRMustacheTemplateDelegate
 */
+ (id)invocationWithToken:(GRMustacheToken *)token keys:(NSArray *)keys GRMUSTACHE_API_INTERNAL;

/**
 * Performs key lookup in the context stack, and sets the return value.
 *
 * @param context   The context stack where invocation keys should be looked up.
 *
 * @see GRMustacheContext
 */
- (void)invokeWithContext:(GRMustacheContext *)context GRMUSTACHE_API_INTERNAL;
@end
