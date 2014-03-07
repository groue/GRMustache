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

@interface GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript : NSObject<GRMustacheKeyValidation>
@end

@implementation GRMustacheContextKeyAccess_ClassWithObjectForKeyedSubscript

+ (NSSet *)validMustacheKeys
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

@interface GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys : NSObject<GRMustacheKeyValidation>
@property (nonatomic, readonly) NSString *disallowedProperty;
@end

@implementation GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys

+ (NSSet *)validMustacheKeys
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
    STAssertFalse([[object class] respondsToSelector:@selector(validMustacheKeys)], @"");
    STAssertEqualObjects([object objectForKeyedSubscript:@"foo"], @"foo", @"");
    STAssertEqualObjects([object objectForKeyedSubscript:@"bar"], @"bar", @"");
    STAssertEqualObjects([object valueForKey:@"foo"], @"FOO", @"");
    STAssertEqualObjects([object valueForKey:@"bar"], @"BAR", @"");
    STAssertTrue([[[object class] validMustacheKeys] containsObject:@"foo"], @"");
    STAssertTrue([[[object class] validMustacheKeys] containsObject:@"bar"], @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertEqualObjects([context valueForMustacheKey:@"foo"], @"foo", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"bar"], @"bar", @"");
}

- (void)testPropertiesAreAllowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] init] autorelease];
    
    // test setup
    STAssertFalse([[object class] respondsToSelector:@selector(validMustacheKeys)], @"");
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
    STAssertFalse([[object class] respondsToSelector:@selector(validMustacheKeys)], @"");
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects([object method], @"method", @"");
    STAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertNil([context valueForMustacheKey:@"method"], @"");
}

- (void)testCustomValidMustacheKeys
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    STAssertFalse([[object class] respondsToSelector:@selector(validMustacheKeys)], @"");
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    STAssertTrue([[[object class] validMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object class] validMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
    STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testAllowsAllKeys
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    STAssertTrue([[[object class] validMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object class] validMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    context.allowsAllKeys = YES;
    STAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
}

- (void)testAllowsAllKeysInDerivedContexts
{
    GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys *object = [[[GRMustacheContextKeyAccess_ClassWithCustomAllowedKeys alloc] init] autorelease];
    
    // test setup
    STAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    STAssertEqualObjects(object.disallowedProperty, @"disallowedProperty", @"");
    STAssertEqualObjects([object allowedMethod], @"allowedMethod", @"");
    STAssertEqualObjects([object valueForKey:@"disallowedProperty"], @"disallowedProperty", @"");
    STAssertEqualObjects([object valueForKey:@"allowedMethod"], @"allowedMethod", @"");
    STAssertTrue([[[object class] validMustacheKeys] containsObject:@"allowedMethod"], @"");
    STAssertFalse([[[object class] validMustacheKeys] containsObject:@"disallowedProperty"], @"");
    
    // test context
    {
        // Derived context inherits allowsAllKeys from parent: YES
        
        GRMustacheContext *context = [GRMustacheContext context];
        context.allowsAllKeys = YES;
        context = [context contextByAddingObject:object];
        STAssertEqualObjects([context valueForMustacheKey:@"disallowedProperty"], @"disallowedProperty", @"");
        STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Derived context inherits allowsAllKeys from parent: NO
        
        GRMustacheContext *context = [GRMustacheContext context];
        context.allowsAllKeys = NO;
        context = [context contextByAddingObject:object];
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
    {
        // Derived context can not access keys disallowed in parent
        
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        
        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"foo", nil];
        STAssertTrue(([array count] == 1), @"");    // array is not empty
        context = [context contextByAddingObject:array];
        context.allowsAllKeys = YES;
        STAssertEqualObjects([context valueForMustacheKey:@"removeAllObjects"], nil, @"");
        STAssertTrue(([array count] == 0), @"");    // array is now empty
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
    }
    {
        // Derived context can not access keys disallowed in parent
        //
        // Avoid security breach: make sure contextByAddingObject returns a new
        // context, even when added object is nil.
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
        context.allowsAllKeys = NO;
        context = [context contextByAddingObject:nil];
        context.allowsAllKeys = YES;
        STAssertNil([context valueForMustacheKey:@"disallowedProperty"], @"");
        STAssertEqualObjects([context valueForMustacheKey:@"allowedMethod"], @"allowedMethod", @"");
    }
}

@end
