[up](../../../../GRMustache), [next](template_repositories.md)

Templates
=========

You'll learn here how to load, and render templates. [Guides/runtime.md](runtime.md) will talk about about what happens *during* the rendering itself.

Errors
------

Not funny, but those happens.

Once and for all: GRMustache methods may return errors whose domain is `GRMustacheErrorDomain`, and error codes interpreted with the `GRMustacheErrorCode` enumeration:

```objc
extern NSString* const GRMustacheErrorDomain;

typedef enum {
    GRMustacheErrorCodeParseError,
    GRMustacheErrorCodeTemplateNotFound,
} GRMustacheErrorCode;
```

On-the-fly rendering methods
----------------------------

There are methods for rendering from strings, files, and bundle resources:
    
```objc
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
```


Parse-once-and-render-many-times methods
----------------------------------------

It's efficient to parse a template once, and then render it as often as needed:

```objc
@interface GRMustacheTemplate

// Parses the templateString.
+ (id)templateFromString:(NSString *)templateString
                   error:(NSError **)outError;

// Loads and parses the template from url. (from MacOS 10.6 and iOS 4.0)
+ (id)templateFromContentsOfURL:(NSURL *)url
                          error:(NSError **)outError;

// Loads and parses the template from path.
+ (id)templateFromContentsOfFile:(NSString *)path
                           error:(NSError **)outError;

// Loads and parses the template from a bundle resource of extension "mustache".
+ (id)templateFromResource:(NSString *)name
                    bundle:(NSBundle *)bundle  // nil stands for the main bundle
                     error:(NSError **)outError;

// Loads and parses the template from a bundle resource of provided extension.
+ (id)templateFromResource:(NSString *)name
             withExtension:(NSString *)ext
                    bundle:(NSBundle *)bundle  // nil stands for the main bundle
                     error:(NSError **)outError;
```

Those methods return GRMustacheTemplate instances, which render objects with the following methods:

```objc
- (NSString *)renderObject:(id)object;
- (NSString *)renderObjects:(id)object, ...;    // nil-terminated list
```

The latter method, which takes several arguments, is helpful when several objects should feed the template. It actually initializes the rendering [context stack](runtime/context_stack.md) with those objects.

Partials
--------

When a `{{>name}}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

Depending on the method which has been used to create the original template, partials will be looked for in different places :

- In the main bundle, with ".mustache" extension:
    - `renderObject:fromString:error:`
    - `templateFromString:error:`
- In the specified bundle, with ".mustache" extension:
    - `renderObject:fromResource:bundle:error:`
    - `templateFromResource:bundle:error:`
- In the specified bundle, with the provided extension:
    - `renderObject:fromResource:withExtension:bundle:error:`
    - `templateFromResource:withExtension:bundle:error:`
- Relatively to the URL of the including template, with the same extension:
    - `renderObject:fromContentsOfURL:error:`
    - `templateFromContentsOfURL:error:`
- Relatively to the path of the including template, with the same extension:
    - `renderObject:fromContentsOfFile:error:`
    - `templateFromContentsOfFile:error:`

You can write recursive partials. Just avoid infinite loops in your context objects.

More loading options
--------------------

All methods above load UTF8-encoded templates and partials from disk. If this does not fulfill your needs, check [Guides/template_repositories.md](template_repositories.md)

[up](../../../../GRMustache), [next](template_repositories.md)
