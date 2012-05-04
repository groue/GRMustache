[up](../runtime.md), [next](loops.md)

The context stack
=================

Mustache sections open new contexts
-----------------------------------

Mustache sections allow you digging inside an object:

    {{#person}}
      {{#pet}}
          My pet is named {{name}}.
      {{/pet}}
    {{/person}}

Suppose this template is provided this object:

    { person: { pet: { name: 'Plato' }}}

The `person` key will return a person.

This person becomes the context in the `person` section: the `pet` key will be looked in that person.

Finally, the `name` key will be looked in the pet.


Context stack and missing keys
------------------------------

Should a key be missing in the current context, GRMustache will look for it in the enclosing contexts, the values that populated the enclosing sections.

For instance, when rendering the above template, the `name` key will be asked to the pet first. In case of failure, GRMustache will then check the `person` object. Eventually, when all previous objects have failed providing the key, the lookup will stop.

This is the context stack: it starts with the object initially provided, grows when GRMustache enters a section, and shrinks on section leaving.


Sections vs. Key paths
----------------------

You should be aware that these two template snippets are quite similar, but not stricly equivalent:

- `...{{#foo}}{{bar}}{{/foo}}...`
- `...{{foo.bar}}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The latter ensures the `bar` key comes from the `foo` object.


Missing keys in detail: NSUndefinedKeyException
-----------------------------------------------

### GRMustache catches NSUndefinedKeyException

GRMustache uses the standard [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) `valueForKey:` method when performing key lookup.

NSDictionary never complains when asked for an unknown key. However, the default NSObject implementation of `valueForKey:` invokes `valueForUndefinedKey:` when asked for an unknown key. `valueForUndefinedKey:`, in turn, raises an `NSUndefinedKeyException` in its default implementation.

*GRMustache catches those exceptions*, and behaves as if the value for that key were `nil`. Precisely, it catches `NSUndefinedKeyException` exceptions that come from the very objects that are sent the `valueForKey:` message. All other exceptions raise out of GRMustache, which does not aim at being a black hole.

For instance, if the pet above has to `name` property, it will raise an `NSUndefinedKeyException` that will be caught by GRMustache so that the key lookup can continue with the `person` object.

### Debugging

When debugging your project, those exceptions may become a real annoyance, because it's likely you've told your debugger to stop on every Objective-C exceptions.

You can avoid that: make sure you call before any GRMustache rendering the following method:

    [GRMustache preventNSUndefinedKeyExceptionAttack];

You'll get a slight performance hit, so you'd probably make sure this call does not enter your Release configuration.

One way to achieve this is to add `-DDEBUG` to the "Other C Flags" setting of your development configuration, and to wrap the preventNSUndefinedKeyExceptionAttack method call in a #if block, like:

```objc
#ifdef DEBUG
[GRMustache preventNSUndefinedKeyExceptionAttack];
#endif
```

[up](../runtime.md), [next](loops.md)

