[up](../../../../GRMustache#documentation), [next](variable_tag_helpers.md)

Section Tag Helpers
===================


Overview
--------

Section tag helpers allow you to render a Mustache section such as `{{#name}}...{{/name}}` with you own custom code.

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a *section tag helper*. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a section tag helper when it finds an object that conforms to the `GRMustacheSectionTagHelper` protocol.


GRMustacheSectionTagHelper protocol and class
---------------------------------------------

This protocol is defined as:

```objc
@protocol GRMustacheSectionTagHelper <NSObject>
@required
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context;
@end
```

This `renderForSectionTagInContext:` method will be called when the helper is asked to render the section is it attached to. Its result will be directly inserted in the final rendering.

The protocol comes with a `GRMustacheSectionTagHelper` class, which provides a convenient method for building a helper without implementing a full class that conforms to the protocol:

```objc
@interface GRMustacheSectionTagHelper: NSObject<GRMustacheSectionTagHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSectionTagRenderingContext* context))block;
@end
```

Just like the `renderForSectionTagInContext:` protocol method, the block takes a context and returns the rendering. In most cases, this is the easiest way to write a helper.

The `GRMustacheSectionTagRenderingContext` parameter provides the following methods:

```objc
@interface GRMustacheSectionTagRenderingContext: NSObject
@property (nonatomic, readonly) NSString *innerTemplateString;
- (NSString *)render;
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
@end
```

The `innerTemplateString` property contains the *raw template string* inside the section, the `...` in `{{#lambda}}...{{/lambda}}`. In the inner template string, `{{tags}}` will not have been interpolated: you'll get the raw template string.

The `render` method returns the *rendering of the inner content* of the section, just as if the helper was not here. `{{tags}}` are, this time, interpolated in the current context. This allows helper to perform "double-pass" rendering, by performing a first "classical" Mustache rendering followed by some post-processing.

The `renderTemplateString:error:` returns the *rendering of an alternate content*. The eventual `{{tags}}` in the alternate content are, again, interpolated. Should you provide a template string with a syntax error, or that loads a missing template partial, the method would return nil, and sets its error argument.

Let's see a few examples.


Examples
--------

### Wrapping a section's content

Let's write a helper which wraps its section:

Template:

    {{#wrapped}}
      {{name}} is awesome.
    {{/wrapped}}

Data:

```objc
id data = @{
    @"name": @"Arthur",
    @"wrapped": [GRMustacheSectionTagHelper helperWithBlock:^(GRMustacheSectionTagRenderingContext *context) {
                    NSString *rawRendering = [context render];
                    return [NSString stringWithFormat:@"<b>%@</b>", rawRendering];
                }]};
```

Render:

    <b>Arthur is awesome.</b>

```objc
NSString *rendering = [template renderObject:data];
```

This wrapper helper performs a *double-pass rendering*: The `[context render]` would return the rendering of the inner content, that is to say, `Arthur is awesome.`.

The helper then returns this raw rendering wrapped inside a HTML `<b>` tag, which enters the final rendering.


### Have a section render an alternate template string

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
    @"link": [GRMustacheSectionTagHelper helperWithBlock:^(GRMustacheSectionTagRenderingContext *context) {
        NSString *format = @"<a href=\"{{url}}\">%@</a>";
        NSString *templateString = [NSString stringWithFormat:format, context.innerTemplateString];
        return [context renderTemplateString:templateString error:NULL];
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


Providing section tag helpers aside
-----------------------------------

All the examples above use an ad-hoc NSDictionary for filling the template. This dictionary contains both values and helpers.

However, generally, your data will not come from dictionaries, but from your *model objects*. And you don't want to pollute them with Mustache helpers:

```objc
Movie *movie = ...;

// How to provide the `link` helper?
NSString *rendering = [template renderObject:movie];
```

The solution is the `renderObjectsFromArray:` method of GRMustacheTemplate. Simply provide an array filled with you helper, and your model object:

```objc
Movie *movie = ...;
id helpers = @{ @"link": [GRMustacheSectionTagHelper ...] };
NSString *rendering = [template renderObjectsFromArray:@[helpers, movie]];
```


Compatibility with other Mustache implementations
-------------------------------------------------

There are many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations). They all basically enter one of these two sets:

- Implementations that do support "Mustache lambdas" as specified by the [specification](https://github.com/mustache/spec).
- Implementations that do not support "Mustache lambdas" at all, or support a form of "Mustache lambdas" that does not comply with the [specification](https://github.com/mustache/spec).

GRMustache itself belongs to the first set, since you *can* write specification-compliant "mustache lambdas" with section tag helpers. However section tag helpers are more versatile than plain Mustache lambdas:

In order to be compatible with all specification-compliant implementations, your section tag helper MUST return the result of the `renderTemplateString:error:` method of its _context_ parameter, as the `link` helper seen above.

For compatibility with other Mustache implementations, check their documentation.


Sample code
-----------

The [localization.md](sample_code/localization.md) sample code uses section tag helpers for localizing portions of template.

The [indexes.md](sample_code/indexes.md) sample code uses section tag helpers for rendering indexes of an array items.


[up](../../../../GRMustache#documentation), [next](variable_tag_helpers.md)
