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


Detailed description of GRMustache handling of `valueForKey:`
-------------------------------------------------------------

When GRMustache looks for a key in your data objects, it invokes their implementation of `valueForKey:`. With some extra bits.

### NSUndefinedKeyException handling

NSDictionary never complains when asked for an unknown key. However, the default NSObject implementation of `valueForKey:` raises an `NSUndefinedKeyException`.

*GRMustache catches those exceptions*.

For instance, if the pet above has to `name` property, it will raise an `NSUndefinedKeyException` that will be caught by GRMustache so that the key lookup can continue with the `person` object.

When debugging your project, those exceptions may become a real annoyance, because it's likely you've told your debugger to stop on every Objective-C exceptions.

You can avoid that: add the `-ObjC` linker flag to your target (http://developer.apple.com/library/mac/#qa/qa1490/_index.html), and make sure you call before any GRMustache rendering the following method:

```objc
#if !defined(NS_BLOCK_ASSERTIONS)
[GRMustache preventNSUndefinedKeyExceptionAttack];
#endif
```

You'll get a slight performance hit, so you'd probably make sure this call does not enter your Release configuration. This is the purpose of the conditional compilation based on the `NS_BLOCK_ASSERTIONS` preprocessor macro (see http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/Reference/reference.html).

### NSArray, NSSet, NSOrderedSet

*GRMustache shunts the valueForKey: implementation of Foundation collections to NSObject's one*.

It is little know that the implementation of `valueForKey:` of Foundation collections return another collection containing the results of invoking `valueForKey:` using the key on each of the collection's objects.

This is very handy, but this clashes with the [rule of least surprise](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2878339) in the context of Mustache template rendering.

First, `{{collection.count}}` would not render the number of objects in the collection. `{{#collection.count}}...{{/}}` would not conditionally render if and only if the array is not empty. This has bitten at least [one GRMustache user](https://github.com/groue/GRMustache/issues/21), and this should not happen again.

Second, `{{#collection.name}}{{.}}{{/}}` would render the same as `{{#collection}}{{name}}{{/}}`. No sane user would ever try to use the convoluted first syntax. But sane users want a clean and clear failure when their code has a bug, leading to GRMustache not render the object they expect. When `object` resolves to an unexpected collection, `object.name` should behave like a missing key, not like a key that returns a unexpected collection with weird and hard-to-debug side effects.

Based on this rationale, GRMustache uses the implementation of `valueForKey:` of `NSObject` for arrays, sets, and ordered sets.


[up](../runtime.md), [next](loops.md)

