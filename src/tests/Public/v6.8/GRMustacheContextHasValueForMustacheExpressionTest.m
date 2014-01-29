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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_8
#import "GRMustachePublicAPITest.h"

@interface GRMustacheContextHasValueForMustacheExpressionTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextHasValueForMustacheExpressionTest

- (void)testHasValueForMustacheExpression
{
    GRMustacheContext *context = [GRMustacheContext contextWithObject:[GRMustache standardLibrary]];
    id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [[value description] uppercaseString];
    }];
    id data = @{ @"name": @"name1", @"a": @{ @"name": @"name2" }, @"filter": filter };
    context = [context contextByAddingObject:data];
    id value;
    {
        BOOL success = [context hasValue:&value forMustacheExpression:@"." error:NULL];
        STAssertTrue(success, @"");
        STAssertEquals(value, data, @"");
    }
    {
        BOOL success = [context hasValue:&value forMustacheExpression:@"name" error:NULL];
        STAssertTrue(success, @"");
        STAssertEqualObjects(value, @"name1", @"");
    }
    {
        BOOL success = [context hasValue:&value forMustacheExpression:@"a.name" error:NULL];
        STAssertTrue(success, @"");
        STAssertEqualObjects(value, @"name2", @"");
    }
    {
        BOOL success = [context hasValue:&value forMustacheExpression:@"filter(a.name)" error:NULL];
        STAssertTrue(success, @"");
        STAssertEqualObjects(value, @"NAME2", @"");
    }
}

- (void)testHasValueForInvalidMustacheExpression
{
    GRMustacheContext *context = [GRMustacheContext contextWithObject:@{@"foo": @"bar"}];
    id value;
    {
        NSError *error;
        BOOL success = [context hasValue:&value forMustacheExpression:@"a." error:&error];
        STAssertFalse(success, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeParseError, @"");
    }
    {
        NSError *error;
        BOOL success = [context hasValue:&value forMustacheExpression:@"a(b)" error:&error];
        STAssertFalse(success, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @""); // missing filter a
    }
    {
        NSError *error;
        BOOL success = [context hasValue:&value forMustacheExpression:@"foo(bar)" error:&error];
        STAssertFalse(success, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @""); // not a filter
    }
}

@end
