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

@interface GRMustachePositionFilter_7_2 : NSObject<GRMustacheFilter>
@end

@implementation GRMustachePositionFilter_7_2

- (id)transformedValue:(id<NSFastEnumeration>)objects
{
    NSMutableArray *renderingObjects = [NSMutableArray array];
    NSUInteger index = 0;
    for (id object in objects) {
        id<GRMustacheRendering> original = [GRMustacheRendering renderingObjectForObject:object];
        id<GRMustacheRendering> renderingObject = [GRMustacheRendering renderingObjectWithBoolValue:original.mustacheBoolValue block:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            context = [context contextByAddingObject:@{ @"position": @(index + 1) }];
            return [original renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
        }];
        [renderingObjects addObject:renderingObject];
        ++index;
    }
    return renderingObjects;
}

@end


@interface GRMustachePositionFilter_7_2_Test : GRMustachePublicAPITest

@end

@implementation GRMustachePositionFilter_7_2_Test

- (void)testGRMustachePositionFilter_7_2_rendersPositions
{
    // GRMustachePositionFilter_7_2 should do its job
    id data = @{ @"array": @[@"foo", @"bar"], @"f": [[[GRMustachePositionFilter_7_2 alloc] init] autorelease] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}{{position}}:{{.}} {{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"1:foo 2:bar ", @"");
}

- (void)testGRMustachePositionFilter_7_2_triggersRenderingObjectItems
{
    id renderingObject = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [NSString stringWithFormat:@"<%@>", [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error]];
    }];
    id data = @{ @"array": @[renderingObject, renderingObject], @"f": [[[GRMustachePositionFilter_7_2 alloc] init] autorelease] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}{{position}} {{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"<1 ><2 >", @"");
}

- (void)testGRMustachePositionFilter_7_2_rendersArrayOfFilteredStringsJustAsOriginalArray
{
    // GRMustachePositionFilter_7_2 should not alter the way an array is rendered
    id data = @{ @"array": @[@"a", @"b"], @"f": [[[GRMustachePositionFilter_7_2 alloc] init] autorelease] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{uppercase(.)}}>{{/}}" error:NULL] renderObject:data error:NULL];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{uppercase(.)}}>{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering1, @"<A><B>", @"");
    XCTAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRMustachePositionFilter_7_2_rendersArrayOfFalseValuesJustAsOriginalArray
{
    // GRMustachePositionFilter_7_2 should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO], @"f": [[[GRMustachePositionFilter_7_2 alloc] init] autorelease] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering1, @"<><0>", @"");
    XCTAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRMustachePositionFilter_7_2_rendersEmptyArrayJustAsOriginalArray
{
    // GRMustachePositionFilter_7_2 should not alter the way an array is rendered
    id data = @{ @"array": @[], @"f": [[[GRMustachePositionFilter_7_2 alloc] init] autorelease] };
    
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"<{{#array}}---{{/}}>" error:NULL] renderObject:data error:NULL];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"<{{#f(array)}}---{{/}}>" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering1, @"<>", @"");
        XCTAssertEqualObjects(rendering1, rendering2, @"");
    }
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{^array}}---{{/}}" error:NULL] renderObject:data error:NULL];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{^f(array)}}---{{/}}" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering1, @"---", @"");
        XCTAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
