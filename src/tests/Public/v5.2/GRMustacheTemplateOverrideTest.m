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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_5_2
#import "GRMustachePublicAPITest.h"

@interface GRMustacheTemplateOverrideTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateOverrideTest

- (void)testPartialOverridingItselfRaisesGRMustacheRenderingException
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:@{ @"partial": @"{{<partial}}{{/}}" }];
    NSError *error;
    GRMustacheTemplate *template = [repository templateFromString:@"{{>partial}}" error:&error];
    STAssertThrowsSpecificNamed([template render], NSException, GRMustacheRenderingException, nil);
}

- (void)testPartialOverridingCycleRaisesGRMustacheRenderingException
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:@{ @"partial1": @"{{<partial2}}{{/}}", @"partial2": @"{{<partial1}}{{/}}" }];
    NSError *error;
    GRMustacheTemplate *template = [repository templateFromString:@"{{>partial1}}" error:&error];
    STAssertThrowsSpecificNamed([template render], NSException, GRMustacheRenderingException, nil);
}

@end
