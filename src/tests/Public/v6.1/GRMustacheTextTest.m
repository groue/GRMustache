// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

@interface GRMustacheTextTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTextTest

- (void)testRENDERPragmaCanNotFollowVariableTag
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{% RENDER:TEXT }}" error:NULL];
    STAssertNil(template, @"");
}

- (void)testRENDERPragmaCanNotFollowSectionTag
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{/foo}}{{% RENDER:TEXT }}" error:NULL];
        STAssertNil(template, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{/foo}}{{% RENDER:TEXT }}" error:NULL];
        STAssertNil(template, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{$foo}}{{/foo}}{{% RENDER:TEXT }}" error:NULL];
        STAssertNil(template, @"");
    }
}

- (void)testRENDERPragmaCanNotEnterSectionTag
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{% RENDER:TEXT }}{{/foo}}" error:NULL];
        STAssertNil(template, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{% RENDER:TEXT }}{{/foo}}" error:NULL];
        STAssertNil(template, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{$foo}}{{% RENDER:TEXT }}{{/foo}}" error:NULL];
        STAssertNil(template, @"");
    }
}

- (void)testRENDERPragmaCanNotFollowPartialTag
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:@{@"foo":@"bar"}];
    GRMustacheTemplate *template = [repository templateFromString:@"{{>foo}}{{% RENDER:TEXT }}" error:NULL];
    STAssertNil(template, @"");
}

- (void)testPartialOverridingAcceptsTemplatesWithIdenticalHTMLSafety
{
    {
        NSDictionary *partials = @{
            @"template": @"{{% RENDER:TEXT }}{{<layout}}{{$content}}{{subject}}{{{subject}}}{{/content}}{{/layout}}",
            @"layout": @"{{% RENDER:TEXT }}{{subject}}{{{subject}}} = {{$content}}{{/content}}"
        };
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        GRMustacheTemplate *template = [repository templateNamed:@"template" error:NULL];
        STAssertNotNil(template, @"");
    }
    {
        NSDictionary *partials = @{
            @"template": @"{{% RENDER:HTML }}{{<layout}}{{$content}}{{subject}}{{{subject}}}{{/content}}{{/layout}}",
            @"layout": @"{{subject}}{{{subject}}} = {{$content}}{{/content}}"
        };
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        GRMustacheTemplate *template = [repository templateNamed:@"template" error:NULL];
        STAssertNotNil(template, @"");
    }
}

- (void)testPartialOverridingRequiresTemplatesWithIdenticalHTMLSafety
{
    {
        NSDictionary *partials = @{
            @"template": @"{{% RENDER:TEXT }}{{<layout}}{{$content}}{{subject}}{{{subject}}}{{/content}}{{/layout}}",
            @"layout": @"{{subject}}{{{subject}}} = {{$content}}{{/content}}"
        };
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        GRMustacheTemplate *template = [repository templateNamed:@"template" error:NULL];
        STAssertNil(template, @"");
    }
    {
        NSDictionary *partials = @{
            @"template": @"{{<layout}}{{$content}}{{subject}}{{{subject}}}{{/content}}{{/layout}}",
            @"layout": @"{{% RENDER:TEXT }}{{subject}}{{{subject}}} = {{$content}}{{/content}}"
        };
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        GRMustacheTemplate *template = [repository templateNamed:@"template" error:NULL];
        STAssertNil(template, @"");
    }
}

@end
