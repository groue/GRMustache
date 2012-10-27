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
#import "GRMustacheRuntime_private.h"

@interface GRMustacheTemplateOverride()
- (id)initWithTemplate:(GRMustacheTemplate *)template components:(NSArray *)components;
@end

@implementation GRMustacheTemplateOverride
@synthesize template=_template;

+ (id)templateOverrideWithTemplate:(GRMustacheTemplate *)template components:(NSArray *)components
{
    return [[[self alloc] initWithTemplate:template components:components] autorelease];
}

- (void)dealloc
{
    [_template release];
    [_components release];
    [super dealloc];
}

#pragma mark - GRMustacheTemplateComponent

- (BOOL)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime error:(NSError **)error
{
    runtime = [runtime runtimeByAddingTemplateOverride:self];
    return [_template renderInBuffer:buffer withRuntime:runtime error:error];
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // look for the last overriding component in inner components
    for (id<GRMustacheTemplateComponent> innerComponent in _components) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}


#pragma mark - Private

- (id)initWithTemplate:(GRMustacheTemplate *)template components:(NSArray *)components
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _components = [components retain];
    }
    return self;
}

@end
