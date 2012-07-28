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
#import "GRMustacheInvocation.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

#if NS_BLOCKS_AVAILABLE

/**
 * Private subclass of GRMustacheFilter that filter values by calling a block.
 */
@interface GRMustacheBlockFilter: GRMustacheFilter<GRMustacheTemplateDelegate> {
@private
    id(^_block)(id value);
}
- (id)initWithBlock:(id(^)(id value))block;
@end

#endif /* if NS_BLOCKS_AVAILABLE */


// =============================================================================
#pragma mark - GRMustacheFilter

@implementation GRMustacheFilter

#if NS_BLOCKS_AVAILABLE

+ (id)filterWithBlock:(id(^)(id value))block
{
    return [[[GRMustacheBlockFilter alloc] initWithBlock:block] autorelease];
}

#endif /* if NS_BLOCKS_AVAILABLE */

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockFilter

#if NS_BLOCKS_AVAILABLE

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

#pragma mark <GRMustacheTemplateDelegate>

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    if (_block) {
        invocation.returnValue = _block(invocation.returnValue);
    }
}

@end

#endif /* if NS_BLOCKS_AVAILABLE */
