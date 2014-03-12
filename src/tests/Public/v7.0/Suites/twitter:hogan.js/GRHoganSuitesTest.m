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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_0
#import "GRMustachePublicAPITest.h"

@interface GRHoganSuitesTest : GRMustachePublicAPISuiteTest
@end

@implementation GRHoganSuitesTest

- (void)testHoganSuites
{
    [self runTestsFromResource:@"inheritable_partials.json" subdirectory:@"GRHoganSuites"];
}

- (void)testRenderingObjectInInheritedTemplateSubsections
{
    id lambda = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *alteredContent = [NSString stringWithFormat:@"altered %@", tag.innerTemplateString];
        GRMustacheTemplate *template = [tag.templateRepository templateFromString:alteredContent error:NULL];
        return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }];
    
    id templateStrings = @{ @"partial": @"{{$section1}}{{#lambda}}parent1{{/lambda}}{{/section1}} - {{$section2}}{{#lambda}}parent2{{/lambda}}{{/section2}}",
                            @"template": @"{{< partial}}{{$section1}}{{#lambda}}child1{{/lambda}}{{/section1}}{{/ partial}}" };
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:templateStrings];
    GRMustacheTemplate *template = [repo templateNamed:@"template" error:NULL];
    
    NSString *rendering = [template renderObject:@{ @"lambda": lambda } error:NULL];
    XCTAssertEqualObjects(rendering, @"altered child1 - altered parent2", @"");
}

- (void)testRenderingObjectInIncludedPartialTemplates
{
    id lambda = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *alteredContent = [NSString stringWithFormat:@"changed %@", tag.innerTemplateString];
        GRMustacheTemplate *template = [tag.templateRepository templateFromString:alteredContent error:NULL];
        return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }];
    
    id templateStrings = @{ @"parent": @"{{$section}}{{/section}}",
                            @"partial": @"{{$label}}test1{{/label}}",
                            @"template": @"{{< parent}}{{$section}}{{<partial}}{{$label}}{{#lambda}}test2{{/lambda}}{{/label}}{{/partial}}{{/section}}{{/parent}}" };
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:templateStrings];
    GRMustacheTemplate *template = [repo templateNamed:@"template" error:NULL];
    
    NSString *rendering = [template renderObject:@{ @"lambda": lambda } error:NULL];
    XCTAssertEqualObjects(rendering, @"changed test2", @"");
}

@end
