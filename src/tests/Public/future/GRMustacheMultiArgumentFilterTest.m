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

#import "GRMustachePublicAPITest.h"

@interface GRMustacheMultiArgumentFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustacheMultiArgumentFilterTest

- (void)testMultiArgumentsFiltersCanAccessAllArguments
{
    GRMustacheFilter *joinFilter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return [[arguments valueForKey:@"description"] componentsJoinedByString:@","];
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c" };
    id filters = @{ @"join": joinFilter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{join(a,b)}} {{join(a,b,c)}}" error:NULL];
    STAssertEqualObjects(rendering, @"a,b a,b,c", @"");
}

- (void)testMultiArgumentsFiltersHaveNSNullArgumentForNilInput
{
    __block NSUInteger NSNullCount = 0;
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        for (id argument in arguments) {
            if (argument == [NSNull null]) {
                ++NSNullCount;
            }
        }
        return nil;
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{f(a,b,c)}}" error:NULL];
    STAssertEquals(NSNullCount, (NSUInteger)3, @"");
}

- (void)testMultiArgumentsFiltersCanBeRootOfScopedExpression
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{f(a,b).foo}}" error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForObjectSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(a,b)}}{{foo}}{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForEnumerableSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return arguments;
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c" };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"ab abc", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForBooleanSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return [arguments objectAtIndex:0];
    }];
    
    id data = @{ @"yes": @YES, @"no": @NO };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"YES NO", @"");
}

@end
