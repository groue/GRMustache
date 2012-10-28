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
#import "GRMustacheTagDelegate.h"

/**
 * The GRMustacheContext internally maintains a context stack that
 * makes it able to provide the current context object, and to perform key
 * lookup.
 *
 * TODO tag delegates
 */
@interface GRMustacheContext : NSObject {
    NSArray *_contextStack;
    NSArray *_delegateStack;
    NSArray *_templateOverrideStack;
}

/**
 * TODO
 *
 * Returns a GRMustacheContext with extended context stack. The added
 * object comes to the top of the stack.
 *
 * TODO: talk about delegate stack
 *
 * @param object  A context object
 *
 * @return A GRMustacheContext object.
 */
- (GRMustacheContext *)contextByAddingObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * TODO
 *
 * Returns a GRMustacheContext object identical to the receiver, but for the
 * delegate stack that is extended with _tagDelegate_.
 *
 * @param tagDelegate  A delegate
 *
 * @return A GRMustacheContext object.
 */
- (GRMustacheContext *)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end
