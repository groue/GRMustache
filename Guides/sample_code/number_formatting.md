[up](../../../../tree/master/Guides/sample_code), [next](indexes.md)

Number formatting
=================

For the purpose of demonstration, we'll render the value 0.5 as a *raw* number, as a percentage, and as a *decimal*. For instance, on a French system, we'll get the following output:

    raw: 0.5
    percent: 50 %
    decimal: 0,5


In a genuine Mustache way
-------------------------

Mustache is a simple template language. This is why there are so many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations).

If your goal is to design your templates so that they are compatible with those, the best way to format numbers is to have your data objects provide those formatted numbers.

### 1st genuine Mustache technique: NSDictionary

Let's render the simple template:

    raw: {{ value }}
    percent: {{ percent }}
    decimal: {{ decimal }}

It's quite easy to put numbers and formatted numbers in a dictionary:

```objc
// The raw number
NSNumber *value = @0.5:

// NSNumberFormatter objects knows how to format numbers
NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
NSString *percent = [numberFormatter stringFromNumber:value];

NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
NSString *decimal = [numberFormatter stringFromNumber:value];

// Render "raw: 0.5, percent: 50 %, decimal: 0,5"
NSDictionary *dictionary = @{
    @"value": value,
    @"percent": percent,
    @"decimal": decimal
};
NSString *rendering = [template renderObject:dictionary];
```

### 2nd genuine Mustache technique: specific properties

Often, data comes from your model objects, not from a hand-crafted NSDictionary.

In this case, the best option is to declare a category on your model object, and implement specific keys that will output the formatted numbers:

```objc
@interface Model
@property float value;   // the original property provided by the model
@end

@interface Model(GRMustache)
@property (readonly) NSString *percent;
@property (readonly) NSString *decimal;
@end

@implementation Model(GRMustache)
- (NSString *)percent
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.value]];
}

- (NSString *)decimal
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.value]];
}
@end
```

You would then render normally:

```objc
// Render "raw: 0.5, percent: 50 %, decimal: 0,5"
Model *model = ...
model.value = 0.5;
NSString *rendering = [template renderObject:model];
```

Tag delegates
-------------

[Tag delegates](delegate.md) allow all numbers in a section to be formatted. For instance, in the following template, all numbers would be formatted as currencies:

    {{#currency}}
        {{#items}}
            {{name}}: {{price}}
        {{/items}}
        total: {{total}}
        taxes: {{taxes}}
    {{/currency}}

You'll find the code in the [Tag Delegates Guide](delegate.md#altering-the-rendering-of-tags-in-a-section).

Filters
-------

**[Download the code](../../../../tree/master/Guides/sample_code/number_formatting)**

Let's first rewrite our initial template so that it uses filters:

    raw: {{ value }}
    percent: {{ percent(value) }}
    decimal: {{ decimal(value) }}

After we have told GRMustache how the `percent` and `decimal` filters should process their input, we will be releived from the need to prepare our data before it is rendered: no more adding of specific keys in a dictionary, no more declaration of a category on our models.

```objc
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
```

**[Download the code](../../../../tree/master/Guides/sample_code/number_formatting)**


[up](../../../../tree/master/Guides/sample_code), [next](indexes.md)