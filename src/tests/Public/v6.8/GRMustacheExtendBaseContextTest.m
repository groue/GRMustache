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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_8
#import "GRMustachePublicAPITest.h"

@interface GRMustacheExtendBaseContextTest : GRMustachePublicAPITest
@end

@implementation GRMustacheExtendBaseContextTest

- (void)testTemplateExtendBaseContextWithObject
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
    
    [template extendBaseContextWithObject:@{ @"name": @"Arthur" }];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"Arthur", @"");
    }
    {
        NSString *rendering = [template renderObject:@{ @"name": @"Bobby" } error:NULL];
        STAssertEqualObjects(rendering, @"Bobby", @"");
    }
}

- (void)testTemplateExtendBaseContextWithProtectedObject
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{precious}}" error:NULL];
    
    [template extendBaseContextWithProtectedObject:@{ @"precious": @"Gold" }];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"Gold", @"");
    }
    {
        NSString *rendering = [template renderObject:@{ @"precious": @"Lead" } error:NULL];
        STAssertEqualObjects(rendering, @"Gold", @"");
    }
}

- (void)testTemplateExtendBaseContextWithTagDelegate
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{tag}}" error:NULL];
    
    GRMustacheTestingDelegate *tagDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    tagDelegate.mustacheTagWillRenderBlock = ^(GRMustacheTag *tag, id object) { return @"delegate"; };
    [template extendBaseContextWithTagDelegate:tagDelegate];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"delegate", @"");
    }
}

- (void)testConfigurationExtendBaseContextWithObject
{
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    [configuration extendBaseContextWithObject:@{ @"name": @"Arthur" }];
    
    GRMustacheTemplateRepository *repository = [[[GRMustacheTemplateRepository alloc] init] autorelease];
    repository.configuration = configuration;
    GRMustacheTemplate *template = [repository templateFromString:@"{{name}}" error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"Arthur", @"");
    }
    {
        NSString *rendering = [template renderObject:@{ @"name": @"Bobby" } error:NULL];
        STAssertEqualObjects(rendering, @"Bobby", @"");
    }
}

- (void)testConfigurationExtendBaseContextWithProtectedObject
{
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    [configuration extendBaseContextWithProtectedObject:@{ @"precious": @"Gold" }];
    
    GRMustacheTemplateRepository *repository = [[[GRMustacheTemplateRepository alloc] init] autorelease];
    repository.configuration = configuration;
    GRMustacheTemplate *template = [repository templateFromString:@"{{precious}}" error:NULL];
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"Gold", @"");
    }
    {
        NSString *rendering = [template renderObject:@{ @"precious": @"Lead" } error:NULL];
        STAssertEqualObjects(rendering, @"Gold", @"");
    }
}

- (void)testConfigurationExtendBaseContextWithTagDelegate
{
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    GRMustacheTestingDelegate *tagDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    tagDelegate.mustacheTagWillRenderBlock = ^(GRMustacheTag *tag, id object) { return @"delegate"; };
    [configuration extendBaseContextWithTagDelegate:tagDelegate];
    
    GRMustacheTemplateRepository *repository = [[[GRMustacheTemplateRepository alloc] init] autorelease];
    repository.configuration = configuration;
    GRMustacheTemplate *template = [repository templateFromString:@"{{tag}}" error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"delegate", @"");
    }
}

@end
