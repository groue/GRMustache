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

- (void)testStandardLibraryHTMLEscapeDoesEscapeNonHTMLSafeRenderingObjects
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<";
        }];
        id data = @{ @"object": object };
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# HTML.escape }}{{ object }}{{/ }}" error:NULL];
        STAssertEqualObjects(rendering, @"&amp;lt;", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = NO;
            return @"<";
        }];
        id data = @{ @"object": object };
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# HTML.escape }}{{{ object }}}{{/ }}" error:NULL];
        STAssertEqualObjects(rendering, @"&lt;", @"");
    }
}

- (void)testStandardLibraryHTMLEscapeDoesEscapeHTMLSafeRenderingObjects
{
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<br>";
        }];
        id data = @{ @"object": object };
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# HTML.escape }}{{ object }}{{/ }}" error:NULL];
        STAssertEqualObjects(rendering, @"&lt;br&gt;", @"");
    }
    {
        id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            *HTMLSafe = YES;
            return @"<br>";
        }];
        id data = @{ @"object": object };
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# HTML.escape }}{{{ object }}}{{/ }}" error:NULL];
        STAssertEqualObjects(rendering, @"&lt;br&gt;", @"");
    }
}

- (void)testStandardLibraryJavascriptEscapeDoesEscapeRenderingObjects
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"\"double quotes\" and 'single quotes'";
    }];
    id data = @{ @"object": object };
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# javascript.escape }}{{ object }}{{/ }}" error:NULL];
    STAssertEqualObjects(rendering, @"\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027", @"");
}

- (void)testStandardLibraryURLEscapeDoesEscapeRenderingObjects
{
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"&";
    }];
    id data = @{ @"object": object };
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{# URL.escape }}{{ object }}{{/ }}" error:NULL];
    STAssertEqualObjects(rendering, @"%26", @"");
}

@end
