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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_2
#import "GRMustachePublicAPITest.h"

@interface GRMustacheDefaultConfigurationTest : GRMustachePublicAPITest
@end

static BOOL defaultConfigurationHasBeenTouched = NO;

@implementation GRMustacheDefaultConfigurationTest

- (void)tearDown
{
    [super tearDown];
    
    // Restore default configuration
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    // Help test1DefaultConfigurationHasHTMLContentType test the *real* default
    // configuration.
    defaultConfigurationHasBeenTouched = YES;
}

// The digit 1 is there to have this test run first
- (void)test1DefaultConfigurationHasHTMLContentType
{
    STAssertFalse(defaultConfigurationHasBeenTouched, @"this test should run first.");
    STAssertNotNil([GRMustacheConfiguration defaultConfiguration], @"");
    STAssertEquals([GRMustacheConfiguration defaultConfiguration].contentType, GRMustacheContentTypeHTML, @"");
}

- (void)testDefaultConfigurationContentTypeHTMLHasTemplateEscapeInput
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&amp;", @"");
}

- (void)testDefaultConfigurationContentTypeTextHasTemplateEscapeInput
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&", @"");
}

- (void)testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    // Templates tell if they render HTML or text via the HTMLSafe output of the
    // -[GRMustacheTemplate renderContentWithContext:HTMLSafe:error:] method.
    //
    // There is no public way to build a context.
    //
    // Thus we'll use a rendering object that will provide us with one:
    
    GRMustacheTemplate *testedTemplate = [GRMustacheTemplate templateFromString:@"" error:NULL];
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        // API
        NSString *rendering = [testedTemplate renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasTemplateRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    // Templates tell if they render HTML or text via the HTMLSafe output of the
    // -[GRMustacheTemplate renderContentWithContext:HTMLSafe:error:] method.
    //
    // There is no public way to build a context.
    //
    // Thus we'll use a rendering object that will provide us with one:
    
    GRMustacheTemplate *testedTemplate = [GRMustacheTemplate templateFromString:@"" error:NULL];
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [testedTemplate renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{#object}}{{/object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasSectionTagRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{#object}}{{/object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasVariableTagRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

@end
