[up](../../../../GRMustache), [next](forking.md)

GRMustacheTemplateDelegate protocol
===================================

This protocol lets you observe, and possibly alter the rendering of a template.

**Whoever needs to develop and use templates that are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) should make sure he does not use this protocol to alter template rendering.**

For everybody else, this protocol brings some yummy expressiveness.


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
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
```

Maybe verbose. But quite on target: as a matter of fact, in order to render a tag, GRMustache has to *invoke* the tag name on the rendered object, the one you've given to the template.

You can read the following properties of the *invocation* argument:

- `id returnValue`: the return value of the invocation.
- `NSString *key`: the key that did provide this value.

Note that a tag like `{{person.name}}` is rendered once. Thus `template:willRenderReturnValueOfInvocation:` will be called once. If the person has been found, the invocation's key will be `@"name"`, and the return value the name of the person. If the person could not be found, the key will be `@"person"`, and the return value `nil`.

### A practical use: debugging templates

You may, for instance, locate keys that could not find any data:

```objc
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        
        // Log the missing key
        NSLog(@"GRMustache missing key: %@", invocation.key);
    }
}
```

Alter the template rendering
----------------------------

The `returnValue` property of the *invocation* argument can be written. If you set it in `template:willRenderReturnValueOfInvocation:`, GRMustache will render the value you have provided.

```objc
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    invocation.returnValue = @"blah";
}
```

### A practical use: more debugging templates

Let's improve the targetting of missing keys by rendering a big visible value in the template where there should have been some correct data:

```objc
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        
        // Log the missing key...
        NSLog(@"GRMustache missing key: %@", invocation.key);
        
        // ...and render a big visible value so that we can't miss it.
        invocation.returnValue = @"[MISSING]";
    }
}
```


[up](../../../../GRMustache), [next](forking.md)
