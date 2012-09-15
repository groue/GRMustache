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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheTestBase.h"

@implementation GRMustacheTestBase
@dynamic testBundle;

- (NSBundle *)testBundle
{
    return [NSBundle bundleWithIdentifier:@"com.github.groue.GRMustache"];
}

@end

@implementation GRMustacheTestingDelegate

- (void)dealloc
{
    self.templateWillRenderBlock = nil;
    self.templateDidRenderBlock = nil;
    self.templateWillInterpretBlock = nil;
    self.templateDidInterpretBlock = nil;
    [super dealloc];
}

- (void)templateWillRender:(GRMustacheTemplate *)template
{
    if (self.templateWillRenderBlock) {
        self.templateWillRenderBlock(template);
    }
}

- (void)templateDidRender:(GRMustacheTemplate *)template
{
    if (self.templateDidRenderBlock) {
        self.templateDidRenderBlock(template);
    }
}

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    if (self.templateWillInterpretBlock) {
        self.templateWillInterpretBlock(template, invocation, interpretation);
    }
}

- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    if (self.templateDidInterpretBlock) {
        self.templateDidInterpretBlock(template, invocation, interpretation);
    }
}

@end

