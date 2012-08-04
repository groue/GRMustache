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

#import "GRMustacheSection_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheSection()
- (id)initWithSectionElement:(GRMustacheSectionElement *)sectionElement renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates;
@end

@implementation GRMustacheSection
@synthesize renderingContext=_renderingContext;

+ (id)sectionWithSectionElement:(GRMustacheSectionElement *)sectionElement renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates
{
    return [[[GRMustacheSection alloc] initWithSectionElement:sectionElement renderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates] autorelease];
}

- (void)dealloc
{
    [_sectionElement release];
    [_renderingContext release];
    [_filterContext release];
    [_delegatingTemplate release];
    [_delegates release];
    [super dealloc];
}

- (id)initWithSectionElement:(GRMustacheSectionElement *)sectionElement renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates
{
    self = [super init];
    if (self) {
        _sectionElement = [sectionElement retain];
        _renderingContext = [renderingContext retain];
        _filterContext = [filterContext retain];
        _delegatingTemplate = [delegatingTemplate retain];
        _delegates = [delegates retain];
    }
    return self;
}

- (void)setRenderingContext:(GRMustacheContext *)renderingContext
{
    if (_renderingContext != renderingContext) {
        [_renderingContext release];
        _renderingContext = [renderingContext retain];
    }
}

- (NSString *)render
{
    return [_sectionElement renderElementsWithRenderingContext:_renderingContext filterContext:_filterContext delegatingTemplate:_delegatingTemplate delegates:_delegates];
}

- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError
{
    return [GRMustacheTemplate renderObject:_renderingContext fromString:string error:outError];
}

- (NSString *)innerTemplateString
{
    return _sectionElement.innerTemplateString;
}

@end
