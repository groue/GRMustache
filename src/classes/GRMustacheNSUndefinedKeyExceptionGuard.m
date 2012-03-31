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

#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "JRSwizzle.h"

static const NSString *GRMustacheNSUndefinedKeyExceptionGuardSilentObjects = @"GRMustacheNSUndefinedKeyExceptionGuardSilentObjects";


// =============================================================================
#pragma mark - GRMustacheNSUndefinedKeyExceptionGuard

@interface GRMustacheNSUndefinedKeyExceptionGuard()
+ (void)swizzleIfNeeded;
+ (NSMutableSet *)silentObjectsForCurrentThread;
@end

@implementation GRMustacheNSUndefinedKeyExceptionGuard

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    if (object == nil) {
        return nil;
    }
    [self swizzleIfNeeded];
    NSMutableSet *silentObjects = [self silentObjectsForCurrentThread];
    [silentObjects addObject:object];
    id value = nil;
    @try {
        value = [object valueForKey:key];
    }
    @catch (NSException *exception) {
        // We may not prevent all exceptions.
        // Make sure we do not leak any memory, and raise again.
        [silentObjects removeObject:object];
        [exception raise];
    }
    [silentObjects removeObject:object];
    return value;
}

#pragma mark Private

+ (NSMutableSet *)silentObjectsForCurrentThread
{
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheNSUndefinedKeyExceptionGuardSilentObjects];
    if (silentObjects == nil) {
        silentObjects = [NSMutableSet set];
        [[[NSThread currentThread] threadDictionary] setObject:silentObjects forKey:GRMustacheNSUndefinedKeyExceptionGuardSilentObjects];
    }
    return silentObjects;
}

+ (void)swizzleIfNeeded
{
    static BOOL needsSwizzle = YES;
    if (needsSwizzle) {
        [NSObject jr_swizzleMethod:@selector(valueForUndefinedKey:)
                        withMethod:@selector(GRMustacheSilentValueForUndefinedKey_NSObject:)
                             error:nil];
        
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                        withMethod:@selector(GRMustacheSilentValueForUndefinedKey_NSManagedObject:)
                                             error:nil];
        }
        
        needsSwizzle = NO;
    }
}

@end


// =============================================================================
#pragma mark - NSObject(GRMustacheNSUndefinedKeyExceptionGuard)

@implementation NSObject(GRMustacheNSUndefinedKeyExceptionGuard)

// NSObject
- (id)GRMustacheSilentValueForUndefinedKey_NSObject:(NSString *)key
{
    NSMutableSet *silentObjects = [GRMustacheNSUndefinedKeyExceptionGuard silentObjectsForCurrentThread];
    if ([silentObjects containsObject:self]) {
        return nil;
    }
    return [self GRMustacheSilentValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheSilentValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    NSMutableSet *silentObjects = [GRMustacheNSUndefinedKeyExceptionGuard silentObjectsForCurrentThread];
    if ([silentObjects containsObject:self]) {
        return nil;
    }
    return [self GRMustacheSilentValueForUndefinedKey_NSManagedObject:key];
}
@end
