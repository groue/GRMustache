[up](../sample_code.md), [next](indexes.md)

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

Before you answer "Of course not, I'm a lazy bastard, just gimme the code", beware that we will use below the [GRMustacheTemplateDelegate](../delegate.md) protocol. **It thus may be tedious or impossible for [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) to produce the same rendering.**

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

The sample code below format all numbers in specific sections, without any cooperation from the data object. For instance, consider the following template, that uses a single `{{float}}` value:

    raw: {{float}}

    {{#PERCENT_FORMAT}}
    percent: {{float}}
    {{/PERCENT_FORMAT}}

    {{#DECIMAL_FORMAT}}
    decimal: {{float}}
    {{/DECIMAL_FORMAT}}

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
     So, our goal is to format all numbers in the `{{#PERCENT_FORMAT}}` and
     `{{#DECIMAL_FORMAT}}` sections of template.mustache.
     
     First, we attach a NSNumberFormatter instance to those sections. This is
     done by setting NSNumberFormatter instances to corresponding keys in the
     data object that we will render. We'll use a NSDictionary for storing
     the data, but you can use any other KVC-compliant container.
     
     The NSNumberFormatter instances will never be rendered: GRMustache
     considers them as "true" objects that will trigger the rendering of the
     sections they are attached to. We use them as plain sentinels.
     */
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Attach a percent NSNumberFormatter to the "PERCENT_FORMAT" key
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    [data setObject:percentNumberFormatter forKey:@"PERCENT_FORMAT"];
    
    // Attach a decimal NSNumberFormatter to the "DECIMAL_FORMAT" key
    NSNumberFormatter *decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    [data setObject:decimalNumberFormatter forKey:@"DECIMAL_FORMAT"];
    
    
    /**
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
    return [template renderObject:data];
}
@end
```

But we haven't told yet how those number formatters will be used for rendering the `{{float}}` tags.

We'll build a stack of number formatters. When GRMustache is about to render a section attached to a number formatter, we'll enqueue it. When the section has been rendered, we'll dequeue. Meanwhile, when we'll have to render a number, we'll format it with the last enqueued number formatter.

First declare a property that will hold the number formatters stack, and pose ourselves as a GRMustacheTemplateDelegate:

```objc
@interface MYObject() <GRMustacheTemplateDelegate>
@property (nonatomic, strong) NSMutableArray *templateNumberFormatterStack;
@end
```

And then implement the delegate methods:

```objc
@implementation MYObject()
@synthesize templateNumberFormatterStack;

/**
 This method is called right before the template start rendering.
 */
- (void)templateWillRender:(GRMustacheTemplate *)template
{
    /**
     Prepare a stack of NSNumberFormatter objects.
     
     Each time we'll enter a section that is attached to a NSNumberFormatter,
     we'll enqueue this NSNumberFormatter in the stack. This is done in
     [template:willInterpretReturnValueOfInvocation:as:]
     */
    self.templateNumberFormatterStack = [NSMutableArray array];
}

/**
 This method is called when the template is about to render a tag.
 */
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     The invocation object tells us which object is about to be rendered.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumberFormatter class]])
    {
        /**
         If it is a NSNumberFormatter, enqueue it in
         templateNumberFormatterStack, and return.
         */
        [self.templateNumberFormatterStack addObject:invocation.returnValue];
        return;
    }
    
    if (interpretation == GRMustacheInterpretationSection)
    {
        /**
         We actually only format numbers for variable tags such as `{{name}}`.
         We must carefully avoid messing with sections: they as well can be
         provided with numbers, that they interpret as booleans. We surely
         do not want to convert booleans to strings...
         
         So let's ignore sections, and return.
         */
        return;
    }
    
    if (self.templateNumberFormatterStack.count == 0)
    {
        /**
         If our number formatter stack is empty, we can not format anything:
         let's return.
         */
        return;
    }
    
    if ([invocation.returnValue isKindOfClass:[NSNumber class]])
    {
        /**
         There we are: invocation's return value is a NSNumber, and our
         templateNumberFormatterStack is not empty.
         
         Let's use the top NSNumberFormatter to format this number, and set
         the invocation's returnValue: this is the object that will be
         rendered.
         */
        NSNumberFormatter *numberFormatter = self.templateNumberFormatterStack.lastObject;
        NSNumber *number = invocation.returnValue;
        invocation.returnValue = [numberFormatter stringFromNumber:number];
    }
}

/**
 This method is called right after the template has rendered a tag.
 */
- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     Make sure we dequeue NSNumberFormatters when we leave their scope.
     */
    if ([invocation.returnValue isKindOfClass:[NSNumberFormatter class]])
    {
        [self.templateNumberFormatterStack removeLastObject];
    }
}

/**
 This method is called right after the template has finished rendering.
 */
- (void)templateDidRender:(GRMustacheTemplate *)template
{
    /**
     Final cleanup: release the stack created in templateWillRender:
     */
    self.templateNumberFormatterStack = nil;
}
@end
```

[up](../sample_code.md), [next](indexes.md)
