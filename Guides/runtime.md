[up](../../../../GRMustache#documentation), [next](runtime_patterns.md)

GRMustache runtime
==================

You'll learn here how GRMustache renders your data. The loading of templates is covered in the [Templates Guide](templates.md). Common patterns for feeding templates are described in the [Feeding Templates Guides](runtime_patterns.md).

Variable tags
-------------

Variable tags `{{ name }}` and `{{{ name }}}` look for the `name` key in the object you provide:

```objc
id data = @{ @"name": @"Arthur" };

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];
```

Any [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) compliant object that responds to the `valueForKey:` method can be used.

Dictionaries are such objects. So are, generally speaking, your custom models:

```objc
// The Person class defines the `name` property:
Person *barbara = [Person personWithName:@"Barbara"];

// Renders "Hello Barbara!"
NSString *rendering = [GRMustacheTemplate renderObject:barbara
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];
```

Remember that `{{ name }}` renders HTML-escaped values, when `{{{ name }}}` and `{{& name }}` render unescaped values.

Objects are usually rendered with the [standard](http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html) `description` method, with two exceptions:

- Your custom objects that take full charge of their own rendering. See the [Rendering Objects Guide](rendering_objects.md) for further details.
- Objects conforming to the [NSFastEnumeration](http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html) protocol (but NSDictionary):

A variable tag renders all items of enumerable objects:

```objc
id data = @{ @"voyels": @[@"A", @"E", @"I", @"O", @"U"] };

// Renders "AEIOU"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"{{voyels}}"
                                                 error:NULL];
```

This especially comes handy with your custom [rendering objects](rendering_objects.md): you may think of Ruby on Rails' `<%= render @items %>`.

Expressions
-----------

Variable tags render simple keys as seen above, and, more generally, *expressions*, such as the key path `person.name` and the filtered expression `uppercase(person.name)`.

```objc
Person *craig = [Person personWithName:@"Craig"];
id data = @{ @"person": craig };

// Renders "Hello CRAIG!"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"Hello {{ uppercase(person.name) }}!"
                                                 error:NULL];
```

GRMustache first looks for the `person` key, extracts its `name`, and applies the `uppercase` built-in [filter](filters.md). The variable tag eventually renders the resulting string.


Section tags
------------

The rendering of section tags such as `{{# name }}...{{/ name }}` and `{{^ name }}...{{/ name }}` depend on the value attached to the `name` expression.

Generally speaking, *inverted sections* `{{^ name }}...{{/ name }}` render when *regular sections* `{{# name }}...{{/ name }}` do not. You can think of the caret `^` as the Mustache "unless".

Precisely speaking:

### False sections

If the value is *false*, regular sections are omitted, and inverted sections rendered:

```objc
id data = @{ @"red": @NO, @"blue": @YES };

// Renders "Not red"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"{{#red}}Red{{/red}}{{^red}}Not red{{/red}}"
                                                 error:NULL];

// Renders "Blue"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"{{#blue}}Blue{{/blue}}{{^blue}}Not blue{{/blue}}"
                                                 error:NULL];

```

When an inverted sections follows a regular section with the same expression, you can use the short `{{# name }}...{{^ name }}...{{/ name }}` form, avoiding the closing tag for `{{# name }}`. Think of "if ... else ... end". For brevity's sake, you can also omit the expression after the opening tag: `{{#name}}...{{^}}...{{/}}` is valid.

The full list of false values are:

- `nil` and missing keys
- `[NSNull null]`
- `NSNumber` instances whose `boolValue` method returns `NO`
- empty strings `@""`
- empty enumerables.

They all prevent Mustache sections `{{# name }}...{{/ name }}` rendering.

They all trigger inverted sections `{{^ name }}...{{/ name }}` rendering.

### Enumerable sections

If the value attached to a section conforms to the [NSFastEnumeration](http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html) protocol (except NSDictionary), regular sections are rendered as many times as there are items in the enumerable object:

```objc
NSArray *friends = @[
    [Person personWithName:@"Dennis"],
    [Person personWithName:@"Eugene"],
    [Person personWithName:@"Fiona"]];
id data = @{ @"friends": friends };

NSString *templateString = @"My friends are:\n"
                           @"{{# friends }}"
                           @"- {{ name }}\n"
                           @"{{/ friends }}";

// My friends are:
// - Dennis
// - Eugene
// - Fiona
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

Each item in the collection gets, each on its turn, available for the key lookup: that is how the `{{ name }}` tag renders each of my friend's name.

Inverted sections render if and only if the collection is empty:

```objc
id data = @{ @"friends": @[] }; // empty array

NSString *templateString = @"{{^ friends }}"
                           @"I have no friend, sob."
                           @"{{/ friends }}";

// I have no friend, sob.
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

#### Rendering a collection of strings

You may render a collection of strings with the dot expression `.`, aka "implicit iterator":

```objc
id data = @{ @"items": @[@"Ham", @"Jam"] };

NSString *templateString = @"{{# items }}"
                           @"- {{ . }}"
                           @"{{/ items }}";

// - Ham
// - Jam
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```


#### Rendering a section once when a collection contains several items

Sections render as many times as they contain items.

However, you may want to render a section *once* if and only if a collection is not empty. For example, when rendering a single `<ul>` HTML element that wraps several `<li>`.

A template that is compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) needs an extra boolean key that states whether the collection is empty or not:

```objc
NSArray *friends = ...;
id data = @{
    @"hasFriends": @(friends.count > 0),
    @"friends": friends };

NSString *templateString = @"{{# hasFriends }}"
                           @"<ul>"
                           @"  {{# friends }}"
                           @"  <li>{{ name }}</li>"
                           @"  {{/ friends }}";
                           @"</ul>"
                           @"{{/ hasFriends }}";

// <ul>
//   <li>Dennis</li>
//   <li>Eugene</li>
//   <li>Fiona</li>
// </ul>
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

If you do not care about compatibility, you can simply use the `count` property of NSArray, and use the fact that GRMustache considers zero numbers as false:

```objc
NSArray *friends = ...;
id data = @{ @"friends": friends };

NSString *templateString = @"{{# friends.count }}"
                           @"<ul>"
                           @"  {{# friends }}"
                           @"  <li>{{ name }}</li>"
                           @"  {{/ friends }}";
                           @"</ul>"
                           @"{{/ friends.count }}";

// <ul>
//   <li>Dennis</li>
//   <li>Eugene</li>
//   <li>Fiona</li>
// </ul>
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```


### Lambda sections

Mustache defines [lambda sections](http://mustache.github.com/mustache.5.html), that is, sections that execute your own application code, and allow you to extend the core Mustache engine.

Such sections are fully documented in the [Rendering Objects Guide](rendering_objects.md), but here is a preview:

```objc
id data = @{
    @"localize": [LocalizingHelper new],
    @"name1": @"Gustave",
    @"name2": @"Henriett" };

NSString *templateString = @"{{#localize}}Hello {{name1}}, do you know {{name2}}?{{/localize}}";

// Assuming a Spanish locale:
// Hola Gustave, sabes Henriett?
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

This fancy `LocalizingHelper` class is described in the [Localization Sample Code](sample_code/localization.md).


### Other sections

When a section renders an object that is not false, not enumerable, not a lambda, it renders once, making the objet available for the key lookup inside the section:

```objc
Person *ignacio = [Person personWithName:@"Ignacio"];
id data = @{ @"person": ignacio };

// Renders "Hello Ignacio!"
NSString *templateString = @"{{# person }}Hello {{ name }}!{{/ person }}";
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

### Expressions in sections

Just as variable tags, section tags render any well-formed expressions:

```objc
id data = @{
    @"person": @{
        @"friends": @[
            [Person personWithName:@"José"],
            [Person personWithName:@"Karl"],
            [Person personWithName:@"Lubitza"]]
    }
};

NSString *templateString = @"{{# withPosition(person.friends) }}"
                           @"    {{ position }}: {{ name }}"
                           @"{{/}}";

// 1: José
// 2: Karl
// 3: Lubitza
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

The `withPosition` filter, that makes the `position` key available inside the section, is described in the [Collection Indexes Sample Code](sample_code/indexes.md).


The Context Stack
-----------------

We have seen that values rendered by sections are made available for the key lookup inside the section.

As a matter of fact, objects that were the context of enclosing sections are still available: the latest object has just entered the top of the *context stack*.

An example should make this clearer. Let's consider the template below:

    {{# title }}
        {{ length }}
    {{/ title }}
    
    {{# title }}
        {{ title }}
    {{/ title }}

In the first section, the `length` key will be fetched from the `title` string which has just entered the context stack: it will be rendered as "6" if the title is "Hamlet".

In the last section, the title string is still the context. However it has no `title` key. Thus GRMustache looks for it in the enclosing context, finds again the title string, and renders it:

    6
    Hamlet

This technique allows, for example, the conditional rendering of a `<h1>` HTML tag if and only if the title is not empty (empty strings are considered false, see "false sections" above):

    {{# title }}
      <h1>{{ title }}</h1>  {{! rendered if there is a title }}
    {{/ title }}


Fine tuning of key lookup
-------------------------

### Focus on the current context

These three template snippets are quite similar, but not stricly equivalent:

- `...{{# foo }}{{ bar  }}{{/ foo }}...`
- `...{{# foo }}{{ .bar }}{{/ foo }}...`
- `...{{ foo.bar }}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The two others are identical: they ensure the `bar` key comes from the very `foo` object. If `foo` is not found, the `bar` lookup will fail as well, regardless of `bar` keys defined by enclosing contexts.

### Protected contexts

*Protected contexts* let you make sure some keys get always evaluated to the same value, regardless of objects that enter the context stack. Check the [Protected Contexts Guide](protected_contexts.md).

### Tag delegates

Values extracted from the context stack are directly rendered unless you had some *tag delegates* enter the game. They help you render default values for missing keys, for example. See the [Tag Delegates Guide](delegate.md) for a full discussion.


Detailed description of GRMustache handling of `valueForKey:`
-------------------------------------------------------------

As seen above, GRMustache looks for a key in your data objects with the `valueForKey:` method. With some extra bits.

### NSUndefinedKeyException handling

NSDictionary never complains when asked for an unknown key. However, the default NSObject implementation of `valueForKey:` raises an `NSUndefinedKeyException`.

*GRMustache catches those exceptions*, so that the key lookup can continue down the context stack.

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

Second, `{{#collection.name}}{{.}}{{/}}` would render the same as `{{#collection}}{{name}}{{/}}`. No sane user would ever try to use the convoluted first syntax. But sane users want a clean and clear failure when their code has a bug, leading to GRMustache not render the object they expect. When `object` resolves to an unexpected collection, `object.name` should behave like a missing key, not like a key that returns an unexpected collection with weird and hard-to-debug side effects.

Based on this rationale, GRMustache uses the implementation of `valueForKey:` of `NSObject` for arrays, sets, and ordered sets. As a consequence, the `count` key can be used in templates, and no unexpected collections comes messing with the rendering.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not enforce the list of *false* values, the values that trigger or prevent the rendering of sections and inverted sections:

There is *no guarantee* that `{{# value }}...{{/ value }}` and `{{^ value }}...{{/ value }}` will render the same, provided with the exact same input, in all Mustache implementations.

That's unfortunate. Anyway, for the record, here is a reminder of all false values in GRMustache:

- `nil` and missing keys
- `[NSNull null]`
- `NSNumber` instances whose `boolValue` method returns `NO`
- empty strings `@""`
- empty enumerables.

[up](../../../../GRMustache#documentation), [next](runtime_patterns.md)
