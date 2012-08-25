[up](introduction.md), [next](filters.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say sections such as `{{#name}}...{{/name}}` that render in your own fashion.


Overview
--------

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a helper. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a helper when it finds an object that conforms to the `GRMustacheHelper` protocol.


### GRMustacheHelper protocol

This protocol is defined as:

```objc
@protocol GRMustacheHelper <NSObject>
@required
- (NSString *)renderSection:(GRMustacheSection *)section;
@end
```

This `renderSection:` method will be called when the helper is asked to render the section is it attached to.

The protocol comes with a `GRMustacheHelper` class, which provides a convenient method for building a helper without implementing a full class that conforms to the protocol:

```objc
@interface GRMustacheHelper: NSObject<GRMustacheHelper>
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

The `render` method returns the *rendering of the inner content* of the section, just as if the helper was not here. `{{tags}}` are, this time, interpolated. This allows helper to perform "double-pass" rendering, by performing a first "classical" Mustache rendering followed by some post-processing.

The `renderTemplateString:error:` returns the *rendering of an alternate content* for the section. The eventual `{{tags}}` in the alternate content are, again, interpolated. Should you provide a template string with a syntax error, the method would return nil, and sets its error argument.

Let's see some examples.


Wrapping a section's content
----------------------------

Let's write a helper which wraps its section:

Template:

    {{#wrapped}}
      {{name}} is awesome.
    {{/wrapped}}

Data:

```objc
id data = @{
    @"name": @"Arthur",
    @"wrapped": [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
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


Rendering an alternate template string
--------------------------------------

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
        @title: @"Citizen Kane",
        @director: @{
            @"url": @"/people/321",
            @"firstName": @"Orson",
            @"lastName": @"Welles",
        }
    },
    @"link": [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
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


Providing helpers aside
-----------------------

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
id helpers = @{ @"link": [GRMustacheHelper ...] };
NSString *rendering = [template renderObjectsInArray:@[helpers, movie]];
```


GRMustache helpers vs. Mustache lambdas
---------------------------------------

**Warning: If your goal is to design GRMustache helpers that remain compatible with Mustache lambdas of [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), read the following with great care.**

The strings returned by GRMustache helpers are directly inserted in the final rendering, without any further processing.

However, the specification [states](https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml#L90) that "Lambdas used for sections should have their results parsed" (read, processed as a Mustache template, and rendered in the current context).

In order to comply with the genuine Mustache behavior, a helper must return the result of the `renderTemplateString:` method of the section, as the linking helper seen above.


Sample code
-----------

The [localization.md](sample_code/localization.md) sample code uses helpers for localizing portions of template.


[up](introduction.md), [next](filters.md)
