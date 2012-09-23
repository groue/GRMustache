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

#import "GRMustacheTemplateOverride_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheTemplateOverride()
- (id)initWithSuperTemplate:(GRMustacheTemplate *)superTemplate elements:(NSArray *)elements;
@end

@implementation GRMustacheTemplateOverride

+ (id)templateOverrideWithSuperTemplate:(GRMustacheTemplate *)superTemplate elements:(NSArray *)elements
{
    return [[[self alloc] initWithSuperTemplate:superTemplate elements:elements] autorelease];
}

- (void)dealloc
{
    [_superTemplate release];
    [_elems release];
    [super dealloc];
}


#pragma mark - GRMustacheRenderingOverride

- (id<GRMustacheRenderingElement>)overridingElementForNonFinalRenderingElement:(id<GRMustacheRenderingElement>)element
{
    for (id<GRMustacheRenderingElement> elem in _elems) {
        if ([elem canOverrideRenderingElement:element]) {
            return elem;
        }
    }
    return nil;
}


#pragma mark - GRMustacheRenderingElement

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    runtime = [runtime runtimeByAddingRenderingOverride:self];
    [_superTemplate renderInBuffer:buffer withRuntime:runtime];
}

- (BOOL)isFinal
{
    return YES;
}

- (BOOL)canOverrideRenderingElement:(id<GRMustacheRenderingElement>)element
{
    return NO;
}


#pragma mark - Private

- (id)initWithSuperTemplate:(GRMustacheTemplate *)superTemplate elements:(NSArray *)elements
{
    self = [super init];
    if (self) {
        _superTemplate = [superTemplate retain];
        _elems = [elements retain];
    }
    return self;
}

@end
