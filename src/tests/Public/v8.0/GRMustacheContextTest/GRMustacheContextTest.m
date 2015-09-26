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

@interface GRMustacheContextTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextTest

- (void)testContextWithObjectConstructor
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        XCTAssertEqualObjects(rendering, @"", @"");
    }
    {
        id data = @{ @"foo": @"bar" };
        template.baseContext = [GRMustacheContext contextWithObject:data];
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"bar", @"");
    }
}

- (void)testContextWithObjectConstructorHaveTagDelegatesEnterTagDelegateStack
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{mustacheTagWillRenderObjectBlock}}" error:NULL];
    
    __block id value = nil;
    GRMustacheTestingDelegate *tagDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    tagDelegate.mustacheTagWillRenderObjectBlock = ^(GRMustacheTag *tag, id object) {
        value = object;
        return object;
    };
    template.baseContext = [GRMustacheContext contextWithObject:tagDelegate];
    NSString *rendering = [template renderObject:nil error:NULL];
    XCTAssertEqual(value, (id)(tagDelegate.mustacheTagWillRenderObjectBlock), @"");
    XCTAssertTrue(rendering.length > 0, @"");
}

- (void)testContextWithProtectedObjectConstructor
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe}} {{foo}}" error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        XCTAssertEqualObjects(rendering, @" ", @"");
    }
    {
        id protectedData = @{ @"safe": @"success" };
        template.baseContext = [GRMustacheContext contextWithProtectedObject:protectedData];
        id data = @{ @"safe": @"failure", @"foo": @"bar" };
        NSString *rendering = [template renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering, @"success bar", @"");
    }
}

- (void)testContextWithTagDelegateConstructor
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    
    __block id value = nil;
    GRMustacheTestingDelegate *tagDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    tagDelegate.mustacheTagWillRenderObjectBlock = ^(GRMustacheTag *tag, id object) {
        value = object;
        return object;
    };
    template.baseContext = [GRMustacheContext contextWithTagDelegate:tagDelegate];
    id data = @{ @"foo": @"bar" };
    [template renderObject:data error:NULL];
    XCTAssertEqualObjects(value, @"bar", @"");
}

@end
