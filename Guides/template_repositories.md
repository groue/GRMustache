[up](../../../../GRMustache), [next](runtime.md)

Template repositories
=====================

The GRMustacheTemplateRepository class allows you to load template strings and partials from various data sources.


Loading templates and partials from the file system
---------------------------------------------------

GRMustacheTemplateRepository ships with the following class methods:

```objc
// Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
+ (id)templateRepositoryWithBaseURL:(NSURL *)url;

// Loads templates and partials from a directory, with provided extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
+ (id)templateRepositoryWithBaseURL:(NSURL *)url
                  templateExtension:(NSString *)ext;

// Loads templates and partials from a directory, with provided extension, encoded in provided encoding (from MacOS 10.6 and iOS 4.0)
+ (id)templateRepositoryWithBaseURL:(NSURL *)url
                  templateExtension:(NSString *)ext
                           encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8
+ (id)templateRepositoryWithDirectory:(NSString *)path;

// Loads templates and partials from a directory, with provided extension, encoded in UTF8
+ (id)templateRepositoryWithDirectory:(NSString *)path
                    templateExtension:(NSString *)ext;

// Loads templates and partials from a directory, with provided extension, encoded in provided encoding
+ (id)templateRepositoryWithDirectory:(NSString *)path
                    templateExtension:(NSString *)ext
                             encoding:(NSStringEncoding)encoding;

// Loads templates and partials from a bundle, with "mustache" extension, encoded in UTF8
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle;  // nil stands for the main bundle

// Loads templates and partials from a bundle, with provided extension, encoded in UTF8
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle   // nil stands for the main bundle
                 templateExtension:(NSString *)ext;

// Loads templates and partials from a bundle, with provided extension, encoded in provided encoding
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle   // nil stands for the main bundle
                 templateExtension:(NSString *)ext
                          encoding:(NSStringEncoding)encoding;
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
GRMustacheTemplate *template = [repository templateFromString:@"...{(> partial)}..." error:NULL];
```
 
The rendering is done as usual:

```objc
NSString *rendering = [template renderObject:...];
```

Loading templates and partials from a dictionary of template strings
--------------------------------------------------------------------

Use the following GRMustacheTemplateRepository class method:

```objc
// Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary;
```

Now we may instanciate one:
    
```objc
NSDictionary *templates = [NSDictionary dictionaryWithObject:@"It works!" forKey:@"partial"];
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:templates];
```

Then load templates from it:

```objc
GRMustacheTemplate *template1 = [repository templateFromString:@"{{>partial}}" error:NULL];
GRMustacheTemplate *template2 = [repository templateWithTemplateName:@"partial" error:NULL];
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
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
@required

/**
 Provided with a partial name that comes from a `{{>name}}` mustache tag,
 this method should return an object which uniquely identifies a template.
*/
- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID;

/**
 Provided with a template ID that comes from the previous method,
 Returns a template string.
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
