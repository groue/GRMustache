[up](../../../../GRMustache#documentation), [next](html_vs_text.md)

Configuration
=============

GRMustache has options: they are properties of a GRMustacheConfiguration instance. You basically have three levels of tuning:

- global configuration for all templates,
- configuration for all templates of a [template repository](template_repositories.md),
- configuration for a single template.

The global default configuration is `[GRMustacheConfiguration defaultConfiguration]`:

```objc
// Have GRMustache templates render text by default,
// and do not HTML-escape their input.
[GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;

// Load the text template `profile.mustache` from the main bundle:
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"profile" bundle:nil error:NULL];
```

Each template repository has its custom configuration, initialized with the default one:

```objc
GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDirectory:@"/path/to/templates"];

// Have all templates in /path/to/templates render HTML
repo.configuration.contentType = GRMustacheContentTypeHTML;

// Load the HTML template `profile.mustache`:
GRMustacheTemplate *template = [repo templateNamed:@"profile" error:NULL];
```

Options can be configured at the template level also: this is described below.


Factory configuration
---------------------

The global default configuration is there to suit your needs: tweak it.

Whenever you need a raw pristine configuration, use the `[GRMustacheConfiguration configuration]` class method. It returns a configuration initialized with factory defaults.

```objc
GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithDirectory:@"/path/to/templates"];

// Have all templates in /path/to/templates render with factory configuration:
repo.configuration = [GRMustacheConfiguration configuration];
```

GRMustacheConfiguration properties
----------------------------------

- [baseContext](#basecontext)
- [contentType](#contenttype)
- [tagStartDelimiter](#tagstartdelimiter-and-tagenddelimiter)
- [tagEndDelimiter](#tagstartdelimiter-and-tagenddelimiter)

### baseContext

Mustache rendering is all about looking for values in a *context stack*. That context stack is initialized with the *base context*, gets extended with the objects you provide to templates, and grows as Mustache sections get rendered each on its turn. See the [Runtime Guide](runtime.md#the-context-stack) for more information.

The default configuration contains the default base context, pre-filled with the GRMustache [standard library](standard_library.md).

The standard library pre-defines a few keys, such as `localize` and `uppercase`. For instance, the following template:

    {{# localize }}Hello {{ uppercase(name) }}!{{/ localize }}

Would render:

    Bonjour ARTHUR !

Provided with a name and a localization for "Hello %@!" string in the Localizable.strings file of the main bundle.

You can extend the base context:

```objc
// Globally for all templates:
[[GRMustache defaultConfiguration] extendBaseContextWithObject:myCustomLibrary]

// For templates of a template repository:
GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWith...];
[repo.configuration extendBaseContextWithObject:myCustomLibrary]
```

You can also reset it to a blank slate, getting rid of the whole standard library:

```objc
[GRMustache defaultConfiguration].baseContext = [GRMustacheContext context];
repo.configuration.baseContext = [GRMustacheContext context];
```

You may also be interested in [protected contexts](protected_contexts.md). They guarantee that a particular identifier will always evaluate to the same value.

```objc
// Guarantee that {{my_important_value}} will always render the same and cannot
// be overriden by custom data:
id library = @{ @"my_important_value": ... };
[repo.configuration extendBaseContextWithProtectedObject:library];
```

See the [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of the GRMustacheContext class.

#### At the template level

The base context can also be defined right at the template level:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
[template extendBaseContextWith...];    // base context extension
template.baseContext = ...;             // base context replacement
```

### contentType

The default configuration has the `GRMustacheContentTypeHTML` contentType, meaning that all templates render HTML by default, and escape their input.

GRMustache also supports *text templates*, that render text and do not escape anything.

This subject is fully covered in the [HTML vs. Text Templates Guide](html_vs_text.md).


### tagStartDelimiter and tagEndDelimiter

Mustache takes its name from its tag delimiters: `{{` and `}}`.

You can configure them through GRMustacheConfiguration:

```objc
// Have all templates use <% and %> as tag delimiters:
[GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
[GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";

// Only for templates of a template repository:
GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWith...];
repo.configuration.tagStartDelimiter = @"[[";
repo.configuration.tagEndDelimiter = @"]]";
```

#### At the template level

The tag delimiters can be overriden at the template level using a "Set Delimiters Tag" such as `{{=<% %>=}}`: now tag would look like `<% name %>`.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not talk about any of the options above.

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), check their documentation.**


[up](../../../../GRMustache#documentation), [next](html_vs_text.md)
