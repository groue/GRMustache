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
#import "GRMustacheTemplateDelegate.h"

@protocol GRMustacheTemplateDelegate;
@protocol GRMustacheRenderingElement;
@class GRMustacheTemplate;
@class GRMustacheToken;
@class GRMustacheTemplateOverride;

#if !defined(NS_BLOCK_ASSERTIONS)
/**
 * This global variable is used by GRPreventNSUndefinedKeyExceptionAttackTest.
 */
extern BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

/**
 * The GRMustacheRuntime responsability is to provide a runtime context for
 * Mustache rendering. It internally maintains three stacks:
 *
 * - a context stack,
 * - a filter stack,
 * - a delegate stack.
 *
 * As such, it is able to:
 *
 * - provide the current context object.
 * - perform a key lookup in the context stack.
 * - perform a key lookup in the filter stack.
 * - let template and section delegates interpret rendered values.
 */
@interface GRMustacheRuntime : NSObject {
    BOOL _parentHasContext;
    BOOL _parentHasFilter;
    BOOL _parentHasTemplateDelegate;
    BOOL _parentHasTemplateOverride;
    GRMustacheRuntime *_parent;
    GRMustacheTemplate *_template;
    id<GRMustacheTemplateDelegate> _templateDelegate;
    GRMustacheTemplateOverride *_templateOverride;
    id _contextObject;
    id _filterObject;
}

/**
 * Triggers the trick for avoiding most NSUndefinedException to be raised
 * by the invocation of `valueForKey:` method on user's objects.
 *
 * @see GRMustacheNSUndefinedKeyExceptionGuard
 */
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_INTERNAL;

/**
 * Sends the `valueForKey:` message to _object_ with the provided _key_, and
 * returns the result. Should `valueForKey:` raise an NSUndefinedKeyException,
 * returns nil.
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
 * Returns a GRMustacheRuntime object whose:
 *
 * - context stack is empty,
 * - delegate stack is empty,
 * - filter stack is initialized with the filter library.
 *
 * This method is only used by GRMustacheRuntimeTest.
 *
 * @return A GRMustacheRuntime object.
 *
 * @see GRMustacheFilterLibrary
 */
+ (id)runtime GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object whose:
 *
 * - context stack is initialized with _contextObject_,
 * - delegate stack is initialized with _template_'s delegate,
 * - filter stack is initialized with the filter library.
 *
 * @param template       a template
 * @param contextObject  a context object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see GRMustacheFilterLibrary
 * @see -[GRMustacheTemplate renderObject:withFilters:]
 */
+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObject:(id)contextObject GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object whose:
 *
 * - context stack is initialized with objects in _contextObjects_,
 * - delegate stack is initialized with _template_'s delegate,
 * - filter stack is initialized with the filter library.
 *
 * @param template       a template
 * @param contextObject  a context object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see GRMustacheFilterLibrary
 * @see -[GRMustacheTemplate renderObjectsFromArray:withFilters:]
 */
+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObjects:(NSArray *)contextObjects GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * delegate stack that is extended with _templateDelegate_.
 *
 * @param templateDelegate  A delegate
 *
 * @return A GRMustacheRuntime object.
 *
 * @see -[GRMustacheSectionElement renderInBuffer:withRuntime:]
 */
- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * context stack that is extended with _contextObject_.
 *
 * @param contextObject  A context object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see -[GRMustacheSectionElement renderInBuffer:withRuntime:]
 */
- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheRuntime object identical to the receiver, but for the
 * filter stack that is extended with _filterObject_.
 *
 * @param filterObject  A filter object
 *
 * @return A GRMustacheRuntime object.
 *
 * @see -[GRMustacheTemplate renderObject:withFilters:]
 * @see -[GRMustacheTemplate renderObjectsFromArray:withFilters:]
 */
- (GRMustacheRuntime *)runtimeByAddingFilterObject:(id)filterObject GRMUSTACHE_API_INTERNAL;

/**
 * TODO
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
 * @see -[GRMustacheIdentifierExpression evaluateInRuntime:asFilterValue:]
 */
- (id)contextValueForKey:(NSString *)key GRMUSTACHE_API_INTERNAL;

/**
 * Performs a key lookup in the receiver's filter stack, and returns the found
 * value.
 *
 * @param key  The searched key.
 *
 * @return The value found in the filter stack.
 *
 * @see -[GRMustacheIdentifierExpression evaluateInRuntime:asFilterValue:]
 */
- (id)filterValueForKey:(NSString *)key GRMUSTACHE_API_INTERNAL;

/**
 * Returns the top object of the receiver's context stack.
 *
 * @return The top object of the receiver's context stack.
 *
 * @see -[GRMustacheImplicitIteratorExpression evaluateInRuntime:asFilterValue:]
 */
- (id)currentContextValue GRMUSTACHE_API_INTERNAL;

/**
 * Invoke callbacks of all delegates in the delegate stack before and after
 * _value_ is rendered with _block_.
 *
 * @param value           The interpreted value.
 * @param interpretation  The value interpretation.
 * @param token           A token used for building GRMustacheInvocation
 *                        objects.
 * @param block           The rendering block.
 *
 * @see -[GRMustacheSectionElement renderInBuffer:withRuntime:]
 * @see -[GRMustacheVariableElement renderInBuffer:withRuntime:]
 */
- (void)delegateValue:(id)value interpretation:(GRMustacheInterpretation)interpretation forRenderingToken:(GRMustacheToken *)token usingBlock:(void(^)(id value))block GRMUSTACHE_API_INTERNAL;

/**
 * TODO
 */
- (id<GRMustacheRenderingElement>)resolveRenderingElement:(id<GRMustacheRenderingElement>)element GRMUSTACHE_API_INTERNAL;

@end
