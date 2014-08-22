[up](../../../../GRMustache#documentation), [next](view_model.md)

GRMustache runtime
==================

You'll learn here how your data is rendered. The loading of templates is covered in the [Templates Guide](templates.md). Common patterns for feeding templates are described in the [ViewModel Guide](view_model.md).

- [How keys are accessed](#how-keys-are-accessed)
- [Variable tags](#variable-tags)
- [Expressions](#expressions)
- [Section tags](#section-tags)
- [The context stack](#the-context-stack)
- [Fine tuning of key lookup](#fine-tuning-of-key-lookup)
- [Detailed description of GRMustache handling of `valueForKey:`](#detailed-description-of-grmustache-handling-of-valueforkey)
- [Compatibility with other Mustache implementations](#compatibility-with-other-mustache-implementations)

How keys are accessed
---------------------

Most Mustache tags will look for keys in your rendered objects. In the example below, the `{{name}}` tag fetches the key `name` from a dictionary, leading to the "Hello Arthur!" rendering:

```objc
NSDictionary *dictionary = @{ @"name": @"Arthur" };
NSString *rendering = [GRMustacheTemplate renderObject:dictionary fromString:@"Hello {{name}}!" error:NULL];
```

Dictionaries are an easy way to provide keys. Your own custom objects can be rendered as well, as long as they declare properties for keys used in templates:

```objc
@interface Person : NSObject
@property (nonatomic) NSString *name;
@end

NSDictionary *person = [[Person alloc] init];
person.name = @"Arthur";

// "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:person fromString:@"Hello {{name}}!" error:NULL];
```

Precisely, here is how keys are fetched:

1. If the object responds to the [keyed subscripting](http://clang.llvm.org/docs/ObjectiveCLiterals.html#dictionary-style-subscripting) `objectForKeyedSubscript:` method, this method is used.
2. Otherwise, if the key is safe, then the `valueForKey:` method is used.
3. Otherwise, the key is considered missed.

By default, a key is *safe* if it is backed by a declared Objective-C property, or a Core Data attribute (for managed objects).

You can mitigate this limitation, though. For example, `-[NSArray count]` is a method, not a property. However, GRMustache can render `{{ items.count }}`. This is because NSArray conforms to the `GRMustacheSafeKeyAccess` protocol. Check the [Security Guide](security.md#safe-key-access) for more information.


Variable tags
-------------

Variable tags `{{ name }}`, `{{{ name }}}` and `{{& name }}` look for the `name` key in the object you provide, and render the returned value.

`{{ name }}` renders HTML-escaped values, when `{{{ name }}}` and `{{& name }}` render unescaped values (the two last forms are equivalent).

Most objects are rendered with the `description` [standard method](http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html).

Objects conforming to the [NSFastEnumeration](http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html) protocol (but NSDictionary), such as NSArray are rendered as the concatenation of their elements:

```objc
id data = @{ @"voyels": @[@"A", @"E", @"I", @"O", @"U"] };

// Renders "AEIOU"
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:@"{{voyels}}"
                                                 error:NULL];
```

Finally, objects that implement the `GRMustacheRendering` protocol take full charge of their own rendering. See the [Rendering Objects Guide](rendering_objects.md) for further details.


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

GRMustache first looks for the `person` key, extracts its `name`, and applies the `uppercase` built-in filter of the [standard library](standard_library.md#uppercase). The variable tag eventually renders the resulting string.


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

Mustache defines [lambda sections](http://mustache.github.io/mustache.5.html), that is, sections that execute your own application code, and allow you to extend the core Mustache engine.

Such sections are fully documented in the [Rendering Objects Guide](rendering_objects.md), but here is a preview:

```objc
id data = @{
    @"name1": @"Gustave",
    @"name2": @"Henriett" };

NSString *templateString = @"{{#localize}}Hello {{name1}}, do you know {{name2}}?{{/localize}}";

// Assuming a Spanish locale:
// Hola Gustave, sabes Henriett?
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

The `localize` key is attached to a rendering object that is built in the [standard library](standard_library.md#localize) shipped with GRMustache.


### Other sections

When a section renders a value that is not false, not enumerable, not a [rendering object](rendering_objects.md), it renders once, making the value available for the key lookup inside the section:

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

NSString *templateString = @"{{# each(person.friends) }}"
                           @"    {{ @indexPlusOne }}: {{ name }}"
                           @"{{/}}";

// 1: José
// 2: Karl
// 3: Lubitza
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

The `each` filter is part of the [standard library](standard_library.md#each).


The context stack
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

### Priority keys

A *priority key* is always evaluated to the same value, regardless of objects that enter the context stack. Check the [Security Guide](security.md#priority-keys).

### Tag delegates

Values extracted from the context stack are directly rendered unless you had some *tag delegates* enter the game. They help you render default values for missing keys, for example. See the [Tag Delegates Guide](delegate.md) for a full discussion.


Detailed description of GRMustache handling of `valueForKey:`
-------------------------------------------------------------

As seen above, GRMustache looks for a key in your data objects with the `objectForKeyedSubscript:` and `valueForKey:` methods. If an object responds to `objectForKeyedSubscript:`, this method is used. For other objects, `valueForKey:` is used, as long as the key is safe (see the [Security Guide](security.md)).


### NSArray, NSSet, NSOrderedSet

GRMustache does not use `valueForKey:` for NSArray, NSSet, and NSOrderedSet. Instead, it directly invokes methods of those objects. As a consequence, keys like `count`, `firstObject`, etc. can be used in templates.


### NSUndefinedKeyException Handling

NSDictionary never complains when asked for an unknown key. However, the default NSObject implementation of `valueForKey:` raises an `NSUndefinedKeyException`.

*GRMustache catches those exceptions*, so that the key lookup can continue down the context stack.

Some of you may feel uncomfortable with those exceptions. See the paragraph below.


### NSUndefinedKeyException Prevention

Objective-C exceptions have several drawbacks, particularly:

1. they play badly with autorelease pools, and are reputed to leak memory.
2. they usually stop your debugger when you are developping your application.

The first point is indeed a matter of worry: Apple does not guarantee that exceptions raised by `valueForKey:` do not leak memory. However, I never had any evidence of such a leak from NSObject's implementation.

Should you still worry, we recommend that you avoid the `valueForKey:` method altogether. Instead, implement the [keyed subscripting](http://clang.llvm.org/docs/ObjectiveCLiterals.html#dictionary-style-subscripting) `objectForKeyedSubscript:` method on objects that you provide to GRMustache.

The second point is valid also: NSUndefinedKeyException raised by template rendering may become a real annoyance when you are debugging your project, because it's likely you've told your debugger to stop on every Objective-C exceptions.

You can avoid them as well: make sure you invoke once, early in your application, the following method:

```objc
[GRMustache preventNSUndefinedKeyExceptionAttack];
```

Depending on the number of NSUndefinedKeyException that get prevented, you will experience a slight performance hit, or a performance improvement.

Since the main use case for this method is to avoid Xcode breaks on rendering exceptions, the best practice is to conditionally invoke this method, using the [NS_BLOCK_ASSERTIONS](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/Reference/reference.html) that helps identifying the Debug configuration of your targets:

```objc
#if !defined(NS_BLOCK_ASSERTIONS)
// Debug configuration: keep GRMustache quiet
[GRMustache preventNSUndefinedKeyExceptionAttack];
#endif
```


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

[up](../../../../GRMustache#documentation), [next](view_model.md)
