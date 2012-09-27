[up](introduction.md), [next](filters.md)

Variable Tag Helpers
====================

Variable tag helpers allow you to render a Mustache variable tag such as `{{name}}` with you own custom code.


Overview
--------

When GRMustache renders a variable tag `{{name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a *variable tag helper*. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a variable tag helper when it finds an object that conforms to the `GRMustacheVariableTagHelper` protocol.


### GRMustacheVariableTagHelper protocol and class

This protocol is defined as:

```objc
@protocol GRMustacheVariableTagHelper<NSObject>
@required
- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context;
@end
```

This `renderForVariableTagInContext:` method will be called when the helper is asked to render the variable tag is it attached to. Its result will be directly inserted in the final rendering, *without any HTML escaping*, regardless of the number of braces in the template. More on that below.

The protocol comes with a `GRMustacheVariableTagHelper` class, which provides a convenient method for building a helper without implementing a full class that conforms to the protocol:

```objc
@interface GRMustacheVariableTagHelper: NSObject<GRMustacheVariableTagHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariableTagRenderingContext* context))block;
@end
```

Just like the `renderForVariableTagInContext:` protocol method, the block takes a context and returns the rendering. In most cases, this is the easiest way to write a helper.

The `GRMustacheVariableTagRenderingContext` parameter provides the following methods:

```objc
@interface GRMustacheVariableTagRenderingContext : NSObject
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
- (NSString *)renderTemplateNamed:(NSString *)name error:(NSError **)outError;
@end
```
The `renderTemplateString:error:` method returns the *rendering of a template string*. The eventual `{{tags}}` in the template string are interpolated. Should you provide a template string with a syntax error, or that loads a missing template partial, the method would return nil, and sets its error argument.

The `renderTemplateNamed:error:` method is a shortcut that returns the *rendering of a partial template*, given its name.


### Purpose of variable tag helpers

Variable tag helpers are designed to let you send simple variable tags on steroids. Let's see an example, based on the story of a very short template snippet:

    by {{author}}

Let's assume, for the purpose of the demonstration, that this template is shared among several Mustache applications: an iOS app, an Android app, a website: you can *not* change it freely.

The 1st iteration of your application simply renders a person name:

```objc
id data = @{ @"author": person.name };

// by Orson Welles
NSString *rendering = [template render:data];
```

2nd iteration of your application should now render a link to the person instead of its plain name. Remember: the template can not change. How would we do?

Variable tag helpers to the rescue!

```objc
id data = @{
    @"author_url": person.url
    @"author_name": person.name
    @"author": [GRMustacheVariableTagHelper helperWithBlock:^(GRMustacheVariableTagRenderingContext *context) {
        return [context renderTemplateString:@"<a href=\"{{author_url}}\">{{author_name}}</a>" error:NULL];
    }]
};

// by <a href="...">Orson Welles</a>
NSString *rendering = [template render:data];
```

Using this technique, you can still safely HTML-escape your values, while performing a complex rendering out from a simple variable tag.

Now you understand why the output of variable tag helpers is not HTML-escaped: your helpers use rendering APIs that already provide HTML escaping.


#### Dynamic partials

You may not want to embed inline templates in your code, and keep them in partial templates. The example above could be rewritten this way:

```objc
id data = @{
    @"author_url": person.url
    @"author_name": person.name
    // author.mustache contains `<a href="{{author_url}}">{{author_name}}</a>`
    @"author": [GRMustacheVariableTagHelper helperWithBlock:^(GRMustacheVariableTagRenderingContext *context) {
        return [context renderTemplateNamed:@"author" error:NULL];
    }]
};

// by <a href="...">Orson Welles</a>
NSString *rendering = [template render:data];
```

Since some of you may fall in love with dynamic partials, the library ships with the `GRMustacheDynamicPartial` class, which is less verbose:

```objc
id data = @{
    @"author_url": person.url
    @"author_name": person.name
    @"author": [GRMustacheDynamicPartial dynamicPartialWithName:@"author"]
};

// by <a href="...">Orson Welles</a>
NSString *rendering = [template render:data];
```

However, keep in mind the longer version that uses `renderTemplateNamed:error:`, that we'll find again in the final example.

Examples
--------

### Have a variable tag expand into a template string

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
        @"link": [GRMustacheVariableTagHelper helperWithBlock:^(GRMustacheVariableTagRenderingContext *context) {
            return [context renderTemplateString:movieLinkTemplateString error:NULL];
        }],
        @"director": @{
            @"url": @"/people/321",
            @"firstName": @"Orson",
            @"lastName": @"Welles",
            @"link": [GRMustacheVariableTagHelper helperWithBlock:^(GRMustacheVariableTagRenderingContext *context) {
                return [context renderTemplateString:directorLinkTemplateString error:NULL];
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


### Have a variable tag expand into a partial template

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
        @{    // movie
            @"url": @"/movies/123",
            @"title": @"Citizen Kane",
            @"link": [GRMustacheDynamicPartial dynamicPartialWithName:@"movie_link"],
        },
        @{    // director
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


### Have objects able to "render themselves"

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

How can this work? Let's assume the core interface of our Movie and Person classes is already defined, and let's have them render themselves with a partial:

```objc

// Declare categories on our classes so that they conform to the
// GRMustacheVariableTagHelper protocol.

@interface Movie(GRMustache)<GRMustacheVariableTagHelper>
@end

@interface Person(GRMustache)<GRMustacheVariableTagHelper>
@end

// And now implement the protocol:

@implementation Movie(GRMustache)

- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
{
    // Render the "movie.mustache" partial
    return [context renderTemplateNamed:@"movie" error:NULL];
}

@end

@implementation Person(GRMustache)

- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
{
    // Render the "person.mustache" partial
    return [context renderTemplateNamed:@"person" error:NULL];
}

@end
```


Compatibility with other Mustache implementations
-------------------------------------------------

There are many [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations). They all basically enter one of these two sets:

- Implementations that do support "Mustache lambdas" as specified by the [specification](https://github.com/mustache/spec).
- Implementations that do not support "Mustache lambdas" at all, or support a form of "Mustache lambdas" that does not comply with the [specification](https://github.com/mustache/spec).

GRMustache itself belongs to the first set, since you *can* write specification-compliant "mustache lambdas" with variable tag helpers. However variable tag helpers are more versatile than plain Mustache lambdas:

In order to be compatible with all specification-compliant implementations, your variable tag helper MUST return the result of the `renderTemplateString:error:` or `renderTemplateNamed:error:` methods of its _context_ parameter, and it MUST be embedded with triple braces in your templates: `{{{helper}}}`.

For compatibility with other Mustache implementations, check their documentation.


[up](introduction.md), [next](filters.md)
