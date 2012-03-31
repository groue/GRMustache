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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheRenderingElement_private.h"

@class GRMustacheInvocation;
@class GRMustacheTemplate;

@interface GRMustacheSection: NSObject<GRMustacheRenderingElement> {
@private
    GRMustacheInvocation *_invocation;
    GRMustacheTemplate *_rootTemplate;
    NSString *_templateString;
    NSRange _range;
    BOOL _inverted;
    NSArray *_elems;
}

@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;
+ (id)sectionElementWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString range:(NSRange)range inverted:(BOOL)inverted elements:(NSArray *)elems GRMUSTACHE_API_INTERNAL;
- (NSString *)renderObject:(id)object GRMUSTACHE_API_PUBLIC;
- (NSString *)renderObjects:(id)object, ... GRMUSTACHE_API_PUBLIC;

@end
