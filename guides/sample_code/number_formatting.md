[up](../sample_code.md), [next](counters.md)

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

Often, data comes from your model objects, not from an hand-crafted NSDictionary.

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

You may ask yourself, is it worth declaring dozens of stub properties just for formatting numbers?

Before you answer "Of course not, I'm a lazy bastard, just gimme the code", beware that we will use below the [GRMustacheTemplateDelegate](delegate.md) protocol. As such, this technique may not be compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations).

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

The sample code below format all numbers in specific sections. For instance, the following template:

    raw: {{float}}

    {{#percent_format}}
    percent: {{float}}
    {{/percent_format}}

    {{#decimal_format}}
    decimal: {{float}}
    {{/decimal_format}}

...will render, on a French system:

    raw: 0.5
    percent: 50%
    decimal: 0,5

Here is the rendering code:

```objc
@implementation MYObject

- (NSString *)render
{
    /**
     So, our goal is to format all numbers in the `{{#percent_format}}` and
     `{{#decimal_format}}` sections of template.mustache.
     
     First, we attach a NSNumberFormatter instance to those sections. This is
     done by setting NSNumberFormatter instances to corresponding keys in the
     data object that we will render. We'll use a NSDictionary for storing
     the data, but you can use any other container.
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
     The NSNumberFormatter instances will never be rendered: GRMustache
     considers them as "true" objects that will trigger the rendering of the
     sections they are attached to. We use them as plain sentinels.
     
     Now we need a float to be rendered as the {{float}} tags of our
     template.
     */
    
    // Attach a float to the "float" key
    [data setObject:[NSNumber numberWithFloat:0.5] forKey:@"float"];
    
    
    /**
     Render. The formatting of numbers will happen in the
     GRMustacheTemplateDelegate methods, hereafter.
     */
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"template" bundle:nil error:NULL];
    template.delegate = self;
    NSString *result = [template renderObject:data];
}
@end
```

But we haven't yet told how those number formatters will be used for rendering the `{{float}}` tags.

We'll build a stack of number formatters. When GRMustache is about to render a section attached to a number formatter, we'll enqueue it. When the section has been rendered, we'll dequeue. Meanwhile, when we'll have to render a number, we'll format it with the last enqueued number formatter.

First declare a property that will hold the number formatters stack, and pose ourselves as a GRMustacheTemplateDelegate:

```objc
@interface MYObject(GRMustache) <GRMustacheTemplateDelegate>
@property (nonatomic, retain) NSMutableArray *templateNumberFormatterStack;
@end
```

And then implement the delegate methods:

```objc
@implementation MYObject(GRMustache)
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
```

[up](../sample_code.md), [next](counters.md)
