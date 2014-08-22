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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_2
#import "GRMustachePublicAPITest.h"

@interface GRMustacheEachFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustacheEachFilterTest

- (void)testGRMustacheEachFilterRendersPositions
{
    id data = @{ @"array": @[@"a", @"b", @"c"] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#each(array)}}{{@index}}{{#@first}}(first){{/}}{{#@last}}(last){{/}}:{{.}} {{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"0(first):a 1:b 2(last):c ", @"");
}

- (void)testGRMustacheEachFilterTriggersRenderingObjectItems
{
    id renderingObject = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [NSString stringWithFormat:@"<%@>", [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error]];
    }];
    id data = @{ @"array": @[renderingObject, renderingObject] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#each(array)}}{{@index}}{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<0><1>", @"");
}

- (void)testGRMustacheEachFilterRendersArrayOfFilteredStringsJustAsOriginalArray
{
    // `each` filter should not alter the way an array is rendered
    id data = @{ @"array": @[@"a", @"b"] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{uppercase(.)}}>{{/}}" error:NULL] renderObject:data error:NULL];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#each(array)}}<{{uppercase(.)}}>{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering1, @"<A><B>", @"");
    XCTAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRMustacheEachFilterRendersArrayOfFalseValuesJustAsOriginalArray
{
    // `each` filter should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#each(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering1, @"<><0>", @"");
    XCTAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRMustacheEachFilterRendersEmptyArrayJustAsOriginalArray
{
    // `each` filter should not alter the way an array is rendered
    id data = @{ @"array": @[] };
    
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"<{{#array}}---{{/}}>" error:NULL] renderObject:data error:NULL];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"<{{#each(array)}}---{{/}}>" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering1, @"<>", @"");
        XCTAssertEqualObjects(rendering1, rendering2, @"");
    }
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{^array}}---{{/}}" error:NULL] renderObject:data error:NULL];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{^each(array)}}---{{/}}" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering1, @"---", @"");
        XCTAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
