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
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    GRMustacheTemplate *template = [tag.templateRepository templateFromString:@"attribute:{{attribute}}" error:NULL];
    return [template renderContext:context HTMLSafe:HTMLSafe error:error];
}
@end

@implementation GRMustacheSectionTagTagHelperTest

- (void)testRenderingObjectPerformsVariableRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsSectionRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsInvertedSectionRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{^object}}{{/object}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsOverridableSectionRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{$object}}{{/object}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsHTMLSafeVariableRendering
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testRenderingObjectPerformsHTMLSafeSectionRendering
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
}

- (void)testRenderingObjectCanSetError
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:@"GRMustacheRenderingObjectDomain" code:-1 userInfo:nil];
            }
            return nil;
        }];
        NSError *error;
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:&error];
        STAssertNil(result, @"");
        STAssertEqualObjects(error.domain, @"GRMustacheRenderingObjectDomain", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:@"GRMustacheRenderingObjectDomain" code:-1 userInfo:nil];
            }
            return nil;
        }];
        NSError *error;
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:&error];
        STAssertNil(result, @"");
        STAssertEqualObjects(error.domain, @"GRMustacheRenderingObjectDomain", @"");
    }
}

- (void)testRenderingObjectCanRenderNilWithoutSettingAnyError
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"", @"");
    }
}

- (void)testRenderingObjectCanAccessTagType
{
    __block NSUInteger invertedSectionCount = 0;
    __block NSUInteger overridableSectionCount = 0;
    __block NSUInteger regularSectionCount = 0;
    __block NSUInteger variableCount = 0;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        switch (tag.type) {
            case GRMustacheTagTypeInvertedSection:
                ++invertedSectionCount;
                break;
                
            case GRMustacheTagTypeOverridableSection:
                ++overridableSectionCount;
                break;
                
            case GRMustacheTagTypeSection:
                ++regularSectionCount;
                break;
                
            case GRMustacheTagTypeVariable:
                ++variableCount;
                break;
                
            default:
                STAssertTrue(NO, @"");
                break;
        }
        return nil;
    }];
    
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)1, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{#object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)1, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{$object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)0, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)1, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
    }
    {
        invertedSectionCount = 0;
        overridableSectionCount = 0;
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{^object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        STAssertEquals(invertedSectionCount, (NSUInteger)1, @"");
        STAssertEquals(overridableSectionCount, (NSUInteger)0, @"");
        STAssertEquals(regularSectionCount, (NSUInteger)0, @"");
        STAssertEquals(variableCount, (NSUInteger)0, @"");
    }
}

- (void)testRenderingObjectCanAccessInnerTemplateString
{
    {
        __block NSString *lastInnerTemplateString = nil;
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            lastInnerTemplateString = tag.innerTemplateString;
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertNil(lastInnerTemplateString, @"");
    }
    {
        __block NSString *lastInnerTemplateString = nil;
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            [lastInnerTemplateString release];
            lastInnerTemplateString = [tag.innerTemplateString retain];
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:object forKey:@"object"];
        [[GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
        [lastInnerTemplateString release];
    }
}

- (void)testRenderingObjectCanAccessRenderedContent
{
    __block NSString *lastRenderedContent = nil;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        [lastRenderedContent release];
        lastRenderedContent = [[tag renderContext:context HTMLSafe:HTMLSafe error:error] retain];
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             object, @"object",
                             @"---", @"subject", nil];
    [[GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}==={{subject}}{{/object}}" error:nil] renderObject:context error:NULL];
    STAssertEqualObjects(lastRenderedContent, @"---===---", @"");
    [lastRenderedContent release];
}

- (void)testRenderingObjectCanRenderCurrentContextInDistinctTemplate
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
                     {
                         GRMustacheTemplate *template = [tag.templateRepository templateFromString:@"{{subject}}" error:NULL];
                         return [template renderContext:context HTMLSafe:HTMLSafe error:error];
                     }];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 object, @"object",
                                 @"---", @"subject", nil];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"---", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
        {
            GRMustacheTemplate *template = [tag.templateRepository templateFromString:@"{{subject}}" error:NULL];
            return [template renderContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 object, @"object",
                                 @"---", @"subject", nil];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        STAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testRenderingObjectDoesNotAutomaticallyEntersCurrentContext
{
    GRMustacheAttributedSectionTagHelper *object = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
    object.attribute = @"---";
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:NULL] renderObject:@{ @"object": object } error:NULL];
    STAssertEqualObjects(result, @"attribute:", @"");
}

- (void)testRenderingObjectCanExplicitelyExtendCurrentContext
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        context = [context contextByAddingObject:@{ @"subject": @"---" }];
        GRMustacheTemplate *template = [tag.templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderContext:context HTMLSafe:HTMLSafe error:error];
    }];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:NULL] renderObject:@{ @"object": object } error:NULL];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testTagDelegateCallbacksAreCalledWithinSectionRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [tag renderContext:context HTMLSafe:HTMLSafe error:error];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        if (tag.type != GRMustacheTagTypeSection) {
            return @"delegate";
        } else {
            return object;
        }
    };
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             object, @"object",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}{{/object}}" error:NULL];
    template.tagDelegate = delegate;
    NSString *result = [template renderObject:context error:NULL];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testTagDelegateCallbacksAreCalledWithinSectionAlternateTemplateStringRendering
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        GRMustacheTemplate *template = [tag.templateRepository templateFromString:@"{{subject}}" error:NULL];
        return [template renderContext:context HTMLSafe:HTMLSafe error:error];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        if (tag.type != GRMustacheTagTypeSection) {
            return @"delegate";
        } else {
            return object;
        }
    };

    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             object, @"object",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:NULL];
    template.tagDelegate = delegate;
    NSString *result = [template renderObject:context error:NULL];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testArrayOfHelpersInSectionTag
{
    id object1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"1";
    }];
    id object2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[object1, object2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}{{.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTag
{
    id object1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"1";
    }];
    id object2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[object1, object2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
    STAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHelpersInVariableTagWithInconsistentHTMLEscaping
{
    id object1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        *HTMLSafe = YES;
        return @"1";
    }];
    id object2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        *HTMLSafe = NO;
        return @"2";
    }];
    
    id items = @{@"items": @[object1, object2] };
    STAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, nil);
}

@end
