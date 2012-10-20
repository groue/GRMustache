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

#import "GRMustachePublicAPITest.h"

@interface GRPositionFilterItem : GRMustacheProxy {
    NSUInteger index_;
}
@property (nonatomic, readonly) NSUInteger position;
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array;
@end

@interface GRPositionFilter : NSObject<GRMustacheFilter>
@end

@implementation GRPositionFilter

- (id)transformedValue:(id)object
{
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    NSMutableArray *replacementArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        GRPositionFilterItem *item = [[[GRPositionFilterItem alloc] initWithObjectAtIndex:index fromArray:array] autorelease];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end

@interface GRPositionFilterItem()
@property (nonatomic) NSUInteger index_;
@end

@implementation GRPositionFilterItem
@synthesize index_;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array
{
    self = [super initWithDelegate:[array objectAtIndex:index]];
    if (self) {
        self.index_ = index;
    }
    return self;
}

- (NSUInteger)position
{
    return self.index_ + 1;
}

@end


@interface GRPositionFilterTest : GRMustachePublicAPITest

@end

@implementation GRPositionFilterTest

- (void)testGRPositionFilterRendersPositions
{
    // GRPositionFilter should do its job
    id data = @{ @"array": @[@"foo", @"bar"] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                               withFilters:filters
                                                fromString:@"{{#f(array)}}{{position}}:{{.}} {{/}}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"1:foo 2:bar ", @"");
}

- (void)testGRPositionFilterRendersArrayOfFalseValuesJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                 fromString:@"{{#array}}<{{.}}>{{/}}"
                                                      error:NULL];
    NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                withFilters:filters
                                                 fromString:@"{{#f(array)}}<{{.}}>{{/}}"
                                                      error:NULL];
    STAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRPositionFilterRendersEmptyArrayJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    
    {
        NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                     fromString:@"{{#array}}<{{.}}>{{/}}"
                                                          error:NULL];
        NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                    withFilters:filters
                                                     fromString:@"{{#f(array)}}<{{.}}>{{/}}"
                                                          error:NULL];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
    {
        NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                     fromString:@"{{^array}}empty{{/}}"
                                                          error:NULL];
        NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                    withFilters:filters
                                                     fromString:@"{{^f(array)}}empty{{/}}"
                                                          error:NULL];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
