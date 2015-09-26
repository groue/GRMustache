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

@interface GRMustachePositionFilter : NSObject<GRMustacheFilter>
@end

@implementation GRMustachePositionFilter

- (id)transformedValue:(id)object
{
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        
        switch (tag.type) {
            case GRMustacheTagTypeSection: {
                // {{# f(...) }}...{{/}}
                
                // Custom rendering for non-inverted sections:
                
                __block NSMutableString *buffer = [NSMutableString string];
                
                [array enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
                    GRMustacheContext *itemContext = [context contextByAddingObject:@{ @"position": @(index + 1) }];
                    itemContext = [itemContext contextByAddingObject:item];
                    
                    NSString *rendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
                    if (rendering) {
                        [buffer appendString:rendering];
                    } else {
                        buffer = nil;
                        *stop = YES;
                    }
                }];
                
                return buffer;
            }
                
            default:
                // Genuine Mustache rendering otherwise
                
                return [[GRMustacheRendering renderingObjectForObject:array] renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
        }
    }];
}

@end


@interface GRMustachePositionFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustachePositionFilterTest

- (void)testGRMustachePositionFilterRendersPositions
{
    // GRMustachePositionFilter should do its job
    id data = @{ @"array": @[@"foo", @"bar"], @"f": [[[GRMustachePositionFilter alloc] init] autorelease] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}{{position}}:{{.}} {{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering, @"1:foo 2:bar ", @"");
}

- (void)testGRMustachePositionFilterRendersArrayOfFalseValuesJustAsOriginalArray
{
    // GRMustachePositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO], @"f": [[[GRMustachePositionFilter alloc] init] autorelease] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
    XCTAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRMustachePositionFilterRendersEmptyArrayJustAsOriginalArray
{
    // GRMustachePositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[], @"f": [[[GRMustachePositionFilter alloc] init] autorelease] };
    
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data error:NULL];
        XCTAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
