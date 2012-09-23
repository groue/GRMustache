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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_5_0
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

- (void)testFilterCanChain
{
    id uppercaseFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [[value description] uppercaseString];
    }];
    id prefixFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [NSString stringWithFormat:@"prefix%@", [value description]];
    }];
    
    NSDictionary *data = [NSDictionary dictionaryWithObject:@"Name" forKey:@"name"];
    NSDictionary *filters = [NSDictionary dictionaryWithObjectsAndKeys:
                             uppercaseFilter, @"uppercase",
                             prefixFilter, @"prefix",
                             nil];
    
    NSString *templateString = @"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>", nil);
}

- (void)testScopedValueAreExtractedOutOfAFilterExpression
{
    NSString *templateString = @"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    {
        id data = [NSDictionary dictionaryWithObjectsAndKeys:
                     [NSDictionary dictionaryWithObject:@"objectName" forKey:@"name"], @"object",
                     @"rootName", @"name",
                     nil];
        id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
            return value;
        }];
        NSString *rendering = [template renderObject:data withFilters:[NSDictionary dictionaryWithObject:filter forKey:@"f"]];
        STAssertEqualObjects(rendering, @"<objectName> <objectName>", nil);
    }
    
    {
        id data = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSDictionary dictionaryWithObject:@"objectName" forKey:@"name"], @"object",
                   @"rootName", @"name",
                   nil];
        id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
            return [NSDictionary dictionaryWithObject:@"filterName" forKey:@"name"];
        }];
        NSString *rendering = [template renderObject:data withFilters:[NSDictionary dictionaryWithObject:filter forKey:@"f"]];
        STAssertEqualObjects(rendering, @"<filterName> <filterName>", nil);
    }
    
    {
        id data = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSDictionary dictionaryWithObject:@"objectName" forKey:@"name"], @"object",
                   @"rootName", @"name",
                   nil];
        id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
            return [NSDictionary dictionary];
        }];
        NSString *rendering = [template renderObject:data withFilters:[NSDictionary dictionaryWithObject:filter forKey:@"f"]];
        STAssertEqualObjects(rendering, @"<> <rootName>", nil);
    }
}

- (void)testFilteredSectionClosingTagCanHaveDifferentWhiteSpaceThanSectionOpeningTag
{
    NSString *templateString = @"{{#a(b)}}{{/ \t\na \t\n( \t\nb \t\n) \t\n}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    STAssertNotNil(template, nil);
}

- (void)testFilteredSectionClosingTagCanBeBlank
{
    NSString *templateString = @"<{{#uppercase(.)}}{{.}}{{/}}> <{{#uppercase(.)}}{{.}}{{/ }}>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    STAssertNotNil(template, nil);
    NSString *rendering = [template renderObject:@"foo"];
    STAssertEqualObjects(rendering, @"<FOO> <FOO>", nil);
}

- (void)testFilteredSectionClosingTagCanNotBeInvalid
{
    NSString *templateString = @"<{{#uppercase(.)}}{{.}}{{/uppercase(.}}>";
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:templateString error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testMissingFilterChainRaisesGRMustacheFilterException
{
    id replaceFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"replace";
    }];
    
    NSDictionary *data = [NSDictionary dictionaryWithObject:@"Name" forKey:@"name"];
    NSDictionary *filters = [NSDictionary dictionaryWithObject:replaceFilter forKey:@"replace"];
    
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:@"<{{missing(missing)}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:@"<{{missing(name)}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:@"<{{replace(missing(name))}}>" error:NULL], NSException, GRMustacheFilterException, nil);
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:@"<{{missing(replace(name))}}>" error:NULL], NSException, GRMustacheFilterException, nil);
}

- (void)testNotAFilterRaisesGRMustacheFilterException
{
    NSDictionary *data = [NSDictionary dictionaryWithObject:@"Name" forKey:@"name"];
    NSDictionary *filters = [NSDictionary dictionaryWithObject:@"filter" forKey:@"filter"];
    
    NSString *templateString = @"<{{filter(name)}}>";
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:templateString error:NULL], NSException, GRMustacheFilterException, nil);
}

- (void)testFiltersAreNotLoadedFromContextStack
{
    id filter = [[[GRMustacheFilterTestSupport alloc] init] autorelease];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Name", @"name",
                          filter, @"filter",
                          nil];
    NSDictionary *filters = [NSDictionary dictionary];
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:data withFilters:filters fromString:@"<{{filter(name)}}>" error:NULL], NSException, GRMustacheFilterException, nil);
}

- (void)testFiltersDoNotEnterContextStack
{
    id filter = [[[GRMustacheFilterTestSupport alloc] init] autorelease];
    NSDictionary *data = [NSDictionary dictionaryWithObject:@"success" forKey:@"test"];
    NSDictionary *filters = [NSDictionary dictionaryWithObject:filter forKey:@"filter"];
    STAssertEqualObjects([filter valueForKey:@"test"], @"failure", nil);
    NSString *templateString = @"<{{#filter}}failure{{/filter}}{{^filter}}success{{/filter}}><{{filter.test}}><{{filter(test)}}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success><><success>", nil);
}

- (void)testFilteredValuesDoNotEnterSectionContextStack
{
    id filter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @"filter";
    }];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSDictionary dictionaryWithObject:@"failure" forKey:@"test"], @"filtered",
                          @"success", @"test",
                          nil];
    NSDictionary *filters = [NSDictionary dictionaryWithObject:filter forKey:@"filter"];
    NSString *templateString = @"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}";
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<success instead of failure>", nil);
}

- (void)testFilterNameSpace
{
    id doubleFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return @(2 * [(NSNumber *)value doubleValue]);
    }];
    NSString *rendering = [GRMustacheTemplate renderObject:@(0.5)
                                               withFilters:@{ @"math": @{ @"double": doubleFilter } }
                                                fromString:@"{{ math.double(.) }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"1", nil);
}

@end
