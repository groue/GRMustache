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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheSectionTagHelperTest : GRMustachePublicAPITest
@end

@interface GRMustacheAttributedSectionTagHelper : NSObject<GRMustacheRenderingObject> {
    NSString *_attribute;
}
@property (nonatomic, copy) NSString *attribute;
@end

@implementation GRMustacheAttributedSectionTagHelper
@synthesize attribute=_attribute;
- (void)dealloc
{
    self.attribute = nil;
    [super dealloc];
}
- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    GRMustacheTemplate *template = [templateRepository templateFromString:@"{{attribute}}" error:NULL];
    return [template renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
}
@end

@implementation GRMustacheSectionTagHelperTest

- (void)testHelperPerformsRendering
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        *HTMLEscaped = NO;
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperRenderingIsHTMLEscaped
{
    {
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperRenderingIsHTMLEscapedByDefault
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"&<>{{foo}}";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
    STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
}

- (void)testHelperCanRenderNil
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
    STAssertEqualObjects(result, @"", @"");
}

- (void)testHelperCanAccessInnerTemplateString
{
    __block NSString *lastInnerTemplateString = nil;
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        [lastInnerTemplateString release];
        lastInnerTemplateString = [section.innerTemplateString retain];
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil];
    STAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
    [lastInnerTemplateString release];
}

- (void)testHelperCanAccessRenderedContent
{
    // [GRMustacheSectionTagHelper helperWithBlock:]
    __block NSString *lastRenderedContent = nil;
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        [lastRenderedContent release];
        lastRenderedContent = [[section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped] retain];
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil];
    STAssertEqualObjects(lastRenderedContent, @"---===---", @"");
    [lastRenderedContent release];
}

- (void)testHelperCanAccessSectionInvertedProperty
{
    // [GRMustacheSectionTagHelper helperWithBlock:]
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (section && !section.isInverted) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (section && !section.isInverted) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEquals(invocationCount, (NSUInteger)1, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (section && !section.isInverted) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (section && !section.isInverted) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplate
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
    {
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperDoNotAutomaticallyEntersCurrentContext
{
    // GRMustacheAttributedSectionTagHelper does not modify the runtime
    GRMustacheAttributedSectionTagHelper *helper = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
    helper.attribute = @"---";
    NSString *result = [GRMustacheTemplate renderObject:@{ @"helper": helper } fromString:@"{{#helper}}{{/helper}}" error:NULL];
    STAssertEqualObjects(result, @"", @"");
}

- (void)testHelperCanExplicitelyExtendCurrentContext
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        runtime = [runtime runtimeByAddingContextObject:@{ @"subject": @"---" }];
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];
    NSString *result = [GRMustacheTemplate renderObject:@{ @"helper": helper } fromString:@"{{#helper}}{{/helper}}" error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledWithinSectionRendering
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if (interpretation != GRMustacheSectionTagInterpretation) {
            invocation.returnValue = @"delegate";
        }
    };
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{subject}}{{/helper}}" error:NULL];
    template.delegate = delegate;
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledWithinSectionAlternateTemplateStringRendering
{
    id helper = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if (interpretation != GRMustacheSectionTagInterpretation) {
            invocation.returnValue = @"delegate";
        }
    };

    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:NULL];
    template.delegate = delegate;
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testArrayOfHelpersInSectionTag
{
    id helper1 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"1";
    }];
    id helper2 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    NSString *rendering = [GRMustacheTemplate renderObject:items fromString:@"{{#items}}{{.}}{{/items}}" error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTag
{
    id helper1 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"1";
    }];
    id helper2 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    NSString *rendering = [GRMustacheTemplate renderObject:items fromString:@"{{items}}" error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTagWithInconsistentHTMLEscaping
{
    id helper1 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        *HTMLEscaped = YES;
        return @"1";
    }];
    id helper2 = [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        *HTMLEscaped = NO;
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    STAssertThrowsSpecificNamed([GRMustacheTemplate renderObject:items fromString:@"{{items}}" error:NULL], NSException, GRMustacheRenderingException, nil);
}

@end
