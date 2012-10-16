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

#import "GRMustacheFilter.h"
#import "GRMustacheSectionTagHelper.h"
#import "GRMustacheSectionTagRenderingContext.h"
#import "GRMustacheVariableTagHelper.h"
#import "GRMustacheVariableTagRenderingContext.h"

// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

/**
 * Private subclass of GRMustacheFilter that filter values by calling a block.
 */
@interface GRMustacheBlockFilter: GRMustacheFilter {
@private
    id(^_block)(id value);
}
- (id)initWithBlock:(id(^)(id value))block;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheMultiArgumentBlockFilter

/**
 * TODO
 */
@interface GRMustacheMultiArgumentBlockFilter: GRMustacheFilter {
@private
    id(^_block)(NSArray *arguments);
}
- (id)initWithBlock:(id(^)(NSArray *arguments))block;
@end


// =============================================================================
#pragma mark - GRMustacheFilter

@implementation GRMustacheFilter

+ (id)filterWithBlock:(id(^)(id value))block
{
    return [[[GRMustacheBlockFilter alloc] initWithBlock:block] autorelease];
}

+ (id)multiArgumentsFilterWithBlock:(id(^)(NSArray *arguments))block
{
    return [[[GRMustacheMultiArgumentBlockFilter alloc] initWithBlock:block] autorelease];
}

- (id)transformedValue:(id)object
{
    return object;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

@implementation GRMustacheBlockFilter

- (id)initWithBlock:(id(^)(id value))block
{
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}


- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    if (_block) {
        return _block(object);
    }
    
    return nil;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheMultiArgumentBlockFilter

@interface GRTruc : NSObject<GRMustacheFilter, GRMustacheSectionTagHelper, GRMustacheVariableTagHelper> {
@private
    NSArray *_arguments;
    id(^_block)(NSArray *arguments);
}
- (id)initWithBlock:(id(^)(NSArray *arguments))block arguments:(NSArray *)arguments;
@end

@implementation GRMustacheMultiArgumentBlockFilter

- (id)initWithBlock:(id(^)(NSArray *arguments))block
{
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}


- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    return [[[GRTruc alloc] initWithBlock:_block arguments:[NSArray arrayWithObject:object]] autorelease];
}

@end

@implementation GRTruc

- (id)initWithBlock:(id (^)(NSArray *))block arguments:(NSArray *)arguments
{
    self = [self init];
    if (self) {
        _block = [block copy];
        _arguments = [arguments retain];
    }
    return self;
}

- (void)dealloc
{
    [_block release];
    [_arguments release];
    [super dealloc];
}

- (id)transformedValue:(id)object
{
    return [[[GRTruc alloc] initWithBlock:_block arguments:[_arguments arrayByAddingObject:object]] autorelease];
}

- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    NSString *templateString = [NSString stringWithFormat:@"{{#_value}}%@{{/value}}", context.innerTemplateString];
    return [context renderTemplateString:templateString error:NULL];
}

- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
{
    return [context renderTemplateString:@"{{_value}}" error:NULL];
}

- (id)_value
{
    return _block(_arguments);
}

@end