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

GRMustache uses the standard [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) `valueForKey:` method when performing key lookup.

GRMustache considers a key to be missing if and only if this method returns nil or throws an `NSUndefinedKeyException`.

When a key is missing, GRMustache looks for it in the enclosing contexts, the values that populated the enclosing sections, one after the other, until it finds a non-nil value.

For instance, when rendering the above template, the `name` key will be asked to the pet first. In case of failure, GRMustache will then check the `person` object. Eventually, when all previous objects have failed providing the key, the lookup will stop.

This is the context stack: it starts with the object initially provided, grows when GRMustache enters a section, and shrinks on section leaving.

A pratical use of this feature is the conditional rendering of a string:

```
{{#title}}
  <h1>{{title}}</h1>
{{/title}}
```

The `{{#title}}` section renders only if the title is not empty. In the section, the current context is the title string itself. Since this string fails providing the `title` key, the key loopup hence goes on, and finds again the title in the enclosing context, so that it can be rendered.

Sections vs. Key paths
----------------------

You should be aware that these three template snippets are quite similar, but not stricly equivalent:

- `...{{#foo}}{{bar}}{{/foo}}...`
- `...{{#foo}}{{.bar}}{{/foo}}...`
- `...{{foo.bar}}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The two others are identical: they ensure the `bar` key comes from the `foo` object.


Missing keys in detail: NSUndefinedKeyException
-----------------------------------------------

### GRMustache catches NSUndefinedKeyException

NSDictionary never complains when asked for an unknown key. However, the default NSObject implementation of `valueForKey:` invokes `valueForUndefinedKey:` when asked for an unknown key. `valueForUndefinedKey:`, in turn, raises an `NSUndefinedKeyException` in its default implementation.

*GRMustache catches those exceptions*.

For instance, if the pet above has to `name` property, it will raise an `NSUndefinedKeyException` that will be caught by GRMustache so that the key lookup can continue with the `person` object.

### Debugging

When debugging your project, those exceptions may become a real annoyance, because it's likely you've told your debugger to stop on every Objective-C exceptions.

You can avoid that: add the `-ObjC` linker flag to your target (http://developer.apple.com/library/mac/#qa/qa1490/_index.html), and make sure you call before any GRMustache rendering the following method:

```objc
#if !defined(NS_BLOCK_ASSERTIONS)
[GRMustache preventNSUndefinedKeyExceptionAttack];
#endif
```

You'll get a slight performance hit, so you'd probably make sure this call does not enter your Release configuration. This is the purpose of the conditional compilation based on the `NS_BLOCK_ASSERTIONS` preprocessor macro (see http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/Reference/reference.html).

[up](../runtime.md), [next](loops.md)

