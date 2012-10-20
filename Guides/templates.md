[up](../../../../GRMustache#documentation), [next](partials.md)

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

That means that the only errors you'll ever get from GRMustache are parse errors and missing templates errors. There is no such thing as a rendering error.

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

Error handling follows [Cocoa conventions](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/CreateCustomizeNSError/CreateCustomizeNSError.html). Especially:

> Success or failure is indicated by the return value of the method. [...] You should always check that the return value is nil or NO before attempting to do anything with the NSError object.


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

Error handling follows [Cocoa conventions](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/CreateCustomizeNSError/CreateCustomizeNSError.html). Especially:

> Success or failure is indicated by the return value of the method. [...] You should always check that the return value is nil or NO before attempting to do anything with the NSError object.

On success, those methods return GRMustacheTemplate instances, which render objects with the following methods:

```objc
- (NSString *)renderObject:(id)object;
- (NSString *)renderObjectsFromArray:(NSArray *)objects
```

The latter method, which takes an array of objects, is helpful when several objects should feed the template.


More loading options
--------------------

All methods above load UTF8-encoded templates and partials from disk. If this does not fulfill your needs, check [Guides/template_repositories.md](template_repositories.md)

[up](../../../../GRMustache#documentation), [next](partials.md)
