[up](../../../../GRMustache#documentation), [next](html_vs_text.md)

Configuration
=============

GRMustache has options: they are properties of a GRMustacheConfiguration instance. You basically have three levels of tuning: globally for all templates, per [template repository](template_repositories.md), or per template.

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

Most options can be configured at the template level also. The `contentType` property seen above can be set using a pragma tag (see the [HTML vs. Text Templates Guide](html_vs_text.md)).


Factory configuration
---------------------

The global default configuration is there to suit your needs: tweak it.

Whenever you need a raw pristine configuration, use the `[GRMustacheConfiguration configuration]` class method. It returns a configuration initialized with factory defaults.


GRMustacheConfiguration properties
----------------------------------

```objc
@interface GRMustacheConfiguration : NSObject<NSCopying>
@property (nonatomic, retain) GRMustacheContext *baseContext;
@property (nonatomic) GRMustacheContentType contentType;
@property (nonatomic, copy) NSString *tagStartDelimiter;
@property (nonatomic, copy) NSString *tagEndDelimiter;
@end
```

### baseContext

Mustache rendering is all about looking for values in a *context stack*. That context stack is initialized with the *base context*, gets extended with the objects you provide to templates, and grows as Mustache sections get rendered each on its turn. See the [Runtime Guide](runtime.md) for more information.

The default configuration contains the default base context, pre-filled with the GRMustache [standard library](standard_library.md).

The standard library pre-defines a few keys, such as `localize` and `uppercase`. For instance, the following template:

    {{# localize }}Hello {{ uppercase(name) }}!{{/ localize }}

Would render:

    Bonjour ARTHUR !

Provided with a name and a localization for the "Hello %@!" string.

You can extend the global base context:

```objc
GRMustacheContext *baseContext = [GRMustache defaultConfiguration].baseContext;
GRMustacheContext *extendedContext = [baseContext contextByAddingObject:myCustomLibrary];
[GRMustache defaultConfiguration].baseContext = extendedContext;
```

You can also reset it to a blank slate, getting rid of the whole standard library:

```objc
[GRMustache defaultConfiguration].baseContext = [GRMustacheContext context];
```

#### At the template repository level

The configuration of a template repository overrides the default configuration: you can set the baseContext for a bunch of templates only.

```objc
// Configure all templates of the main bundle:
GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithBundle:nil];

repo.configuration.baseContext = ...;

// This template will use its repository base context:
GRMustacheTemplate *template = [repo templateNamed:@"profile" error:NULL];
```

#### At the template level

The base context can also be defined right at the template level:

```objc
// This template has its own base context:
GRMustacheTemplate *template = ...;
template.baseContext = ...;
```

### contentType

The default configuration has the `GRMustacheContentTypeHTML` contentType, meaning that all templates render HTML by default, and escape their input.

GRMustache also supports *text templates*, that render text and do not escape anything.

This subject is fully covered in the [HTML vs. Text Templates Guide](html_vs_text.md).


### tagStartDelimiter` and `tagEndDelimiter

Mustache takes its name from its tag delimiters: `{{` and `}}`.

Those can be overriden at the template level using a "Set Delimiters Tag" such as `{{=<% %>=}}`: now tag would look like `<% name %>`.

You can also configure them through GRMustacheConfiguration:

```objc
// Have all templates use <% and %> as tag delimiters:
[GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
[GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
```


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not talk about any of the options above.

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), check their documentation.**


[up](../../../../GRMustache#documentation), [next](html_vs_text.md)
