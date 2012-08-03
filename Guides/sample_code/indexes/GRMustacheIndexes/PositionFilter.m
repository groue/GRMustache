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
 * PositionFilterItem's responsability is, given an array and an index, to
 * forward to the original item in the array all keys but:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 *
 * All other keys are forwared to the original item.
 */
@interface PositionFilterItem : NSObject
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) BOOL isFirst;
@property (nonatomic, readonly) BOOL isOdd;
- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array;
@end


#pragma mark - PositionFilter

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
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PositionFilterItem *item = [[PositionFilterItem alloc] initWithObjectAtIndex:idx inArray:array];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end


#pragma mark - PositionFilterItem implementation

@implementation PositionFilterItem {
    /**
     * The original 0-based index and the array of original items are stored in
     * ivars without any exposed property: we do not want GRMustache to render
     * the unintended {{ index }} or {{ array }}.
     */
    NSUInteger _index;
    NSArray *_array;
}

- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _index = index;
        _array = array;
    }
    return self;
}

/**
 * The implementation of `description` is required so that whenever GRMustache
 * wants to render the original item itself (with a `{{ . }}` tag, for
 * instance).
 */
- (NSString *)description
{
    id originalObject = [_array objectAtIndex:_index];
    return [originalObject description];
}

/**
 * Support for `{{position}}`: return a 1-based index.
 */
- (NSUInteger)position
{
    return _index + 1;
}

/**
 * Support for `{{#isFirst}}...{{/isFirst}}`: return YES if element is the first
 */
- (BOOL)isFirst
{
    return _index == 0;
}

/**
 * Support for `{{#isOdd}}...{{/isOdd}}`: return YES if element's position is
 * odd.
 */
- (BOOL)isOdd
{
    return (_index % 2) == 0;
}

/**
 * Support for other keys: forward to original array element
 */
- (id)valueForUndefinedKey:(NSString *)key
{
    id originalObject = [_array objectAtIndex:_index];
    return [originalObject valueForKey:key];
}

@end


