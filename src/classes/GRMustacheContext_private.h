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

#if !defined(NS_BLOCK_ASSERTIONS)
/**
 * This global variable is used by GRPreventNSUndefinedKeyExceptionAttackTest.
 */
extern BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

/**
 * The GRMustacheContext class implements a context stack as a linked list.
 */
@interface GRMustacheContext: NSObject {
@private
    id _object;
    GRMustacheContext *_parent;
}

/**
 * The top object is the context stack.
 *
 * This object is never nil.
 */
@property (nonatomic, retain, readonly) id object GRMUSTACHE_API_INTERNAL;

/**
 * The remaining of the stack.
 */
@property (nonatomic, retain, readonly) GRMustacheContext *parent GRMUSTACHE_API_INTERNAL;

/**
 * Triggers the trick for avoiding most NSUndefinedException to be raised
 * by the invocation of `valueForKey:` method on user's objects.
 *
 * @see GRMustacheNSUndefinedKeyExceptionGuard
 */
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_INTERNAL;

/**
 * Returns a context stack containing a single object.
 *
 * @param object  The object in the context stack
 *
 * @return nil if the object is nil; the object if it is already a
 *         GRMustacheContext; a new context stack otherwise.
 */
+ (id)contextWithObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Returns a context stack containing several objects.
 *
 * @param object      The bottom object in the context stack
 * @param objectList  A list of other objects
 *
 * @return nil if the object is nil; a new context stack otherwise.
 */
+ (id)contextWithObject:(id)object andObjectList:(va_list)objectList GRMUSTACHE_API_INTERNAL;

/**
 * Returns a new context stack by adding an object at the top.
 *
 * @param object  The top object of the retured context stack.
 *
 * @return A new context stack.
 */
- (GRMustacheContext *)contextByAddingObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Looks for an object in the context stack that returns a non-nil value when
 * sent the `valueForKey:` message with the provided key, and return this value.
 *
 * If scoped is YES, only the top object is tested.
 *
 * If scoped is NO, all objects in the stack are tested, starting with the
 * top object.
 *
 * @param key     The searched key
 * @param scoped  YES if the lookup should test all objects in the stack.
 *
 * @return The found value
 */
- (id)valueForKey:(NSString *)key scoped:(BOOL)scoped GRMUSTACHE_API_INTERNAL;

@end
