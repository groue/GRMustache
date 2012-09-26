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

#import "GRMustacheVariableTagHelper.h"
#import "GRMustacheVariableTagRenderingContext.h"
#import "GRMustacheError.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariableTagHelper

/**
 * Private subclass of GRMustacheVariableTagHelper that render variable tags by
 * calling a block.
 */
@interface GRMustacheBlockVariableTagHelper: GRMustacheVariableTagHelper {
@private
    NSString *(^_block)(GRMustacheVariableTagRenderingContext* context);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheVariableTagRenderingContext* context))block;
@end


// =============================================================================
#pragma mark - GRMustacheVariableTagHelper

@implementation GRMustacheVariableTagHelper

+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariableTagRenderingContext* context))block
{
    return [[[GRMustacheBlockVariableTagHelper alloc] initWithBlock:block] autorelease];
}

#pragma mark <GRMustacheVariableTagHelper>

- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
{
    return [self description];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariableTagHelper

@implementation GRMustacheBlockVariableTagHelper

- (id)initWithBlock:(NSString *(^)(GRMustacheVariableTagRenderingContext* context))block
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

#pragma mark <GRMustacheVariableTagHelper>

- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
{
    NSString *rendering = nil;
    
    if (_block) {
        rendering = _block(context);
    }
    
    return rendering;
}

@end


