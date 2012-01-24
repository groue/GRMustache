GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine, for MacOS 10.6+, iPhoneOS 3.0, iOS 4.0, and iOS 5.0.

It supports the [regular Mustache syntax](http://mustache.github.com/mustache.5.html), the [Mustache specification v1.1.2](https://github.com/mustache/spec), except for whitespace management (more on that below), and language extensions brought by [Handlebars.js](https://github.com/wycats/handlebars.js).

Full features list:

- HTML-escaped variable tags: `{{name}}`
- Unescaped variable tags: `{{{name}}}` and `{{&name}}`
- Sections (boolean, enumerable, inverted, lambdas): `{{#name}}...{{/name}}`
- partials (and recursive partials): `{{>name}}`
- delimiter changes: `{{=<% %>=}}`
- comments: `{{!...}}`
- "dotted names": `{{foo.bar}}`
- "implicit iterator": `{{.}}`
- "extended paths" of [Handlebars.js](https://github.com/wycats/handlebars.js): `{{../foo/bar}}`

On top of the core Mustache engine, GRMustache ships with a few handy stuff:

- Number formatting
- Date formatting

Note that:

- GRMustache does not honor the whitespace management rules of the [Mustache specification v1.1.2](https://github.com/mustache/spec): each character of your templates will be rendered as is.
- The default rendering of GRMustache is compatible with [Handlebars.js](https://github.com/wycats/handlebars.js). This means that support for "extended paths" such as `{{../foo/bar}}` is enabled by default. In order to use the "dotted names" of [Mustache v1.1.2](https://github.com/mustache/spec), such as `{{foo.bar}}`, you will have to ask for them explicitely.

### Embedding in your XCode project

GRMustache ships as a static library and a header file, and only depends on the Foundation.framework.

The `GRMustache.h` header file is located into the `/include` folder at the root of the GRMustache repository. Add it to your project.

You'll have next to choose a static library among those located in the `/lib` folder:

- `libGRMustache1-ios3.a`
- `libGRMustache1-ios4.a`
- `libGRMustache1-macosx10.6.a`

`libGRMustache1-ios3.a` targets iOS3+, and include both device and simulator architectures (i386 armv6 armv7). This means that this single static library allows you to run GRMustache on both simulator and iOS devices.

`libGRMustache1-ios4.a` targets iOS4+, and include both device and simulator architectures (i386 armv6 armv7). On top of all the APIs provided by `libGRMustache1-ios3.a`, you'll find blocks and NSURL* APIs in this version of the lib.

`libGRMustache1-macosx10.6.a` targets MaxOSX 10.6+. It includes both 32 and 64 bits architectures (i386 x86_64), and the full set of GRMustache APIs.

### Versioning and backward compatibility

Until GRMustache hits version 2, there is no risk upgrading GRMustache in your project: you will get bugfixes and improvements without changing a line of your code.

You may well get deprecation warnings, but these are only warnings. Support for deprecated APIs will only be removed in the next major version.

This is because GRMustache versioning policy complies to the one defined by the [Apache APR](http://apr.apache.org/versioning.html).

Check the [release notes](https://github.com/groue/GRMustache/blob/master/RELEASE_NOTES.md) for more information, and [Follow us on twitter](http://twitter.com/GRMustache) for breaking development news.

### Forking

Please fork, and read the [Note on forking](https://github.com/groue/GRMustache/wiki/Note-on-forking) wiki page.

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

All those methods perform a rendering that is compatible with [Handlebars.js](https://github.com/wycats/handlebars.js) and its "extended paths", such as `{{../foo/bar}}` (see below).

In order to process the "dotted names" of [Mustache v1.1.2](https://github.com/mustache/spec), such as `{{foo.bar}}`, you have to ask for it explicitely:

The recommended way is to call, prior to any rendering, the following method:

	[GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionMustacheSpecCompatibility];
	[GRMustacheTemplate renderObject:...]   // will use Mustache v1.1.2 rendering

Since GRMustache 2 will stop using Handlebars as its default behavior, think of this line as something similar to Python's `from __future__ import ...` (see [PEP 236](http://www.python.org/dev/peps/pep-0236/)). When GRMustache hits version 2, it will be easier for you to migrate.

You may also take the explicit and more verbose path, and provide the `GRMustacheTemplateOptionMustacheSpecCompatibility` option to methods below.

	enum {
	    // default, with support for extended paths of Handlebars.js
	    GRMustacheTemplateOptionNone = 0,
	    
	    // support for the dotted names of Mustache v1.1.2
	    GRMustacheTemplateOptionMustacheSpecCompatibility = 0x01,
	};
	
	typedef NSUInteger GRMustacheTemplateOptions;
	
	// Renders the provided templateString.
	+ (NSString *)renderObject:(id)object
	                fromString:(NSString *)templateString
	                   options:(GRMustacheTemplateOptions)options
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a url. (from MacOS 10.6 and iOS 4.0)
	+ (NSString *)renderObject:(id)object
	         fromContentsOfURL:(NSURL *)url
	                   options:(GRMustacheTemplateOptions)options
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a path.
	+ (NSString *)renderObject:(id)object
	        fromContentsOfFile:(NSString *)path
	                   options:(GRMustacheTemplateOptions)options
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a bundle resource of extension "mustache".
	+ (NSString *)renderObject:(id)object
	              fromResource:(NSString *)name
	                    bundle:(NSBundle *)bundle
	                   options:(GRMustacheTemplateOptions)options
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a bundle resource of provided extension.
	+ (NSString *)renderObject:(id)object
	              fromResource:(NSString *)name
	             withExtension:(NSString *)ext
	                    bundle:(NSBundle *)bundle
	                   options:(GRMustacheTemplateOptions)options
	                     error:(NSError **)outError;


### Errors

GRMustache methods may return errors whose domain is GRMustacheErrorDomain.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the GRMustacheErrorCode enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodeTemplateNotFound,
	} GRMustacheErrorCode;

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

All those methods return templates that are compatible with [Handlebars.js](https://github.com/wycats/handlebars.js) and its "extended paths", such as `{{../foo/bar}}` (see below).

In order to process the "dotted names" of [Mustache v1.1.2](https://github.com/mustache/spec), such as `{{foo.bar}}`, you have to ask for it explicitely. See "Rendering methods" above.

Context objects
---------------

You will provide a rendering method with a context object.

Mustache tag names are looked for in the context object, through the standard Key-Value Coding method `valueForKey:`.

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

When a key is missed at the item level, it is looked for in the enclosing context.

#### Lambda sections

Read below "Helpers", which covers in detail how GRMustache allows you to provide custom code for rendering sections.

#### Other sections

Otherwise - if the value is not enumerable, false, or lambda - the content of the section is rendered once.

The value becomes the context while being rendered. This is how you traverse an object hierarchy:

	{{#me}}
	  {{#mother}}
	    {{#father}}
	      My mother's father was named {{name}}.
	    {{/father}}
	  {{/mother}}
	{{/me}}

When a key is missed, it is looked for in the enclosing context. This is the base mechanism for templates like:

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

Depending on the method which has been used to create the original template, partials will be looked for in different places :

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

Implicit iterator, dotted names and extended paths
--------------------------------------------------

### Implicit iterator

The dot "`.`" stands for the current context itself. This "implicit iterator" can be useful when iterating a list of scalar objects. For instance, the following context:

	context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects: @"beer", @"ham", nil]
	                                      forKey:@"item"];

renders:

	<ul><li>beer</li><li>ham</li></ul>

when applied to the template:

	<ul>{{#item}}<li>{{.}}</li>{{/item}}</ul>

### Extended paths

GRMustache supports extended paths introduced by [Handlebars.js](https://github.com/wycats/handlebars.js). Paths are made up of typical expressions and / characters. Expressions allow you to not only display data from the current context, but to display data from contexts that are descendents and ancestors of the current context.

To display data from descendent contexts, use the `/` character. So, for example, if your context were structured like:

	context = [NSDictionary dictionaryWithObjectsAndKeys:
	           [Person personWithName:@"Alan"],   @"person",
	           [Company companyWithName:@"Acme"], @"company",
	           nil];

you could display the person's name from the top-level context with the following expression:

	{{person/name}}

Similarly, if already traversed into the person object you could still display the company's name with an expression like ``{{../company/name}}`, so:

	{{#person}}{{name}} - {{../company/name}}{{/person}}

would render:

	Alan - Acme

### Dotted names

GRMustache supports the dotted names of [Mustache v1.1.2](https://github.com/mustache/spec). Dotted names are made up of typical names and . characters. Expressions allow you to not only display data from the current context, but to display data from contexts that are descendents of the current context.

To display data from descendent contexts, use the `.` character. So, for example, if your context were structured like:

	context = [NSDictionary dictionaryWithObjectsAndKeys:
	           [Person personWithName:@"Alan"], @"person",
	           nil];

you could display the person's name from the top-level context with the following expression:

	{{person.name}}

You have to explicitely ask for the Mustache spec compatibility in order to use dotted names. See "Rendering methods" above.

Helpers
-------

Mustache helpers, also known as lambdas, allow you to execute custom code when rendering a mustache section such as:

	{{#name}}...{{/name}}

For the purpose of demonstration, we'll implement a helper that translates, via `NSLocalizedString`, the content of the section: one will expect `{{#localize}}Delete{{/localize}}` to output `Effacer` when the locale is French.

We'll see three techniques for implementing the behavior.

### Implementing helpers with specific selectors

If the context used for mustache rendering implements the `localizeSection:withContext:` selector (generally, a method whose name is the name of the section, to which you append `Section:withContext:`), then this method will be called when rendering the section.

The choice of the class that should implement this selector is up to you, as long as it can be reached when rendering the template, just as regular values.

For instance, let's focus on the following template snippet:

	{{#cart}}
	  {{#items}}
	    {{quantity}} × {{name}}
	    {{#localize}}Delete{{/localize}}
	  {{/items}}
	{{/cart}}

When the `localize` section is rendered, the context contains an item object, an items collection, a cart object, plus any surrounding objects.

If the item object implements the `localizeSection:withContext:` selector, then its implementation will be called. Otherwise, the selector will be looked up in the items collection. Since this collection is likely an `NSArray` instance, the lookup will continue with the cart and its surrounding context, until some object is found that implements the `localizeSection:withContext:` selector.

In order to have a reusable `localize` helper, we'll isolate it in a specific class, `MustacheHelper`, and make sure this helper is provided to GRMustache when rendering our template.

Let's first declare our helper class:

	@interface MustacheHelper: NSObject

Since our helper doesn't carry any state, let's declare our `localizeSection:withContext:` selector as a class method:

	  + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context;
	@end

#### The literal inner content

Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.

This _section_ object has a `templateString` property, which returns the literal inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

	@implementation MustacheHelper
	+ (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
	{
	  return NSLocalizedString(section.templateString, nil);
	}
	@end

So far, so good, this would work as expected.

#### Rendering the inner content

Yet the application keeps on evolving, and it appears that the item names should also be localized. The template snippet now reads:

	{{#cart}}
	  {{#items}}
	    {{quantity}} × {{#localize}}{{name}}{{/localize}}
	    {{#localize}}Delete{{/localize}}
	  {{/items}}
	{{/cart}}

Now the strings we have to localize may be:

- literal strings from the template: `Delete`
- strings coming from cart items : `{{name}}`

Our first `MustacheHelper` will fail, since it will return `NSLocalizedString(@"{{name}}", nil)` when localizing item names.

Actually we now need to feed `NSLocalizedString` with the _rendering_ of the inner content, not the _literal_ inner content.

Fortunately, we have:

- the `renderObject:` method of `GRMustacheSection`, which renders the content of the receiver with the provided object. 
- the _context_ parameter, which is the current rendering context, containing a cart item, an item collection, a cart, and any surrouding objects.

`[section renderObject:context]` is exactly what we need: the inner content rendered in the current context.

Now we can fix our implementation:

	@implementation MustacheHelper
	+ (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
	{
	  NSString *renderedContent = [section renderObject:context];
	  return NSLocalizedString(renderedContent, nil);
	}
	@end

#### Using the helper object

Now that our helper class is well defined, let's use it.

Assuming:

- `orderConfirmation.mustache` is a mustache template resource,
- `self` has a `cart` property suitable for our template rendering,

Let's first parse the template:

	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:@"orderConfirmation" bundle:nil error:NULL];

Let's now render, with two objects: our `MustacheHelper` class that will provide the `localize` helper, and `self` that will provide the `cart`:

	[template renderObjects:[MustacheHelper class], self, nil];

### Implementing helpers with blocks

Starting MacOS6 and iOS4, blocks are available to the Objective-C language. GRMustache provides a block-based helper API.

This technique does not involve declaring any special selector. But when asked for the `localized` key, your context will return a GRMustacheBlockHelper instance, built in the same fashion as the helper methods seen above:

	id localizeHelper = [GRMustacheBlockHelper helperWithBlock:(^(GRMustacheSection *section, id context) {
	  NSString *renderedContent = [section renderObject:context];
	  return NSLocalizedString(renderedContent, nil);
	}];

See how the block implementation is strictly identical to the helper method discussed above.

Actually, your only concern is to make sure your values and helper code can be reached by GRMustache when rendering your templates. Implementing `localizeSection:withContext` or returning a GRMustacheBlockHelper instance for the `localize` key is strictly equivalent.

However, unlike the selector technique seen above, our code is not yet bound to the section name, `localize`. And actually, we need some container object. Let's go with a dictionary:

	id mustacheHelper = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

And now the rendering is done as usual:

	[template renderObjects:mustacheHelper, self, nil];


### Implementing helpers with classes conforming to the `GRMustacheHelper` protocol

Now that we have a nice working localizing helper, we may well want to reuse it in some other projects. Unfortunately, the two techniques seen above don't help us that much acheiving this goal:

- the selector technique binds the helper code to the section name, thus making impossible to share the helper code between various sections of various templates.
- the block technique provides no way to cleanly encapsulate the helper code.

The `GRMustacheHelper` protocol aims at giving you a way to create classes which encapsulate a helper.

In our case, here would be the implementation of our localizing helper:

	@interface LocalizedStringHelper: NSObject<GRMustacheHelper>
	@end
	
	@implementation LocalizedStringHelper
	// The renderSection:inContext method is required by the GRMustacheHelper protocol
	- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
	{
	  NSString *renderedContent = [section renderObject:context];
	  return NSLocalizedString(renderedContent, nil);
	}
	@end

We, again, need some container object, in order to attach our helper to the `localize` key:

	LocalizedStringHelper *localizeHelper = [[[LocalizedStringHelper alloc] init] autorelease];
	id mustacheHelper = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

And now the rendering is done as usual:

	[template renderObjects:mustacheHelper, self, nil];

Speaking of encapsulation, our `LocalizedStringHelper` can even now support localization tables. This is left as an exercise for the reader :-)

### Usages of helpers

Helpers can be used for whatever you may find relevant.

You may implement caching:

	- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
	  if (self.cache == nil) { self.cache = [section renderObject:context]; }
	  return self.cache;
	};

You may render an extended context:

	- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
	  return [section renderObjects:context, ...];
	});

You may render a totally different context (note that this is the base technique for the GRMustacheNumberFormatterHelper and GRMustacheDateFormatterHelper helpers that ship with GRMustache):

	- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
	  return [section renderObject:...];
	});

You may implement debugging sections:

	- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
	  NSLog(section.templateString);         // log the unrendered section 
	  NSLog([section renderObject:context]); // log the rendered section 
	  return nil;                            // don't render anything
	});


Utils
-----

GRMustache ships with a few helper classes. They do not belong the the core GRMustache code, and as such must be imported separately:

	#import "GRMustacheUtils.h"

### Number formatting with `GRMustacheNumberFormatterHelper`

This helper allows you to format *all* numbers in a section of your template.

For instance, given the following template:

	raw: {{float}}
	
	{{#percent_format}}
	percent: {{float}}
	{{/percent_format}}
	
	{{#decimal_format}}
	decimal: {{float}}
	{{/decimal_format}}

The float value would be displayed as a percentage in the `percent_format` section, and as a decimal in the `decimal_format` section.

We just have to create two `GRMustacheNumberFormatterHelper` objects, provide them with `NSNumberFormatter` instances, and attach them to the section names:

	#import "GRMustacheUtils.h"
	
	// The percent formatter, and helper:
	NSNumberFormatter percentNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
	GRMustacheNumberFormatterHelper *percentHelper = [GRMustacheNumberFormatterHelper helperWithNumberFormatter:percentNumberFormatter];
	
	// The decimal formatter, and helper:
	NSNumberFormatter decimalNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
	GRMustacheNumberFormatterHelper *decimalHelper = [GRMustacheNumberFormatterHelper helperWithNumberFormatter:decimalNumberFormatter];
	
	// The rendered data:
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
	                      percentHelper,                   @"percent_format",
	                      decimalHelper,                   @"decimal_format",
	                      [NSNumber numberWithFloat:0.5f], @"float",
	                      nil];
	
	// The final rendering (on a French system):
	//   raw: 0.5
	//   percent: 50 %
	//   decimal: 0,5
	[template renderObject:data];

It is worth noting that the `GRMustacheNumberFormatterHelper` is implemented on top of public GRMustache APIs. Check the code for inspiration.

### Date formatting with `GRMustacheDateFormatterHelper`

This helper allows you to format *all* dates in a section of your template.

Read the `GRMustacheNumberFormatterHelper` documentation above, because the principles are the same. You'll just provide a `NSDateFormatter` instead of a `NSNumberFormatter`.

Template loaders
----------------

### Fine tuning loading of templates

The GRMustacheTemplateLoader class is able to load templates and their partials from anywhere.

The [Implementing your own template loading strategy](https://github.com/groue/GRMustache/wiki/Implementing-your-own-template-loading-strategy) wiki page will tell you how to subclass GRMustacheTemplateLoader in order to load templates and partials from an NSDictionary.

The GRMustacheTemplateLoader class itself is able to load templates and their partials from anywhere in the file system, and provides more options than the high-level methods already seen.

You may instantiate one with the following GRMustacheTemplateLoader class methods:

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


All those template loaders return templates that are compatible with [Handlebars.js](https://github.com/wycats/handlebars.js) and its "extended paths", such as `{{../foo/bar}}` (see below).

In order to process the "dotted names" of [Mustache v1.1.2](https://github.com/mustache/spec), such as `{{foo.bar}}`, you have to ask for it explicitely. See "Rendering methods" above.


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

