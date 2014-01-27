[up](../../../../GRMustache#documentation), [next](protected_contexts.md)

GRMustacheTagDelegate protocol
==============================

This protocol lets you observe, and possibly alter the rendering of the Mustache tags that consume your data.

It provides you with a pair of classic "will.../did..." methods that are invoked just before, and just after a tag gets rendered:

```objc
@protocol GRMustacheTagDelegate<NSObject>
@optional
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object;
- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering;
- (void)mustacheTag:(GRMustacheTag *)tag didFailRenderingObject:(id)object withError:(NSError *)error;
@end
```

- The _object_ argument is the rendered value: a string, a number, an array, depending on the data you provided.
- The _tag_ argument represents the rendering tag: `{{ name }}`, `{{# name }}...{{/}}`, etc.

See the [GRMustacheTag Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html) for a full documentation of the GRMustacheTag class.

- `mustacheTag:willRenderObject:` returns the value that should be rendered by the tag. It can return its `object` argument, leaving this value untouched, or it can return another value.

- `mustacheTag:didRenderObject:as:` can let you clean up anything that has been prepared in `mustacheTag:willRenderObject:`. Besides, it is provided with the actual rendering of the tag.

- `mustacheTag:didFailRenderingObject:withError:` has no other purpose but to let you perform any necessary clean up. There is no error recovery, and the error would eventually come out of the initial rendering method.

Note that a tag like `{{ person.name }}` is rendered once. Thus the delegate will be called once. If the person has been found, the rendered object will be the name of the person. If the person could not be found, the rendered object will be `nil`.

Also: when a section tag `{{# pets }}...{{/ pets }}` is provided with an array, its content is rendered several times. However the delegate will be called once, with the array passed in the _object_ argument.


Providing Tag Delegates
-----------------------

Tag delegates are an uncommon kind of delegate. There is no object exposing a `delegate` property that you would set to your custom delegate, as one could expect.

Actually, *many* tag delegates can enter the game, observe, and alter the rendering of a template. For example, NSDateFormatter and NSNumberFormatter are tag delegates, and this is how they can format all dates and numbers inside the section they are attached to (see the [NSFormatter Guide](NSFormatter.md)).

Delegates are scoped. They can observe all tags in a template, or all inner tags of a template section, such as `{{# xxx }}...{{/ xxx }}`.

You have to ways to inject tag delegates. The simplest is to have them enter the [context stack](runtime.md#the-context-stack). However, sometimes, your delegate should not "pollute" the template rendering with its own keys, and you will need to explicitely derive new contexts. Please follow us:

### By Entering the Context Stack

The [context stack](runtime.md#the-context-stack) contains all objects that can provide values to templates through their methods and properties. It is initialized by the object you render, and it extends by objects attached to sections.

*An object conforming to the GRMustacheTagDelegate protocol gets "active" as soon as it enters the context stack.*

For example, consider the following template and rendering code:

`Document.mustache`

    {{# currentDate }}
    {{# user }}
        {{ name }} ({{ age }})
    {{/ user }}

```objc
// Load Document.mustache
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];

// Initialize Document object
Document *document = [[Document alloc] init];
document.user = self.user;

// Render
NSString *rendering = [template renderObject:document error:NULL];
```

The first object entering the context stack is the document. As long as it conforms to the GRMustacheTagDelegate protocol, it will get notified of the rendering of *all* tags (`{{# currentDate }}`, `{{# user }}...{{/ user }}`, `{{ name }}`, and `{{ age }}`).

As soon as the `{{# user }}...{{/ user }}` section renders, the user enters the context stack. It will get notified of the rendering of the inner tags of the section (explicitly: `{{ name }}`, and `{{ age }}`).


### By Entering the Base Context of a Template

As soon as an object enters the [context stack](runtime.md#the-context-stack), all its methods, properties, and generally speaking, values returned by the `objectForKeyedSubscript:` and `valueForKey:` methods are available for the templates (see the [Runtime Guide](runtime.md)).

This may be undesirable. You may want an object to be a tag delegate while not providing any value to the templates.

In this case, you can observe all tags in a template by deriving its *base context*. The base context contains values and tag delegates that are always available for the template rendering. It contains all the ready for use tools of the [standard library](standard_library.md), for example.

Let's see how `self` can become a tag delegate for the whole template:

```objc
// Load Document.mustache
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];

// Add self as a tag delegate
[template extendBaseContextWithTagDelegate:self];

// Initialize Document object
Document *document = [[Document alloc] init];
document.user = self.user;

// Render
NSString *rendering = [template renderObject:document error:NULL];
```

See the [GRMustacheTemplate Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTemplate.html) for a full discussion of `extendBaseContextWithTagDelegate:`.



### By Deriving a Deep Context

To illustrate this last use case, let's write an object that renders the uppercase version of all inner tags of the section it is attached to.

We do not want it to "pollute" the [context stack](runtime.md#the-context-stack), because we want it to be able to transform *all* tags, including `{{ description }}`. Should our object be in the context stack, its own description (inherited from NSObject) would render, and we would have a bug.

`Document.mustache`

    {{ firstName }} {{ lastName }}: {{ description }}
    {{# uppercase }}
        {{ firstName }} {{ lastName }}: {{ description }}
    {{/ uppercase }}

We expect the rendering to be:

    John Locke: English philosopher and physician
    JOHN LOCKE: ENGLISH PHILOSOPHER AND PHYSICIAN

Here is the implementation of our UppercaseTagDelegate class.

It conforms to GRMustacheTagDelegate, obviously, but also to the [GRMustacheRendering protocol](rendering_objects.md). This protocol allows it to avoid the default rendering, that would send it right into the the context stack.

```objc
@interface UppercaseTagDelegate : NSObject<GRMustacheTagDelegate, GRMustacheRendering>
@end

@implementation UppercaseTagDelegate

// GRMustacheRendering
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError *__autoreleasing *)error
{
    // Render the Mustache tag with an extended context
    context = [context contextByAddingTagDelegate:self];
    return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}

// GRMustacheTagDelegate
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    return [[object description] uppercaseString];
}

@end
```

See the [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full discussion of `contextByAddingTagDelegate:`.

See also the [GRMustacheRendering Protocol Reference](http://groue.github.io/GRMustache/Reference/Protocols/GRMustacheRendering.html) and [GRMustacheTag Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html) for a full documentation of GRMustacheRendering and GRMustacheTag.


Use Cases for Tag Delegates
---------------------------

### Default Values

```objc
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    if (object == nil) {
        NSLog(@"Missing value for %@", tag);
        return @"DEFAULT";
    }
    return object;
}
```

Your application log will contain lines like:

    Missing value for <GRMustacheVariableTag `{{ name }}` at line 3>
    Missing value for <GRMustacheVariableTag `{{ fullDateFormat(joinDate) }}` at line 12>


### Cross-Platform Filters

Tag delegates can alter the rendering of all tags inside the section they are attached to.

Let's consider the behavior of NSFormatter in GRMustache. They are able to format all variable tags inside a section (check the [NSFormatter Guide](NSFormatter.md)).

For example, `{{#percent}}x = {{x}}{{/percent}}` renders as `x = 50 %` when `percent` is attached to an NSNumberFormatter. That is because formatters are tag delegates, just as our UppercaseTagDelegate class above.

We could also use [filters](filters.md) in order to format numbers: `x = {{ percent(x) }}` would render just as well.

However, `{{#percent}}x = {{x}}{{/percent}}` has one advantage over `x = {{ percent(x) }}`: it uses plain Mustache syntax, and is compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations).

With such a common template, it's now a matter of providing different data, depending on the platform:

    // common template
    {{#percent}}x = {{x}}{{/percent}}
    
    // data for GRMustache
    {
      "x": 0.5,
      "percent": (some well-configured NSNumberFormatter)
    }

    // data for other Mustache implementations
    {
      "percent": {
        "x": "50 %" (computed during the "ViewModel preparation phase")
      }
    }

See? When you, GRMustache user, can provide your raw model data and have tag delegates do the formatting, users of the other implementations can still *prepare* their data and build a "ViewModel" that contains the values that should be rendered. Eventually both renderings are identical.


### Funny Hooks

Many objects of the [standard library](standard_library.md) are tag delegates. They are all built on top of public APIs, APIs that you can use, so check them out. For example:

- GRMustacheHTMLEscapeFilter is quite simple: [GRMustacheHTMLLibrary.m](../src/classes/GRMustacheHTMLLibrary.m)
- GRMustacheLocalizer is less simple: [GRMustacheLocalizer.m](../src/classes/GRMustacheLocalizer.m)


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concept of "tag delegates".

**As a consequence, if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use `GRMustacheTagDelegate` with great care.**


[up](../../../../GRMustache#documentation), [next](protected_contexts.md)
