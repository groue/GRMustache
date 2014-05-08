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

#import "GRMustachePrivateAPITest.h"
#import "GRMustacheTemplateGenerator_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheTemplateGeneratorTest : GRMustachePrivateAPITest
@end

@implementation GRMustacheTemplateGeneratorTest

- (void)testTemplateGeneration
{
    NSDictionary *partials = @{@"template": @"|{{>partial}}|{{<partial}}{{$a}}b{{/a}}{{/partial}}{{c}}{{#d}}e{{^f}}g{{/f}}g{{/d}}h{{&i}}",
                               @"partial": @""};
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    GRMustacheTemplate *template = [repo templateNamed:@"template" error:NULL];
    GRMustacheTemplateGenerator *generator = [GRMustacheTemplateGenerator templateGeneratorWithTemplateRepository:template.templateRepository];
    NSString *generatedTemplateString = [generator templateStringWithTemplate:template];
    XCTAssertEqualObjects([partials objectForKey:@"template"], generatedTemplateString);
}

@end
