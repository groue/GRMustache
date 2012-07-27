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
@property (nonatomic, retain) GRMustacheSectionElement *sectionElement;
@property (nonatomic, retain) GRMustacheContext *renderingContext;
@property (nonatomic, retain) GRMustacheTemplate *rootTemplate;
@property (nonatomic, retain) NSArray *delegates;
@end

@implementation GRMustacheSection
@synthesize sectionElement=_sectionElement;
@synthesize renderingContext=_renderingContext;
@synthesize rootTemplate=_rootTemplate;
@synthesize delegates=_delegates;

+ (id)sectionWithSectionElement:(GRMustacheSectionElement *)sectionElement renderingContext:(GRMustacheContext *)renderingContext rootTemplate:(GRMustacheTemplate *)rootTemplate delegates:(NSArray *)delegates
{
    GRMustacheSection *section = [[GRMustacheSection alloc] init];
    section.sectionElement = sectionElement;
    section.renderingContext = renderingContext;
    section.rootTemplate = rootTemplate;
    section.delegates = delegates;
    return [section autorelease];
}

- (void)dealloc
{
    self.sectionElement = nil;
    self.renderingContext = nil;
    self.rootTemplate = nil;
    self.delegates = nil;
    [super dealloc];
}

- (NSString *)render
{
    return [_sectionElement renderElementsWithContext:_renderingContext forTemplate:_rootTemplate delegates:_delegates];
}

- (NSString *)innerTemplateString
{
    return _sectionElement.innerTemplateString;
}

@end
