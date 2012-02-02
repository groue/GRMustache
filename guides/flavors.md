[up](../../..), [next](forking.md)

Mustache flavors
================

**TL;DR** Should you use compound key paths in your templates, you'd rather use the dot `"."` as a separator: `{{foo.bar}}`, and execute once, before any template processing, the following statement:

    // Use genuine Mustache flavor
    [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionMustacheSpecCompatibility];

---

GRMustache ships with two concurrent interpretations of Mustache templates:

- genuine Mustache, as described by the [Mustache specification v1.1.2](https://github.com/mustache/spec)
- [Handlebars.js](https://github.com/wycats/handlebars.js)

How to choose a flavor
----------------------

The only difference so far between the two flavors implementation lies in the syntax for key paths: genuine Mustache reads `{{foo.bar.baz}}`, Handlebars reads `{{foo/bar/baz}}`, and even `{{../foo/bar/baz}}`.

If your templates do not use compound key paths, you can ignore this guide entirely.

If you are designing new templates from scratch, we encourage you writing your templates in the genuine Mustache flavor. Beware that GRMustache defaults to Handlebars: keep on reading.

### Application-wide flavor

If all of the templates processed by your application belong to the same flavor, consider setting the application-wide flavor with one of the following statement, prior to any template processing:

    // Use genuine Mustache flavor
    [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionMustacheSpecCompatibility];

    // Use Handlebars flavor (the default)
    [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionNone];

### Per-template flavor

Your application may have to process templates of different flavors.

All GRMustache methods that are involved in template parsing have sister methods that take options as an argument.

- `+[GRMustacheTemplate renderObject:fromString:error:]`
- `+[GRMustacheTemplate renderObject:fromString:options:error:]`
- `+[GRMustacheTemplate parseResource:bundle:error:]`
- `+[GRMustacheTemplate parseResource:bundle:options:error:]`
- `+[GRMustacheTemplateLoader templateLoaderWithBaseURL:]`
- `+[GRMustacheTemplateLoader templateLoaderWithBaseURL:options:]`
- etc.

The methods with explicit options will process the template as expected:

    // Use genuine Mustache flavor
    [GRMustacheTemplate renderObject:...
                          fromString:...
                             options:GRMustacheTemplateOptionMustacheSpecCompatibility
                               error:...];

    // Use Handlebars flavor
    [GRMustacheTemplate renderObject:...
                          fromString:...
                             options:GRMustacheTemplateOptionNone
                               error:...];

The methods with no explicit option use the default one set by `+[GRMustache setDefaultTemplateOptions:]`.

Note that once a template has been parsed, you can not render it in another flavor:
    
    // Parse a Handlebars template
    GRMustacheTemplate *template = [GRMustacheTemplate parseResource:...
                                                              bundle:...
                                                             options:GRMustacheTemplateOptionNone
                                                               error:...]`
    
    // Renders a Handlebars template (there is no `renderObject:options:` method):
    [template renderObject:...]

Specifications coverage
-----------------------

### Genuine Mustache

GRMustache has full coverage of [Mustache specification v1.1.2](https://github.com/mustache/spec), **except for whitespace management**.

That is to say, each character of your templates will be rendered as is, whitespace included.

### Handlebars

[Handlebars.js](https://github.com/wycats/handlebars.js) has introduced many nifty features.

Actually, GRMustache implements a single one: the syntax for key paths `{{foo/bar/baz}}` and `{{../foo/bar/baz}}`.

[up](../../..), [next](forking.md)
