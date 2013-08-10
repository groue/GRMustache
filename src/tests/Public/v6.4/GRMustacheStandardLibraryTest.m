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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_4
#import "GRMustachePublicAPITest.h"

@interface GRMustacheStandardLibraryTest : GRMustachePublicAPITest
@end

@implementation GRMustacheStandardLibraryTest

- (void)testStandardLibraryExists
{
    STAssertNotNil([GRMustache standardLibrary], @"");
}

- (void)testStandardLibraryHasUppercaseKey
{
    id filter = [[GRMustache standardLibrary] valueForKey:@"uppercase"];
    STAssertNotNil(filter, @"");
    STAssertTrue([filter conformsToProtocol:@protocol(GRMustacheFilter)], @"");
}

- (void)testHTMLescapeAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"<>"; }]};
    
    {
        NSString *templateString = @"<{{ HTML.escape(value) }}>";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"<&amp;lt;&amp;gt;>", @"");
    }
    {
        NSString *templateString = @"{{# HTML.escape }}<{{ value }} {{{ value }}}>{{/}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"<&amp;lt;&amp;gt; &lt;&gt;>", @"");
    }
}

- (void)testJavascriptEscapeAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"\"string\""; }]};
    
    {
        NSString *templateString = @"\"{{ javascript.escape(value) }}\"";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"\"\\u0022string\\u0022\"", @"");
    }
    {
        NSString *templateString = @"{{# javascript.escape }}\"{{ value }}\"{{/}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"\"\\u0022string\\u0022\"", @"");
    }
}

- (void)testURLEscapeAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"?"; }]};
    
    {
        NSString *templateString = @"<{{ URL.escape(value) }}>";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"<%3F>", @"");
    }
    {
        NSString *templateString = @"{{# URL.escape }}<{{ value }}>{{/}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        STAssertEqualObjects(rendering, @"<%3F>", @"");
    }
}

- (void)testCapitalizedAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"aB"; }]};
    
    NSString *templateString = @"<{{ capitalized(value) }}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<Ab>", @"");
}

- (void)testLowercaseAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"aB"; }]};
    
    NSString *templateString = @"<{{ lowercase(value) }}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<ab>", @"");
}

- (void)testUppercaseAppliesPostRendering
{
    id data = @{ @"value": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) { return @"aB"; }]};
    
    NSString *templateString = @"<{{ uppercase(value) }}>";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
    STAssertEqualObjects(rendering, @"<AB>", @"");
}

@end
