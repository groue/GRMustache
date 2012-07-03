[up](../../../../GRMustache), [next](sample_code/README.md)

GRMustacheTemplateDelegate protocol
===================================

This protocol lets you observe, and possibly alter the rendering of a template.


Observe the template rendering
------------------------------

### Whole template rendering

The following methods are called before, and after the whole template rendering:

```objc
- (void)templateWillRender:(GRMustacheTemplate *)template;
- (void)templateDidRender:(GRMustacheTemplate *)template;
```

### Tag rendering

The following methods are called before, and after the rendering of substitution and sections tags (`{{name}}` and `{{#name}}...{{/name}}`):

```objc
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
```

Maybe verbose. But quite on target: as a matter of fact, in order to render a tag, GRMustache has to *invoke* the tag name on the rendered object, the one you've given to the template, and then to *interpret* it.

You can read the following properties of the *invocation* parameter:

- `id returnValue`: the return value of the invocation.
- `NSString *key`: the key that did provide this value.
- `NSString *description`: a string that helps you locate the corresponding Mustache tag.

Note that those methods do not allow you to build a complete "stack trace" of GRMustache rendering. They are not called for each accessed key. They are called for each tag rendering, which is quite different.

For instance, a tag like `{{person.name}}` is rendered once. Thus `template:willInterpretReturnValueOfInvocation:as:` will be called once. If the person has been found, the invocation's key will be `@"name"`, and the return value the name of the person. If the person could not be found, the key will be `@"person"`, and the return value `nil`.

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

You will find an actual use of this *interpretation* parameter in the [number formatting sample code](sample_code/number_formatting.md).


### A practical use: debugging templates

You may, for instance, locate keys that could not find any data:

```objc
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        
        // Log the missing key
        NSLog(@"GRMustache missing key: `%@` for %@", invocation.key, invocation.description);
    }
}
```

You'll get something like:

```
GRMustache missing key: `items` for <GRMustacheInvocation: {{#items}} at line 23
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
        invocation.returnValue = @"[DEFAULT]";
    }
}
```

[up](../../../../GRMustache), [next](sample_code/README.md)
