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

/**
 * This class avoids most NSUndefinedException to be raised by the invocation of
 * `valueForKey:` method on user's objects.
 *
 * It is used by GRMustacheRuntime after the library user has called
 * `[GRMustache preventNSUndefinedKeyExceptionAttack]`.
 *
 * @see GRMustache.
 * @see GRMustacheRuntime
 */
@interface GRMustacheNSUndefinedKeyExceptionGuard : NSObject

/**
 * Wrapper around the `valueForKey:` method, that avoids NSUndefinedException to
 * be raised, as long as the object's implementation of `valueForUndefinedKey:`
 * is the one of NSObject or NSManagedObject.
 *
 * For objects that have a custom implementation of `valueForUndefinedKey:`,
 * this method does not guarantee that NSUndefinedException will be avoided.
 * 
 * @param key     The key
 * @param object  The object
 *
 * @return `[object valueForKey:key]`, or nil if the object would have raised
 *         an NSUndefinedException.
 */
+ (id)valueForKey:(NSString *)key inObject:(id)object GRMUSTACHE_API_INTERNAL;

/**
 * Wrapper around the `valueForKey:` method, that avoids NSUndefinedException to
 * be raised, as long as the object's implementation of `valueForUndefinedKey:`
 * is the one of NSObject or NSManagedObject.
 *
 * For objects that have a custom implementation of `valueForUndefinedKey:`,
 * this method does not guarantee that NSUndefinedException will be avoided.
 *
 * This method is used by the GRMustacheProxy class.
 *
 * @param key         The key
 * @param super_data  A pointer to an objc_super struct
 *
 * @return The result of `objc_msgSendSuper(super_data, @selector(valueForKey:), key);`,
 *         or nil if this function call raises an NSUndefinedException.
 */
+ (id)valueForKey:(NSString *)key inSuper:(struct objc_super *)super_data GRMUSTACHE_API_INTERNAL;
@end
