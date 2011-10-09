GRMustache Release Notes
========================

## v1.8.2

Better testing of public API thanks to availability macros.

## v1.8.1

Bug fixes

## v1.8

**GRMustache now supports the [Mustache specification v1.1.2](https://github.com/mustache/spec).**

New type and enum:

    enum {
        GRMustacheTemplateOptionNone = 0,
        GRMustacheTemplateOptionMustacheSpecCompatibility = 0x01,
    };

    typedef NSUInteger GRMustacheTemplateOptions;

New GRMustache methods:

- `+ (GRMustacheTemplateOptions)defaultTemplateOptions;`
- `+ (void)setDefaultTemplateOptions:(GRMustacheTemplateOptions)templateOptions;`

New GRMustacheTemplate methods:

- `+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (id)parseContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`
- `+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;`

New GRMustacheTemplateLoader methods:

- `+ (id)templateLoaderWithBaseURL:(NSURL *)url options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;`
- `+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;`


## v1.7.4

Bug fix: avoid crashing when one provides uninitialized NSError* to GRMustache.

## v1.7.3

One no longer needs to add `-all_load` to the "Other Linker Flags" target option tu use GRMustache static libraries.

## v1.7.2

- Fixed [issue #6](https://github.com/groue/GRMustache/issues/6)
- `[GRMustache preventNSUndefinedKeyExceptionAttack]` no longer prevents the rendering of `nil`.

## v1.7.1

Added missing header file

## v1.7.0

**GRMustache now ships as a static library.**

See the [Embedding](https://github.com/groue/GRMustache/wiki/Embedding) wiki page in order to see how to embed GRMustache in your project.

Besides, the NSUndefinedKeyException silencing is no longer activated by the DEBUG macro. You now have to explicitely call the `[GRMustache preventNSUndefinedKeyExceptionAttack]` method. For more details, see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page.

## v1.6.2

**LLVM3 compatibility**

## v1.6.1

The NSUndefinedKeyException silencing activated by the DEBUG macro applies to NSManagedObject instances (see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page).

## v1.6.0

**Reduced memory footprint**

New GRMustacheTemplateLoader methods:

- `+ (id)templateLoaderWithDirectory:(NSString *)path;`
- `+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext;`
- `+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;`

Deprecated GRMustacheTemplateLoader methods (replace `BasePath` with `Directory`):

- `+ (id)templateLoaderWithBasePath:(NSString *)path;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;`

Bug fixes around the NSUndefinedKeyException handling when the `DEBUG` macro is set (thanks to [Mike Ash](http://www.mikeash.com/)).

## v1.5.2

The `DEBUG` macro makes GRMustache raise much less NSUndefinedKeyException (see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page).

## v1.5.1

Bug fixes

## v1.5.0

**API simplification**

New GRMustacheTemplate method:

- `- (NSString *)renderObjects:(id)object, ...;`

New GRMustacheSection method:

- `- (NSString *)renderObjects:(id)object, ...;`

New class:

- `GRMustacheBlockHelper`

Deprecated class (use `id` instead when refering to a context, and use `renderObjects:` methods instead of instanciating one):

- `GRMustacheContext`

Deprecated function (use GRMustacheBlockHelper instead):

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

## v1.4.0

**iOS 3.0 support**

New `GRMustacheTemplate` methods:

- `+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError;`
- `+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError;`

New `GRMustacheTemplateLoader` methods:

- `+ (id)templateLoaderWithBasePath:(NSString *)path;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;`

## v1.3.3

Bug fixes

## v1.3.2

Bug fixes

## v1.3.1

Bug fixes

## v1.3.0

**Block-less API for helpers.**

New classes:

- `GRMustacheContext`
- `GRMustacheSection`

New functions:

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

Deprecated functions (use GRMustacheLambdaBlockMake instead):

- `GRMustacheLambda GRMustacheLambdaMake(NSString *(^block)(NSString *(^)(id object), id, NSString *));`

## v1.2.0

**iOS 4.0 support**

Deprecated class (use `[NSNumber numberWithBool:YES]` instead of `[GRYes yes]`):

- `GRYes`

Deprecated class (use `[NSNumber numberWithBool:NO]` instead of `[GRNo no]`):

- `GRNo`

## v1.1.6

GRMustacheTemplateLoader subclasses can now rely on an immutable `extension` property.

## v1.1.5

Bug fixes

## v1.1.4

Bug fixes

## v1.1.3

**Rendering performance improvement**

## v1.1.2

**Template compiling performance improvement**

## v1.1.1

Bug fixes

## v1.1.0

New methods:

- `[GRYes yes]` responds to `boolValue`
- `[GRNo no]` responds to `boolValue`

## v1.0.0

**First versioned release**
