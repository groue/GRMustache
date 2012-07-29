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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_3
#import "GRMustachePublicAPITest.h"

@interface GRMustacheFilterTestSupport: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheFilterTestSupport

- (id)transformedValue:(id)object
{
    return object;
}

- (NSString *)test
{
    return @"failure";
}

@end

@interface GRMustacheFilterTest : GRMustachePublicAPITest
@end

@implementation GRMustacheFilterTest

- (void)testFilterChain
{
    id uppercaseFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [[value description] uppercaseString];
    }];
    id prefixFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [NSString stringWithFormat:@"prefix%@", [value description]];
    }];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          uppercaseFilter, @"uppercase",
                          prefixFilter, @"prefix",
                          @"Name", @"name",
                          nil];
    
    NSString *templateString = @"{{%FILTERS}}<{{name}}> <{{name|prefix}}> <{{name|uppercase}}> <{{name|uppercase|prefix}}> <{{name|prefix|uppercase}}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>", nil);
}

- (void)testFilteredSectionClosingTagCanHaveDifferentWhiteSpaceThanSectionOpeningTag
{
    NSString *templateString = @"{{%FILTERS}}{{#a|b}}{{/ \t\na \t\n| \t\nb \t\n}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    STAssertNotNil(template, nil);
}

- (void)testBrokenFilterChainRaisesGRMustacheFilterException
{
    id replaceFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"replace";
    }];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          replaceFilter, @"replace",
                          @"Name", @"name",
                          nil];
    
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}<{{missing|missing}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}<{{name|missing}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}<{{name|missing|replace}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}<{{name|replace|missing}}>" error:NULL], NSException, GRMustacheFilterException, nil);
}

- (void)testNotAFilterRaisesGRMustacheFilterException
{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Name", @"name",
                          nil];
    
    NSString *templateString = @"{{%FILTERS}}<{{name|name}}>";
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data fromString:templateString error:NULL], NSException, GRMustacheFilterException, nil);
}

- (void)testFilteredValuesCanNotOverrideFilters
{
    id successFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"success";
    }];
    id failFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"failure";
    }];
    id filtered = [NSDictionary dictionaryWithObject:failFilter forKey:@"filter"];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          filtered, @"filtered",
                          successFilter, @"filter",
                          nil];
    NSString *templateString = @"{{%FILTERS}}<{{filtered|filter}} instead of {{filtered|filtered.filter}}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success instead of failure>", nil);
}

- (void)testFiltersCanNotOverrideFilteredValue
{
    id filter = [[[GRMustacheFilterTestSupport alloc] init] autorelease];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"success", @"test",
                          filter, @"filter",
                          nil];
    NSString *templateString = @"{{%FILTERS}}<{{test|filter}} instead of {{filter.test|filter}}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success instead of failure>", nil);
}

- (void)testFilteredValuesDoNotEnterSectionContextStack
{
    id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"filter";
    }];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSDictionary dictionaryWithObject:@"failure" forKey:@"test"], @"filtered",
                          filter, @"filter",
                          @"success", @"test",
                          nil];
    NSString *templateString = @"{{%FILTERS}}{{#filtered|filter}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filtered|filter}}";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success instead of failure>", nil);
}

- (void)testFiltersDoNotEnterSectionContextStack
{
    id filter = [[[GRMustacheFilterTestSupport alloc] init] autorelease];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"filtered", @"filtered",
                          filter, @"filter",
                          @"success", @"test",
                          nil];
    NSString *templateString = @"{{%FILTERS}}{{#filtered|filter}}<{{test}} instead of {{#filter}}{{test}}{{/filter}}>{{/filtered|filter}}";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success instead of failure>", nil);
}

@end
