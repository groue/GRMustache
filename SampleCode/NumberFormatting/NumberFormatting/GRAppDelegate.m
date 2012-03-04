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

#import "GRAppDelegate.h"
#import "GRMustache.h"

@interface GRAppDelegate() <GRMustacheTemplateDelegate>
@property (nonatomic, retain) NSMutableArray *templateNumberFormatterStack;
@end

@implementation GRAppDelegate

@synthesize window = _window;
@synthesize templateNumberFormatterStack=_templateNumberFormatterStack;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /**
     Our goal is to format all numbers in the {{#percent_format}} and
     {{#decimal_format}} sections of template.mustache.
     
     First, we attach a NSNumberFormatter instance to those sections. This is done
     by setting NSNumberFormatter instances to corresponding keys in the data object
     that we will render.
     */
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Attach a percent NSNumberFormatter to the "percent_format" key
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    [data setObject:percentNumberFormatter forKey:@"percent_format"];
    
    // Attach a decimal NSNumberFormatter to the "percent_format" key
    NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    [data setObject:decimalNumberFormatter forKey:@"decimal_format"];
    
    /**
     We need a float to be rendered as the {{float}} tags of template.mustache.
     */
    
    // Attach a float to the "float" key
    [data setObject:[NSNumber numberWithFloat:0.5] forKey:@"float"];
    
    
    /**
     Render. The formatting of numbers will happen in the
     GRMustacheTemplateDelegate methods.
     */
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"template" bundle:nil error:NULL];
    template.delegate = self;
    NSString *result = [template renderObject:data];
    NSLog(@"%@", result);
}


#pragma mark GRMustacheTemplateDelegate

- (void)templateWillRender:(GRMustacheTemplate *)template
{
    /**
     Prepare a stack of NSNumberFormatter objects.
     
     Each time we'll enter a section that is attached to a NSNumberFormatter,
     we'll enqueue this NSNumberFormatter in the stack. This is done in
     [template:willRenderReturnValueOfInvocation:]
     */
    self.templateNumberFormatterStack = [NSMutableArray array];
}

- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    /**
     The invocation object tells us which object is about to be rendered.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumberFormatter class]])
    {
        /**
         If it is a NSNumberFormatter, enqueue it in templateNumberFormatterStack.
         */
        [self.templateNumberFormatterStack addObject:invocation.returnValue];
    }
    else if (self.templateNumberFormatterStack.count > 0 && [invocation.returnValue isKindOfClass:[NSNumber class]])
    {
        /**
         If it is a NSNumber, and if our templateNumberFormatterStack is not empty,
         use the top NSNumberFormatter to format the number.
         
         The invocation's returnValue can be set: this is the object that will be
         rendered.
         */
        NSNumberFormatter *numberFormatter = self.templateNumberFormatterStack.lastObject;
        invocation.returnValue = [numberFormatter stringFromNumber:(NSNumber *)invocation.returnValue];
    }
}

- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    /**
     Make sure we dequeue NSNumberFormatters when we leave their scope.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumberFormatter class]])
    {
        [self.templateNumberFormatterStack removeLastObject];
    }
}

- (void)templateDidRender:(GRMustacheTemplate *)template
{
    /**
     Final cleanup: release the stack created in templateWillRender:
     */
    self.templateNumberFormatterStack = nil;
}

@end
