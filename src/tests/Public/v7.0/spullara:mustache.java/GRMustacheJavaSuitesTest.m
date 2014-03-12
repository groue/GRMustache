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

@interface GRMustacheJavaSuitesTest : GRMustachePublicAPISuiteTest
- (GRMustacheTemplate *)templateNamed:(NSString *)name;
- (NSString *)expectedRenderingNamed:(NSString *)name;
- (BOOL)rendering:(NSString *)rendering isEqualToRendering:(NSString *)rendering2;
@end

@implementation GRMustacheJavaSuitesTest

#pragma mark - Utils

- (GRMustacheTemplate *)templateNamed:(NSString *)name
{
    NSString *directory = [self.testBundle pathForResource:@"GRMustacheJavaSuites" ofType:nil];
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directory templateExtension:@"html" encoding:NSUTF8StringEncoding];
    return [repo templateNamed:name error:NULL];
}

- (NSString *)expectedRenderingNamed:(NSString *)name
{
    NSString *directory = [self.testBundle pathForResource:@"GRMustacheJavaSuites" ofType:nil];
    return [NSString stringWithContentsOfFile:[directory stringByAppendingPathComponent:name] encoding:NSUTF8StringEncoding error:NULL];
}

- (BOOL)rendering:(NSString *)rendering1 isEqualToRendering:(NSString *)rendering2
{
    // GRMustache doesn't care about white space rules of the Mustache specification.
    // Compare rendering and expected rendering, but ignoring white space.
    NSCharacterSet *w = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    rendering1 = [[rendering1 componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
    rendering2 = [[rendering2 componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
    return [rendering1 isEqualToString:rendering2];
}

#pragma mark - Tests

// com.github.mustachejava.ExtensionTest.testMethod
- (void)testExtensionClientMethod
{
    GRMustacheTemplate *template = [self templateNamed:@"client"];
    id data = @{ @"reply": @"TestReply",
                 @"commands": @[ @"a", @"b" ] };
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"client.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testFollow
- (void)testExtensionFollow
{
    GRMustacheTemplate *template = [self templateNamed:@"follownomenu"];
    id data = nil;
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"follownomenu.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testMultipleExtensions
- (void)testExtensionMultipleExtensions
{
    GRMustacheTemplate *template = [self templateNamed:@"multipleextensions"];
    id data = nil;
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"multipleextensions.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

#warning Disabled test
//// com.github.mustachejava.ExtensionTest.testNested
//- (void)testExtensionNested
//{
//    GRMustacheTemplate *template = [self templateNamed:@"nested_inheritance"];
//    id data = nil;
//    NSString *rendering = [template renderObject:data error:NULL];
//    NSString *expectedRendering = [self expectedRenderingNamed:@"nested_inheritance.txt"];
//    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
//}

// com.github.mustachejava.ExtensionTest.testPartialInSub
- (void)testExtensionPartialInSub
{
    GRMustacheTemplate *template = [self templateNamed:@"partialsubpartial"];
    id data = @{ @"randomid": @"asdlkfj" };
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"partialsubpartial.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testParentReplace
- (void)testExtensionParentReplace
{
    GRMustacheTemplate *template = [self templateNamed:@"replace"];
    id data = nil;
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"replace.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testSub
- (void)testExtensionSub
{
    GRMustacheTemplate *template = [self templateNamed:@"sub"];
    id data = @{ @"name": @"Sam", @"randomid": @"asdlkfj" };
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"sub.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testSubInPartial
- (void)testExtensionSubInPartial
{
    GRMustacheTemplate *template = [self templateNamed:@"partialsub"];
    id data = @{ @"name": @"Sam", @"randomid": @"asdlkfj" };
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"sub.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testSubBlockCaching
- (void)testExtensionSubBlockCaching
{
    {
        GRMustacheTemplate *template = [self templateNamed:@"subblockchild1"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subblockchild1.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
    {
        GRMustacheTemplate *template = [self templateNamed:@"subblockchild2"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subblockchild2.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
    {
        GRMustacheTemplate *template = [self templateNamed:@"subblockchild1"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subblockchild1.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
}

// com.github.mustachejava.ExtensionTest.testSubSub
- (void)testExtensionSubSub
{
    GRMustacheTemplate *template = [self templateNamed:@"subsub"];
    id data = @{ @"name": @"Sam", @"randomid": @"asdlkfj" };
    NSString *rendering = [template renderObject:data error:NULL];
    NSString *expectedRendering = [self expectedRenderingNamed:@"subsub.txt"];
    XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
}

// com.github.mustachejava.ExtensionTest.testSubCaching
- (void)testExtensionSubCaching
{
    {
        GRMustacheTemplate *template = [self templateNamed:@"subsubchild1"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subsubchild1.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
    {
        GRMustacheTemplate *template = [self templateNamed:@"subsubchild2"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subsubchild2.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
}

// com.github.mustachejava.ExtensionTest.testSubSubCaching2
- (void)testExtensionSubSubCaching2
{
    {
        GRMustacheTemplate *template = [self templateNamed:@"subsubchild1"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subsubchild1.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
    {
        GRMustacheTemplate *template = [self templateNamed:@"subsubchild3"];
        id data = nil;
        NSString *rendering = [template renderObject:data error:NULL];
        NSString *expectedRendering = [self expectedRenderingNamed:@"subsubchild3.txt"];
        XCTAssertTrue([self rendering:rendering isEqualToRendering:expectedRendering], @"");
    }
}

@end
