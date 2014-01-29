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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheVariadicFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustacheVariadicFilterTest

- (void)testVariadicFiltersCanAccessAllArguments
{
    GRMustacheFilter *joinFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return [[arguments valueForKey:@"description"] componentsJoinedByString:@","];
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c", @"join": joinFilter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{join(a,b)}} {{join(a,b,c)}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"a,b a,b,c", @"");
}

- (void)testVariadicFiltersHaveNSNullArgumentForNilInput
{
    __block NSUInteger NSNullCount = 0;
    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        for (id argument in arguments) {
            if (argument == [NSNull null]) {
                ++NSNullCount;
            }
        }
        return nil;
    }];
    
    id data = @{ @"f": filter };
    [[GRMustacheTemplate templateFromString:@"{{f(a,b,c)}}" error:NULL] renderObject:data error:NULL];
    STAssertEquals(NSNullCount, (NSUInteger)3, @"");
}

- (void)testVariadicFiltersCanReturnFilters
{
    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return [GRMustacheFilter filterWithBlock:^id(id value) {
            return [NSString stringWithFormat:@"%@+%@", [arguments componentsJoinedByString:@","], value];
        }];
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c", @"d": @"d", @"f": filter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{f(a)(d)}} {{f(a,b)(d)}} {{f(a,b,c)(d)}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"a+d a,b+d a,b,c+d", @"");
}

- (void)testVariadicFiltersCanBeRootOfScopedExpression
{
    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ @"f": filter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{f(a,b).foo}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testVariadicFiltersCanBeUsedForObjectSections
{
    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ @"f": filter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(a,b)}}{{foo}}{{/}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testVariadicFiltersCanBeUsedForEnumerableSections
{
    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return arguments;
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c", @"f": filter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"ab abc", @"");
}

- (void)testVariadicFiltersCanBeUsedForBooleanSections
{
    GRMustacheFilter *identityFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return [arguments objectAtIndex:0];
    }];
    
    id data = @{ @"yes": @YES, @"no": @NO, @"f": identityFilter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"YES NO", @"");
}

- (void)testVariadicFiltersThatReturnNilCanBeUsedInBooleanSections
{
    GRMustacheFilter *nilFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        return nil;
    }];
    
    id data = @{ @"f": nilFilter };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{^f(x)}}nil{{/}}" error:NULL] renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"nil", @"");
}

@end
