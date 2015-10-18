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
    id data = @{
        @"name" : @"Name",
        @"uppercase": [GRMustacheFilter filterWithBlock:^id(id value) {
            return [[value description] uppercaseString];
        }],
        @"prefix": [GRMustacheFilter filterWithBlock:^id(id value) {
            return [NSString stringWithFormat:@"prefix%@", [value description]];
        }],
    };
    
    NSString *templateString = @"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>";
    NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>");
}

- (void)testScopedValueAreExtractedOutOfAFilterExpression
{
    NSString *templateString = @"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    {
        id data = @{
            @"object" : @{
                @"name": @"objectName",
            },
            @"name": @"rootName",
            @"f": [GRMustacheFilter filterWithBlock:^id(id value) {
                return value;
            }],
        };
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"<objectName> <objectName>");
    }
    
    {
        id data = @{
            @"object" : @{
                @"name": @"objectName",
            },
            @"name": @"rootName",
            @"f": [GRMustacheFilter filterWithBlock:^id(id value) {
                return @{ @"name": @"filterName" };
            }],
        };
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"<filterName> <filterName>");
    }
    
    {
        id data = @{
            @"object" : @{
                @"name": @"objectName",
            },
            @"name": @"rootName",
            @"f": [GRMustacheFilter filterWithBlock:^id(id value) {
                return @{};
            }],
        };
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"<> <rootName>");
    }
}

- (void)testFilteredSectionClosingTagCanHaveDifferentWhiteSpaceThanSectionOpeningTag
{
    NSString *templateString = @"{{#a(b)}}{{/ \t\na \t\n( \t\nb \t\n) \t\n}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    XCTAssertNotNil(template);
}

- (void)testFilteredSectionClosingTagCanBeBlank
{
    NSString *templateString = @"<{{#uppercase(.)}}{{.}}{{/}}> <{{#uppercase(.)}}{{.}}{{/ }}>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    XCTAssertNotNil(template);
    [template extendBaseContextWithObject:@{ @"uppercase": [GRMustacheFilter filterWithBlock:^(id object) {
        return [[object description] uppercaseString];
    }]}];
    NSString *rendering = [template renderObject:@"foo" error:NULL];
    XCTAssertEqualObjects(rendering, @"<FOO> <FOO>");
}

- (void)testFilteredSectionClosingTagCanNotBeInvalid
{
    NSString *templateString = @"<{{#uppercase(.)}}{{.}}{{/uppercase(.}}>";
    NSError *error;
    XCTAssertNil([GRMustacheTemplate templateFromString:templateString error:&error]);
    XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);
}

- (void)testFilterArgumentsDoNotEnterSectionContextStack
{
    id data = @{
        @"test": @"success",
        @"filtered": @{
            @"test": @"failure",
        },
        @"filter": [GRMustacheFilter filterWithBlock:^id(id value) {
            return @"filter";
        }],
    };
    NSString *templateString = @"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}";
    NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<success instead of failure>");
}

- (void)testFilterNameSpace
{
    id data = @{
        @"x": @(0.5),
        @"math": @{
            @"double": [GRMustacheFilter filterWithBlock:^id(id value) {
                return @(2 * [(NSNumber *)value doubleValue]);
            }],
        },
    };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{ math.double(x) }}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"1");
}

- (void)testFiltersCanReturnFilters
{
    id data = @{
        @"prefix": @"prefix",
        @"value": @"value",
        @"f": [GRMustacheFilter filterWithBlock:^id(id value1) {
            return [GRMustacheFilter filterWithBlock:^id(id value2) {
                return [NSString stringWithFormat:@"%@%@", value1, value2];
            }];
        }],
    };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{f(prefix)(value)}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"prefixvalue", @"");
}

- (void)testImplicitIteratorCanReturnFilter
{
    {
        id data = [GRMustacheFilter filterWithBlock:^id(id value) { return @"filter"; }];
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{.(a)}}" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"filter", @"");
    }
    {
        id data = @{ @"f": [GRMustacheFilter filterWithBlock:^id(id value) { return @"filter"; }] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{.f(a)}}" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"filter", @"");
    }
}

- (void)testImplicitIteratorCanBeVariadicFilterArgument
{
    id data = @{
        @"f": [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
            NSMutableString *buffer = [NSMutableString string];
            for (NSDictionary *dictionary in arguments) {
                [buffer appendFormat:@"%d", (int)[dictionary count]];
            }
            return buffer;
        }],
        @"foo": @{ @"a":@"a", @"b":@"b", @"c":@"c" },
    };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{f(foo,.)}} {{f(.,foo)}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"32 23", @"");
}

- (void)testMissingFilterError
{
    id data = @{
                @"name": @"Name",
                @"replace": [GRMustacheFilter filterWithBlock:^id(id value) {
                    return @"replace";
                }],
                };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(missing)}}>" error:NULL];
        XCTAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        XCTAssertNil(rendering, @"WTF");
        XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        XCTAssertEqual(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(name)}}>" error:NULL];
        XCTAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        XCTAssertNil(rendering, @"WTF");
        XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        XCTAssertEqual(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{replace(missing(name))}}>" error:NULL];
        XCTAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        XCTAssertNil(rendering, @"WTF");
        XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        XCTAssertEqual(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(replace(name))}}>" error:NULL];
        XCTAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        XCTAssertNil(rendering, @"WTF");
        XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        XCTAssertEqual(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
}

- (void)testNotAFilterError
{
    id data = @{
                @"name": @"Name",
                @"filter": @"filter",
                };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{filter(name)}}>" error:NULL];
    XCTAssertNotNil(template, @"");
    NSError *error;
    NSString *rendering = [template renderObject:data error:&error];
    XCTAssertNil(rendering, @"WTF");
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    XCTAssertEqual(error.code, GRMustacheErrorCodeRenderingError, @"");
}

@end
