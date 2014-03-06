[up](../../../../GRMustache#documentation), [next](compatibility.md)

Security
========

GRMustache is a template engine that combines template strings and data objects into its final rendering.

Both the template strings and the data objects may come from untrusted sources. For example, they may be remotely loaded from an untrusted remote host, or they may be user-defined.

GRMustache ships with both built-in and opt-in features that prevent vilain templates and data to threaten your application.


Secure Key Access
-----------------

Here is how GRMustache looks for a key in your data objects:

1. If the object responds to the `objectForKeyedSubscript:` instance method, return the result of this method.
2. Otherwise, build the list of valid keys:
  1. If the object responds to the `validMustacheKeys` class method defined by the `GRMustacheKeyValidation` protocol, use this method.
  2. Otherwise, use the list of Objective-C properties declared with `@property`.
  3. If object is an instance of NSManagedObject, add all the attributes of its Core Data entity.
3. If the key belongs to the list of valid keys, return the result of the `valueForKey:` method (catching NSUndefinedKeyException, as described in the [Runtime Guide](runtime.md#detailed-description-of-grmustache-handling-of-valueforkey).
4. Otherwise, this is a key miss.

The goal is to prevent `valueForKey:` from accessing dangerous methods.

Consider the code below:

```objc
@interface DBRecord : NSObject
- (void)deleteRecord;
@end

@implementation DBRecord
- (void)deleteRecord
{
    NSLog(@"Oooops, your record was just deleted!");
}
@end

// Render a vilain template:
NSString *templateString = @"{{# records }}{{ deleteRecord }}{{/ records }}";
NSString *rendering = [GRMustacheTemplate renderObject:document
                                            fromString:templateString
                                                 error:NULL];
```

Thanks to key validation, the `deleteRecord` method would not be called.

Limiting access to declared Objective-C properties by default is a good tradeoff. Your class can still implement the `validMustacheKeys` method, should you want to allow a different set of keys.

> The key validation mechanism is directly inspired by [fotonauts/handlebars-objc](https://github.com/fotonauts/handlebars-objc). Many thanks to [Bertrand Guiheneuf](https://github.com/bertrand).


Protected Contexts
------------------

### The Mustache key shadowing

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

Key shadowing is a threat on robust and/or reusable [partials](partials.md), [filters](filters.md), [rendering objects](rendering_objects.md) that process untrusted data in untrusted templates.

Because of untrusted data, you can not be sure that your precious keys won't be shadowed.

Because of untrusted templates, you can not be sure that your precious keys will be invoked with the correct syntax, should a syntax for navigating the context stack exist.


### Protected objects

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


### Protected namespaces

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

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of security.

In particular, **if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use protected objects with great care.**


[up](../../../../GRMustache#documentation), [next](compatibility.md)
