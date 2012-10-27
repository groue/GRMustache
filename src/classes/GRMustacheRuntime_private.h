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
extern BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

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
    NSArray *_contextStack;
    NSArray *_delegateStack;
    NSArray *_templateOverrideStack;
}

/**
 * Avoids most NSUndefinedException to be raised by the invocation of
 * `valueForKey:inObject:` and `valueForKey:inSuper:`.
 *
 * @see valueForKey:inObject:
 * @see valueForKey:inSuper:
 */
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_INTERNAL;

/**
 * Sends the `valueForKey:` message to _object_ with the provided _key_, and
 * returns the result.
 *
 * Should [GRMustacheRuntime preventNSUndefinedKeyExceptionAttack] method have
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
 * TODO
 */
+ (id)runtime GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheRuntime.h
- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject GRMUSTACHE_API_PUBLIC;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * delegate stack that is extended with _tagDelegate_.
 *
 * @param tagDelegate  A delegate
 *
 * @return A GRMustacheRuntime object.
 */
- (GRMustacheRuntime *)runtimeByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * template override stack that is extended with _templateOverride_.
 *
 * @param templateOverride  A template override object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see GRMustacheTemplateOverride
 * @see [GRMustacheTemplateOverride renderInBuffer:withRuntime:error:]
 */
- (GRMustacheRuntime *)runtimeByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride GRMUSTACHE_API_INTERNAL;

/**
 * Performs a key lookup in the receiver's context stack, and returns the found
 * value.
 *
 * @param key  The searched key.
 *
 * @return The value found in the context stack.
 *
 * @see -[GRMustacheIdentifierExpression evaluateInRuntime:]
 */
- (id)contextValueForKey:(NSString *)key GRMUSTACHE_API_INTERNAL;

/**
 * Returns the top object of the receiver's context stack.
 *
 * @return The top object of the receiver's context stack.
 *
 * @see -[GRMustacheImplicitIteratorExpression evaluateInRuntime:]
 */
- (id)currentContextValue GRMUSTACHE_API_INTERNAL;

/**
 * Invoke callbacks of all delegates in the delegate stack before and after
 * _object_ is rendered with _block_.
 *
 * @param object The rendered object
 * @param tag    The tag.
 * @param block  The rendering block.
 *
 * @see -[GRMustacheSectionTag renderInBuffer:withRuntime:error:]
 * @see -[GRMustacheVariableTag renderInBuffer:withRuntime:error:]
 */
- (void)renderObject:(id)object withTag:(GRMustacheTag *)tag usingBlock:(void(^)(id value))block GRMUSTACHE_API_INTERNAL;

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

@end
