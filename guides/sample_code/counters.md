[up](../sample_code.md), [next](../forking.md)

Counters
========

A frequent request of Mustache (not only GRMustache) users is: "My template renders some arrays. How do I render each index, with some {{index}} tag or whatever?"

The frequent answer is: "Mustache does not provide this feature. Just have each of your data objects provide its own index."

That's right. Mustache is a simple template language. This is why there are so many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations). And there is no support for indices in the [Mustache specification](https://github.com/mustache/spec).

If your goal is to design your templates so that they are compatible with Mustache specification, the best way to render indices is really to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

Indices vs counters
-------------------

GRMustache can help you implement *counters*. This is not quite exactly the same as array indices, but they are close enough.

Here we will have the tag `{{index}}` render a sequence of numbers, without any cooperation from the data objects. Each time a new collection is rendered, the counter will be reset.

The technique involves the [GRMustacheTemplateDelegate](delegate.md) protocol. As such, it may not be compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations).

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

We'll render the following template:

    {{#people}}
    - {{index}}:{{name}}
    {{/people}}

    One more time:

    {{#people}}
    - {{index}}:{{name}}
    {{/people}}

We expect, on output, the following rendering:

    - 0:Alice
    - 1:Bob
    - 2:Craig
    
    One more time:
    
    - 0:Alice
    - 1:Bob
    - 2:Craig

Here is the rendering code:

```objc
@implementation MYObject

- (NSString *)render
{
    /**
     First, let's attach an array of people to the `people` key, so that they
     are sequentially rendered by the `{{#people}}...{{/people}}` sections.
     
     We'll use a NSDictionary for storing the data, but you can use any other
     KVC-compliant container.
     */
    
    MYPerson *alice = [MYPerson personWithName:@"Alice"];
    MYPerson *bob = [MYPerson personWithName:@"Bob"];
    MYPerson *craig = [MYPerson personWithName:@"Craig"];
    NSArray *people = [NSArray arrayWithObjects: alice, bob, craig, nil];
    NSDictionary *data = [NSDictionary dictionaryWithObject:people forKey:@"people"];
    
    /**
     Render. The rendering of indices will happen in the
     GRMustacheTemplateDelegate methods, hereafter.
     */
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"template" bundle:nil error:NULL];
    template.delegate = self;
    return [template renderObject:data];
}
```

We haven't told yet how those indices will be rendered by the `{{index}}` tags.

We'll simply keep a reference to a number. When GRMustache is about to render a section attached to an array, we'll reset it to zero. When we'll have to render an index, we'll provide it to GRMustache, and increment it.

Of course, we won't render nested counters this way. For that, we would need something like a counter stack, or maybe different counters accessed via different keys. This is beyond the scope of this simple sample code.

First declare a property that will hold the counter, and pose ourselves as a GRMustacheTemplateDelegate:

```objc
@interface MYObject() <GRMustacheTemplateDelegate>
@property (nonatomic, strong) NSNumber *templateCounter;
@end
```

And then implement the delegate methods:

```objc
@implementation MYObject()
@synthesize templateCounter;

/**
 This method is called when the template is about to render a tag.
 */
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    /**
     The invocation object tells us which object is about to be rendered.
     */
    if ([invocation.returnValue isKindOfClass:[NSArray class]])
    {
        /**
         If it is an NSArray, reset our counter.
         */
        self.templateCounter = [NSNumber numberWithUnsignedInteger:0];
    }
    else if (self.templateCounter && [invocation.key isEqualToString:@"index"])
    {
        /**
         If we have a counter, and we're asked for the `index` key, set the
         invocation's returnValue to the counter: it will be rendered.
         
         And increment the counter, of course.
        */
        invocation.returnValue = self.templateCounter;
        self.templateCounter = [NSNumber numberWithUnsignedInteger:self.templateCounter.unsignedIntegerValue + 1];
    }
}

/**
 This method is called right after the template has rendered a tag.
 */
- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    /**
     Make sure we release the counter when we leave an NSArray.
     */
    if ([invocation.returnValue isKindOfClass:[NSArray class]])
    {
        self.templateCounter = nil;
    }
}
@end
```

[up](../sample_code.md), [next](../forking.md)
