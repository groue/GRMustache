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

@interface GRMustacheSectionTagTagHelperTest : GRMustachePublicAPITest
@end

@interface GRMustacheAttributedSectionTagHelper : NSObject<GRMustacheRendering> {
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
- (NSString *)renderForTag:(GRMustacheTag *)tag inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    GRMustacheTemplate *template = [templateRepository templateFromString:@"{{attribute}}" error:NULL];
    return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
}
@end

@implementation GRMustacheSectionTagTagHelperTest

- (void)testHelperPerformsRendering
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        *HTMLEscaped = NO;
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperRenderingIsHTMLEscaped
{
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
            *HTMLEscaped = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
            *HTMLEscaped = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperRenderingIsHTMLEscapedByDefault
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return @"&<>{{foo}}";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
}

- (void)testHelperCanRenderNil
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"", @"");
}

- (void)testHelperCanAccessInnerTemplateString
{
    __block NSString *lastInnerTemplateString = nil;
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        [lastInnerTemplateString release];
        lastInnerTemplateString = [tag.innerTemplateString retain];
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    [[GRMustacheTemplate templateFromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
    [lastInnerTemplateString release];
}

- (void)testHelperCanAccessRenderedContent
{
    __block NSString *lastRenderedContent = nil;
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        [lastRenderedContent release];
        lastRenderedContent = [[tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error] retain];
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    [[GRMustacheTemplate templateFromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(lastRenderedContent, @"---===---", @"");
    [lastRenderedContent release];
}

- (void)testHelperCanAccessTagType
{
    __block NSUInteger invertedSectionCount = 0;
    __block NSUInteger overridableSectionCount = 0;
    __block NSUInteger regularSectionCount = 0;
    __block NSUInteger variableCount = 0;
    __block NSUInteger maskInvertedSectionCount = 0;
    __block NSUInteger maskNonInvertedSectionCount = 0;
    __block NSUInteger maskOverridableSectionCount = 0;
    __block NSUInteger maskRegularSectionCount = 0;
    __block NSUInteger maskSectionCount = 0;
    __block NSUInteger maskVariableCount = 0;
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        switch (tag.type) {
            case GRMustacheTagTypeInvertedSection:
                ++invertedSectionCount;
                break;
                
            case GRMustacheTagTypeOverridableSection:
                ++overridableSectionCount;
                break;
                
            case GRMustacheTagTypeRegularSection:
                ++regularSectionCount;
                break;
                
            case GRMustacheTagTypeVariable:
                ++variableCount;
                break;
        }
        if (tag.type & GRMustacheTagTypeMaskInvertedSection) {
            maskInvertedSectionCount++;
        }
        if (tag.type & GRMustacheTagTypeMaskNonInvertedSection) {
            maskNonInvertedSectionCount++;
        }
        if (tag.type & GRMustacheTagTypeMaskOverridableSection) {
            maskOverridableSectionCount++;
        }
        if (tag.type & GRMustacheTagTypeMaskRegularSection) {
            maskRegularSectionCount++;
        }
        if (tag.type & GRMustacheTagTypeMaskSection) {
            maskSectionCount++;
        }
        if (tag.type & GRMustacheTagTypeMaskVariable) {
            maskVariableCount++;
        }
        return nil;
    }];
    
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        maskInvertedSectionCount = 0;
        maskNonInvertedSectionCount = 0;
        maskOverridableSectionCount = 0;
        maskRegularSectionCount = 0;
        maskSectionCount = 0;
        maskVariableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:@{ @"helper": helper } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)1, @"");
        STAssertEquals(maskInvertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskNonInvertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskOverridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskRegularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskVariableCount, (NSUInteger)1, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        maskInvertedSectionCount = 0;
        maskNonInvertedSectionCount = 0;
        maskOverridableSectionCount = 0;
        maskRegularSectionCount = 0;
        maskSectionCount = 0;
        maskVariableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{#helper}}...{{/helper}}" error:nil] renderObject:@{ @"helper": helper } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)1, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
        STAssertEquals(maskInvertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskNonInvertedSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskOverridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskRegularSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskVariableCount, (NSUInteger)0, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        maskInvertedSectionCount = 0;
        maskNonInvertedSectionCount = 0;
        maskOverridableSectionCount = 0;
        maskRegularSectionCount = 0;
        maskSectionCount = 0;
        maskVariableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{$helper}}...{{/helper}}" error:nil] renderObject:@{ @"helper": helper } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)1, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
        STAssertEquals(maskInvertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskNonInvertedSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskOverridableSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskRegularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskVariableCount, (NSUInteger)0, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        maskInvertedSectionCount = 0;
        maskNonInvertedSectionCount = 0;
        maskOverridableSectionCount = 0;
        maskRegularSectionCount = 0;
        maskSectionCount = 0;
        maskVariableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{^helper}}...{{/helper}}" error:nil] renderObject:@{ @"helper": helper } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)1, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
        STAssertEquals(maskInvertedSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskNonInvertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskOverridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskRegularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(maskSectionCount, (NSUInteger)1, @"");
        STAssertEquals(maskVariableCount, (NSUInteger)0, @"");
    }
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplate
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
    {
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperDoNotAutomaticallyEntersCurrentContext
{
    // GRMustacheAttributedSectionTagHelper does not modify the runtime
    GRMustacheAttributedSectionTagHelper *helper = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
    helper.attribute = @"---";
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:NULL] renderObject:@{ @"helper": helper } error:NULL];
    STAssertEqualObjects(result, @"", @"");
}

- (void)testHelperCanExplicitelyExtendCurrentContext
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        runtime = [runtime runtimeByAddingContextObject:@{ @"subject": @"---" }];
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
    }];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:NULL] renderObject:@{ @"helper": helper } error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledWithinSectionRendering
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheTag *tag) {
        if (tag.type != GRMustacheTagTypeRegularSection) {
            invocation.returnValue = @"delegate";
        }
    };
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{subject}}{{/helper}}" error:NULL];
    template.delegate = delegate;
    NSString *result = [template renderObject:context error:NULL];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledWithinSectionAlternateTemplateStringRendering
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        GRMustacheTemplate *template = [templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheTag *tag) {
        if (tag.type != GRMustacheTagTypeRegularSection) {
            invocation.returnValue = @"delegate";
        }
    };

    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:NULL];
    template.delegate = delegate;
    NSString *result = [template renderObject:context error:NULL];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testArrayOfHelpersInSectionTag
{
    id helper1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return @"1";
    }];
    id helper2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}{{.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTag
{
    id helper1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return @"1";
    }];
    id helper2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTagWithInconsistentHTMLEscaping
{
    id helper1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        *HTMLEscaped = YES;
        return @"1";
    }];
    id helper2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error) {
        *HTMLEscaped = NO;
        return @"2";
    }];
    
    id items = @{@"items": @[helper1, helper2] };
    STAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, nil);
}

@end
