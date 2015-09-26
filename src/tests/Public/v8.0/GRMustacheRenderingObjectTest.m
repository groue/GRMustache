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
#import "GRMustacheTestingDelegate.h"

@interface GRMustacheImplicitTrueRenderingObject : NSObject<GRMustacheRendering>
@end

@implementation GRMustacheImplicitTrueRenderingObject

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            return @"variable";
            break;
            
        case GRMustacheTagTypeSection:
            return @"section";
            break;
    }
}

@end

@interface GRMustacheRenderingObjectTest : GRMustachePublicAPITest
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
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"attribute:{{attribute}}" error:NULL];
    return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}
@end

@implementation GRMustacheRenderingObjectTest

- (void)testRenderingObjectPerformsVariableRendering
{
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = @{ @"object": object };
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
    XCTAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsSectionRendering
{
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"---";
    }];
    NSDictionary *context = @{ @"object": object };
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
    XCTAssertEqualObjects(result, @"---", @"");
}

- (void)testRenderingObjectPerformsHTMLSafeVariableRendering
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{object}}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testRenderingObjectPerformsHTMLSafeSectionRendering
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
}

- (void)testRenderingObjectCanSetError
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:@"GRMustacheRenderingObjectDomain" code:-1 userInfo:nil];
            }
            return nil;
        }];
        NSError *error;
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:&error];
        XCTAssertNil(result, @"");
        XCTAssertEqualObjects(error.domain, @"GRMustacheRenderingObjectDomain", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:@"GRMustacheRenderingObjectDomain" code:-1 userInfo:nil];
            }
            return nil;
        }];
        NSError *error;
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:&error];
        XCTAssertNil(result, @"");
        XCTAssertEqualObjects(error.domain, @"GRMustacheRenderingObjectDomain", @"");
    }
}

- (void)testRenderingObjectCanRenderNilWithoutSettingAnyError
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            return nil;
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            return nil;
        }];
        NSDictionary *context = @{ @"object": object };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"", @"");
    }
}

- (void)testRenderingObjectCanAccessTagType
{
    __block NSUInteger regularSectionCount = 0;
    __block NSUInteger variableCount = 0;
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        switch (tag.type) {
            case GRMustacheTagTypeSection:
                ++regularSectionCount;
                break;
                
            case GRMustacheTagTypeVariable:
                ++variableCount;
                break;
        }
        return nil;
    }];
    
    {
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        XCTAssertEqual(regularSectionCount, (NSUInteger)0, @"");
        XCTAssertEqual(variableCount, (NSUInteger)1, @"");
    }
    {
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{#object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        XCTAssertEqual(regularSectionCount, (NSUInteger)1, @"");
        XCTAssertEqual(variableCount, (NSUInteger)0, @"");
    }
    {
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{$object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        XCTAssertEqual(regularSectionCount, (NSUInteger)0, @"");
        XCTAssertEqual(variableCount, (NSUInteger)0, @"");
    }
    {
        regularSectionCount = 0;
        variableCount = 0;
        
        [[GRMustacheTemplate templateFromString:@"{{^object}}...{{/object}}" error:nil] renderObject:@{ @"object": object } error:NULL];
        
        XCTAssertEqual(regularSectionCount, (NSUInteger)0, @"");
        XCTAssertEqual(variableCount, (NSUInteger)0, @"");
    }
}

- (void)testRenderingObjectCanAccessInnerTemplateString
{
    {
        __block NSString *lastInnerTemplateString = nil;
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            lastInnerTemplateString = tag.innerTemplateString;
            return nil;
        }];
        NSDictionary *context = @{ @"object": object };
        [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(lastInnerTemplateString, @"", @"");
    }
    {
        __block NSString *lastInnerTemplateString = nil;
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            [lastInnerTemplateString release];
            lastInnerTemplateString = [tag.innerTemplateString retain];
            return nil;
        }];
        NSDictionary *context = @{ @"object": object };
        [[GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
        [lastInnerTemplateString release];
    }
}

- (void)testRenderingObjectCanAccessRenderedContent
{
    __block NSString *lastRenderedContent = nil;
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        [lastRenderedContent release];
        lastRenderedContent = [[tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error] retain];
        return nil;
    }];
    NSDictionary *context = @{ @"object": object, @"subject": @"---" };
    [[GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}==={{subject}}{{/object}}" error:nil] renderObject:context error:NULL];
    XCTAssertEqualObjects(lastRenderedContent, @"---===---", @"");
    [lastRenderedContent release];
}

- (void)testRenderingObjectCanRenderCurrentContextInDistinctTemplate
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testRenderingObjectCanRenderCurrentContextInDistinctTemplateContainingPartial
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{> partial}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *partials = @{@"partial": @"{{subject}}"};
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[repository templateFromString:@"{{object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{> partial}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *partials = @{@"partial": @"{{subject}}"};
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[repository templateFromString:@"{{#object}}{{/object}}" error:nil] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testRenderingObjectDoesNotAutomaticallyEntersCurrentContext
{
    {
        GRMustacheAttributedSectionTagHelper *object = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
        object.attribute = @"---";
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:NULL] renderObject:@{ @"object": object } error:NULL];
        XCTAssertEqualObjects(result, @"attribute:", @"");
    }
    {
        GRMustacheAttributedSectionTagHelper *object = [[[GRMustacheAttributedSectionTagHelper alloc] init] autorelease];
        object.attribute = @"---";
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:NULL] renderObject:@{ @"object": object } error:NULL];
        XCTAssertEqualObjects(result, @"attribute:", @"");
    }
}

- (void)testRenderingObjectCanExplicitelyExtendContextStack
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            context = [context contextByAddingObject:@{ @"subject2": @"+++" }];
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}{{subject2}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{object}}" error:NULL] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---+++", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            context = [context contextByAddingObject:@{ @"subject2": @"+++" }];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}{{subject2}}{{/object}}" error:NULL] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---+++", @"");
    }
}

- (void)testRenderingObjectCanExplicitelyExtendTagDelegateStack
{
    {
        __block NSUInteger tagWillRenderCount = 0;
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        delegate.mustacheTagWillRenderObjectBlock = ^id(GRMustacheTag *tag, id object) {
            ++tagWillRenderCount;
            return object;
        };
        
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            context = [context contextByAddingTagDelegate:delegate];
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{subject}}{{object}}{{subject}}" error:NULL] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---------", @"");
        XCTAssertEqual(tagWillRenderCount, (NSUInteger)1, @"");
    }
    {
        __block NSUInteger tagWillRenderCount = 0;
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        delegate.mustacheTagWillRenderObjectBlock = ^id(GRMustacheTag *tag, id object) {
            ++tagWillRenderCount;
            return object;
        };
        
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            context = [context contextByAddingTagDelegate:delegate];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{subject}}{{#object}}{{subject}}{{/object}}{{subject}}" error:NULL] renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"---------", @"");
        XCTAssertEqual(tagWillRenderCount, (NSUInteger)1, @"");
    }
}

- (void)testTagDelegateCallbacksAreCalledWithinSectionRendering
{
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.mustacheTagWillRenderObjectBlock = ^id(GRMustacheTag *tag, id object) {
        if (tag.type != GRMustacheTagTypeSection) {
            return @"delegate";
        } else {
            return object;
        }
    };
    
    NSDictionary *context = @{ @"object": object, @"subject": @"---" };
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#object}}{{subject}}{{/object}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingTagDelegate:delegate];
    NSString *result = [template renderObject:context error:NULL];
    XCTAssertEqualObjects(result, @"delegate", @"");
}

- (void)testTagDelegateCallbacksAreCalledWithinAlternateTemplateRendering
{
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        delegate.mustacheTagWillRenderObjectBlock = ^id(GRMustacheTag *tag, id object) {
            if (tag.type != GRMustacheTagTypeSection) {
                return @"delegate";
            } else {
                return object;
            }
        };
        
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{object}}" error:NULL];
        template.baseContext = [template.baseContext contextByAddingTagDelegate:delegate];
        NSString *result = [template renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"delegate", @"");
    }
    {
        id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
            return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }];
        
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        delegate.mustacheTagWillRenderObjectBlock = ^id(GRMustacheTag *tag, id object) {
            if (tag.type != GRMustacheTagTypeSection) {
                return @"delegate";
            } else {
                return object;
            }
        };
        
        NSDictionary *context = @{ @"object": object, @"subject": @"---" };
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#object}}{{/object}}" error:NULL];
        template.baseContext = [template.baseContext contextByAddingTagDelegate:delegate];
        NSString *result = [template renderObject:context error:NULL];
        XCTAssertEqualObjects(result, @"delegate", @"");
    }
}

- (void)testArrayOfRenderingObjectsInSectionTag
{
    id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"1";
    }];
    id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[object1, object2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}{{.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    XCTAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfRenderingObjectsInVariableTag
{
    id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"1";
    }];
    id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"2";
    }];
    
    id items = @{@"items": @[object1, object2] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
    XCTAssertEqualObjects(rendering, @"12", @"");
}

- (void)testArrayOfHTMLSafeRenderingObjectsInVariableTag
{
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"<1><2>", @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{{items}}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"<1><2>", @"");
    }
}

- (void)testArrayOfHTMLUnsafeRenderingObjectsInVariableTag
{
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"&lt;1&gt;&lt;2&gt;", @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{{items}}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"<1><2>", @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"&lt;1&gt;&lt;2&gt;", @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"<1>";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"<2>";
        }];
        id items = @{@"items": @[object1, object2] };
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{{items}}}" error:NULL] renderObject:items error:NULL];
        XCTAssertEqualObjects(rendering, @"<1><2>", @"");
    }
}

- (void)testArrayOfRenderingObjectsWithInconsistentHTMLEscapingInVariableTag
{
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"1";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"2";
        }];
        
        id items = @{@"items": @[object1, object2] };
        XCTAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"1";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"2";
        }];
        
        id items = @{@"items": @[object1, object2] };
        XCTAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"1";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"2";
        }];
        
        id items = @{@"items": @[object1, object2] };
        XCTAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{{items}}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, @"");
    }
    {
        id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"1";
        }];
        id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            // implicitly not safe
            return @"2";
        }];
        
        id items = @{@"items": @[object1, object2] };
        XCTAssertThrowsSpecificNamed([[GRMustacheTemplate templateFromString:@"{{{items}}}" error:NULL] renderObject:items error:NULL], NSException, GRMustacheRenderingException, @"");
    }
}

- (void)testRenderingFacetOfTemplate
{
    NSDictionary *partials = @{ @"partial": @"In partial." };
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    
    NSDictionary *context = @{ @"partial": [repository templateNamed:@"partial" error:NULL] };
    NSString *result = [[repository templateFromString:@"{{partial}}" error:NULL] renderObject:context error:NULL];
    
    XCTAssertEqualObjects(result, @"In partial.", @"");
}

- (void)testTemplateAreNotHTMLEscaped
{
    NSDictionary *partials = @{ @"partial": @"&<>{{foo}}" };
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    
    NSDictionary *context = @{ @"partial": [repository templateNamed:@"partial" error:NULL] };
    NSString *result = [[repository templateFromString:@"{{partial}}{{{partial}}}" error:NULL] renderObject:context error:NULL];
    
    XCTAssertEqualObjects(result, @"&<>&<>", @"");
}

- (void)testCurrentTemplateRepositoryIsAvailableForRenderingObjects
{
    NSDictionary *partials = @{ @"partial": @"partial" };
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    id data = @{ @"renderingObject" : [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{> partial }}" error:NULL];
        return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }]};
    GRMustacheTemplate *template = [repo templateFromString:@"{{renderingObject}}" error:NULL];
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"partial");
}

- (void)testCurrentTemplateRepositoryIsUpdatedByDynamicPartials
{
    NSDictionary *partials1 = @{ @"template1": @"{{ renderingObject }}|{{ template2 }}",
                                 @"partial": @"partial1" };
    GRMustacheTemplateRepository *repo1 = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials1];
    
    NSDictionary *partials2 = @{ @"template2": @"{{ renderingObject }}",
                                 @"partial": @"partial2" };
    GRMustacheTemplateRepository *repo2 = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials2];
    
    id data = @{ @"template2": [repo2 templateNamed:@"template2" error:NULL],
                 @"renderingObject" : [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                     GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{> partial }}" error:NULL];
                     return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                 }]};
    GRMustacheTemplate *template = [repo1 templateNamed:@"template1" error:NULL];
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"partial1|partial2");
}

- (void)testCurrentContentTypeIsAvailableForRenderingObjects
{
    id data = @{ @"value": @"&",
                 @"renderingObject" : [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                     GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{ value }}" error:NULL];
                     return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                 }]};
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{%CONTENT_TYPE:HTML}}{{renderingObject}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"&amp;");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{%CONTENT_TYPE:TEXT}}{{renderingObject}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"&");
    }
}

- (void)testCurrentContentTypeIsUpdatedByPartials
{
    NSDictionary *partialsHTML = @{ @"templateHTML": @"{{ renderingObject }}|{{> templateText }}",
                                    @"templateText": @"{{% CONTENT_TYPE:TEXT }}{{ renderingObject }}"};
    GRMustacheTemplateRepository *repoHTML = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsHTML];
    
    id data = @{ @"value": @"&",
                 @"renderingObject" : [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                     GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{ value }}" error:NULL];
                     return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                 }]};
    GRMustacheTemplate *template = [repoHTML templateNamed:@"templateHTML" error:NULL];
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"&amp;|&amp;");
}

- (void)testCurrentContentTypeIsUpdatedByDynamicPartials
{
    NSDictionary *partialsHTML = @{ @"templateHTML": @"{{ renderingObject }}|{{ templateText }}" };
    GRMustacheTemplateRepository *repoHTML = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsHTML];
    
    NSDictionary *partialsText = @{ @"templateText": @"{{ renderingObject }}" };
    GRMustacheTemplateRepository *repo2 = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsText];
    repo2.configuration.contentType = GRMustacheContentTypeText;
    
    id data = @{ @"value": @"&",
                 @"templateText": [repo2 templateNamed:@"templateText" error:NULL],
                 @"renderingObject" : [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                     GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{{ value }}}" error:NULL];
                     return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                 }]};
    GRMustacheTemplate *template = [repoHTML templateNamed:@"templateHTML" error:NULL];
    NSString *rendering = [template renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"&|&amp;");
}


- (void)testImplicitTrueRenderingObjects
{
    id object = [[[GRMustacheImplicitTrueRenderingObject alloc] init] autorelease];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
}

- (void)testImplicitTrueRenderingObjectsWithBlocks
{
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        switch (tag.type) {
            case GRMustacheTagTypeVariable:
                return @"variable";
                break;
                
            case GRMustacheTagTypeSection:
                return @"section";
                break;
        }
    }];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
}

- (void)testArrayOfRenderingObjectsInSectionTagDoesNotNeedExplicitInvocation
{
    id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *tagRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return [NSString stringWithFormat:@"[1:%@]", tagRendering];
    }];
    id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *tagRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return [NSString stringWithFormat:@"[2:%@]", tagRendering];
    }];
    
    id items = @{@"items": @[object1, object2, @YES, @NO] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    XCTAssertEqualObjects(rendering, @"[1:---][2:---]------,[1:---][2:---]---", @"");
}

@end
