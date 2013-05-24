// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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
 * The GRMustacheContext represents a Mustache rendering context: it internally
 * maintains two stacks:
 *
 * - a *context stack*, that makes it able to provide the current context
 *   object, and to perform key lookup.
 * - a *tag delegate stack*, so that tag delegates are notified when a Mustache
 *   tag is rendered.
 *
 * **Companion guides:**
 *
 * - https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * - https://github.com/groue/GRMustache/blob/master/Guides/rendering_objects.md
 *
 * @see GRMustacheRendering protocol
 */
@interface GRMustacheContext : NSObject {
@private
    NSDictionary *_depthsForAncestors;
    GRMustacheContext *_contextParent;
    NSMutableDictionary *_mutableContextObject;
    id _contextObject;
    GRMustacheContext *_protectedContextParent;
    id _protectedContextObject;
    GRMustacheContext *_hiddenContextParent;
    id _hiddenContextObject;
    GRMustacheContext *_tagDelegateParent;
    id<GRMustacheTagDelegate> _tagDelegate;
    GRMustacheContext *_templateOverrideParent;
    id _templateOverride;
    NSString *_nonManagedKey;
}


////////////////////////////////////////////////////////////////////////////////
/// @name Creating Contexts
////////////////////////////////////////////////////////////////////////////////


/**
 * @return An empty rendering context.
 *
 * @since v6.4
 */
+ (instancetype)context AVAILABLE_GRMUSTACHE_VERSION_6_4_AND_LATER;

/**
 * Returns a context with _object_ at the top of the context stack.
 *
 * If _object_ conforms to the GRMustacheTemplateDelegate protocol, it is also
 * made the top of the tag delegate stack.
 *
 * If _object_ is an instance of GRMustacheContext, its class must be the class
 * of the receiver, or any subclass, and the returned context is _object.
 * An exception is raised otherwise.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param object  An object
 *
 * @return A rendering context.
 *
 * @see GRMustacheTemplateDelegate
 *
 * @since v6.4
 */
+ (instancetype)contextWithObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_4_AND_LATER;

/**
 * Returns a context with _object_ at the top of the protected context stack.
 *
 * Unlike contextWithObject:, this method does not put the object to the
 * tag delegate stack if it conforms to the GRMustacheTemplateDelegate protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/protected_context.md
 *
 * @param object  An object
 *
 * @return A rendering context.
 *
 * @since v6.4
 */
+ (instancetype)contextWithProtectedObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_4_AND_LATER;

/**
 * Returns a context with _tagDelegate_ at the top of the tag delegate stack.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param tagDelegate  A tag delegate
 *
 * @return A rendering context.
 *
 * @see GRMustacheTagDelegate
 *
 * @since v6.4
 */
+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_6_4_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Deriving New Contexts
////////////////////////////////////////////////////////////////////////////////


/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the context stack.
 *
 * If _object_ conforms to the GRMustacheTemplateDelegate protocol, it is also
 * added at the top of the tag delegate stack.
 *
 * If _object_ is an instance of GRMustacheContext, its class must be the class
 * of the receiver, or any subclass, and the returned context will be an
 * instance of the class of _object_. An exception is raised otherwise.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param object  An object
 *
 * @return A new rendering context.
 *
 * @see GRMustacheTemplateDelegate
 *
 * @since v6.0
 */
- (instancetype)contextByAddingObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the protected context stack.
 *
 * Unlike contextByAddingObject:, this method does not add the object to the
 * tag delegate stack if it conforms to the GRMustacheTemplateDelegate protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/protected_context.md
 *
 * @param object  An object
 *
 * @return A new rendering context.
 *
 * @since v6.0
 */
- (instancetype)contextByAddingProtectedObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the tag delegate stack.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @param tagDelegate  A tag delegate
 *
 * @return A new rendering context.
 *
 * @see GRMustacheTagDelegate
 *
 * @since v6.0
 */
- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Fetching Values from the Context Stack
////////////////////////////////////////////////////////////////////////////////


/**
 * Returns the value stored in the context stack for the given key.
 *
 * If you want the value for an full expression such as @"user.name" or
 * @"uppercase(user.name)", use the valueForMustacheExpression:error: method.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 *
 * @see valueForUndefinedMustacheKey:
 * @see valueForMustacheExpression:error:
 *
 * @since v6.6
 */
- (id)valueForMustacheKey:(NSString *)key AVAILABLE_GRMUSTACHE_VERSION_6_6_AND_LATER;

/**
 * This method is invoked when a key could not be resolved to any value.
 *
 * Subclasses can override this method to return an alternate value for
 * undefined keys. The default implementation returns nil.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 *
 * @see valueForMustacheKey:
 * @see valueForMustacheExpression:error:
 *
 * @since v6.7
 */
- (id)valueForUndefinedMustacheKey:(NSString *)key AVAILABLE_GRMUSTACHE_VERSION_6_7_AND_LATER;

/**
 * Evaluate the expression in the receiver context.
 *
 * This method can evaluate complex expressions such as @"user.name" or
 * @"uppercase(user.name)".
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/view_model.md
 *
 * @see valueForUndefinedMustacheKey:
 * @see valueForMustacheExpression:error:
 *
 * @since v6.6
 */
- (id)valueForMustacheExpression:(NSString *)expression error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_6_AND_LATER;

@end
