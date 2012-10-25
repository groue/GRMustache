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

#import "GRMustacheRenderingObject_private.h"

@interface GRMustacheRenderingObjectWithBlock:GRMustacheRenderingObject {
    NSString *(^_block)(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped))block;
@end

@interface GRMustacheRenderingObjectWithIMP:GRMustacheRenderingObject {
    id _object;
    IMP _implementation;
}
- (id)initWithObject:(id)object implementation:(IMP)implementation;
@end

@implementation GRMustacheRenderingObject

+ (id)renderingObjectWithBlock:(NSString *(^)(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped))block
{
    return [[[GRMustacheRenderingObjectWithBlock alloc] initWithBlock:block] autorelease];
}

+ (id)renderingObjectWithObject:(id)object implementation:(IMP)implementation
{
    return [[[GRMustacheRenderingObjectWithIMP alloc] initWithObject:object implementation:implementation] autorelease];
}

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    return nil;
}

@end

@implementation GRMustacheRenderingObjectWithBlock

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

- (id)initWithBlock:(NSString *(^)(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    if (!_block) {
        return nil;
    }
    return _block(section, runtime, templateRepository, HTMLEscaped);
}

@end

@implementation GRMustacheRenderingObjectWithIMP

- (void)dealloc
{
    [_object release];
    [super dealloc];
}

- (id)initWithObject:(id)object implementation:(IMP)implementation
{
    self = [super init];
    if (self) {
        _object = [object retain];
        _implementation = implementation;
    }
    return self;
}

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    if (!_implementation || !_object) {
        return nil;
    }
    return _implementation(_object, @selector(renderForSection:inRuntime:templateRepository:HTMLEscaped:), section, runtime, templateRepository, HTMLEscaped);
}

@end
