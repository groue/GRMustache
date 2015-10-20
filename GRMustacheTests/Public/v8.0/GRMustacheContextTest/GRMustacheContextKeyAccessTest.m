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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_8_0
#import "GRMustachePublicAPITest.h"


@interface GRMustacheContextKeyAccess_ClassWithProperties : NSObject
@property (nonatomic, copy) NSString *property;
@end

@implementation GRMustacheContextKeyAccess_ClassWithProperties

- (void)dealloc
{
    self.property = nil;
    [super dealloc];
}

- (instancetype)initWithProperty:(NSString *)property
{
    self = [self init];
    if (self) {
        self.property = property;
    }
    return self;
}

- (NSString *)method
{
    return @"method";
}

@end

//

@interface GRMustacheContextKeyAccess_ClassWithProperties2 : NSObject
@property (nonatomic, readonly) NSString *property2;
@end

@implementation GRMustacheContextKeyAccess_ClassWithProperties2

- (NSString *)property2
{
    return @"property2";
}

- (NSString *)method2
{
    return @"method2";
}

@end

//

@interface GRMustacheContextKeyAccessTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextKeyAccessTest

- (void)testPropertiesAreAllowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"] autorelease];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object.property, @"property", @"");
    XCTAssertEqualObjects([object valueForKey:@"property"], @"property", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
}

- (void)testNilPropertyEvaluatesToNSNullAndStopsContextStackLookup
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:nil] autorelease];
    GRMustacheContext *context = [GRMustacheContext contextWithObject:@{@"property": @"root"}];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"root", @"");
    context = [context contextByAddingObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], [NSNull null]);
}

- (void)testMethodAreDisallowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"] autorelease];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object method], @"method", @"");
    XCTAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertNil([context valueForMustacheKey:@"method"], @"");
}

- (void)testUnsafeKeyAccess
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"] autorelease];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object method], @"method", @"");
    XCTAssertEqualObjects(object.property, @"property", @"");
    XCTAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    XCTAssertEqualObjects([object valueForKey:@"property"], @"property", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    context = [context contextWithUnsafeKeyAccess];
    XCTAssertEqualObjects([context valueForMustacheKey:@"method"], @"method", @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
}

- (void)testUnsafeKeyAccessInDerivedContexts
{
    GRMustacheContextKeyAccess_ClassWithProperties *object1 = [[[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"] autorelease];
    GRMustacheContextKeyAccess_ClassWithProperties2 *object2 = [[[GRMustacheContextKeyAccess_ClassWithProperties2 alloc] init] autorelease];
    
    // test setup
    XCTAssertFalse([object1 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object1 method], @"method", @"");
    XCTAssertEqualObjects(object1.property, @"property", @"");
    XCTAssertEqualObjects([object1 valueForKey:@"method"], @"method", @"");
    XCTAssertEqualObjects([object1 valueForKey:@"property"], @"property", @"");
    
    XCTAssertFalse([object2 respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object2 method2], @"method2", @"");
    XCTAssertEqualObjects(object2.property2, @"property2", @"");
    XCTAssertEqualObjects([object2 valueForKey:@"method2"], @"method2", @"");
    XCTAssertEqualObjects([object2 valueForKey:@"property2"], @"property2", @"");
    
    // test context
    {
        // Context derived from unsafe context is unsafe.
        
        GRMustacheContext *context = [GRMustacheContext contextWithUnsafeKeyAccess];
        context = [context contextByAddingObject:object1];
        XCTAssertEqualObjects([context valueForMustacheKey:@"method"], @"method", @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
    }
    {
        // Context derived from safe context is safe.
        
        GRMustacheContext *context = [GRMustacheContext context];
        context = [context contextByAddingObject:object1];
        XCTAssertNil([context valueForMustacheKey:@"method"], @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
    }
    {
        // Derived unsafe context is fully unsafe
        
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object1];
        XCTAssertNil([context valueForMustacheKey:@"method"], @"");
        context = [context contextByAddingObject:object2];
        XCTAssertNil([context valueForMustacheKey:@"method"], @"");
        XCTAssertNil([context valueForMustacheKey:@"methd2"], @"");
        context = [context contextWithUnsafeKeyAccess];
        XCTAssertEqualObjects([context valueForMustacheKey:@"method"], @"method", @"");
        XCTAssertEqualObjects([context valueForMustacheKey:@"method2"], @"method2", @"");
    }
}

@end
