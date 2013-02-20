[up](../../../../GRMustache#documentation), [next](runtime.md)

Template repositories
=====================

A `GRMustacheTemplateRepository` instance represents a bunch of templates and partials that can embed each other via partial tags such as `{{> name }}`.

This class helps you solving cases that are not covered by other high-level methods:

- when the `[GRMustacheTemplate templateFrom...]` methods do not fit your needs (see the [Templates Guide](templates.md)).

    For example, your templates are not stored in the file system, or they are not encoded as UTF8.
    
- when your templates are stored in a hierarchy of directories, and you want to use absolute paths to [partials](partials.md).

    `{{> header }}` loads a `header` partial template stored next to its enclosing template, but `{{> /partials/header }}`, with a leading slash, loads a template located at the absolute path `/partials/header` from the root of the template repository.

- when you want a specific set of templates to have a specific configuration. For example you want them to render text, when all other templates of your application render HTML.

The first two use cases are covered by this guide. See the [Configuration Guide](configuration.md) for the latter.


Loading templates and partials from the file system
---------------------------------------------------

```objc
@interface GRMustacheTemplateRepository : NSObject

// Loads templates and partials from a directory, with "mustache" extension,
// encoded in UTF8.
+ (id)templateRepositoryWithBaseURL:(NSURL *)url;

// Loads templates and partials from a directory, with provided extension,
// encoded in provided encoding.
+ (id)templateRepositoryWithBaseURL:(NSURL *)url
                  templateExtension:(NSString *)ext
                           encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a directory, with "mustache" extension,
// encoded in UTF8.
+ (id)templateRepositoryWithDirectory:(NSString *)path;

// Loads templates and partials from a directory, with provided extension,
// encoded in provided encoding.
+ (id)templateRepositoryWithDirectory:(NSString *)path
                    templateExtension:(NSString *)ext
                             encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a bundle, with "mustache" extension,
// encoded in UTF8.
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle;  // nil stands for the main bundle

// Loads templates and partials from a bundle, with provided extension, encoded
// in provided encoding.
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle   // nil stands for the main bundle
                 templateExtension:(NSString *)ext
                          encoding:(NSStringEncoding)encoding;
@end
```

For instance:

```objc
NSString *templatesPath = @"path/to/templates";
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesPath];
```

You may now load a template:

```objc
// Loads path/to/templates/document.mustache
GRMustacheTemplate *template = [repository templateNamed:@"document" error:NULL];
```
 
You may also have the repository parse a template string. Only partials would then be loaded from the repository:

```objc
// Would load path/to/templates/partials/header.mustache
GRMustacheTemplate *template = [repository templateFromString:@"...{{> partials/header}}..." error:NULL];
```


The rendering is done as usual (see the [Templates Guide](templates.md)):

```objc
NSString *rendering = [template renderObject:... error:...];
```

### Absolute paths to partial templates

Assuming your templates are stored in a hierarchy of directories, you may sometimes have to refer to the same [partial template](partials.md) from different templates stored at different levels of your hierarchy.

For example, those three templates all include the same `shared/header.mustache` partial:

    a.mustache:
    {{> shared/header }}    {{! relative path to shared/header }}
    
    shared/b.mustache
    {{> header }}           {{! relative path to shared/header }}

    ios/c.mustache
    {{> ../shared/header }} {{! relative path to shared/header }}

In this case, use an absolute path in your partial tags, starting with a slash, and explicitly choose the root of absolute paths with a `GRMustacheTemplateRepository` object:

    a.mustache:
    {{> /shared/header }}   {{! absolute path to shared/header }}

    shared/b.mustache
    {{> /shared/header }}   {{! absolute path to shared/header }}

    ios/c.mustache
    {{> /shared/header }}   {{! absolute path to shared/header }}
    
```objc 
NSString *templatesPath = @"path/to/templates";
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesPath];

// Loads path/to/templates/a.mustache, and provides a root for
// absolute partial tags: 
GRMustacheTemplate aTemplate = [repository templateNamed:@"a"];
NSString *rendering = [aTemplate renderObject:... error:...];
```


Loading templates and partials from a dictionary of template strings
--------------------------------------------------------------------

When your template and partial strings are stored in memory, store them in a dictionary, and use the following GRMustacheTemplateRepository class method:

```objc
@interface GRMustacheTemplateRepository : NSObject

// _templates_ is a dictionary whose keys are partial names, and
// values template strings.
+ (id)templateRepositoryWithDictionary:(NSDictionary *)templates;

@end
```

Now we may instanciate one:
    
```objc
NSDictionary *templates = @{ @"partial": @"It works!" }
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:templates];
```

Then load templates from it:

```objc
GRMustacheTemplate *template1 = [repository templateFromString:@"{{>partial}}" error:NULL];
GRMustacheTemplate *template2 = [repository templateNamed:@"partial" error:NULL];
```

And finally render:

```objc
[template1 render];     // "It works!"
[template2 render];     // "It works!"
```


GRMustacheTemplateRepository Data Source
----------------------------------------

Finally, you may implement the `GRMustacheTemplateRepositoryDataSource` protocol in order to load templates for unimagined sources.

```objc
/**
 * The protocol for a GRMustacheTemplateRepository's data source.
 * 
 * The responsability of the data source's is to provide Mustache template
 * strings for template and partial names.
 * 
 * @see GRMustacheTemplateRepository
 */
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
@required

/**
 * Returns a template ID, that is to say an object that uniquely identifies a
 * template or a template partial.
 * 
 * The class of this ID is opaque: your implementation of a
 * GRMustacheTemplateRepositoryDataSource would define, for itself, what kind of
 * object would identity a template or a partial.
 * 
 * For instance, a file-based data source may use NSString objects containing
 * paths to the templates.
 * 
 * You should try to choose "human-readable" template IDs, because template IDs
 * are embedded in the description of errors that may happen during a template
 * processing, in order to help the library user locate, and fix, the faulting
 * template.
 * 
 * Whenever relevant, template and partial hierarchies are supported via the
 * _baseTemplateID_ parameter: it contains the template ID of the enclosing
 * template, or nil when the data source is asked for a template ID for a
 * partial that is referred from a raw template string (see
 * [GRMustacheTemplateRepository templateFromString:error:]).
 * 
 * Not all data sources have to implement hierarchies: they can simply ignore
 * this parameter.
 *
 * Data sources that implement hierarchies have to implement their own support
 * for absolute partial paths.
 * 
 * The return value of this method can be nil: the library user would then
 * eventually get an NSError of domain GRMustacheErrorDomain and code
 * GRMustacheErrorCodeTemplateNotFound.
 * 
 * @param templateRepository  The GRMustacheTemplateRepository asking for a
 *                            template ID.
 * @param name                The name of the template or template partial.
 * @param baseTemplateID      The template ID of the enclosing template, or nil.
 *
 * @return a template ID
 */
- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID;

/**
 * Provided with a template ID that comes from
 * templateRepository:templateIDForName:relativeToTemplateID:,
 * returns a Mustache template string.
 * 
 * For instance, a file-based data source may interpret the template ID as a
 * NSString object containing paths to the template, and return the file
 * content.
 * 
 * As usual, whenever this method returns nil, the _outError_ parameter should
 * point to a valid NSError. This NSError would eventually reach the library
 * user.
 * 
 * @param templateRepository  The GRMustacheTemplateRepository asking for a
 *                            Mustache template string.
 * @param templateID          The template ID of the template
 * @param outError            If there is an error returning a template string,
 *                            upon return contains nil, or an NSError object
 *                            that describes the problem.
 *
 * @return a Mustache template string
 */
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError;
@end
```

Now you just have to set the repository dataSource, and everything would go as usual:

```objc
Planet *mars = [Planet planetFromName:@"Mars"];
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepository];
repository.dataSource = mars;
```

[up](../../../../GRMustache#documentation), [next](runtime.md)
