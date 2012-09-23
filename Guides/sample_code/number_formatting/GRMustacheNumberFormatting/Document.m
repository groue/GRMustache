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

@implementation Document

- (NSString *)render
{
    /**
     * Our template wants to render floats in various formats: raw, or formatted
     * as percentage, or formatted as decimal.
     *
     * This is typically a job for filters: we'll define the `percent` and
     * `decimal` filters.
     *
     * For now, we just have our template use them.
     */
     
    NSString *templateString = @"raw: {{value}}\n"
                               @"percent: {{percent(value)}}\n"
                               @"decimal: {{decimal(value)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    /**
     * Now we have to define those filters.
     *
     * Filters have to be objects that conform to the GRMustacheFilter protocol.
     * The easiest way to build one is to use the
     * [GRMustacheFilter filterWithBlock:] method.
     *
     * The formatting itself is done by our friend NSNumberFormatter.
     */
    
    // Build our formatters
    
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;

    NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    
    
    // Build our filters
    
    id percentFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [percentNumberFormatter stringFromNumber:value];
    }];
    
    id decimalFilter = [GRMustacheFilter filterWithBlock:^id(id value) {
        return [decimalNumberFormatter stringFromNumber:value];
    }];
    
    
    /**
     * GRMustache does not load filters from the rendered data, but from a
     * specific filters container.
     *
     * We'll use a NSDictionary for storing the filters, but you can use any
     * other KVC-compliant container.
     */
    
    NSDictionary *filters = [NSDictionary dictionaryWithObjectsAndKeys:
                             percentFilter, @"percent",
                             decimalFilter, @"decimal",
                             nil];
    
    
    /**
     * Now we need a float to be rendered as `value` in our template:
     */
    
    NSDictionary *data = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5] forKey:@"value"];
    
    
    /**
     * Render.
     */
    
    return [template renderObject:data withFilters:filters];
}

@end

