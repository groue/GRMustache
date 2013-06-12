[up](../../../../GRMustache), [next](templates.md)

GRMustache introduction
=======================

Core Mustache
-------------

Make sure you get familiar with the Mustache syntax and features first: http://mustache.github.io/mustache.5.html.

- **variable tags**, as `{{name}}`, `{{{name}}}` and `{{&name}}` (HTML-escaped or not)
- **section tags** (boolean, loop, lambda, inverted), as `{{#name}}...{{/name}}` and `{{^name}}...{{/name}}`
- **partial tags**, as `{{> partial}}`
- **comment tag**, as `{{! comment }}`
- **"set delimiter tags"**, as `{{=<% %>=}}`


Overlooked Mustache
-------------------

Those are not documented in [mustache.5.html](http://mustache.github.io/mustache.5.html), despite their inclusion in the [Mustache specification](https://github.com/mustache/spec):

- **Key paths**, as `{{ person.name }}`, for direct access to an object's property.
- **"Implicit iterator"**, aka `{{.}}`, directly renders the current object (useful when looping over strings, for instance).
- **"Mustache lambdas"**, allow both `{{name}}` and `{{#name}}...{{/name}}` tags to invoke your own rendering code. This is documented in the [Rendering Objects Guide](rendering_objects.md).


Beyond Mustache
---------------

Genuine Mustache falls short on a few topics.

GRMustache core engine implements syntaxes and features that are not in the specification (see the [Compatibility Guide](compatibility.md) for details).

### ViewModel classes

ViewModel classes let you implement specific keys for your templates. Check the [ViewModel Guide](view_model.md).


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

- **"Overridable partials"**, aka "template inheritance", inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java), allow you to define reusable template layouts:
    
        {{< page }}      {{! page.mustache defines the layout.  }}
          {{$ content }} {{! this template defines the content. }}
            ...
          {{/ content }}
        {{/ page }}
    
    Overridable partials are documented in the [Partials Guide](partials.md).


### Text templates

Mustache focuses on rendering HTML, and safely HTML-escape your data.

GRMustache also supports text templates, that do not escape anything. Check the [HTML vs. Text Templates Guide](html_vs_text.md).


### Filters

Filters, as `{{ uppercase(name) }}`, are documented in the [Filters Guide](filters.md).


### Lambdas that work

Forget everything you know about genuine Mustache lambdas, and give GRMustache [rendering objects](rendering_objects.md) a try.


Services
--------

GRMustache ships with a [standard library](standard_library.md) of various filters and tools for rendering your data.

Our old friend [NSFormatter](NSFormatter.md) is also welcome to the party.


Flexibility
-----------

GRMustache's core engine is extensible. Feel free to hook in:

- [Filters](filters.md) transform your raw data.
- [Rendering objects](rendering_objects.md) provide custom rendering.
- [Tag delegates](delegate.md) observe and alter tag rendering.

Those three hooks are lego bricks: from them you can build more complex tools, such as [NSFormatter](NSFormatter.md) and the [localize](standard_library.md#localize) helper.

Should you eventually build a library of reusable code snippets, you'll find [Protected Contexts](protected_contexts.md) useful.


Getting started
---------------

### Rendering dictionaries from template strings

You'll generally gather a template and a data object that will fill the "holes" in the template.

The shortest way to render a template is to mix a literal template string and a dictionary:

```objc
#import "GRMustache.h"

// Render "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" }
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];
```

`+[GRMustacheTemplate renderObject:fromString:error:]` is documented in the [Templates Guide](templates.md).

### Rendering model objects from template resources

However, your templates will often be stored as *resources* in your application bundle, and your data will come from your *model objects*. It turns out the following code should be more common:

```objc
#import "GRMustache.h"

// Render a profile document from the `Profile.mustache` resource:
Person *person = [Person personWithName:@"Arthur"];
NSString *profile = [GRMustacheTemplate renderObject:person
                                        fromResource:@"Profile"
                                              bundle:nil
                                               error:NULL];
```

`+[GRMustacheTemplate renderObject:fromResource:bundle:error:]` is documented in the [Templates Guide](templates.md).

### Reusing templates

You will spare CPU cycles by creating and reusing template objects:

```objc
#import "GRMustache.h"

GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:NULL];

// Render ad nauseam
NSString *arthurProfile = [template renderObject:arthur error:NULL];
NSString *barbaraProfile = [template renderObject:barbara error:NULL];
```

`+[GRMustacheTemplate templateFromResource:bundle:error:]` and `-[GRMustacheTemplate renderObject:error:]` are documented in the [Templates Guide](templates.md).

### Other use cases

Examples above are common use cases for MacOS and iOS applications. The library does [much more](../../../../GRMustache#documentation).

[up](../../../../GRMustache), [next](templates.md)
