[up](../../../../GRMustache), [next](templates.md)

GRMustache introduction
=======================

Make sure you get familiar with the Mustache syntax and features first: http://mustache.github.com/mustache.5.html.

Features
--------

### Core Mustache

- **variable tags**, as `{{name}}` and `{{{name}}}` (HTML-escaped or not)
- **section tags** (boolean, loop, lambda, inverted), as `{{#name}}...{{/name}}` and `{{^name}}...{{/name}}`
- **partial tags**, as `{{> partial}}`
- **comment tag**, as `{{! comment }}`
- **"set delimiter tags"**, as `{{=<% %>=}}`


### Overlooked Mustache

Those features are not documented in [mustache.5.html](http://mustache.github.com/mustache.5.html), despite their inclusion in the [Mustache specification](https://github.com/mustache/spec):

- **Key paths**, as `{{ person.name }}`, for direct access to an object's property.
- **"Implicit iterator"**, aka `{{.}}`, directly renders the current object (useful when looping over strings, for instance).
- **"Mustache lambdas"**, allow tags such as `{{name}}` and `{{#name}}...{{/name}}` to perform custom rendering. Those are documented at the [Rendering Objects Guide](rendering_objects.md).


### Mustache Language Extensions

Genuine Mustache falls short on a few topics. GRMustache implements syntaxes that are not in the specification:

- **Empty closing tags**, as in `{{#name}}...{{/}}`

    You don't have to repeat the opening expression in the closing tag.

- **"Else"**, as in `{{#name}}...{{^name}}...{{/name}}`
    
    You don't have to close a regular section if it is immediately followed by its inverted form.
    
    The short form `{{#name}}...{{^}}...{{/}}` is accepted, as well as the "unless" form `{{^name}}...{{#}}...{{/}}`.

- **"Anchored key paths"**, as `{{ .name }}` which prevents the lookup of the `name` key in the context stack built by Mustache sections, and guarantees that the `name` key will be fetched from the very current context.
    
    If you are not familiar with the "context stack" and the Mustache key lookup mechanism, check the [Runtime Guide](runtime.md).

- **Loops in variable tags**: a simple variable tag `{{items}}` renders as the concatenation of the rendering of each individual items. You may think of Ruby on Rails' `<%= render @items %>`: check the [Rendering Objects Guide](rendering_objects.md).

- **"Filters"**, as `{{ uppercase(name) }}`.
    
    Filters are documented in the [Filters Guide](filters.md).

- **Support for partial templates in a file system hierarchy**.
    
    Use relative `{{> header }}` or absolute paths `{{> /shared/header }}` to your partial templates: see the [Partials Guide](partials.md).

- **"Overridable partials"**, aka "template inheritance", inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java).
    
    Overridable partials are documented in the [Partials Guide](partials.md).


### Powerful APIs

GRMustache is a Mustache engine that you can hack in.

- [Rendering objects](rendering_objects.md) provide their own custom rendering.
- [Tag delegates](delegate.md) observe and alter objects rendered by tags.
- [Filters](filters.md) transform your raw data.

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
