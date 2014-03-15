[up](../../../../GRMustache#documentation), [next](template_repositories.md)

Security
========

GRMustache ships with security features that help preventing untrusted templates and data to threaten your application.

- [Safe Key Access](#safe-key-access)
- [Priority keys](#priority-keys)
- [Compatibility with other Mustache implementations](#compatibility-with-other-mustache-implementations)


Safe Key Access
---------------

The [Runtime Guide](runtime.md) describes how GRMustache looks for a key in your data objects:

1. If the object responds to the `objectForKeyedSubscript:` method, this method is used.
2. Otherwise, if the key is safe, then the `valueForKey:` method is used.
3. Otherwise, the key is considered missed.

By default, a key is *safe* if it is backed by a declared Objective-C property, or a Core Data attribute (for managed objects).

The goal is to prevent `valueForKey:` from accessing dangerous methods. Consider the code below:

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

Not being declared as a property, the `deleteRecord` key is considered unsafe. The `deleteRecord` method is not called.


### Custom list of safe keys

If this default secure behavior does not fit your need, you can implement the `safeMustacheKeys` method of the `GRMustacheSafeKeyAccess` protocol in your object class:

```objc
+ (NSSet *)safeMustacheKeys;
```

This method returns the set of all keys you want to allow access to.

GRMustache ships with built-in implementation of `safeMustacheKeys` for most immutable Foundation classes, so that you can freely use them in your templates: `{{ array.count }}`, `{{ set.anyObject}}`, `{{ url.host }}`, etc. render as expected.

> The full list of handled Foundation classes are: NSArray, NSAttributedString, NSData, NSDate, NSDateComponents, NSDecimalNumber, NSError, NSHashTable, NSIndexPath, NSIndexSet, NSMapTable, NSNotification, NSException, NSNumber, NSOrderedSet, NSPointerArray, NSSet, NSString, NSURL, and NSValue.

The `objectForKeyedSubscript:` method is another way to go: it is considered safe, and there is no limitation on keys that can be accessed through this method.


### Disabling safe key access

If you know what you are doing, you can disable safe key access altogether, removing all limitations on the keys that can be accessed via the `valueForKey:` method.

This can be done globally for all renderings:

```objc
GRMustacheConfiguration *config = [GRMustacheConfiguration defaultConfiguration];
config.baseContext = [config.baseContext contextWithUnsafeKeyAccess];
```

`GRMustacheConfiguration` is described in the [Configuration Guide](configuration.md).

Safe key access can be disabled for a single template as well:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
template.baseContext = [template.baseContext contextWithUnsafeKeyAccess];
```

See the [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of the GRMustacheContext class.

> The safe key access mechanism is directly inspired by [fotonauts/handlebars-objc](https://github.com/fotonauts/handlebars-objc). Many thanks to [Bertrand Guiheneuf](https://github.com/bertrand).


Priority keys
-------------

### The trouble: the Mustache key shadowing

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


### Priority keys

GRMustache addresses this concern by letting you store *priority objects* in the *base context* of a template.

The base context contains [context stack values](runtime.md#the-context-stack) and [tag delegates](delegate.md) that are always available for the template rendering. It contains all the ready for use tools of the [standard library](standard_library.md), for example. Context objects are detailed in the [Rendering Objects Guide](rendering_objects.md).

You can extend it with a priority object with the `extendBaseContextWithProtectedObject:` method:

```objc

id object = @{
    @"safe": @"important",
};

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
[template extendBaseContextWithProtectedObject:object];
```

Now the `safe` key can not be shadowed: it will always evaluate to the `important` value.

See the [GRMustacheTemplate Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTemplate.html) for a full discussion of `extendBaseContextWithProtectedObject:`.


### Priority namespaces

In order to explain how GRMustache behaves when you give priority to an object than contains other objects, let's use a metaphor:

Think of a priority object as a module in a programming language, and consider this Python snippet:

```python
import string
print string.digits # 0123456789
print digits        # NameError: "name 'digits' is not defined"
```

In Python, you need to provide the full path to an object inside a module, or you get an error. With GRMustache, access to objects inside priority objects is similar. Deep priority objects must be accessed via their full path:

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

Conclusion: you must use full paths to your deep priority objects, or they won't be found.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of security.

In particular, **if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use priority objects with great care.**


[up](../../../../GRMustache#documentation), [next](template_repositories.md)
