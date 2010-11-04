GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

Its implementation has been highly inspired by the Mustache [go implementation](http://github.com/hoisie/mustache.go/). Its tests are based on the [Ruby](http://github.com/defunkt/mustache) one, that we have considered as a reference.

It supports the following Mustache features:

- comments
- delimiter changes
- variables
- boolean sections
- enumerable sections
- inverted sections
- lambda sections
- partials and recursive partials

It supports some extensions to the regular [Mustache syntax](http://mustache.github.com/mustache.5.html):

- dot variable tag: `{{.}}`

Embedding in your XCode project
-------------------------------

Add to your project all files contained in the `Classes` folder.

Import `GRMustache.h` in order to access all GRMustache features.

Header files whose names contain `private` declare private APIs which are subject to change, without notice, over releases.

All other headers contain public and stable declarations.

Simple example
--------------

	#import "GRMustache.h"
	
	NSDictionary *object = [NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"];
	[GRMustacheTemplate renderObject:object fromString:@"Hi {{name}}!" error:nil];
	// returns @"Hi Mom!"

That's just for a start. We'll cover a more practical example below.

Rendering methods
-----------------

The main rendering methods provided by the GRMustacheTemplate class are:

	// Renders the provided templateString.
	+ (NSString *)renderObject:(id)object
	                fromString:(NSString *)templateString
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a url.
	+ (NSString *)renderObject:(id)object
	         fromContentsOfURL:(NSURL *)url
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
	
	// Loads and parses the template from url.
	+ (id)parseContentsOfURL:(NSURL *)url
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

Key misses are OK:

	// raises @"Hi !"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{blame}}!"
	                           error:nil];

The case of booleans in a KVC context is quite particular. We'll cover it in the "Booleans" section below.

Tag types
---------

We'll now cover all mustache tag types, and how they are rendered.

But let's give some definitions first:

- GRMustache considers *enumerable* all objects conforming to the NSFastEnumeration protocol, but NSDictionary.

- GRMustache considers *false* the following values: `nil`, `[NSNull null]`, the empty string `@""`, and `[GRNo no]` which we'll see below in the "Booleans" section.


### Comments `{{!...}}`

Comments tags are not rendered.

### Variable tags `{{name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is rendered with the empty string.

Otherwise, it is rendered with the regular string description of the value, HTML escaped.

### Unescaped variable tags `{{{name}}}` and `{{&name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is rendered with the empty string.

Otherwise, it is rendered with the regular string description of the value, without HTML escaping.

### Enumerable sections `{{#name}}...{{/name}}`

If the value for key `name` in the context is *enumerable*, the text between the `{{#name}}` and `{{/name}}` tags is rendered once for each item in the enumerable. Each item will extend the context while being rendered. The section is rendered with an empty string if the enumerable is empty.

### Lambda sections `{{#name}}...{{/name}}`

Such a section is rendered with the string returned by a block of code if the value for key `name` in the context is a GRMustacheLambda.

You will build a GRMustacheLambda with the GRMustacheLambdaMake function. This function takes a block which returns the string that should be rendered, as in the example below:

	// A lambda which renders its section without any special effect:
	GRMustacheLambda lambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                 GRMustacheContext *context,
	                                                 NSString *templateString) {
	    return renderer(context);
	});

- `renderer` is a block which renders the inner section with its argument as a context.
- `context` is the current context object.
- `templateString` contains the litteral section block, unrendered : `{{tags}}` will not have been expanded.

You may implement caching:

	__block NSString *cache = nil;
	GRMustacheLambda cacheLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                      GRMustacheContext *context,
	                                                      NSString *templateString) {
	  if (cache == nil) { cache = renderer(context); }
	  return cache;
	});

You may also render a totally different template:

	GRMustacheTemplate *outerspaceTemplate = [GRMustacheTemplate parseString:@"..." error:nil];
	GRMustacheLambda outerspaceLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                           GRMustacheContext *context,
	                                                           NSString *templateString) {
		return [outerspaceTemplate renderObject:context];
	});

Actually, you may use all three arguments for any purpose:

	GRMustacheLambda weirdLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                      GRMustacheContext *context,
	                                                      NSString *templateString) {
	  if ([context valueForKey:@"important"]) {
	    return [renderer(context) uppercase];
	  }
	  return [GRMustacheTemplate renderObject:context
	                             fromString:[templateString stringByAppendingString:@"{{foo}}"]
	                             error:nil];
	});


### Boolean sections `{{#name}}...{{/name}}`

Such a section is rendered according to the value for key `name` in the context.

When *false*, the section is rendered with an empty string.

Otherwise, the section is rendered within a context extended by the value.

### Inverted sections `{{^name}}...{{/name}}`

Such a section is rendered *iff* the `{{#name}}...{{/name}}` would not: if the value for key `name` in the context is *false*, or an empty *enumerable*.

### Partials `{{>name}}`

A `{{>name}}` tag is rendered as a partial loaded from the file system.

The partial must have the same extension as its including template.

Depending on the method which has been used to create the original template, the partial will be looked in different places :

- Methods which will look in the current working directory:
	- `renderObject:fromString:error:`
	- `parseString:error:`
- Methods which will look relatively to the URL of the including template:
	- `renderObject:fromContentsOfURL:error:`
	- `parseContentsOfURL:error:`
- Methods which will look in the bundle:
	- `renderObject:fromResource:bundle:error:`
	- `renderObject:fromResource:withExtension:bundle:error:`
	- `parseResource:bundle:error:`
	- `parseResource:withExtension:bundle:error:`

Recursive partials are possible. Just avoid infinite loops in your context objects.

Booleans
--------

There are a few rules to follow to help GRMustache behave correctly regarding booleans:

- Don't use `[NSNumber numberWithBool:]` for controlling boolean sections.
- Use `[GRNo no]` and `[GRYes yes]` instead.
- Declare your BOOL properties with the `@property` keyword.

We'll explain each rule below.

### When good old NSNumber drops

`[NSNumber numberWithBool:NO]` is identical to `[NSNumber numberWithInteger:0]`. There is no way, provided with a NSNumber, to tell whether its a false boolean, or a zero integer.

In order to be consistent with implementations in other languages, GRMustache treats zero as a number, and not as false.

That is why you should not use `[NSNumber numberWithBool:NO]` for controlling boolean sections: it would be considered as true as the 0 number.

### Introducing GRYes and GRNo

GRMustache provides two singletons for you to use as explicit boolean objects, which you can put directly in your dictionary contexts:

	// [GRYes yes] represents a true value
	// [GRNo no] represents a false value
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
	                         @"Michael Jackson", @"name",
	                         [GRYes yes], @"dead",
	                         nil];

### BOOL properties

BOOL properties which have been declared with the `@property` keyword are handled by GRMustache:

	@interface Person: NSObject
	@property BOOL dead;
	@property NSString *name;
	@end

In the following template, GRMustache would process the `dead` boolean property as expected, and display "RIP" next to dead people only:

	{{#persons}}
	- {{name}} {{#dead}}(RIP){{/dead}}
	{{/persons}}

### In-depth BOOL properties

Undeclared BOOL properties, that is to say: selectors implemented without corresponding `@property` in some `@interface` block, will be considered as numbers (see comments on NSNumber above):

	@interface Person: NSObject
	- (BOOL) dead;	// will be considered as 0 and 1 integers
	@end

All declared properties as `signed char` will be considered as booleans:

	@interface Person: NSObject
	@property char initial;	// will be considered as boolean!
	@end

We thought that, besides BOOL, it would be pretty rare that you would use such a value in a template. However, should this behavior annoy you, we provide a mechanism for having GRMustache behave strictly about boolean properties.

	[GRMustacheContext setStrictBooleanMode:YES];

In strict boolean mode, BOOL properties will be considered as numbers.

There is still a way for using booleans, and it's the unbeloved C99 `bool` type:

	@interface Person: NSObject
	- (bool)dead;   // KVC-compatible boolean, even without @property declaration
	@end


Extensions
----------

The Mustache syntax is described at [http://mustache.github.com/mustache.5.html](http://mustache.github.com/mustache.5.html).

GRMustache adds the following extensions:

### Dot Variable tag `{{.}}`

This extension has been inspired by the dot variable tag introduced in [mustache.js](http://github.com/janl/mustache.js).

This tag renders the regular string description of the current context.

For instance:

	NSString *templateString = @"{{#name}}: <ul>{{#item}}<li>{{.}}</li>{{/item}}</ul>";
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
	                         @"Groue's shopping cart", @"name",
	                         [NSArray arrayWithObjects: @"beer", @"ham", nil], @"item",
	                         nil];
	
	// Returns @"Groue's shopping cart: <ul><li>beer</li><li>ham</li></ul>"
	[GRMustacheTemplate renderObject:context fromString:templateString error:nil];

Errors
------

The GRMustache library may return errors whose domain is GRMustacheErrorDomain.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the GRMustacheErrorCode enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodePartialNotFound,
	} GRMustacheErrorCode;

The `userInfo` dictionary of parse errors contain the GRMustacheErrorURL and GRMustacheErrorLine keys, which provide with the URL of the erroneous template, and the line where the error occurred.

	extern NSString* const GRMustacheErrorURL;
	extern NSString* const GRMustacheErrorLine;


A practical example
-------------------

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

	@interface Person(GRMustacheContext)
	@end

	static NSDateFormatter *dateFormatter = nil;
	@implementation Person(GRMustacheContext)
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

