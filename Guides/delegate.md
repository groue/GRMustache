[up](introduction.md), [next](../../../tree/master/Guides/sample_code)

GRMustacheTemplateDelegate protocol
===================================

This protocol lets you observe, and possibly alter the rendering of a template.


Template delegate and section delegates
---------------------------------------

While rendering a template, several objects may get messages from GRMustache:

- The template's delegate itself, which you set via the `delegate` property of the GRMustacheTemplate class.
- Objects attached to sections, as long as they conform to the GRMustacheTemplateDelegate protocol.

The template's delegate can observe the full template rendering. However, sections delegates can only observe the rendering of their inner content. As sections get nested, a template gets more and more delegates.

You'll find template delegate usages below. Section delegates are used in the [localization](sample_code/localization.md) sample code.


Observe the template rendering
------------------------------

### Whole template rendering

The following methods are called before, and after the whole template rendering:

```objc
- (void)templateWillRender:(GRMustacheTemplate *)template;
- (void)templateDidRender:(GRMustacheTemplate *)template;
```

Section delegates are not sent these messages. Only template delegates are.

### Tag rendering

The following methods are called before, and after the rendering of substitution and sections tags (`{{name}}` and `{{#name}}...{{/name}}`):

```objc
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
```

Maybe verbose. But quite on target: as a matter of fact, in order to render a tag, GRMustache has to *invoke* the tag expression on the rendered object, the one you've given to the template, and then to *interpret* it.

You can read the following properties of the *invocation* parameter:

- `id returnValue`: the return value of the invocation.
- `NSString *description`: a string that helps you locate the corresponding Mustache tag.

Note that those methods do not allow you to build a complete "stack trace" of a template rendering.

For instance, a tag like `{{person.name}}` is rendered once. Thus `template:willInterpretReturnValueOfInvocation:as:` will be called once. If the person has been found, the return value will be the name of the person. If the person could not be found, the return value will be `nil`.

Also: if a section tag `{{#name}}...{{/name}}` is provided with an NSArray, its content is rendered several times. However `template:willInterpretReturnValueOfInvocation:as:` will be called once, with the array stored in the return value of the invocation.

The *interpretation* parameter tells you how the return value of the invocation is used:

```objc
typedef enum {
    GRMustacheInterpretationSection,
    GRMustacheInterpretationVariable,
} GRMustacheInterpretation;
```

`GRMustacheInterpretationVariable` tells you that the return value is rendered by a Mustache variable tag such as `{{name}}`. Basically, GRMustache simply invokes its `description` method. See [Guides/runtime.md](runtime.md) for more information.

`GRMustacheInterpretationSection` tells you that the return value is used by a Mustache section such as `{{#name}}...{{/name}}`. Mustache sections are versatile: there are boolean sections, loop sections, and lambda sections, and this depends solely on the rendered value, that is to say: the return value of the invocation. Again, see [Guides/runtime.md](runtime.md) for more information.


### A practical use: debugging templates

You may, for instance, give your templates a delegate that locate missing values:

```objc
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        NSLog(@"GRMustache missing value for %@", invocation.description);
    }
}
```

You'll get something like:

```
GRMustache missing value for <GRMustacheInvocation: {{#items}} at line 23
in template /path/to/template.mustache>
```

Alter the template rendering
----------------------------

The `returnValue` property of the *invocation* parameter can be written. If you set it in `template:willInterpretReturnValueOfInvocation:as:`, GRMustache will render the value you have provided.

**Warning: If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use this feature with great care.**


### A practical use: providing default values for missing keys

```objc
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        invocation.returnValue = @"DEFAULT";
    }
}
```

### Relationship with filters and helpers

Usually, [filters](filters.md) and [helpers](helpers.md) should do the trick when you want to alter a template's rendering.

However, they both require to be explicitly invoked from the template: `{{#helper}}...{{/helper}}`, and `{{ filter(...) }}`.

GRMustacheTemplateDelegate will help you when you can not, or do not want, to embed your extra behaviors right into the template.


Sample code
-----------

The [localization.md](sample_code/localization.md) sample code uses section delegates for localizing portions of template.


[up](introduction.md), [next](../../../tree/master/Guides/sample_code)
