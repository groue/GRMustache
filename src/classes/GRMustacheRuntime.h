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

#import <objc/message.h>
#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"
#import "GRMustacheTemplateDelegate.h"

@protocol GRMustacheTemplateDelegate;
@protocol GRMustacheTemplateComponent;
@class GRMustacheTemplate;
@class GRMustacheToken;
@class GRMustacheTemplateOverride;

/**
 * The GRMustacheRuntime responsability is to provide a runtime context for
 * Mustache rendering. It internally maintains the following stacks:
 *
 * - a context stack,
 * - a delegate stack,
 * - a template override stack.
 *
 * As such, it is able to:
 *
 * - provide the current context object.
 * - perform a key lookup in the context stack.
 * - let template and tag delegates interpret rendered values.
 * - let partial templates override template components.
 */
@interface GRMustacheRuntime : NSObject {
    GRMustacheTemplate *_template;
    NSArray *_contextStack;
    NSArray *_delegateStack;
    NSArray *_templateOverrideStack;
}

/**
 * TODO
 */
+ (id)runtime AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * context stack that is extended with _contextObject_.
 *
 * TODO: talk about delegate stack
 *
 * @param contextObject  A context object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see -[GRMustacheSection renderInBuffer:withRuntime:]
 */
- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end
