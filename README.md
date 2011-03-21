GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine, for MacOS 10.6, iPhoneOS 3.0 and iOS 4.0

It supports the following Mustache features:

- variables
- sections (boolean, enumerable, inverted, helpers)
- partials (and recursive partials)
- delimiter changes
- comments

It supports extensions to the [regular Mustache syntax](http://mustache.github.com/mustache.5.html):

- dot variable tag: `{{.}}` (introduced by [mustache.js](http://github.com/janl/mustache.js))
- extended paths, as in `{{../name}}` (introduced by [Handlebars.js](https://github.com/wycats/handlebars.js))

### Embedding in your XCode project

GRMustache is a standalone library made of the Objective-C files contained in the `Classes` folder. Add them to your XCode project, and link against Foundation.framework.

Import `GRMustache.h` in order to access all GRMustache features.

Header files whose names contain `private` declare private APIs which are subject to change, without notice, over releases.

### Versioning

GRMustache versioning policy complies to the one defined by the [Apache APR](http://apr.apache.org/versioning.html). Check the [release notes](https://github.com/groue/GRMustache/blob/master/RELEASE_NOTES.md).

### Testing

Open the MacOSGRMustache.xcodeproj project, and build the MacOSGRMustacheTest target. Tests pass if the build succeeds. You may also run the `make` command from the Terminal.

GRMustache is tested against the [core](https://github.com/groue/Mustache-Spec/tree/master/specs/core/), [file_system](https://github.com/groue/Mustache-Spec/tree/master/specs/file_system/), [dot_key](https://github.com/groue/Mustache-Spec/tree/master/specs/dot_key/), and [extended_path](https://github.com/groue/Mustache-Spec/tree/master/specs/extended_path/) modules of the [Mustache-Spec](https://github.com/groue/Mustache-Spec) project. More tests come from the [Ruby](http://github.com/defunkt/mustache) implementation.

### Advanced topics

This README file provides with basic GRMustache documentation. Check out the [wiki](https://github.com/groue/GRMustache/wiki) for discussions on some more advanced topics.

Simple example
--------------

	#import "GRMustache.h"
	
	NSDictionary *object = [NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"];
	[GRMustacheTemplate renderObject:object fromString:@"Hi {{name}}!" error:nil];
	// returns @"Hi Mom!"

Rendering methods
-----------------

The main rendering methods provided by the GRMustacheTemplate class are:

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
	                    bundle:(NSBundle *)bundle
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a bundle resource of provided extension.
	+ (NSString *)renderObject:(id)object
	              fromResource:(NSString *)name
	             withExtension:(NSString *)ext
	                    bundle:(NSBundle *)bundle
	                     error:(NSError **)outError;

All methods may return errors, described in the "Errors" section below.

Compiling templates
-------------------

If you are planning to render the same template multiple times, it is more efficient to parse it once, with the compiling methods of the GRMustacheTemplate class:

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
	             bundle:(NSBundle *)bundle
	              error:(NSError **)outError;
	
	// Loads and parses the template from a bundle resource of provided extension.
	+ (id)parseResource:(NSString *)name
	      withExtension:(NSString *)ext
	             bundle:(NSBundle *)bundle
	              error:(NSError **)outError;

Those methods return GRMustacheTemplate instances, which render objects with the following method:

	- (NSString *)renderObject:(id)object;

For instance:

	// Compile template
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:@"Hi {{name}}!" error:nil];
	// @"Hi Mom!"
	[template renderObject:[NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"]];
	// @"Hi Dad!"
	[template renderObject:[NSDictionary dictionaryWithObject:@"Dad" forKey:@"name"]];
	// @"Hi !"
	[template renderObject:nil];
	// @"Hi !", shortcut to renderObject:nil
	[template render];

Context objects
---------------

You will provide a rendering method with a context object.

Mustache tag names are looked in the context object, through the standard Key-Value Coding method `valueForKey:`.

The most obvious objects which support KVC are dictionaries. You may also provide with any other object:

	@interface Person: NSObject
	+ (id)personWithName:(NSString *)name;
	- (NSString *)name;
	@end

	// returns @"Hi Mom!"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{name}}!"
	                           error:nil];

A KVC key miss can raise a NSUndefinedKeyException. GRMustache catches those exceptions:

	// doesn't raise, and returns @"Hi !"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{XXX}}!"
	                           error:nil];

Those exceptions are part of the regular rendering of a template. Yet, when debugging your project, they may become an annoyance. Check the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page.

Tag types
---------

We'll now cover all mustache tag types, and how they are rendered.

But let's give some definitions first:

- GRMustache considers *enumerable* all objects conforming to the NSFastEnumeration protocol, but NSDictionary. The most obvious enumerable is NSArray.

- GRMustache considers *false* KVC key misses, and the following values: `nil`, `[NSNull null]`, `[NSNumber numberWithBool:NO]`, `kCFBooleanFalse`, and the empty string `@""`.

The topic of booleans is not trivial. Check the [Booleans](https://github.com/groue/GRMustache/wiki/Booleans) wiki page.

### Comments `{{!...}}`

Comments tags are not rendered.

### Variable tags `{{name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is not rendered.

Otherwise, it is rendered with the regular string description of the value, HTML escaped.

### Unescaped variable tags `{{{name}}}` and `{{&name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is not rendered.

Otherwise, it is rendered with the regular string description of the value, without HTML escaping.

### Sections `{{#name}}...{{/name}}`

Sections are rendered differently, depending on the value for key `name` in the context:

#### False sections

If the value is *false*, the section is not rendered.

The topic of booleans is not trivial. Check the [Booleans](https://github.com/groue/GRMustache/wiki/Booleans) wiki page.

#### Enumerable sections

If the value is *enumerable*, the text between the `{{#name}}` and `{{/name}}` tags is rendered once for each item in the enumerable.

Each item becomes the context while being rendered. This is how you iterate over a collection of objects:

	My shopping list:
	{{#items}}
	- {{name}}
	{{/items}}

When a key is missed at the item level, it is looked into the enclosing context.

#### Helper sections

Read below "Helpers", which covers in detail how GRMustache allows you to provide custom code for rendering sections.

#### Other sections

Otherwise - if the value is not enumerable, false, or helper - the content of the section is rendered once.

The value becomes the context while being rendered. This is how you traverse an object hierarchy:

	{{#me}}
	  {{#mother}}
	    {{#father}}
	      My mother's father was named {{name}}.
	    {{/father}}
	  {{/mother}}
	{{/me}}

When a key is missed, it is looked into the enclosing context. This is the base mechanism for templates like:

	{{! If there is a title, render it in a <h1> tag }}
	{{#title}}
	  <h1>{{title}}</h1>
	{{/title}}

### Inverted sections `{{^name}}...{{/name}}`

Such a section is rendered when the `{{#name}}...{{/name}}` section would not: in the case of false values, or empty enumerables.

### Partials `{{>partial_name}}`

A `{{>partial_name}}` tag is rendered as a partial loaded from the file system.

Partials must have the same extension as their including template.

Recursive partials are possible. Just avoid infinite loops in your context objects.

Depending on the method which has been used to create the original template, partials will be looked in different places :

- In the main bundle:
	- `renderObject:fromString:error:`
	- `parseString:error:`
- In the specified bundle:
	- `renderObject:fromResource:bundle:error:`
	- `renderObject:fromResource:withExtension:bundle:error:`
	- `parseResource:bundle:error:`
	- `parseResource:withExtension:bundle:error:`
- Relatively to the URL of the including template:
	- `renderObject:fromContentsOfURL:error:`
	- `parseContentsOfURL:error:`
- Relatively to the path of the including template:
	- `renderObject:fromContentsOfFile:error:`
	- `parseContentsOfFile:error:`

The "Template loaders" section below will show you more partial loading GRMustache features.

Dot key and extended paths
--------------------------

### Extended paths

GRMustache supports extended paths introduced by [Handlebars.js](https://github.com/wycats/handlebars.js). Paths are made up of typical expressions and / characters. Expressions allow you to not only display data from the current context, but to display data from contexts that are descendents and ancestors of the current context.

To display data from descendent contexts, use the / character. So, for example, if your context were structured like:

	context = [NSDictionary dictionaryWithObjectsAndKeys:
	           [Person personWithName:@"Alan"], @"person",
	           [Company companyWithName:@"Acme"], @"company",
	           nil];

you could display the person's name from the top-level context with the following expression:

	{{person/name}}

Similarly, if already traversed into the person object you could still display the company's name with an expression like ``{{../company/name}}`, so:

	{{#person}}{{name}} - {{../company/name}}{{/person}}

would render:

	Alan - Acme

### Dot key

Consistently with "`..`", the dot "`.`" stands for the current context itself. This dot key can be useful when iterating a list of scalar objects. For instance, the following context:

	context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects: @"beer", @"ham", nil]
	                                      forKey:@"item"];

renders:

	<ul><li>beer</li><li>ham</li></ul>

when applied to the template:

	<ul>{{#item}}<li>{{.}}</li>{{/item}}</ul>

Helpers
-------

Imagine that, in the following template, you wish the `link` sections to be rendered as hyperlinks:

	<ul>
	  {{#people}}
	  <li>{{#link}}{{name}}{{/link}}</li>
	  {{/people}}
	</ul>

We expect, as an output, something like:

	<ul>
	  <li><a href="/people/1">Roger</a></li>
	  <li><a href="/people/2">Amy</a></li>
	</ul>

GRMustache provides you with two ways in order to achieve this behavior. The first one uses Objective-C blocks, the second requires some selectors to be implemented.

### Block helpers

*Note that block helpers are not available until MacOS 10.6, and iOS 4.0.*

You will provide in the context a GRMustacheBlockHelper instance, built with a block which returns the string that should be rendered:

	id linkHelper = [GRMustacheBlockHelper helperWithBlock:(^(GRMustacheSection *section, id context) {
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          [context valueForKey:@"id"],    // id of person comes from current context
	          [section renderObject:context]] // link text comes from the natural rendering of the inner section
	}];

The block takes two arguments:

- `section` is an object which represents the rendered section.
- `context` is the current rendering context.

The `[section renderObject:context]` expression evaluates to the rendering of the section with the given context.

In case you would need it, the `section` object has a `templateString` property, which contains the litteral inner section, unrendered (`{{tags}}` will not have been expanded).

The final rendering now goes as usual, by providing objects for template keys, the helper for the key `link`, and some people for the key `people`:

	NSArray *people = ...;
	[template renderObject:[NSDictionary dictionaryWithObjectsAndKeys:
	                        linkHelper, @"link",
	                        people, @"people",
	                        nil]];

### Helper methods

Another way to execute code when rendering the `link` sections is to have the context implement the `linkSection:withContext:` selector (generally, implement a method whose name is the name of the section, to which you append `Section:withContext:`).

No block is involved, and this technique works before MacOS 10.6, and iOS 4.0.

Now the question is: which class should implement this helper selector? When the `{{#link}}` section is rendered, GRMustache is actually rendering a person. Remember the template itself:

	<ul>
	  {{#people}}
	  <li>{{#link}}{{name}}{{/link}}</li>
	  {{/people}}
	</ul>

Many objects are in the context and can provide the implementation: the person itself, the `people` array of persons, the object that did provide this array, up to the root, the object which has been initially provided to the template.

Let's narrow those choices to only two: either you have your model objects implement the `linkSection:withContext:` selector, or you isolate helper methods from your model.

#### Isolating helper methods

In order to achieve a strict MVC separation, one might want to isolate helper methods from data.

GRMustache allows you to do that: first declare a container for your helper methods:

	@interface RenderingHelper: NSObject
	@end
	
	@implementation RenderingHelper
	+ (NSString*)linkSection:(GRMustacheSection *)section
	             withContext:(id)context
	{
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          [context valueForKey:@"id"],      // id of person comes from current context
	          [section renderObject:context]];  // link text comes from the natural rendering of the inner section
	}
	@end

Here we have written class methods because our helper doesn't carry any state. You are free to define helpers as instance methods, too.

And now we can render:

	[template renderObjects:[RenderingHelper class], dataModel, nil];

The `renderObjects:` method takes several context objects. Key-value Coding lookup will start from the last provided object (in the above example, `dataModel`). The `{{#link}}` section of the template will thus be eventually be handled by the RenderingHelper class.


#### Helpers as a model category

You may also declare helper methods in categories of your model objects. For instance, if your model object is designed as such:

	@interface DataModel
	@property NSArray *people;  // array of Person objects
	@end
	
	@interface Person
	@property NSString *name;
	@property NSString *id;
	@end

You can declare the `linkSection:withContext` in a category of Person:

	@implementation Person(GRMustache)
	- (NSString*)linkSection:(GRMustacheSection *)section
	             withContext:(id)context
	{
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          self.id,                          // id comes from self
	          [section renderObject:context]];  // link text comes from the natural rendering of the inner section
	}
	@end

This mix of data and rendering code in a single class is a debatable pattern. Well, you can compare this to the NSString(UIStringDrawing) and NSString(AppKitAdditions) categories. Furthermore, a strict MVC separation mechanism is described above.

Anyway, the rendering can now be done with:

	DataModel *dataModel = ...;
	[template renderObject:dataModel];


#### Usages of helpers

Helpers can be used for whatever you may find relevant.

You may localize:

	// {{#NSLocalizedString}}...{{/NSLocalizedString}}
	+ (NSString *)NSLocalizedStringSection:(GRMustacheSection *)section withContext:(id)context {
	  return NSLocalizedString([section renderObject:context]);
	}

You may implement caching:

	// {{#cached}}...{{/cached}}
	- (NSString *)cachedSection:(GRMustacheSection *)section withContext:(id)context {
	  if (self.cache == nil) { self.cache = [section renderObject:context]; }
	  return self.cache;
	};

You may render an extended context:

	// {{#extended}}...{{/extended}}
	+ (NSString *)extendedSection:(GRMustacheSection *)section withContext:(id)context {
	  return [section renderObjects:context, ...];
	});

You may render a totally different context:

	// {{#alternative}}...{{/alternative}}
	+ (NSString *)alternativeSection:(GRMustacheSection *)section withContext:(id)context {
	  return [section renderObject:[NSDictionary ...]];
	});

You may implement debugging sections:

	// {{#debug}}...{{/debug}}
	+ (NSString *)debugSection:(GRMustacheSection *)section withContext:(id)context {
	  NSLog(section.templateString);         // log the unrendered section 
	  NSLog([section renderObject:context]); // log the rendered section 
	  return nil;                            // don't render anything
	});


Template loaders
----------------

### Fine tuning loading of templates

The GRMustacheTemplateLoader class is able to load templates and their partials from anywhere in the file system, and provides more options than the high-level methods already seen.

You may instanciate one with the following GRMustacheTemplateLoader class methods:

	// Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
	+ (id)templateLoaderWithBaseURL:(NSURL *)url;

	// Loads templates and partials from a directory, with provided extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
	+ (id)templateLoaderWithBaseURL:(NSURL *)url
	                      extension:(NSString *)ext;

	// Loads templates and partials from a directory, with provided extension, encoded in provided encoding (from MacOS 10.6 and iOS 4.0)
	+ (id)templateLoaderWithBaseURL:(NSURL *)url
	                      extension:(NSString *)ext
	                       encoding:(NSStringEncoding)encoding;
	
	// Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8
	+ (id)templateLoaderWithDirectory:(NSString *)path;

	// Loads templates and partials from a directory, with provided extension, encoded in UTF8
	+ (id)templateLoaderWithDirectory:(NSString *)path
	                        extension:(NSString *)ext;

	// Loads templates and partials from a directory, with provided extension, encoded in provided encoding
	+ (id)templateLoaderWithDirectory:(NSString *)path
	                        extension:(NSString *)ext
	                         encoding:(NSStringEncoding)encoding;
	
	// Loads templates and partials from a bundle, with "mustache" extension, encoded in UTF8
	+ (id)templateLoaderWithBundle:(NSBundle *)bundle;
	
	// Loads templates and partials from a bundle, with provided extension, encoded in UTF8
	+ (id)templateLoaderWithBundle:(NSBundle *)bundle
	                     extension:(NSString *)ext;
	
	// Loads templates and partials from a bundle, with provided extension, encoded in provided encoding
	+ (id)templateLoaderWithBundle:(NSBundle *)bundle
	                     extension:(NSString *)ext
	                      encoding:(NSStringEncoding)encoding;

Once you have a GRMustacheTemplateLoader object, you may load a template from its location:

	GRMustacheTemplate *template = [loader parseTemplateNamed:@"document" error:nil];

You may also have the loader parse a template string. Only partials would then be loaded from the loader's location:

	GRMustacheTemplate *template = [loader parseString:@"..." error:nil];

The rendering is done as usual:

	NSString *rendering = [template renderObject:...];

Also don't miss the [Implementing your own template loading strategy](https://github.com/groue/GRMustache/wiki/Implementing-your-own-template-loading-strategy) page in the wiki: you will learn how to subclass GRMustacheTemplateLoader in order to load templates and partials from anywhere.

Errors
------

The GRMustache library may return errors whose domain is GRMustacheErrorDomain.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the GRMustacheErrorCode enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodeTemplateNotFound,
	} GRMustacheErrorCode;


A less simple example
---------------------

Let's be totally mad, and display a list of people and their birthdates in a UIWebView embedded in our iOS application.

We'll most certainly have a UIViewController for displaying the web view:

	@interface PersonListViewController: UIViewController
	@property (nonatomic, retain) NSArray *persons;
	@property (nonatomic, retain) IBOutlet UIWebView *webView;
	@end

The `persons` array contains some instances of our Person model:

	@interface Person: NSObject
	@property (nonatomic, retain) NSString *name;
	@property (nonatomic, retain) NSDate *birthdate;
	@end

A PersonListViewController instance and its array of persons is a graph of objects that is already perfectly suitable for rendering our template:

	PersonListViewController.mustache:
	
	<html>
	<body>
	<dl>
	  {{#persons}}
	  <dt>{{name}}</dt>
	  <dd>{{localizedBirthdate}}</dd>
	  {{/persons}}
	</dl>
	</body>
	</html>

We already see the match between our classes' properties, and the `persons` and `name` keys. More on the `birthdate` vs. `localizedBirthdate` later.

We should already be able to render most of our template:

	@implementation PersonListViewController
	- (void)viewWillAppear:(BOOL)animated {
	  // Let's use self as the rendering context:
	  NSString *html = [GRMustacheTemplate renderObject:self
	                                       fromResource:@"PersonListViewController"
	                                       bundle:nil
	                                       error:nil];
	  [self.webView loadHTMLString:html baseURL:nil];
	}
	@end

Now our `{{#persons}}` enumerable section and `{{name}}` variable tag will perfectly render.

What about the `{{localizedBirthdate}}` tag?

Since we don't want to pollute our nice and clean Person model, let's add a category to it:

	@interface Person(GRMustache)
	@end

	static NSDateFormatter *dateFormatter = nil;
	@implementation Person(GRMustache)
	- (NSString *)localizedBirthdate {
	  if (dateFormatter == nil) {
	    dateFormatter = [[NSDateFormatter alloc] init];
	    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
	    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	  }
	  return [dateFormatter stringFromDate:date];
	}
	@end

And we're ready to go!

License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2010 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

