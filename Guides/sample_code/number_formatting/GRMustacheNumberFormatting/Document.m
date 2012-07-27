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

#import "Document.h"
#import "GRMustache.h"

@interface Document()
@property (nonatomic, strong) NSMutableArray *templateNumberFormatterStack;
@end

@implementation Document
@synthesize templateNumberFormatterStack=_templateNumberFormatterStack;

- (NSString *)render
{
    /**
     * So, our goal is to format all numbers in the `{{#formatPercent}}` and
     * `{{#formatDecimal}}` sections of template.mustache.
     * 
     * First, we attach a NSNumberFormatter instance to those sections. This is
     * done by setting NSNumberFormatter instances to corresponding keys in the
     * data object that we will render. We'll use a NSDictionary for storing
     * the data, but you can use any other KVC-compliant container.
     * 
     * The NSNumberFormatter instances will never be rendered: GRMustache
     * considers them as "true" objects that will trigger the rendering of the
     * sections they are attached to. We use them as plain sentinels.
     */
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Attach a percent NSNumberFormatter to the "formatPercent" key
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    [data setObject:percentNumberFormatter forKey:@"formatPercent"];
    
    // Attach a decimal NSNumberFormatter to the "formatDecimal" key
    NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    [data setObject:decimalNumberFormatter forKey:@"formatDecimal"];
    
    
    /**
     * Now we need a float to be rendered as the {{float}} tags of our
     * template.
     */
    
    [data setObject:[NSNumber numberWithFloat:0.5] forKey:@"float"];
    
    
    /**
     * Render.
     */
    
    NSString *templateString = @"raw: {{float}}\n"
                               @"{{#formatPercent}}"
                               @"percent: {{float}}\n"
                               @"{{/formatPercent}}"
                               @"{{#formatDecimal}}"
                               @"decimal: {{float}}\n"
                               @"{{/formatDecimal}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    return [template renderObject:data];
}

@end


/**
 * By conforming to the GRMustacheTemplateDelegate protocol,
 * NSNumberFormatter instances will be able to observe and alter
 * the rendering of templates.
 */
@interface NSNumberFormatter(GRMustache)<GRMustacheTemplateDelegate>
@end

@implementation NSNumberFormatter(GRMustache)


/**
 * This method is called when the template is about to render a tag.
 */
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * We actually only format numbers for variable tags such as `{{name}}`. We
     * must carefully avoid messing with sections: they as well can be provided
     * with numbers, that they interpret as booleans. We surely do not want to
     * convert NO to the truthy @"0%" string...
     * 
     * So let's ignore sections, and return.
     */
    if (interpretation == GRMustacheInterpretationSection)
    {
        return;
    }
    
    /**
     * There we are: invocation's return value is a NSNumber, and our
     * templateNumberFormatterStack is not empty.
     * 
     * Let's use the top NSNumberFormatter to format this number, and set the
     * invocation's returnValue: this is the object that will be rendered.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = invocation.returnValue;
        invocation.returnValue = [self stringFromNumber:number];
    }
}


@end