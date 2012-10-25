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

//@interface GRMustacheStringSectionTagHelper : NSObject<GRMustacheSectionTagHelper> {
//    NSString *_string;
//}
//@property (nonatomic, copy) NSString *string;
//@end
//
//@implementation GRMustacheStringSectionTagHelper
//@synthesize string=_string;
//- (void)dealloc
//{
//    self.string = nil;
//    [super dealloc];
//}
//- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
//{
//    return self.string;
//}
//@end
//
//@interface GRMustacheAttributedSectionTagHelper : NSObject<GRMustacheSectionTagHelper> {
//    NSString *_attribute;
//}
//@property (nonatomic, copy) NSString *attribute;
//@end
//
//@implementation GRMustacheAttributedSectionTagHelper
//@synthesize attribute=_attribute;
//- (void)dealloc
//{
//    self.attribute = nil;
//    [super dealloc];
//}
//- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
//{
//    return [context renderString:@"{{attribute}}" error:NULL];
//}
//@end
//
//@interface GRMustacheRecorderSectionTagHelper : NSObject<GRMustacheSectionTagHelper> {
//    NSUInteger _invocationCount;
//    NSString *_lastInnerTemplateString;
//    NSString *_lastRenderedContent;
//}
//@property (nonatomic) NSUInteger invocationCount;
//@property (nonatomic, retain) NSString *lastInnerTemplateString;
//@property (nonatomic, retain) NSString *lastRenderedContent;
//@end
//
//@implementation GRMustacheRecorderSectionTagHelper
//@synthesize invocationCount=_invocationCount;
//@synthesize lastInnerTemplateString=_lastInnerTemplateString;
//@synthesize lastRenderedContent=_lastRenderedContent;
//- (void)dealloc
//{
//    self.lastInnerTemplateString = nil;
//    self.lastRenderedContent = nil;
//    [super dealloc];
//}
//- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
//{
//    self.invocationCount += 1;
//    self.lastInnerTemplateString = context.innerTemplateString;
//    self.lastRenderedContent = [context render];
//    return self.lastRenderedContent;
//}
//@end

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

//- (void)testHelperIsNotCalledWhenItDoesntNeedTo
//{
//    {
//        // GRMustacheSectionTagHelper protocol
//        {
//            GRMustacheRecorderSectionTagHelper *helper = [[[GRMustacheRecorderSectionTagHelper alloc] init] autorelease];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
//            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
//        }
//        {
//            GRMustacheRecorderSectionTagHelper *helper = [[[GRMustacheRecorderSectionTagHelper alloc] init] autorelease];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
//            STAssertEquals(helper.invocationCount, (NSUInteger)1, @"");
//        }
//        {
//            GRMustacheRecorderSectionTagHelper *helper = [[[GRMustacheRecorderSectionTagHelper alloc] init] autorelease];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
//            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
//        }
//        {
//            GRMustacheRecorderSectionTagHelper *helper = [[[GRMustacheRecorderSectionTagHelper alloc] init] autorelease];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
//            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
//        }
//    }
//    {
//        // [GRMustacheSectionTagHelper helperWithBlock:]
//        {
//            __block NSUInteger invocationCount = 0;
//            id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//                invocationCount++;
//                return nil;
//            }];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
//            STAssertEquals(invocationCount, (NSUInteger)0, @"");
//        }
//        {
//            __block NSUInteger invocationCount = 0;
//            id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//                invocationCount++;
//                return nil;
//            }];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
//            STAssertEquals(invocationCount, (NSUInteger)1, @"");
//        }
//        {
//            __block NSUInteger invocationCount = 0;
//            id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//                invocationCount++;
//                return nil;
//            }];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
//            STAssertEquals(invocationCount, (NSUInteger)0, @"");
//        }
//        {
//            __block NSUInteger invocationCount = 0;
//            id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//                invocationCount++;
//                return nil;
//            }];
//            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
//            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
//            STAssertEquals(invocationCount, (NSUInteger)0, @"");
//        }
//    }
//}
//
//- (void)testHelperCanRenderCurrentContextInDistinctTemplate
//{
//    id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//        return [context renderString:@"{{subject}}" error:NULL];
//    }];
//    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
//                             helper, @"helper",
//                             @"---", @"subject", nil];
//    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
//    STAssertEqualObjects(result, @"---", @"");
//}
//
//- (void)testHelperEnterCurrentContext
//{
//    GRMustacheAttributedSectionTagHelper *attributedHelper = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
//    attributedHelper.attribute = @"---";
//    NSString *result = [GRMustacheTemplate renderObject:@{ @"helper": attributedHelper } fromString:@"{{#helper}}{{/helper}}" error:NULL];
//    STAssertEqualObjects(result, @"---", @"");
//}
//
//- (void)testHelperCanRenderCurrentContextInDistinctTemplateContainingPartial
//{
//    id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//        return [context renderString:@"{{>partial}}" error:NULL];
//    }];
//    NSDictionary *context = @{@"helper": helper};
//    NSDictionary *partials = @{@"partial": @"In partial."};
//    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
//    GRMustacheTemplate *template = [repository templateFromString:@"{{#helper}}{{/helper}}" error:nil];
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"In partial.", @"");
//}
//
//- (void)testTemplateDelegateCallbacksAreCalledWithinSectionRendering
//{
//    id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//        return [context render];
//    }];
//    
//    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
//    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
//        if (interpretation != GRMustacheSectionTagInterpretation) {
//            invocation.returnValue = @"delegate";
//        }
//    };
//    
//    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
//                             helper, @"helper",
//                             @"---", @"subject", nil];
//    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{subject}}{{/helper}}" error:NULL];
//    template.delegate = delegate;
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"delegate", @"");
//}
//
//- (void)testTemplateDelegateCallbacksAreCalledWithinSectionAlternateTemplateStringRendering
//{
//    id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//        return [context renderString:@"{{subject}}" error:NULL];
//    }];
//    
//    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
//    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
//        if (interpretation != GRMustacheSectionTagInterpretation) {
//            invocation.returnValue = @"delegate";
//        }
//    };
//
//    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
//                             helper, @"helper",
//                             @"---", @"subject", nil];
//    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:NULL];
//    template.delegate = delegate;
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"delegate", @"");
//}
//
//- (void)testArrayOfHelpersInSectionTag
//{
//    GRMustacheStringSectionTagHelper *helper1 = [[[GRMustacheStringSectionTagHelper alloc] init] autorelease];
//    helper1.string = @"1";
//    
//    GRMustacheStringSectionTagHelper *helper2 = [[[GRMustacheStringSectionTagHelper alloc] init] autorelease];
//    helper2.string = @"2";
//    
//    id items = @{@"items": @[helper1, helper2] };
//    NSString *rendering = [GRMustacheTemplate renderObject:items fromString:@"{{#items}}{{.}}{{/items}}" error:NULL];
//    STAssertEqualObjects(rendering, @"12", @"");
//}
//
//- (void)testArrayOfHelpersInVariableTag
//{
//    GRMustacheStringSectionTagHelper *helper1 = [[[GRMustacheStringSectionTagHelper alloc] init] autorelease];
//    helper1.string = @"1";
//    
//    GRMustacheStringSectionTagHelper *helper2 = [[[GRMustacheStringSectionTagHelper alloc] init] autorelease];
//    helper2.string = @"2";
//    
//    id items = @{@"items": @[helper1, helper2] };
//    NSString *rendering = [GRMustacheTemplate renderObject:items fromString:@"{{items}}" error:NULL];
//    STAssertEqualObjects(rendering, @"12", @"");
//}
//
//- (void)testHelperCanAccessTheInnerTemplateStringOfAutomaticSectionRequiredByVariableTagRenderingArrays
//{
//    // This test is required for this sample code to work:
//    //
//    //  // item renders its position (1-based index)
//    //  id item = [GRMustacheVariableTagHelper helperWithBlock:^NSString *(GRMustacheVariableTagRenderingContext *context) {
//    //      return [context renderString:@"{{position}}" error:NULL];
//    //  }];
//    //  id data = @{ @"items": @[item] };
//    //  // Same PositionFilter as in GRMustacheIndexes sample project, which
//    //  // uses a section tag helper that needs these tests to pass.
//    //  NSDictionary *filters = [NSDictionary dictionaryWithObject:[[[PositionFilter alloc] init] autorelease] forKey:@"withPosition"];
//    //  NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{withPosition(items)}}" error:NULL];
//    //  STAssertEqualObjects(@"1", rendering, @"");
//
//    __block NSString *lastInnerTemplateString = nil;
//    id helper = [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
//        [lastInnerTemplateString release];
//        lastInnerTemplateString = [context.innerTemplateString retain];
//        return nil;
//    }];
//
//    NSDictionary *context = [NSDictionary dictionaryWithObject:@[helper] forKey:@"items"];
//
//    // {{items}} is supposedly rendered just as {{#items}}{{.}}{{/items}}.
//    // Check that section tag helpers have access to this {{.}}.
//    [GRMustacheTemplate renderObject:context fromString:@"{{items}}" error:nil];
//    STAssertEqualObjects(lastInnerTemplateString, @"{{.}}", @"");
//    
//    // {{{items}}} is supposedly rendered just as {{#items}}{{{.}}}{{/items}}.
//    // Check that section tag helpers have access to this {{{.}}}.
//    [GRMustacheTemplate renderObject:context fromString:@"{{{items}}}" error:nil];
//    STAssertEqualObjects(lastInnerTemplateString, @"{{{.}}}", @"");
//    
//    [lastInnerTemplateString release];
//}

@end
