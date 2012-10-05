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
 * PositionFilterItem's responsability is, given an object and an index, to
 * have a Mustache section render values for the `position`, `isOdd`, and
 * `isFirst` identifiers, while letting the wrapped object provide his own keys.
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilterItem : NSObject
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) BOOL isFirst;
@property (nonatomic, readonly) BOOL isOdd;
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
 * Let's make PositionFilterItem a section tag helper, and give him two private
 * properties: `array_` and `item_` in order to store its state. The underscore
 * suffix avoids those properties to pollute Mustache context: it's unlikely
 * that your templates contain any {{array_}} or {{index_}} tags.
 *
 * @see renderForSectionTagInContext: implementation
 */
@interface PositionFilterItem()<GRMustacheSectionTagHelper>
@property (nonatomic, strong) NSArray *array_;
@property (nonatomic) NSUInteger index_;
@end

@implementation PositionFilterItem

- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.index_ = index;
        self.array_ = array;
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

#pragma mark GRMustacheSectionTagHelper

/**
 * GRMustacheSectionTagHelper protocol implementation.
 *
 * Wrap the section inner template string inside another section:
 *
 *     {{#originalObject_}}...{{/originalObject_}}
 *
 * The `originalObject_` key returns the original object, so
 * that when the innerTemplateString is rendered, both the position filter item
 * and its original object are in the context stack, each of them ready to
 * provide their own keys to the Mustache engine.
 *
 * @see originalObject_ implementation below
 *
 * Section tag helpers are documented at
 * https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md.
 */
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    NSString *templateString = [NSString stringWithFormat:@"{{#originalObject_}}%@{{/originalObject_}}", context.innerTemplateString];
    return [context renderTemplateString:templateString error:NULL];
}

#pragma mark Private

/**
 * Returns the wrapped original object.
 *
 * @see renderForSectionTagInContext: implementation
 */
- (id)originalObject_
{
    return [self.array_ objectAtIndex:self.index_];
}

@end


