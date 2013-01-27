// The MIT License
// 
// Copyright (c) 2013 Gwendal Roué
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

@implementation Document

- (NSString *)render
{
    /**
     * Our template wants to render floats in various formats: raw, or formatted
     * as percentage, or formatted as decimal.
     */

    NSString *templateString = @"raw: {{ value }}\n"
                               @"percent: {{ percent(value) }}\n"
                               @"decimal: {{ decimal(value) }}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    /**
     * Let's define the `percent` and `decimal` filters:
     *
     * Filters have to be objects that conform to the GRMustacheFilter protocol.
     * The easiest way to build one is to use the
     * [GRMustacheFilter filterWithBlock:] method.
     *
     * The formatting itself is done by our friend NSNumberFormatter.
     */
    
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;

    NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    
    id percentFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [percentNumberFormatter stringFromNumber:value];
    }];
    
    id decimalFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [decimalNumberFormatter stringFromNumber:value];
    }];
    
    
    /**
     * We use a NSDictionary for storing our data, but you can use any
     * other KVC-compliant container.
     */
    
    id data = @{
        @"percent": percentFilter,
        @"decimal": decimalFilter,
        @"value": @(0.5),
    };
    
    
    /**
     * Render.
     */
    
    return [template renderObject:data error:NULL];
}

@end

