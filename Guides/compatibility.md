[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)

Compatibility With Other Mustache Engines
=========================================

There are many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) out there.

GRMustache makes sure you can render templates in a [specification](https://github.com/mustache/spec)-compliant way. **What the specification says is possible, is possible with GRMustache.**

There is a caveat, though: GRMustache does not honor the white-space rules of the spec, line suppression, indentation and other niceties. Your templates are rendered *raw*. Contributions are welcome ([Forking Guide](GRMustache/blob/master/Guides/forking.md)).

That being said, you may use GRMustache to its full extent, and build templates that can not be rendered by other Mustache implementations.

This guide is here to tell you where the border line is, topic by topic:

- Syntax extensions
- Sections and inverted sections
- Standard Library
- Text templates
- File system hierarchy of template and partials
- Dynamic partials
- Template inheritance, layouts, overridable partials
- Protected contexts
- Custom rendering objects
- Filters
- Tag delegates


Syntax extensions
-----------------

GRMustache introduces syntax that is not defined by the Mustache specification. Some other implementations may already provide support for these features (you should check their documentation):

- **Empty closing tags**, as in `{{#name}}...{{/}}`

    You don't have to repeat the opening expression in the closing tag.

- **"Else"**, as in `{{#name}}...{{^name}}...{{/name}}`
    
    You don't have to close a regular section if it is immediately followed by its inverted form.
    
    The short form `{{#name}}...{{^}}...{{/}}` is accepted, as well as the "unless" form `{{^name}}...{{#}}...{{/}}`.

- **"Anchored key paths"**, as `{{ .name }}` which enforces lookup of the `name` key in the immediate context instead of going through the context stack built by Mustache sections.
    
    If you are not familiar with the "context stack" and the Mustache key lookup mechanism, check the [Runtime Guide](runtime.md#the-context-stack).

- **Loops in variable tags**: a simple variable tag `{{items}}` renders a concatenation of the rendering of each individual item. You may think of Ruby on Rails' `<%= render @items %>`: check the [Rendering Objects Guide](rendering_objects.md).


Sections and inverted sections
------------------------------

The Mustache specification does not enforce the list of *false* values, the values that trigger or prevent the rendering of sections and inverted sections:

There is *no guarantee* that `{{# value }}...{{/ value }}` and `{{^ value }}...{{/ value }}` will render the same, provided with the exact same input, in all Mustache implementations.

That's unfortunate. Anyway, for the record, here is a reminder of all false values in GRMustache:

- `nil` and missing keys
- `[NSNull null]`
- `NSNumber` instances whose `boolValue` method returns `NO`
- empty strings `@""`
- empty enumerables.


Standard Library
----------------

The Mustache specification does not provide any service like the [GRMustache standard library](standard_library.md).


Text templates
--------------

In GRMustache, [text templates](html_vs_text.md) render text, do not HTML-escape their input, and can be safely embedded in HTML templates (they get HTML-escaped).

This topic is ignored by the Mustache specification, which only provides you with the triple-mustache `{{{ name }}}` tags (that do not HTML-escape).

Some other implementations allow you to disable HTML-escaping. However they may not allow mixing HTML and text templates, and `{{% CONTENT_TYPE:TEXT }}` pragma tags are, as far as I know, a specificity of GRMustache.

Writing cross-language templates require you to use {{{ triple }}} mustache tags, and to avoid mixing text with HTML.


File system hierarchy of template and partials
----------------------------------------------

You may want to store your templates and partials in a hierarchy of directories.

GRMustache allows to embed partials with relative or absolute paths: `{{> header }}`, `{{> ../header }}`, `{{> shared/header }}`, `{{> /shared/header }}`. See the [Partials Guide](partials.md).

This is a GRMustache nicety that is unheard of the Mustache specification.

Writing cross-language templates require you to use a flat storage of templates and partials.


Dynamic partials
----------------

GRMustache lets you embed partial templates that are chosen at runtime (see the [Rendering Objects Guide](rendering_objects.md)).

The Mustache specification does not cover this use case, and provides with lambda-based workarounds that eventually lead to unwanted HTML-escaping issues.

[Jamie Hill](https://github.com/thelucid) has a [Ruby](https://github.com/thelucid/tache) and a [Javascript](https://github.com/thelucid/mustache.js) engine that support dynamic partials.

Generally speaking, writing cross-language templates requires you to avoid this feature.


Template inheritance, layouts, overridable partials
---------------------------------------------------

Forgive the name dropping in this section title, but this feature has many names.

This [GRMustache feature](partials.md) is directly inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java).

There is no guarantee that our implementations are identical, though.

Use this feature with great care, and simply avoid it when looking for compatibility with other implementations.


Protected contexts
------------------

GRMustache lets you [protect](protected_contexts.md) some keys so that they are always evaluated to the same value, regardless of other data that you feed your templates with.

This feature is usually implemented by other implementations with functions or methods whose name start with `register`.

Check their documentation. This feature is, anyway, missing from the Mustache specification.


Custom rendering objects
------------------------

[Rendering objects](rendering_objects.md) let you inject your own rendering code.

They allow you to implement "Mustache lambdas", as described by the Mustache specification.

Rendering objects are more versatile, though. As such, they are an ambiguous tool. You will have to know when you cross the line.


Filters
-------

Now it's easy: [filters](filters.md), as in `{{ uppercase(name) }}`, are an extension that is simply not in the Mustache specification.

Don't use them if you want to write cross-language templates. Check the [Tag Delegates Guide](delegate.md): you'll find a way to implement filtering in a spec-compliant way.


Tag delegates
-------------

GRMustache's [tag delegates](delegate.md), unknown to the Mustache specification, let you observe, and possibly alter the rendering of the Mustache tags.

Tag delegates may be used for formatting values in a spec-compliant way (see sample code in [Tag Delegates Guide](delegate.md)). They may also at the core of many items of the [standard library](standard_library.md).

They are an ambiguous tool. You will have to know when you cross the line.


[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)
