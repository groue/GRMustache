[up](../../../../GRMustache#documentation), [next](filters.md)

GRMustache runtime
==================

Anatomy of a tag rendering
--------------------------

Let's consider the following code:

```objc
// A template
NSString *templateString = @"I have {{ count }} arms.";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// A pirate
template.tagDelegate = pirate;

// Rendering
id data = @{ @"count": @2 };
NSString *rendering = [template renderObject:data];
```

Let's have a precise look at the rendering of the `{{ count }}` tag.

1. First the `count` expression is evaluated. This evaluation is based on a key lookup mechanism based on the invocation of `valueForKey:` on your data object. Here we get an NSNumber of value 2.

2. Tag delegates enter the game. Those objects are covered in the [Tag Delegates Guide](delegate.md).

    Here, our pirate unilateraly decides that "arrr, lost my" should be rendered instead of the number 2.

3. the "arrr, lost my" string is asked to render for the `{{ count }}` tag. It is a string, so it simply renders itself.

Eventually, the final rendering is `I have arrr, lost my arms.`


Core methods and protocols
--------------------------

There are two methods and two protocols that you have to care about when providing data to GRMustache:

- `valueForKey:` is the standard [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) method, that GRMustache invokes when looking for the data that will be rendered. Basically, for a `{{name}}` tag to be rendered, all you need to provide is an NSDictionary with the `@"name"` key, or an object declaring the `name` property.

- `description` is the standard [NSObject](http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html) method, that GRMustache invokes when rendering the data it has fetched from `valueForKey:`. Most classes of Apple frameworks already have sensible implementations of `description`: NSString, NSNumber, etc. You generally won't have to think a lot about it.

- `NSFastEnumeration` is the standard protocol for [enumerable objects](http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html). The most obvious enumerable is NSArray. There are others, and you may provide your own. Objects that conform to the `NSFastEnumeration` protocol are the base of GRMustache loops.
    
    Both variable tags `{{items}}` and section tags `{{#items}}...{{/items}}` can loop. They render as many times as there are items in the collection.

- `GRMustacheRendering` is the protocol for objects that take full control of their rendering. This is how you implement the "Mustache lambdas" of http://mustache.github.com/mustache.5.html, for example. *Rendering objects* have their dedicated guide, the [Rendering Objets Guide](rendering_objects.md).


Mustache boolean sections
-------------------------

The section `{{# condition }}...{{/ condition }}` renders or not, depending on the boolean value of the `condition` key.

GRMustache considers as false the following values, and only those:

- `nil` and missing [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) keys
- `[NSNull null]`
- `NSNumber` instances whose `boolValue` method returns `NO`
- the empty string `@""`
- empty enumerables (all objects conforming to the NSFastEnumeration protocol, but NSDictionary -- the most obvious enumerable is NSArray).

They all prevent Mustache sections `{{#name}}...{{/name}}` rendering.

They all trigger inverted sections `{{^name}}...{{/name}}` rendering.


The context stack
-----------------

For Mustache to render a `{{ name }}` tag, it performs a lookup of the key `name`. This mechanism is detailed below.


### Mustache sections open new contexts

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


### Context stack and missing keys

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

### Sections vs. Key paths

You should be aware that these three template snippets are quite similar, but not stricly equivalent:

- `...{{#foo}}{{bar}}{{/foo}}...`
- `...{{#foo}}{{.bar}}{{/foo}}...`
- `...{{foo.bar}}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The two others are identical: they ensure the `bar` key comes from the `foo` object.


### Detailed description of GRMustache handling of `valueForKey:`

When GRMustache looks for a key in your data objects, it invokes their implementation of `valueForKey:`. With some extra bits.

**NSUndefinedKeyException handling**

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

**NSArray, NSSet, NSOrderedSet**

*GRMustache shunts the valueForKey: implementation of Foundation collections to NSObject's one*.

It is little know that the implementation of `valueForKey:` of Foundation collections return another collection containing the results of invoking `valueForKey:` using the key on each of the collection's objects.

This is very handy, but this clashes with the [rule of least surprise](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2878339) in the context of Mustache template rendering.

First, `{{collection.count}}` would not render the number of objects in the collection. `{{#collection.count}}...{{/}}` would not conditionally render if and only if the array is not empty. This has bitten at least [one GRMustache user](https://github.com/groue/GRMustache/issues/21), and this should not happen again.

Second, `{{#collection.name}}{{.}}{{/}}` would render the same as `{{#collection}}{{name}}{{/}}`. No sane user would ever try to use the convoluted first syntax. But sane users want a clean and clear failure when their code has a bug, leading to GRMustache not render the object they expect. When `object` resolves to an unexpected collection, `object.name` should behave like a missing key, not like a key that returns a unexpected collection with weird and hard-to-debug side effects.

Based on this rationale, GRMustache uses the implementation of `valueForKey:` of `NSObject` for arrays, sets, and ordered sets. As a consequence, the `count` key can be used in templates, and no unexpected collections comes messing with the rendering.


[up](../../../../GRMustache#documentation), [next](filters.md)
