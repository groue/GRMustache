// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

@protocol GRMustacheTagDelegate;
@protocol GRMustacheTemplateComponent;
@class GRMustachePartialOverride;

/**
 * The GRMustacheContext maintains the following stacks:
 *
 * - a context stack,
 * - a protected context stack,
 * - a hidden context stack,
 * - a tag delegate stack,
 * - a partial override stack.
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
 *   [GRMustacheTag renderContentType:inBuffer:withContext:error:].
 *
 * - Let tag delegates interpret rendered values.
 *
 * - Let partial templates override template components.
 */
@interface GRMustacheContext : NSObject {
@private
    // Context stack
    //
    // The top of the stack is the pair (_contextObject, _managedPropertiesStore).
    // Both of them may be nil.
    // The rest of the stack is _contextParent.
    GRMustacheContext *_contextParent;
    id _contextObject;
    NSMutableDictionary *_managedPropertiesStore;
    
    // Protected context stack
    //
    // If _protectedContextObject is nil, the stack is empty.
    // If _protectedContextObject is not nil, the top of the stack is _protectedContextObject, and the rest of the stack is _protectedContextParent.
    GRMustacheContext *_protectedContextParent;
    id _protectedContextObject;
    
    // Hidden context stack
    //
    // If _hiddenContextObject is nil, the stack is empty.
    // If _hiddenContextObject is not nil, the top of the stack is _hiddenContextObject, and the rest of the stack is _hiddenContextParent.
    GRMustacheContext *_hiddenContextParent;
    id _hiddenContextObject;
    
    // Tag delegate stack
    //
    // If _tagDelegate is nil, the stack is empty.
    // If _tagDelegate is not nil, the top of the stack is _tagDelegate, and the rest of the stack is _tagDelegateParent.
    GRMustacheContext *_tagDelegateParent;
    id<GRMustacheTagDelegate> _tagDelegate;
    
    // Partial override stack
    //
    // If _partialOverride is nil, the stack is empty.
    // If _partialOverride is not nil, the top of the stack is _partialOverride, and the rest of the stack is _partialOverrideParent.
    GRMustacheContext *_partialOverrideParent;
    GRMustachePartialOverride *_partialOverride;

    NSDictionary *_depthsForAncestors;
}

// Documented in GRMustacheContext.h
+ (instancetype)context GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
+ (instancetype)contextWithObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
+ (instancetype)contextWithProtectedObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (instancetype)contextByAddingObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (instancetype)contextByAddingProtectedObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (id)valueForMustacheExpression:(NSString *)expression error:(NSError **)error GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

// Documented in GRMustacheContext.h
- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)expression error:(NSError **)error GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (id)valueForMustacheKey:(NSString *)key GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
- (id)valueForUndefinedMustacheKey:(NSString *)key GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheContext.h
// @see -[GRMustacheImplicitIteratorExpression hasValue:withContext:protected:error:]
@property (nonatomic, readonly) id topMustacheObject GRMUSTACHE_API_PUBLIC;

/**
 * Same as [parent contextByAddingObject:object], but returns a retained object.
 * This method helps efficiently managing memory, and targeting slow methods.
 */
+ (instancetype)newContextWithParent:(GRMustacheContext *)parent addedObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheContext object identical to the receiver, but for the
 * hidden object stack that is extended with _object_.
 *
 * Hidden objects can not be queried by the valueForMustacheKey:protected:
 * method.
 *
 * For a full discussion of the interaction between the protected and the hidden
 * stacks, see the implementation of
 * [GRMustacheTag renderContentType:inBuffer:withContext:error:].
 *
 * @param object  An object that should be hidden.
 *
 * @return A GRMustacheContext object.
 *
 * @see [GRMustacheContext valueForMustacheKey:protected:]
 */
- (instancetype)contextByAddingHiddenObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Returns a GRMustacheContext object identical to the receiver, but for the
 * partial override stack that is extended with _partialOverride_.
 *
 * @param partialOverride  A partial template override object
 *
 * @return A GRMustacheContext object.
 *
 * @see GRMustachePartialOverride
 * @see [GRMustachePartialOverride renderWithContext:inBuffer:error:]
 */
- (instancetype)contextByAddingPartialOverride:(GRMustachePartialOverride *)partialOverride GRMUSTACHE_API_INTERNAL;

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
 * @see -[GRMustacheIdentifierExpression hasValue:withContext:protected:error:]
 */
- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected GRMUSTACHE_API_INTERNAL;

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
 * Returns an array containing all tag delegates in the delegate stack.
 * Array may be null (meaning there is no tag delegate in the stack).
 *
 * Last object is the top object in the delegate stack.
 */
- (NSArray *)tagDelegateStack GRMUSTACHE_API_INTERNAL;

@end
