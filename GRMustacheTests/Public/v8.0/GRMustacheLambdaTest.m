// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
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

@interface GRMustacheLambdaTest : GRMustachePublicAPITest

@end

@implementation GRMustacheLambdaTest


- (void)testMustacheSpecInterpolation
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L15
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @"world"; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"Hello, {{lambda}}!" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"Hello, world!");
}

- (void)testMustacheSpecInterpolationExpansion
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L29
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @"{{planet}}"; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"Hello, {{lambda}}!" error:NULL];
    id data = @{
                @"planet": @"world",
                @"lambda": lambda,
                };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"Hello, world!");
}

- (void)testMustacheSpecInterpolationAlternateDelimiters
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L44
    // With a difference: remove the "\n" character because GRMustache does
    // not honor mustache spec white space rules.
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @"|planet| => {{planet}}"; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{= | | =}}Hello, (|&lambda|)!" error:NULL];
    id data = @{
                @"planet": @"world",
                @"lambda": lambda,
                };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"Hello, (|planet| => world)!");
}

- (void)testMustacheSpecMultipleCalls
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L59
    __block NSUInteger calls = 0;
    id lambda = [GRMustacheLambda lambda:^NSString *{
        ++calls;
        return [NSString stringWithFormat:@"%@", @(calls)];
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{lambda}} == {{{lambda}}} == {{lambda}}" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"1 == 2 == 3");
}

- (void)testMustacheSpecEscaping
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L73
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @">"; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{lambda}}{{{lambda}}}" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<&gt;>");
}

- (void)testMustacheSpecSection
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L87
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) {
        if ([string isEqualToString:@"{{x}}"]) {
            return @"yes";
        } else {
            return @"no";
        }
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#lambda}}{{x}}{{/lambda}}>" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<yes>");
}

- (void)testMustacheSpecSectionExpansion
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L102
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) {
        return [NSString stringWithFormat:@"%@{{planet}}%@", string, string];
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#lambda}}-{{/lambda}}>" error:NULL];
    id data = @{
                @"planet": @"Earth",
                @"lambda": lambda,
                };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<-Earth->");
}

- (void)testMustacheSpecSectionAlternateDelimiters
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L117
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) {
        return [NSString stringWithFormat:@"%@{{planet}} => |planet|%@", string, string];
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{= | | =}}<|#lambda|-|/lambda|>" error:NULL];
    id data = @{
                @"planet": @"Earth",
                @"lambda": lambda,
                };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<-{{planet}} => Earth->");
}

- (void)testMustacheSpecSectionMultipleCalls
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L132
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) {
        return [NSString stringWithFormat:@"__%@__", string];
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"__FILE__ != __LINE__");
}

- (void)testMustacheSpecInvertedSection
{
    // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L146
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) {
        return @"";
    }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{^lambda}}{{static}}{{/lambda}}>" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<>");
}

- (void)testPartialInArity0Lambda
{
    // Lambda can't render partials
    NSDictionary *partials = @{ @"partial" : @"success" };
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @"{{>partial}}"; }];
    GRMustacheTemplate *template = [repo templateFromString:@"<{{lambda}}>" error:NULL];
    id data = @{ @"lambda": lambda };
    NSError *error;
    NSString *rendering = [template renderObject:data error:&error];
    XCTAssertNil(rendering);
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain);
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound);
}

- (void)testPartialInArity1Lambda
{
    // Lambda can't render partials
    NSDictionary *partials = @{ @"partial" : @"success" };
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) { return @"{{>partial}}"; }];
    GRMustacheTemplate *template = [repo templateFromString:@"<{{#lambda}}...{{/lambda}}>" error:NULL];
    id data = @{ @"lambda": lambda };
    NSError *error;
    NSString *rendering = [template renderObject:data error:&error];
    XCTAssertNil(rendering);
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain);
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound);
}

- (void)testArity0LambdaInSectionTag
{
    id lambda = [GRMustacheLambda lambda:^NSString *{ return @"success"; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#lambda}}<{{.}}>{{/lambda}}" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<success>");
}

- (void)testArity1LambdaInVariableTag
{
    id lambda = [GRMustacheLambda sectionLambda:^NSString *(NSString *string) { return string; }];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{lambda}}>" error:NULL];
    id data = @{ @"lambda": lambda };
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<(Lambda)>");
}

@end
