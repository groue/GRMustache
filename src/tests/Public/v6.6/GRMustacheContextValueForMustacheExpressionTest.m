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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_6
#import "GRMustachePublicAPITest.h"

@interface GRMustacheContextValueForMustacheExpressionTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextValueForMustacheExpressionTest

- (void)testValueForMustacheKey
{
    GRMustacheContext *context = [GRMustacheContext contextWithObject:[GRMustache standardLibrary]];
    id data = @{ @"name": @"name1", @"a": @{ @"name": @"name2" }};
    context = [context contextByAddingObject:data];
    {
        // '.' is an expression, not a key
        id value = [context valueForMustacheKey:@"."];
        STAssertNil(value, @"");
    }
    {
        // 'name' is a key
        id value = [context valueForMustacheKey:@"name"];
        STAssertEqualObjects(value, @"name1", @"");
    }
    {
        // 'a.name' is an expression, not a key
        id value = [context valueForMustacheKey:@"a.name"];
        STAssertNil(value, @"");
    }
    {
        // 'uppercase' is a key
        id value = [context valueForMustacheKey:@"uppercase"];
        STAssertTrue([value conformsToProtocol:@protocol(GRMustacheFilter)], @"");
    }
}

- (void)testValueForMustacheExpression
{
    GRMustacheContext *context = [GRMustacheContext contextWithObject:[GRMustache standardLibrary]];
    id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [[value description] uppercaseString];
    }];
    id data = @{ @"name": @"name1", @"a": @{ @"name": @"name2" }, @"filter": filter };
    context = [context contextByAddingObject:data];
    {
        id value = [context valueForMustacheExpression:@"." error:NULL];
        STAssertEquals(value, data, @"");
    }
    {
        id value = [context valueForMustacheExpression:@"name" error:NULL];
        STAssertEqualObjects(value, @"name1", @"");
    }
    {
        id value = [context valueForMustacheExpression:@"a.name" error:NULL];
        STAssertEqualObjects(value, @"name2", @"");
    }
    {
        id value = [context valueForMustacheExpression:@"filter(a.name)" error:NULL];
        STAssertEqualObjects(value, @"NAME2", @"");
    }
}

- (void)testValueForInvalidMustacheExpression
{
    GRMustacheContext *context = [GRMustacheContext contextWithObject:@{@"foo": @"bar"}];
    {
        NSError *error;
        id value = [context valueForMustacheExpression:@"a." error:&error];
        STAssertNil(value, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeParseError, @"");
    }
    {
        NSError *error;
        id value = [context valueForMustacheExpression:@"a(b)" error:&error];
        STAssertNil(value, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @""); // missing filter a
    }
    {
        NSError *error;
        id value = [context valueForMustacheExpression:@"foo(bar)" error:&error];
        STAssertNil(value, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @""); // not a filter
    }
}

@end
