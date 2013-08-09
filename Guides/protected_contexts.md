[up](../../../../GRMustache#documentation), [next](compatibility.md)

Protected Contexts
==================

The Mustache key shadowing
--------------------------

As Mustache sections get nested, the [context stack](runtime.md#the-context-stack) expands:

    {{#person}}
        {{#pet}}
            {{name}}  {{! the name of the pet of the person }}
        {{/pet}}
    {{/person}}

This is all good. However, the children contexts shadow their parents: keys get "redefined" as sections get nested:

    {{#person}}
        {{name}}        {{! the person's name }}
        {{#pet}}
            {{name}}    {{! the pet's name }}
        {{/pet}}
    {{/person}}


Robust code in an untrusted environment
---------------------------------------

Key shadowing is a threat on robust and/or reusable [partials](partials.md), [filters](filters.md), [rendering objects](rendering_objects.md) that process *untrusted data* in *untrusted templates*.

Because of untrusted data, you can not be sure that your precious keys won't be shadowed.

Because of untrusted templates, you can not be sure that your precious keys will be invoked with the correct syntax, should a syntax for navigating the context stack exist.

Untrusted data and templates do exist, I've seen them: at the minimum they are the data and the templates built by the [future you](http://xkcd.com/302/).


Protected objects
-----------------

GRMustache addresses this concern by letting you store *protected objects* in the *base context* of a template.

The base context contains [context stack values](runtime.md#the-context-stack) and [tag delegates](delegate.md) that are always available for the template rendering. It contains all the ready for use tools of the [standard library](standard_library.md), for example. Context objects are detailed in the [Rendering Objects Guide](rendering_objects.md).

You can extend it with a protected object with the `extendBaseContextWithProtectedObject:` method:

```objc

id protectedData = @{
    @"safe": @"important",
};

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
[template extendBaseContextWithProtectedObject:protectedData];
```

Now the `safe` key can not be shadowed: it will always evaluate to the `important` value.

See the [GRMustacheTemplate Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTemplate.html) for a full discussion of `extendBaseContextWithProtectedObject:`.


Protected namespaces
--------------------

In order to explain how GRMustache behaves when you protect an object than contains other objects, let's use a metaphor:

Think of a protected object as a module in a programming language, and consider this Python snippet:

```python
import string
print string.digits # 0123456789
print digits        # NameError: "name 'digits' is not defined"
```

In Python, you need to provide the full path to an object inside a module, or you get an error. With GRMustache, access to objects inside protected objects is similar. Deep protected objects must be accessed via their full path:

`Document.mustache`

    - {{string.digits}}                     {{! full path }}
    - {{#string}}{{.digits}}{{/string}}     {{! another kind of full path }}
    - {{digits}}                            {{! digits? which digits? }}
    - {{#string}}{{digits}}{{/string}}      {{! digits? which digits? }}

`Render.m`:

```objc
id modules = @{
    @"string": @{
        @"digits": @"0123456789"
    },
};

GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];

// "import string"
[template extendBaseContextWithProtectedObject:modules];

NSString *rendering = [template renderObject:nil error:NULL];
```

Final rendering:

    - 0123456789
    - 0123456789
    - 
    - 

See how the `digits` key, alone on the third and fourth line, has not been rendered.

Conclusion: you must use full paths to your deep protected objects, or they won't be found.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of "protected objects".

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use protected objects with great care.**


[up](../../../../GRMustache#documentation), [next](compatibility.md)
