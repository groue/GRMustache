GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

It's been highly inspired by the Mustache [go implementation](http://github.com/hoisie/mustache.go/). Its tests are based on the [Ruby](http://github.com/defunkt/mustache) one, that we have considered as a reference.

It supports the following Mustache features:

- comments
- delimiter changes
- variables
- boolean sections
- enumerable sections
- inverted sections
- lambda sections
- partials and recursive partials

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

Rendering methods
-----------------

The main rendering methods provided by the `GRMustacheTemplate` class are:

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

If you are planning to render the same template multiple times, it is more efficient to parse it once, with the compiling methods of the `GRMustacheTemplate` class:

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

Those methods return `GRMustacheTemplate` instances, which render objects with the following method:

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

Mustache tag names are looked in the context object, through standard Key-Value Coding.

The most obvious objects which support KVC are dictionaries. You may also provide with any other object, as long as it conforms to the `GRMustacheContext` protocol.

For instance:

	@interface Person: NSObject<GRMustacheContext>
	+ (id)personWithName:(NSString *)name;
	- (NSString *)name;
	@end

	// returns @"Hi Mom!"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{name}}!"
	                           error:nil];

Note that the KVC method `valueForKey:` raises a `NSUndefinedKeyException` exception in case of key miss. Dictionaries never miss, but your `GRMustacheContext` class could.

For instance:

	// raises an exception, because Person has no `blame` accessor
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{blame}}!"
	                           error:nil];


Tag types
---------

We'll now cover all mustache tag types, and how they are rendered.

### Comments `{{!...}}`

Comments tags are not rendered.

### Variable tags `{{name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is `nil` or `[NSNull null]`, the tag is rendered with the empty string.

Otherwise, it is rendered with the `description` of the value, HTML escaped.

### Unescaped variable tags `{{{name}}}` and `{{&name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is `nil` or `[NSNull null]`, the tag is rendered with the empty string.

Otherwise, it is rendered with the `description` of the value, without HTML escaping.

### Enumerable sections `{{#name}}...{{/name}}`

If the value for key `name` in the context is an enumerable, the text between the `{{#name}}` and `{{/name}}` tags is rendered once for each item in the enumerable. Each item will extend the context while being rendered. The section is rendered with an empty string if the enumerable is empty.

GRMustache considers enumerable all objects conforming to the `NSFastEnumeration` protocol, but `NSDictionary` and those conforming to the `GRMustacheContext` protocol.

### Lambda sections `{{#name}}...{{/name}}`

Such a section is rendered with the string returned by a block of code if the value for key `name` in the context is a `GRMustacheLambda`.

You will build a `GRMustacheLambda` with the `GRMustacheLambdaMake` function. This function takes a block which returns the string that should be rendered, as in the example below:

	// A lambda which renders its section without any special effect:
	GRMustacheLambda lambda = GRMustacheLambdaMake(^(GRMustacheContext *context,
	                                                 NSString *templateString,
	                                                 GRMustacheRenderer render) {
	    return render(templateString);
	});

The `context` argument provides the lambda with the rendering context.

The `templateString` argument contains the litteral section block, unrendered : `{{tags}}` will not have been expanded.

The `render` argument is a block which is able to render a string in the current context.

You may inspect the context, and provide any string to the `render` block:

	GRMustacheLambda lambda = GRMustacheLambdaMake(^(GRMustacheContext *context,
	                                                 NSString *templateString,
	                                                 GRMustacheRenderer render) {
	  if ([context valueForKey:@"hidden"]) return @"";
	  return render([templateString uppercaseString]);
	});

Note that passing to the `render` argument a string which is not `templateString` will trigger a template parsing each time the lambda is invoked. This could affect performances.

If you want to render a different template, you should compile it first, and have it render the context. For instance:

	GRMustacheTemplate *overridingTemplate = [GRMustacheTemplate parseString:@"<b>{{name}}</b>" error:nil];
	GRMustacheLambda overridingLambda = GRMustacheLambdaMake(^(GRMustacheContext *context,
	                                                           NSString *templateString,
	                                                           GRMustacheRenderer render) {
		return [overridingTemplate renderObject:context];
	});


### Boolean sections `{{#name}}...{{/name}}`

Such a section is rendered according to the value for key `name` in the context.

When `nil`, `[NSNull null]`, or empty enumerable object, the section is rendered with an empty string.

If the value is a `NSDictionary`, or conforms to the `GRMustacheContext` protocol, the section is rendered within a context extended by the value.

Otherwise, the section is rendered within the same context.

### Inverted sections `{{^name}}...{{/name}}`

Such a section is rendered *iff* the `{{#name}}...{{/name}}` would not: if the value for key `name` in the context is `nil`, `[NSNull null]`, or an empty enumerable.

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

Errors
------

The GRMustache library may return errors whose domain is `GRMustacheErrorDomain`.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the `GRMustacheErrorCode` enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodePartialNotFound,
	} GRMustacheErrorCode;

The `userInfo` dictionary of parse errors contain the `GRMustacheErrorURL` and `GRMustacheErrorLine` keys, which provide with the URL of the erroneous template, and the line where the error occurred.

	extern NSString* const GRMustacheErrorURL;
	extern NSString* const GRMustacheErrorLine;

License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2010 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

