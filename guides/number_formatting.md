[up](../../../../GRMustache), [next](date_formatting.md)

Number formatting with GRMustacheNumberFormatterHelper
======================================================

**This helper class allows you to format the numbers in a section of your template.**

It does not belong the the core GRMustache code, and as such must be imported separately:

    #import "GRMustacheNumberFormatterHelper.h"

Usage
-----

For instance, given the following template:

    raw: {{float}}
    
    {{#percent_format}}
    percent: {{float}}
    {{/percent_format}}
    
    {{#decimal_format}}
    decimal: {{float}}
    {{/decimal_format}}

We would like the float value to be displayed as a percentage in the `percent_format` section, and as a decimal in the `decimal_format` section.

We just have to create two `GRMustacheNumberFormatterHelper` objects, provide them with `NSNumberFormatter` instances, and attach them to the `percent_format` and `decimal_format` section names:

    #import "GRMustacheNumberFormatterHelper.h"
    
    // The percent formatter, and helper:
    NSNumberFormatter percentNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    id percentHelper = [GRMustacheNumberFormatterHelper helperWithNumberFormatter:percentNumberFormatter];
    
    // The decimal formatter, and helper:
    NSNumberFormatter decimalNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    id decimalHelper = [GRMustacheNumberFormatterHelper helperWithNumberFormatter:decimalNumberFormatter];
    
    // The rendered data:
    NSNumber *float = [NSNumber numberWithFloat:0.5];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          percentHelper, @"percent_format",
                          decimalHelper, @"decimal_format",
                          float,         @"float",
                          nil];
    
    // The final rendering (on a French system):
    //   raw: 0.5
    //   percent: 50 %
    //   decimal: 0,5
    [template renderObject:data];

Scope
-----

GRMustacheNumberFormatterHelper does not format numbers in sub sections. For instance, if you plan to format numbers in a collection, make sure your formatter helper is invoked *inside* the collection section:

    {{#items}}
        {{#decimal_format}}
            {{float}}
        {{/decimal_format}}
    {{/items}}

[up](../../../../GRMustache), [next](date_formatting.md)
