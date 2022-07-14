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
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects(object.property, @"property", @"");
    XCTAssertEqualObjects([object valueForKey:@"property"], @"property", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"property", @"");
}

- (void)testNilPropertyEvaluatesToMissingKeyAndDoesNotStopContextStackLookup
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:nil];
    GRMustacheContext *context = [GRMustacheContext contextWithObject:@{@"property": @"root"}];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"root", @"");
    context = [context contextByAddingObject:object];
    XCTAssertEqualObjects([context valueForMustacheKey:@"property"], @"root");
}

- (void)testMethodAreDisallowed
{
    GRMustacheContextKeyAccess_ClassWithProperties *object = [[GRMustacheContextKeyAccess_ClassWithProperties alloc] initWithProperty:@"property"];
    
    // test setup
    XCTAssertFalse([object respondsToSelector:@selector(objectForKeyedSubscript:)], @"");
    XCTAssertEqualObjects([object method], @"method", @"");
    XCTAssertEqualObjects([object valueForKey:@"method"], @"method", @"");
    
    // test context
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object];
    XCTAssertNil([context valueForMustacheKey:@"method"], @"");
}

@end
