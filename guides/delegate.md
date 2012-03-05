[up](../../../../GRMustache), [next](forking.md)

GRMustacheTemplateDelegate protocol
===================================

This protocol lets you observe, and possibly alter the rendering of a template.

**Whoever needs to develop and use templates that are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) should make sure he does not use this protocol to alter template rendering.**

For everybody else, this protocol brings some yummy expressiveness.


Observe the template rendering
------------------------------

The protocol allows you to observe the rendering of a whole template:

```objc
- (void)templateWillRender:(GRMustacheTemplate *)template;
- (void)templateDidRender:(GRMustacheTemplate *)template;
```

Two other methods allow to observe the rendering of Mustache tags:

```objc
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
```

Maybe verbose. But quite on target.

Those methods are called before and after GRMustache renders the result of an *invocation*. As a matter of fact, in order to render `{{name}}` or `{{#name}}...{{/name}}`, GRMustache has to *invoke* `name` on the rendered object, the one you've given to the template. The return value may be, for instance, "Eric Paul".

You can read the following properties of the *invocation* argument:

```objc
@property (nonatomic, readonly) NSString *key;
@property (nonatomic, retain) id returnValue;
```

`returnValue` will give you the return value (`@"Eric Paul"`, in our example).

`key` contains the key that did provide this value (`@"name"`, in our example).


Alter the template rendering
----------------------------

The `returnValue` property of the *invocation* argument can be written. If you set it in `template:willRenderReturnValueOfInvocation:`, GRMustache will render the value you have provided.


A practical use: debugging templates
----------------------------------

You may, for instance, locate keys that could not find any data:

```objc
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    // When returnValue is nil, GRMustache could not find any value to render.
    if (invocation.returnValue == nil) {
        
        // Log the missing key...
        NSLog(@"GRMustache missing key: %@", invocation.key);
        
        // ...and render a big visible value so that we can't miss it.
        invocation.returnValue = "[MISSING]";
    }
}
```

[up](../../../../GRMustache), [next](forking.md)
