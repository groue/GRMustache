[up](../../../../GRMustache), [next](runtime.md)

Template repositories
=====================

The GRMustacheTemplateRepository class allows you to load template strings and partials from various data sources.


Loading templates and partials from the file system
---------------------------------------------------

The GRMustacheTemplate class itself provides [convenient methods](templates.md) for loading UTF8-encoded templates from bundles and from the file system.

GRMustacheTemplateRepository fills the remaining less-common needs.

It ships with the following class methods:

```objc
@interface GRMustacheTemplateRepository : NSObject

// Loads templates and partials from a directory, with "mustache" extension,
// encoded in UTF8 (from MacOS 10.6 and iOS 4.0).
+ (id)templateRepositoryWithBaseURL:(NSURL *)url;

// Loads templates and partials from a directory, with provided extension,
// encoded in UTF8 (from MacOS 10.6 and iOS 4.0).
+ (id)templateRepositoryWithBaseURL:(NSURL *)url
                  templateExtension:(NSString *)ext;

// Loads templates and partials from a directory, with provided extension,
// encoded in provided encoding (from MacOS 10.6 and iOS 4.0).
+ (id)templateRepositoryWithBaseURL:(NSURL *)url
                  templateExtension:(NSString *)ext
                           encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a directory, with "mustache" extension,
// encoded in UTF8.
+ (id)templateRepositoryWithDirectory:(NSString *)path;

// Loads templates and partials from a directory, with provided extension,
// encoded in UTF8.
+ (id)templateRepositoryWithDirectory:(NSString *)path
                    templateExtension:(NSString *)ext;

// Loads templates and partials from a directory, with provided extension,
// encoded in provided encoding.
+ (id)templateRepositoryWithDirectory:(NSString *)path
                    templateExtension:(NSString *)ext
                             encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a bundle, with "mustache" extension,
// encoded in UTF8.
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle;  // nil stands for the main bundle

// Loads templates and partials from a bundle, with provided extension, encoded
// in UTF8.
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle   // nil stands for the main bundle
                 templateExtension:(NSString *)ext;

// Loads templates and partials from a bundle, with provided extension, encoded
// in provided encoding.
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle   // nil stands for the main bundle
                 templateExtension:(NSString *)ext
                          encoding:(NSStringEncoding)encoding;
@end
```

For instance:

```objc
NSString *path = @"path/to/templates";
GRMustacheTemplateRepository *repository = [GRMustacheTemplate templateRepositoryWithDirectory:path];
```

You may now load a template:

```objc
// Loads path/to/templates/document.mustache
GRMustacheTemplate *template = [repository templateForName:@"document" error:NULL];
```
 
You may also have the repository parse a template string. Only partials would then be loaded from the repository:

```objc
// Would load path/to/templates/partial.mustache
GRMustacheTemplate *template = [repository templateFromString:@"...{{> partial}}..." error:NULL];
```
 
The rendering is done as usual:

```objc
NSString *rendering = [template renderObject:...];
```

Loading templates and partials from a dictionary of template strings
--------------------------------------------------------------------

Use the following GRMustacheTemplateRepository class method:

```objc
@interface GRMustacheTemplateRepository : NSObject

// _partialsDictionary_ is a dictionary whose keys are partial names, and values
// template strings.
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary;

@end
```

Now we may instanciate one:
    
```objc
NSDictionary *templates = [NSDictionary dictionaryWithObject:@"It works!" forKey:@"partial"];
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:templates];
```

Then load templates from it:

```objc
GRMustacheTemplate *template1 = [repository templateFromString:@"{{>partial}}" error:NULL];
GRMustacheTemplate *template2 = [repository templateForName:@"partial" error:NULL];
```

And finally render:

```objc
[template1 render];     // "It works!"
[template2 render];     // "It works!"
```


GRMustacheTemplateRepositoryDataSource protocol
-----------------------------------------------

Finally, you may implement the GRMustacheTemplateRepositoryDataSource protocol in order to load templates for unimagined sources.

```objc
/**
 * The protocol for a GRMustacheTemplateRepository's dataSource.
 * 
 * The dataSource's responsability is to provide Mustache template strings for
 * template and partial names.
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
 * You should try to choose "human-readable" template IDs. That is because
 * template IDs are embedded in the description of errors that may happen during
 * a template processing, in order to help the library user locate, and fix, the
 * faulting template.
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
 * The returned value can be nil: the library user would then eventually get an
 * NSError of domain GRMustacheErrorDomain and code
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
 * As usually, whenever this method returns nil, the _outError_ parameter should
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

[up](../../../../GRMustache), [next](runtime.md)
