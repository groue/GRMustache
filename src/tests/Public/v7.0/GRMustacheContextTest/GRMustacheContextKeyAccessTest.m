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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_0
#import "GRMustachePublicAPITest.h"


//

@interface GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript : NSObject<GRMustacheSafeKeyAccess>
@end

@implementation GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript

+ (NSSet *)safeMustacheKeys
{
    return [NSSet setWithObjects:@"foo", @"bar", nil];
}

- (id)objectForKeyedSubscript:(id)key
{
    return key;
}

- (id)valueForKey:(NSString *)key
{
    return [key uppercaseString];
}

@end

//

@interface GRMustacheContextKeyAccess_ClassWithProperties : NSObject
@property (nonatomic, readonly) NSString *property;
@end

@implementation GRMustacheContextKeyAccess_ClassWithProperties

- (NSString *)property
{
    return @"property";
}

- (NSString *)method
{
    return @"method";
}

@end

//

@interface GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys : NSObject<GRMustacheSafeKeyAccess>
@property (nonatomic, readonly) NSString *disallowedProperty;
@end

@implementation GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys

+ (NSSet *)safeMustacheKeys
{
    return [NSSet setWithObjects:@"allowedMethod", nil];
}

- (NSString *)disallowedProperty
{
    return @"disallowedProperty";
}

- (NSString *)allowedMethod
{
    return @"allowedMethod";
}

@end

//

@interface GRMustacheContextKeyAccessTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextKeyAccessTest

- (void)testObjectForKeyedSubscriptReplacesValueForKey
{
    GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript *object = [[[GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript alloc] init] autorelease];
    
    // test setup
    STAssertTrue([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    STAssertTrue([[[object class] safeMustacheKeys] containsObject:@"foo"], @"");
    STAssertTrue([[[object class] safeMustacheKeys] containsObject:@"bar"], @"");
    STAssertEqualObjects([object objectForKeyedSubscript:@"foo"], @"foo", @"");
    STAssertEqualObjects([object objectForKeyedSubscript:@"bar"], @"bar", @"");
    STAssertEqualObjects([object valueForKey:@"foo"], @"FOO", @"");
    STAssertEqualObjects([object valueForKey:@"bar"], @"BAR", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertEqualObjects([context valueForMustacheKey:@"foo"], @"foo", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"bar"], @"bar", @"");
}

- (void)testPropertiesAreAllowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    STAssertFalse([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.property, @"property", @"");
    STAssertEqualObjects([object valueForKey:@"property"], @"property", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
}

- (void)testMethodAreDisallowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    STAssertFalse([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects([object method], @"method", @"");
    STAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertNil([context valueForMustacheKey:@"method"], @"");
}

- (void)testCustomSafeMustacheKeys
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    STAssertTrue([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    STAssertTrue([[[object class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
    STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testUnsafeKeyAccess
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    STAssertTrue([[[object class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    context = [context contextWithUnsafeKeyAccess];
    STAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testUnsafeKeyAccessInDerivedContexts
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object1 = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    GRMustacheContextKeyAccess_ClassWithProperties *object2 = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    STAssertFalse([object1 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object1.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object1 allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object1 valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object1 valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    STAssertTrue([[[object1 class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object1 class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    STAssertFalse([[object2 class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    STAssertFalse([object2 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object2.property, @"property", @"");
    STAssertEqualObjects([object2 valueForKey:@"property"], @"property", @"");
    
    // test context
    {
        // Context derived from unsafe context is unsafe.
        
        GRMustacheContext *context = [GRMustacheContext contextWithUnsafeKeyAccess];
        context = [context contextByAddingObject:object1];
        STAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
        STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Context derived from safe context is safe.
        
        GRMustacheContext *context = [GRMustacheContext context];
        context = [context contextByAddingObject:object1];
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Derived unsafe context is fully unsafe
        
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object1];
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        context = [context contextByAddingObject:object2];
        STAssertNil([context valueForMustacheKey:@"method"], @"");
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        context = [context contextWithUnsafeKeyAccess];
        STAssertEqualObjects([context valueForMustacheKey:@"method"], @"method", @"");
        STAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
    }
}

@end
