Templates
=========

You'll learn here how to load, and render templates. [guides/runtime.md](runtime.md) will talk about about what happens *during* the rendering itself.

**TL;DR** Let XCode autocompletion magic find the correct method for you: just type "`[GRMustacheTemplate render`" or "`[GRMustacheTemplate parse`".

The `render...` family parses and renders templates on-the-fly, from strings, bundle resources, or files. The `parse...` family parses only. You'll then have to invoke `renderObject:` on the generated GRMustacheTemplate instances:

    // on-the-fly:
    NSString *rendering = [GRMustacheTemplate renderObject:... from...];
    
    // parse once, render many times:
    GRMustacheTemplate *template = [GRMustacheTemplate parse...];
    NSString *rendering = [template renderObject:...]

---

Errors
------

Not funny, but those happens.

Once and for all: GRMustache methods may return errors whose domain is `GRMustacheErrorDomain`, and error codes interpreted with the `GRMustacheErrorCode` enumeration:

    extern NSString* const GRMustacheErrorDomain;
    
    typedef enum {
        GRMustacheErrorCodeParseError,
        GRMustacheErrorCodeTemplateNotFound,
    } GRMustacheErrorCode;

On-the-fly rendering methods
----------------------------

There are methods for rendering from strings, files, and bundle resources:
    
    @interface GRMustacheTemplate
    
    // Renders the provided templateString.
    + (NSString *)renderObject:(id)object
                    fromString:(NSString *)templateString
                         error:(NSError **)outError;
    
    // Renders the template loaded from a url. (from MacOS 10.6 and iOS 4.0)
    + (NSString *)renderObject:(id)object
             fromContentsOfURL:(NSURL *)url
                         error:(NSError **)outError;
    
    // Renders the template loaded from a path.
    + (NSString *)renderObject:(id)object
            fromContentsOfFile:(NSString *)path
                         error:(NSError **)outError;
    
    // Renders the template loaded from a bundle resource of extension "mustache".
    + (NSString *)renderObject:(id)object
                  fromResource:(NSString *)name
                        bundle:(NSBundle *)bundle   // nil stands for the main bundle
                         error:(NSError **)outError;
    
    // Renders the template loaded from a bundle resource of provided extension.
    + (NSString *)renderObject:(id)object
                  fromResource:(NSString *)name
                 withExtension:(NSString *)ext
                        bundle:(NSBundle *)bundle   // nil stands for the main bundle
                         error:(NSError **)outError;

Remember GRMustache supports two flavors of the Mustache language: check [guides/flavors.md](flavors.md)

Parse-once-and-render-many-times methods
----------------------------------------

It's efficient to parse a template once, and then render it as often as needed:

    @interface GRMustacheTemplate
    
    // Parses the templateString.
    + (id)parseString:(NSString *)templateString
                error:(NSError **)outError;
    
    // Loads and parses the template from url. (from MacOS 10.6 and iOS 4.0)
    + (id)parseContentsOfURL:(NSURL *)url
                       error:(NSError **)outError;
    
    // Loads and parses the template from path.
    + (id)parseContentsOfFile:(NSString *)path
                        error:(NSError **)outError;
    
    // Loads and parses the template from a bundle resource of extension "mustache".
    + (id)parseResource:(NSString *)name
                 bundle:(NSBundle *)bundle   // nil stands for the main bundle
                  error:(NSError **)outError;
    
    // Loads and parses the template from a bundle resource of provided extension.
    + (id)parseResource:(NSString *)name
          withExtension:(NSString *)ext
                 bundle:(NSBundle *)bundle   // nil stands for the main bundle
                  error:(NSError **)outError;

Those methods return GRMustacheTemplate instances, which render objects with the following methods:

    - (NSString *)renderObject:(id)object;
    - (NSString *)renderObjects:(id)object, ...;    // nil-terminated list

The latter method, which takes several arguments, is helpful when several objects should feed the template.

Partials
--------

When a `{{>name}}` Mustache tags occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

Depending on the method which has been used to create the original template, partials will be looked for in different places :

- In the main bundle, with ".mustache" extension:
    - `renderObject:fromString:error:`
    - `parseString:error:`
- In the specified bundle, with ".mustache" extension:
    - `renderObject:fromResource:bundle:error:`
    - `parseResource:bundle:error:`
- In the specified bundle, with the provided extension:
    - `renderObject:fromResource:withExtension:bundle:error:`
    - `parseResource:withExtension:bundle:error:`
- Relatively to the URL of the including template, with the same extension:
    - `renderObject:fromContentsOfURL:error:`
    - `parseContentsOfURL:error:`
- Relatively to the path of the including template, with the same extension:
    - `renderObject:fromContentsOfFile:error:`
    - `parseContentsOfFile:error:`

You can write recursive partials. Just avoid infinite loops in your context objects.

More loading options
--------------------

All methods above load UTF8-encoded templates and partials from disk. If this does not fulfill your needs, check [guides/template_loaders.md](template_loaders.md)
