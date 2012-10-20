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

#import "PositionFilter.h"

#pragma mark - PositionFilterItem declaration

/**
 * PositionFilterItem's responsability is, given an array item and an index, to
 * render just as the item, but for the extra following keys;
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 *
 * Since it renders just as the array item, it is a subclass of the
 * GRMustacheProxy class, that is suited for this exact job.
 */
@interface PositionFilterItem : GRMustacheProxy
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array;
@end


#pragma mark - PositionFilter implementation

// Documented in PositionFilter.h
@implementation PositionFilter

/**
 * GRMustacheFilter protocol required method
 */
- (id)transformedValue:(id)object
{
    /**
     * Let's first validate the input: we can only filter arrays.
     */
    
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    
    /**
     * Let's return a new array made of PositionFilterItem instances.
     * They will provide the `position`, `isOdd` and `isFirst` keys while
     * letting original array items provide the other keys.
     */
    
    NSMutableArray *replacementArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        PositionFilterItem *item = [[PositionFilterItem alloc] initWithObjectAtIndex:index fromArray:array];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end


#pragma mark - PositionFilterItem implementation

/**
 * Let's declare a private property that stored the index: `index_`, and allows
 * us to implement the `position`, `isFirst` and `isOdd` keys.
 *
 * The underscore suffix avoids the property to pollute Mustache context:
 * your templates may contain a {{position}} tag, but it's unlikely they embed
 * any {{index_}} tags.
 */
@interface PositionFilterItem()
@property (nonatomic) NSUInteger index_;
@end

@implementation PositionFilterItem

/**
 * PositionFilterItem is a subclass of GRMustacheProxy, so that it behaves
 * just as the array item. The array item is the "delegate" of the proxy.
 *
 * Let's also store the index, so that we can compute values for `position`,
 * `isFirst`, and `isOdd`.
 */
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array
{
    // Initialize as a GRMustacheProxy with delegate:
    self = [super initWithDelegate:[array objectAtIndex:index]];
    
    // Store the index:
    if (self) {
        self.index_ = index;
    }
    return self;
}

/**
 * Support for {{position}}: returns the 1-based index of the object.
 */
- (NSUInteger)position
{
    return self.index_ + 1;
}

/**
 * Support for `{{#isFirst}}...{{/isFirst}}`: return YES if element is the
 * first.
 */
- (BOOL)isFirst
{
    return self.index_ == 0;
}

/**
 * Support for `{{#isOdd}}...{{/isOdd}}`: return YES if element's position is
 * odd.
 */
- (BOOL)isOdd
{
    return (self.index_ % 2) == 0;
}

@end


