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

#import <objc/message.h>
#import "GRMustacheEnvironment.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheSection_private.h"


// =============================================================================
#pragma mark - GRMustacheSelectorHelper

@interface GRMustacheSelectorHelper()
- (id)initWithObject:(id)object selector:(SEL)renderingSelector;
@end


@implementation GRMustacheSelectorHelper

+ (id)helperWithObject:(id)object selector:(SEL)renderingSelector
{
    return [[[self alloc] initWithObject:object selector:renderingSelector] autorelease];
}

- (void)dealloc
{
    [_object release];
    [super dealloc];
}

#pragma mark <GRMustacheHelper>

- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    NSString *result = objc_msgSend(_object, _renderingSelector, section, context);
    if (result == nil) {
        return @"";
    }
    return result;
}

#pragma mark Private

- (id)initWithObject:(id)object selector:(SEL)renderingSelector
{
    self = [self init];
    if (self) {
        _object = [object retain];
        _renderingSelector = renderingSelector;
    }
    return self;
}

@end


// =============================================================================
#pragma mark - GRMustacheBlockHelper

#if GRMUSTACHE_BLOCKS_AVAILABLE

@interface GRMustacheBlockHelper()
- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block;
@end


@implementation GRMustacheBlockHelper

+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block
{
    return [[(GRMustacheBlockHelper *)[self alloc] initWithBlock:block] autorelease];
}

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheHelper>

- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    NSString *result = _block(section, context);
    if (result == nil) {
        return @"";
    }
    return result;
}

#pragma mark Private

- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block
{
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

@end

#endif /* if GRMUSTACHE_BLOCKS_AVAILABLE */
