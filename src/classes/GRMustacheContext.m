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

#if (TARGET_OS_IPHONE)
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-class.h>
#endif
#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheTemplate_private.h"

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;

@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
@end


@implementation GRMustacheContext
@synthesize object=_object;
@synthesize parent=_parent;

+ (void)preventNSUndefinedKeyExceptionAttack
{
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object
{
    if (object == nil) {
        return nil;
    }
    if ([object isKindOfClass:[GRMustacheContext class]]) {
        return object;
    }
    return [[[self alloc] initWithObject:object parent:nil] autorelease];
}

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    id value = nil;
    
    if (object)
    {
        if ([self objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:object]) {
            // Specific case here: we don't want to return another collection.
            // See issue #21 and "anchored key should not extract properties
            // inside an array" test in
            // src/tests/Public/v4.0/GRMustacheSuites/compound_keys.json
            return nil;
        }
        
        @try
        {
            if (preventingNSUndefinedKeyExceptionAttack)
            {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:object];
            }
            else
            {
                value = [object valueForKey:key];
            }
        }
        @catch (NSException *exception)
        {
            // swallow all NSUndefinedKeyException, reraise other exceptions
            if (![[exception name] isEqualToString:NSUndefinedKeyException])
            {
                [exception raise];
            }
#if !defined(NS_BLOCK_ASSERTIONS)
            else
            {
                // For testing purpose
                GRMustacheContextDidCatchNSUndefinedKeyException = YES;
            }
#endif
        }
    }
    
    return value;
}

- (GRMustacheContext *)contextByAddingObject:(id)object
{
    return [[[GRMustacheContext alloc] initWithObject:object parent:self] autorelease];
}

- (id)valueForKey:(NSString *)key
{
    id value = [GRMustacheContext valueForKey:key inObject:_object];
    if (value != nil) { return value; }
    return [_parent valueForKey:key];
}

- (void)dealloc
{
    [_object release];
    [_parent release];
    [super dealloc];
}

#pragma mark Private

- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent
{
    NSAssert(object, @"");
    self = [self init];
    if (self) {
        _object = [object retain];
        _parent = [parent retain];
    }
    return self;
}

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object
{
    static SEL selector = nil;
    static IMP NSObjectIMPL = nil;
    static IMP NSDictionaryIMPL = nil;
    static BOOL NSManagedObjectIMPLComputed = NO;
    static IMP NSManagedObjectIMPL = nil;
    
    if (selector == nil) {
        selector = @selector(valueForKey:);
    }
    
    if (NSObjectIMPL == nil) {
        NSObjectIMPL = class_getMethodImplementation([NSObject class], selector);
    }
    
    if (NSDictionaryIMPL == nil) {
        NSDictionaryIMPL = class_getMethodImplementation([NSDictionary class], selector);
    }
    
    if (NSManagedObjectIMPLComputed == NO) {
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            NSManagedObjectIMPL = class_getMethodImplementation(NSManagedObjectClass, selector);
        }
        NSManagedObjectIMPLComputed = YES;
    }
    
    IMP objectIMPL = class_getMethodImplementation([object class], selector);
    
    if (objectIMPL == NSObjectIMPL) {
        return NO;
    }
    
    if (objectIMPL == NSDictionaryIMPL) {
        return NO;
    }
    
    if (objectIMPL == NSManagedObjectIMPL) {
        return NO;
    }

    // NSOrderedSet is iOS >= 5 or OSX >= 10.7. Don't name it directly. 
    Class NSOrderedSetClass = NSClassFromString(@"NSOrderedSet");
    if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSSet class]] || (NSOrderedSetClass && [object isKindOfClass:NSOrderedSetClass])) {
        return YES;
    }
    
    return NO;
}

@end

