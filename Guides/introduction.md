[up](../../../../GRMustache), [next](templates.md)

GRMustache introduction
=======================

- [The Mustache language](#the-mustache-language)
- [Beyond Mustache](#beyond-mustache)


The Mustache language
---------------------

Make sure you get familiar with the Mustache syntax and features first: http://mustache.github.io/mustache.5.html.

- **Variable tags**, as `{{name}}`, `{{{name}}}` and `{{&name}}` (HTML-escaped or not)
- **Section tags** (boolean, loop, lambda, inverted), as `{{#name}}...{{/name}}` and `{{^name}}...{{/name}}`
- **Partial tags**, as `{{> partial}}`
- **Comment tag**, as `{{! comment }}`
- **"Set delimiter tags"**, as `{{=<% %>=}}`

Features below are not documented in [mustache.5.html](http://mustache.github.io/mustache.5.html), despite their inclusion in the [Mustache specification](https://github.com/mustache/spec):

- **Key paths**, as `{{ person.name }}`, for direct access to an object's property.
- **"Implicit iterator"**, aka `{{.}}`, directly renders the current object (useful when looping over strings, for instance).
- **"Mustache lambdas"**, allow both `{{name}}` and `{{#name}}...{{/name}}` tags to invoke your own rendering code. This is documented in the [Rendering Objects Guide](rendering_objects.md).


Beyond Mustache
---------------

GRMustache goes beyond the [Mustache specification](https://github.com/mustache/spec), and adds many services on top of the minimalistic template engine.

Check the [Compatibility Guide](compatibility.md) whenever you want to render templates compatible with other Mustache implementations.


### Syntax extensions

- **Empty closing tags**, as in `{{#name}}...{{/}}`

    You don't have to repeat the opening expression in the closing tag.

- **"Else"**, as in `{{#name}}...{{^name}}...{{/name}}`
    
    You don't have to close a regular section if it is immediately followed by its inverted form.
    
    The short form `{{#name}}...{{^}}...{{/}}` is accepted, as well as the "unless" form `{{^name}}...{{#}}...{{/}}`.

- **"Anchored key paths"**, as `{{ .name }}` which enforces lookup of the `name` key in the immediate context instead of going through the context stack built by Mustache sections.
    
    If you are not familiar with the "context stack" and the Mustache key lookup mechanism, check the [Runtime Guide](runtime.md#the-context-stack).

- **Loops in variable tags**: a simple variable tag `{{items}}` renders a concatenation of the rendering of each individual item. You may think of Ruby on Rails' `<%= render @items %>`: check the [Rendering Objects Guide](rendering_objects.md).


### More partials

- **Support for the file system hierarchy**.
    
    Use relative `{{> header }}` or absolute paths `{{> /shared/header }}` to your partial templates: see the [Partials Guide](partials.md).

- **Template inheritance**, inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java), allow you to define reusable template layouts:
    
        {{< page }}      {{! page.mustache defines the layout.  }}
          {{$ content }} {{! this template defines the content. }}
            ...
          {{/ content }}
        {{/ page }}
    
    Template inheritance is documented in the [Template Inheritance Guide](template_inheritance.md).


### Text templates

Mustache focuses on rendering HTML, and safely HTML-escape your data.

GRMustache also supports text templates, that do not escape anything. Check the [HTML vs. Text Templates Guide](html_vs_text.md).


### Filters

Filters, as `{{ uppercase(name) }}`, are documented in the [Filters Guide](filters.md).


### Powerful Lambdas

Forget everything you know about the stifled genuine Mustache lambdas, and give GRMustache [rendering objects](rendering_objects.md) a try.


### Services

The library ships with a [standard library](standard_library.md) of various filters and tools for rendering your data.

Our old friend [NSFormatter](NSFormatter.md) is also welcome to the party.


### Flexibility

GRMustache's core engine is extensible. Feel free to hook in:

- [Filters](filters.md) transform your raw data.
- [Rendering objects](rendering_objects.md) provide custom rendering.
- [Tag delegates](delegate.md) observe and alter tag rendering.

Those three hooks are lego bricks: from them you can build more complex tools, such as [NSFormatter](NSFormatter.md) and the [localize](standard_library.md#localize) helper.


### Security

GRMustache has built-in features that prevents it from threatening your application whenever you render untrusted templates or data. See the [Security Guide](security.md) for more information.


[up](../../../../GRMustache), [next](templates.md)
