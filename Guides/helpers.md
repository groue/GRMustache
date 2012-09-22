[up](introduction.md), [next](filters.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say sections and variable tags that render in your own fashion.


Overview
--------

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a *section helper*. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

The same pattern applies to variable tags `{{name}}`, whenever the value attached to the `name` key is a *variable helper*.

GRMustache recognizes a section helper when it finds an object that conforms to the `GRMustacheSectionHelper` protocol, and a variable helper when it finds an object that conforms to the `GRMustacheVariableHelper` protocol.


### GRMustacheSectionHelper protocol and class

This protocol is defined as:

```objc
@protocol GRMustacheSectionHelper <NSObject>
@required
- (NSString *)renderSection:(GRMustacheSection *)section;
@end
```

This `renderSection:` method will be called when the helper is asked to render the section is it attached to. Its result will be directly inserted in the final rendering.

The protocol comes with a `GRMustacheSectionHelper` class, which provides a convenient method for building a helper without implementing a full class that conforms to the protocol:

```objc
@interface GRMustacheSectionHelper: NSObject<GRMustacheSectionHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block;
@end
```

Just like the `renderSection:` protocol method, the block takes a section and returns the rendering. In most cases, this is the easiest way to write a helper.

The `GRMustacheSection` parameter represents the section attached to a helper. It provides the following methods:

```objc
@interface GRMustacheSection: NSObject
@property (nonatomic, readonly) NSString *innerTemplateString;
- (NSString *)render;
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
@end
```

The `innerTemplateString` property contains the *raw template string* inside the section, the `...` in `{{#lambda}}...{{/lambda}}`. In the inner template string, `{{tags}}` will not have been interpolated: you'll get the raw template string.

The `render` method returns the *rendering of the inner content* of the section, just as if the helper was not here. `{{tags}}` are, this time, interpolated in the current context. This allows helper to perform "double-pass" rendering, by performing a first "classical" Mustache rendering followed by some post-processing.

The `renderTemplateString:error:` returns the *rendering of an alternate content* for the section. The eventual `{{tags}}` in the alternate content are, again, interpolated. Should you provide a template string with a syntax error, or that loads a missing template partial, the method would return nil, and sets its error argument.

We'll see a few examples below.


### GRMustacheVariableHelper protocol and class, GRMustacheDynamicPartial

This protocol is defined as:

```objc
@protocol GRMustacheVariableHelper<NSObject>
@required
- (NSString *)renderVariable:(GRMustacheVariable *)variable;
@end
```

This `renderVariable:` method will be called when the helper is asked to render the variable tag is it attached to. Its result will be directly inserted in the final rendering.

The protocol comes with a `GRMustacheVariableHelper` class, which provides a convenient method for building a helper without implementing a full class that conforms to the protocol:

```objc
@interface GRMustacheVariableHelper: NSObject<GRMustacheVariableHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block;
@end
```

Just like the `renderVariable:` protocol method, the block takes a variable and returns the rendering. In most cases, this is the easiest way to write a helper.

The `GRMustacheVariable` parameter represents the variable attached to a helper. It provides the following methods:

```objc
@interface GRMustacheVariable : NSObject
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
- (NSString *)renderTemplateNamed:(NSString *)name error:(NSError **)outError;
@end
```
The `renderTemplateString:error:` returns the *rendering of a template string*. The eventual `{{tags}}` in the template string are interpolated in the current context. Should you provide a template string with a syntax error, or that loads a missing template partial, the method would return nil, and sets its error argument.

The `GRMustacheDynamicPartial` class let you define helpers that render partials whose name in only known at runtime:

```objc
@interface GRMustacheDynamicPartial: NSObject<GRMustacheVariableHelper>
+ (id)dynamicPartialWithName:(NSString *)name;
@end
```

We'll give illustrating examples below.


Section helper example: wrapping a section's content
----------------------------------------------------

Let's write a helper which wraps its section:

Template:

    {{#wrapped}}
      {{name}} is awesome.
    {{/wrapped}}

Data:

```objc
id data = @{
    @"name": @"Arthur",
    @"wrapped": [GRMustacheSectionHelper helperWithBlock:^(GRMustacheSection *section) {
                    NSString *rawRendering = [section render];
                    return [NSString stringWithFormat:@"<b>%@</b>", rawRendering];
                }]};
```

Render:

    <b>Arthur is awesome.</b>

```objc
NSString *rendering = [template renderObject:data];
```

This wrapper helper performs a *double-pass rendering*: The `[section render]` would return the rendering of the inner content, that is to say, `Arthur is awesome.`.

The helper then returns this raw rendering wrapped inside a HTML `<b>` tag, which enters the final rendering.


Section helper example: Have a section render an alternate template string
--------------------------------------------------------------------------

For the purpose of demonstration, we'll implement a helper that turns a portion of a template into a HTML link.

Template:
    
    {{#movie}}
      {{#link}}{{title}}{{/link}}
      {{#director}}
          by {{#link}}{{firstName}} {{lastName}}{{/link}}
      {{/director}}
    {{/movie}}

Data:

```objc
id data = @{
    @"movie": @{
        @"url": @"/movies/123",
        @"title": @"Citizen Kane",
        @"director": @{
            @"url": @"/people/321",
            @"firstName": @"Orson",
            @"lastName": @"Welles",
        }
    },
    @"link": [GRMustacheSectionHelper helperWithBlock:^(GRMustacheSection *section) {
        NSString *format = @"<a href=\"{{url}}\">%@</a>";
        NSString *templateString = [NSString stringWithFormat:format, section.innerTemplateString];
        return [section renderTemplateString:templateString error:NULL];
    }]
}
```

Render:

    <a href="/movies/123">Citizen Kane</a>
    by <a href="/people/321">Orson Welles</a>

```objc
NSString *rendering = [template renderObject:data];
```

This helper again performs a *double-pass rendering*:

It first wraps the inner template string (`{{title}}`, or `{{firstName}} {{lastName}}`) inside a HTML link, whose url is *also expressed* as a Mustache tag. This gives the two alternate template strings: `<a href="{{url}}">{{title}}</a>` and `<a href="{{url}}">{{firstName}} {{lastName}}</a>`.

Since both movie and director data objects contain values for the `url` key, the renderings of those alternate template string embed the URL of Citizen Kane and of its director.


Providing section helpers aside
-------------------------------

All the examples above use an ad-hoc NSDictionary for filling the template. This dictionary contains both values and helpers.

However, generally, your data will not come from dictionaries, but from your *model objects*. And you don't want to pollute them with Mustache helpers:

```objc
Movie *movie = ...;

// How to provide the `link` helper?
NSString *rendering = [template renderObject:movie];
```

The solution is the `renderObjectsInArray:` method of GRMustacheTemplate. Simply provide an array filled with you helper, and your model object:

```objc
Movie *movie = ...;
id helpers = @{ @"link": [GRMustacheSectionHelper ...] };
NSString *rendering = [template renderObjectsInArray:@[helpers, movie]];
```

Variable helper example: have a variable expand into a template string
----------------------------------------------------------------------

Template:

    {{#movie}}
      {{link}}
      {{#director}}
          by {{link}}
      {{/director}}
    {{/movie}}

Data:

```objc
NSString *movieLinkTemplateString = @"<a href=\"{{url}}\">{{title}}</a>";
NSString *directorLinkTemplateString = @"<a href=\"{{url}}\">{{firstName}} {{lastName}}</a>";
id data = @{
    @"movie": @{
        @"url": @"/movies/123",
        @"title": @"Citizen Kane",
		@"link": [GRMustacheVariableHelper helperWithBlock:^(GRMustacheVariable *variable) {
			return [variable renderTemplateString:movieLinkTemplateString error:NULL];
		}],
        @"director": @{
            @"url": @"/people/321",
            @"firstName": @"Orson",
            @"lastName": @"Welles",
			@"link": [GRMustacheVariableHelper helperWithBlock:^(GRMustacheVariable *variable) {
				return [variable renderTemplateString:directorLinkTemplateString error:NULL];
			}],
        }
    }
}
```

Render:

    <a href="/movies/123">Citizen Kane</a>
    by <a href="/people/321">Orson Welles</a>

```objc
NSString *rendering = [template renderObject:data];
```


Variable helper example: have a variable expand into a partial template
-----------------------------------------------------------------------

Templates:

	base.mustache
    {{#items}}
		- {{link}}
	{{/items}}

	movie_link.mustache
	<a href="{{url}}">{{title}}</a>
	
	director_link.mustache
	<a href="{{url}}">{{firstName}} {{lastName}}</a>

Data:

```objc
id data = @{
	@"items": @[
		@{	// movie
	        @"url": @"/movies/123",
	        @"title": @"Citizen Kane",
			@"link": [GRMustacheDynamicPartial dynamicPartialWithName:@"movie_link"],
		},
		@{	// director
            @"url": @"/people/321",
            @"firstName": @"Orson",
            @"lastName": @"Welles",
			@"link": [GRMustacheDynamicPartial dynamicPartialWithName:@"director_link"],
		}
	]
};
```

Render:

    - <a href="/movies/123">Citizen Kane</a>
	- <a href="/people/321">Orson Welles</a>

```objc
NSString *rendering = [template renderObject:data];
```


Variable helper example: have objects able to "render themselves"
-----------------------------------------------------------------

Templates:

	base.mustache
    {{movie}}

	movie.mustache
	{{title}} by {{director}}
	
	person.mustache
	{{firstName}} {{lastName}}

Data:

```objc
Person *orson = [Person personWithFirstName:@"Orson" lastName:@"Welles"];
Movie *movie = [Movie movieWithTitle:@"Citizen Kane" director:orson];
id data = @{ @"movie": movie };
```

Render:

    Citizen Kane by Orson Welles

```objc
NSString *rendering = [template renderObject:data];
```

This works because Movie and Person classes conform to the GRMustacheVariableHelper protocol. Let's assume their core interface is already defined, and let's focus on their rendering:

```objc
@implementation Movie
// A movie renders itself with the movie.mustache partial template.
- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
	return [variable renderTemplateNamed:@"movie" error:NULL];
}
@end

@implementation Person
// A person renders itself with the person.mustache partial template.
- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
	return [variable renderTemplateNamed:@"person" error:NULL];
}
@end


GRMustache helpers vs. Mustache lambdas
---------------------------------------

**Warning: If your goal is to design GRMustache helpers that remain compatible with Mustache lambdas of [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), read the following with great care.**

The strings returned by GRMustache section helpers are directly inserted in the final rendering, without any further processing.

However, the specification [states](https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml#L90) that "Lambdas used for sections should have their results parsed" (read, processed as a Mustache template, and rendered in the current context).

In order to comply with the genuine Mustache behavior, a helper must return the result of the `renderTemplateString:` method of the section, as the linking helper seen above.


Sample code
-----------

The [localization.md](sample_code/localization.md) sample code uses section helpers for localizing portions of template.


[up](introduction.md), [next](filters.md)
