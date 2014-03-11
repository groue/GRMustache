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
    XCTAssertTrue([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    XCTAssertTrue([[[object class] safeMustacheKeys] containsObject:@"foo"], @"");
    XCTAssertTrue([[[object class] safeMustacheKeys] containsObject:@"bar"], @"");
    XCTAssertEqualObjects([object objectForKeyedSubscript:@"foo"], @"foo", @"");
    XCTAssertEqualObjects([object objectForKeyedSubscript:@"bar"], @"bar", @"");
    XCTAssertEqualObjects([object valueForKey:@"foo"], @"FOO", @"");
    XCTAssertEqualObjects([object valueForKey:@"bar"], @"BAR", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"foo"], @"foo", @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"bar"], @"bar", @"");
}

- (void)testPropertiesAreAllowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    XCTAssertFalse([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object.property, @"property", @"");
    XCTAssertEqualObjects([object valueForKey:@"property"], @"property", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
}

- (void)testMethodAreDisallowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    XCTAssertFalse([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object method], @"method", @"");
    XCTAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertNil([context valueForMustacheKey:@"method"], @"");
}

- (void)testCustomSafeMustacheKeys
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    XCTAssertTrue([[object class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    XCTAssertTrue([[[object class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    XCTAssertFalse([[[object class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    XCTAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    XCTAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    XCTAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testUnsafeKeyAccess
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    XCTAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    XCTAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    XCTAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    XCTAssertTrue([[[object class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    XCTAssertFalse([[[object class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    context = [context contextWithUnsafeKeyAccess];
    XCTAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testUnsafeKeyAccessInDerivedContexts
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object1 = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    GRMustacheContextKeyAccess_ClassWithProperties *object2 = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    XCTAssertFalse([object1 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object1.disallowedProperty, @"disallowedProperty", @"");
    XCTAssertEqualObjects([object1 allowedMethod], @"allowedMethod", @"");
    XCTAssertEqualObjects([object1 valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    XCTAssertEqualObjects([object1 valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    XCTAssertTrue([[[object1 class] safeMustacheKeys] containsObject:@"allowedMethod"], @"");
    XCTAssertFalse([[[object1 class] safeMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    XCTAssertFalse([[object2 class] respondsToSelector:@selector(safeMustacheKeys)], @"");
    XCTAssertFalse([object2 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object2.property, @"property", @"");
    XCTAssertEqualObjects([object2 valueForKey:@"property"], @"property", @"");
    
    // test context
    {
        // Context derived from unsafe context is unsafe.
        
        GRMustacheContext *context = [GRMustacheContext contextWithUnsafeKeyAccess];
        context = [context contextByAddingObject:object1];
        XCTAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Context derived from safe context is safe.
        
        GRMustacheContext *context = [GRMustacheContext context];
        context = [context contextByAddingObject:object1];
        XCTAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Derived unsafe context is fully unsafe
        
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object1];
        XCTAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        context = [context contextByAddingObject:object2];
        XCTAssertNil([context valueForMustacheKey:@"method"], @"");
        XCTAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        context = [context contextWithUnsafeKeyAccess];
        XCTAssertEqualObjects([context valueForMustacheKey:@"method"], @"method", @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
    }
}

@end
