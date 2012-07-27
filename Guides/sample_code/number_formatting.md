[up](../../../../tree/master/Guides/sample_code), [next](indexes.md)

Number formatting
=================

In a genuine Mustache way
-------------------------

Mustache is a simple template language. This is why there are so many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations).

If your goal is to design your templates so that they are compatible with those, the best way to format numbers is to have your data objects provide those formatted numbers.

### NSDictionary data objects

Let's render the simple template:

    {(percent)}

It's quite easy to put formatted numbers in a dictionary:

```objc
// The number to render
NSNumber *number = [NSNumber numberWithFloat: 0.5]:

// An NSNumberFormatter knows how to format numbers
NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
NSString *formattedNumber = [numberFormatter stringFromNumber:number];

// Render "50%"
NSDictionary *dictionary = [NSDictionary dictionaryWithObject:formattedNumber forKey:"percent"];
NSString *rendering = [template renderObject:dictionary];
```

### Custom data objects

Often, data comes from your model objects, not from a hand-crafted NSDictionary.

In this case, the best option is to declare a category on your model object, and implement a specific key that will output the formatted number:

```objc
@interface MYModel(GRMustache)
@property (readonly) NSString *percent;
@end

@implementation MYModel(GRMustache)
- (NSString *)percent
{
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:self.number];
}
@end
```

You would then render normally:

```objc
// Render "50%"
MYModel *model = [MYModel modelWithNumber:0.5];
NSString *rendering = [template renderObject:model];
```

In the GRMustache way
---------------------

**[Download the code](../../../../tree/master/Guides/sample_code/number_formatting)**

You may ask yourself, is it worth declaring dozens of stub properties just for formatting numbers?

Before you answer "Of course not, I'm a lazy bastard, just gimme the code", beware that we will use below the [GRMustacheTemplateDelegate](../delegate.md) protocol. **It thus may be tedious or impossible for [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) to produce the same rendering.**

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

The sample code below format all numbers in specific sections, without any cooperation from the data object. For instance, consider the following template, that uses a single `{{float}}` value:

    raw: {{float}}

    {{#formatPercent}}
    percent: {{float}}
    {{/formatPercent}}

    {{#formatDecimal}}
    decimal: {{float}}
    {{/formatDecimal}}

It will render, on a French system:

    raw: 0.5
    percent: 50 %
    decimal: 0,5

Here is the rendering code:

```objc
@implementation MYObject

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
    
    return [GRMustacheTemplate renderObject:data fromResource:@"template" bundle:nil error:NULL]
}
@end
```

But we haven't told yet how those number formatters will be used for rendering the `{{float}}` tags.

We'll have the NSNumberFormatter class conform to the GRMustacheTemplateDelegate protocol.

As a consequence, GRMustache will give formatters that are attached to Mustache sections the opportunity to hook in the template rendering while rendering those sections. This behavior is described in the [GRMustacheTemplateDelegate](../delegate.md) guide.

We just have to implement the `template:willInterpretReturnValueOfInvocation:as:` callback, that is able to tell GRMustache which object it should render. NSNumberFormatter instances will tell GRMustache to render formatted numbers instead of plain numbers.

Let's first have NSNumberFormatter conform to the GRMustacheTemplateDelegate protocol:

```objc
@interface NSNumberFormatter(GRMustache)<GRMustacheTemplateDelegate>
@end
```

Now let's format numbers when GRMustache is about to render them:

```objc
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
     * There we are: invocation's return value is a NSNumber.
     * 
     * Let's set the invocation's returnValue to a formatter number: this string
     * is the object that will be rendered.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = invocation.returnValue;
        invocation.returnValue = [self stringFromNumber:number];
    }
}
@end
```

**[Download the code](../../../../tree/master/Guides/sample_code/number_formatting)**

[up](../../../../tree/master/Guides/sample_code), [next](indexes.md)