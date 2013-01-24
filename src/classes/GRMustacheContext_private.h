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
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheTagDelegate.h"

@protocol GRMustacheTagDelegate;
@protocol GRMustacheTemplateComponent;
@class GRMustacheTemplateOverride;

#if !defined(NS_BLOCK_ASSERTIONS)
/**
 * This global variable is used by GRPreventNSUndefinedKeyExceptionAttackTest.
 */
extern BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

/**
 * The GRMustacheContext maintains the following stacks:
 *
 * - a context stack,
 * - a protected context stack,
 * - a hidden context stack,
 * - a tag delegate stack,
 * - a template override stack.
 *
 * As such, it is able to:
 *
 * - Provide the current context object (the top of the context stack).
 *
 * - Perform a key lookup, starting with the protected context stack, then
 *   looking in the context stack, avoiding objects in the hidden context stack.
 *
 *   For a full discussion of the interaction between the protected and the
 *   hidden stacks, see the implementation of
 *   [GRMustacheTag renderHTML:inBuffer:withContext:error:].
 *
 * - Let tag delegates interpret rendered values.
 *
 * - Let partial templates override template components.
 */
@interface GRMustacheContext : NSObject {
@private
    GRMustacheContext *_contextParent;
    id _contextObject;
    GRMustacheContext *_protectedContextParent;
    id _protectedContextObject;
    GRMustacheContext *_hiddenContextParent;
    id _hiddenContextObject;
    GRMustacheContext *_tagDelegateParent;
    id<GRMustacheTagDelegate> _tagDelegate;
    GRMustacheContext *_templateOverrideParent;
    GRMustacheTemplateOverride *_templateOverride;
}

/**
 * Avoids most NSUndefinedException to be raised by the invocation of
 * `valueForKey:inObject:`.
 *
 * @see valueForKey:inObject:
 */
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_INTERNAL;

/**
 * Sends the `valueForKey:` message to _object_ with the provided _key_, and
 * returns the result.
 *
 * Should [GRMustacheContext preventNSUndefinedKeyExceptionAttack] method have
 * been called earlier, temporarily swizzle _object_ so that most
 * NSUndefinedKeyException are avoided.
 * 
 * Should `valueForKey:` raise an NSUndefinedKeyException, returns nil.
 *
 * @param key     The searched key
 * @param object  The queried object
 *
 * @return `[object valueForKey:key]`, or nil should an NSUndefinedKeyException
 *         be raised.
 *
 * @see preventNSUndefinedKeyExceptionAttack
 */
+ (id)valueForKey:(NSString *)key inObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * @return A new GRMustacheContext instance, prefilled with the filter library.
 */
+ (id)context GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheContext.h
- (GRMustacheContext *)contextByAddingObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (GRMustacheContext *)contextByAddingProtectedObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (GRMustacheContext *)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_PUBLIC;

/**
 * Returns a GRMustacheContext object identical to the receiver, but for the
 * hidden object stack that is extended with _object_.
 *
 * Hidden objects can not be queried by the contextValueForKey:protected:
 * method.
 *
 * @param object  An object that should be hidden.
 *
 * @return A GRMustacheContext object.
 *
 * @see [GRMustacheContext contextValueForKey:protected:]
 */
- (GRMustacheContext *)contextByAddingHiddenObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheContext object identical to the receiver, but for the
 * template override stack that is extended with _templateOverride_.
 *
 * @param templateOverride  A template override object
 *
 * @return A GRMustacheContext object.
 *
 * @see GRMustacheTemplateOverride
 * @see [GRMustacheTemplateOverride renderWithContext:inBuffer:error:]
 */
- (GRMustacheContext *)contextByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride GRMUSTACHE_API_INTERNAL;

/**
 * Performs a key lookup in the receiver's context stack, and returns the found
 * value.
 *
 * @param key        The searched key.
 * @param protected  Upon return, is YES if the value comes from the protected
 *                   context stack.
 *
 * @return The value found in the context stack.
 *
 * @see -[GRMustacheIdentifierExpression valueWithContext:]
 */
- (id)contextValueForKey:(NSString *)key protected:(BOOL *)protected GRMUSTACHE_API_INTERNAL;

/**
 * Returns the top object of the receiver's context stack.
 *
 * @return The top object of the receiver's context stack.
 *
 * @see -[GRMustacheImplicitIteratorExpression valueWithContext:]
 */
- (id)currentContextValue GRMUSTACHE_API_INTERNAL;

/**
 * In the context of overridable partials, return the component that should be
 * rendered in lieu of _component_, should _component_ be overriden by another
 * component.
 *
 * @param component  A template component
 *
 * @return The resolution of the component in the context of Mustache
 *         overridable partials.
 */
- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component GRMUSTACHE_API_INTERNAL;

/**
 * Executes a given block using each tag delegate in the tag delegate stack.
 *
 * @param block  The block to apply to tag delegates.
 */
- (void)enumerateTagDelegatesUsingBlock:(void(^)(id<GRMustacheTagDelegate> tagDelegate))block GRMUSTACHE_API_INTERNAL;
@end
