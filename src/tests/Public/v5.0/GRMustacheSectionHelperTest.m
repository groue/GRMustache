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

@interface GRMustacheSectionHelperTest : GRMustachePublicAPITest
@end

@interface GRMustacheStringSectionHelper : NSObject<GRMustacheSectionHelper> {
    NSString *_string;
}
@property (nonatomic, copy) NSString *string;
@end

@implementation GRMustacheStringSectionHelper
@synthesize string=_string;
- (void)dealloc
{
    self.string = nil;
    [super dealloc];
}
- (NSString *)renderSection:(GRMustacheSection *)section
{
    return self.string;
}
@end

@interface GRMustacheRecorderSectionHelper : NSObject<GRMustacheSectionHelper> {
    NSUInteger _invocationCount;
    NSString *_lastInnerTemplateString;
    NSString *_lastRenderedContent;
}
@property (nonatomic) NSUInteger invocationCount;
@property (nonatomic, retain) NSString *lastInnerTemplateString;
@property (nonatomic, retain) NSString *lastRenderedContent;
@end

@implementation GRMustacheRecorderSectionHelper
@synthesize invocationCount=_invocationCount;
@synthesize lastInnerTemplateString=_lastInnerTemplateString;
@synthesize lastRenderedContent=_lastRenderedContent;
- (void)dealloc
{
    self.lastInnerTemplateString = nil;
    self.lastRenderedContent = nil;
    [super dealloc];
}
- (NSString *)renderSection:(GRMustacheSection *)section
{
    self.invocationCount += 1;
    self.lastInnerTemplateString = section.innerTemplateString;
    self.lastRenderedContent = [section render];
    return self.lastRenderedContent;
}
@end

@implementation GRMustacheSectionHelperTest

- (void)testHelperPerformsRendering
{
    {
        // GRMustacheSectionHelper protocol
        GRMustacheStringSectionHelper *helper = [[[GRMustacheStringSectionHelper alloc] init] autorelease];
        helper.string = @"---";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
            return @"---";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testHelperRenderingIsNotProcessed
{
    // This test is against Mustache spec lambda definition, which render a template string that should be processed.
    
    {
        // GRMustacheSectionHelper protocol
        GRMustacheStringSectionHelper *helper = [[[GRMustacheStringSectionHelper alloc] init] autorelease];
        helper.string = @"&<>{{foo}}";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperCanRenderNil
{
    {
        // GRMustacheSectionHelper protocol
        GRMustacheStringSectionHelper *helper = [[[GRMustacheStringSectionHelper alloc] init] autorelease];
        helper.string = nil;
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
}

- (void)testHelperCanAccessInnerTemplateString
{
    {
        // GRMustacheSectionHelper protocol
        GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(helper.lastInnerTemplateString, @"{{subject}}", @"");
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        __block NSString *lastInnerTemplateString = nil;
        id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
            [lastInnerTemplateString release];
            lastInnerTemplateString = [section.innerTemplateString retain];
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
        [lastInnerTemplateString release];
    }
}

- (void)testHelperCanAccessRenderedContent
{
    {
        // GRMustacheSectionHelper protocol
        GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(helper.lastRenderedContent, @"---===---", @"");
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        __block NSString *lastRenderedContent = nil;
        id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
            [lastRenderedContent release];
            lastRenderedContent = [[section render] retain];
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(lastRenderedContent, @"---===---", @"");
        [lastRenderedContent release];
    }
}

- (void)testHelperIsNotCalledWhenItDoesntNeedTo
{
    {
        // GRMustacheSectionHelper protocol
        {
            GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)1, @"");
        }
        {
            GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderSectionHelper *helper = [[[GRMustacheRecorderSectionHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
    }
    {
        // [GRMustacheSectionHelper helperWithBlock:]
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)1, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
    }
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplate
{
    id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
        return [section renderTemplateString:@"{{subject}}" error:NULL];
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplateContainingPartial
{
    id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
        return [section renderTemplateString:@"{{>partial}}" error:NULL];
    }];
    NSDictionary *context = @{@"helper": helper};
    NSDictionary *partials = @{@"partial": @"In partial."};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{#helper}}{{/helper}}" error:nil];
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"In partial.", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledWithinSectionRendering
{
    id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
        return [section render];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if (interpretation != GRMustacheInterpretationSection) {
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
    id helper = [GRMustacheSectionHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
        return [section renderTemplateString:@"{{subject}}" error:NULL];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if (interpretation != GRMustacheInterpretationSection) {
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

@end
