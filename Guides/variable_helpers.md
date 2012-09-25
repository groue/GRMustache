[up](introduction.md), [next](filters.md)

Variable Helpers
================

GRMustache helpers allow you to implement "Mustache lambda variables", that is to say variable tags that render in your own fashion.


Overview
--------

When GRMustache renders a variable tag `{{name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a *variable helper*. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a variable helper when it finds an object that conforms to the `GRMustacheVariableHelper` protocol.


### GRMustacheVariableHelper protocol and class

This protocol is defined as:

```objc
@protocol GRMustacheVariableHelper<NSObject>
@required
- (NSString *)renderVariable:(GRMustacheVariable *)variable;
@end
```

This `renderVariable:` method will be called when the helper is asked to render the variable tag is it attached to. Its result will be directly inserted in the final rendering, *without any HTML escaping*, regardless of the number of braces in the template. More on that below.

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
The `renderTemplateString:error:` method returns the *rendering of a template string*. The eventual `{{tags}}` in the template string are interpolated in the current context. Should you provide a template string with a syntax error, or that loads a missing template partial, the method would return nil, and sets its error argument.

The `renderTemplateNamed:error:` method is a shortcut that returns the *rendering of a partial template*, given its name.


### Purpose of variable helpers

Variable helpers are designed to let you send simple variable tags on steroids. Let's see an example, based on the story of a very short template snippet:

    by {{author}}

Let's assume, for the purpose of the demonstration, that this template is shared among several Mustache applications: an iOS app, an Android app, a website: you can *not* change it freely.

The 1st iteration of your application simply renders a person name:

```objc
id data = @{ @"author": person.name };

// by Orson Welles
NSString *rendering = [template render:data];
```

2nd iteration of your application should now render a link to the person instead of its plain name. Remember: the template can not change. How would we do?

Variable lambdas to the rescue!

```objc
id data = @{
    @"author_url": person.url
    @"author_name": person.name
    @"author": [GRMustacheVariableHelper helperWithBlock:^(GRMustacheVariable *variable) {
        return [variable renderTemplateString:@"<a href=\"{{author_url}}\">{{author_name}}</a>" error:NULL];
    }]
};

// by <a href="...">Orson Welles</a>
NSString *rendering = [template render:data];
```

Using this technique, you can still safely HTML-escape your values, while performing a complex rendering out from a simple variable tag.

Now you understand why the output of variable lambdas is not HTML-escaped: your lambdas use rendering APIs that already provide HTML escaping.


#### Dynamic partials

You may not want to embed inline templates in your code, and keep them in partial templates. The example above could be rewritten this way:

```objc
id data = @{
    @"author_url": person.url
    @"author_name": person.name
    // author.mustache contains `<a href="{{author_url}}">{{author_name}}</a>`
    @"author": [GRMustacheVariableHelper helperWithBlock:^(GRMustacheVariable *variable) {
        return [variable renderTemplateNamed:@"author" error:NULL];
    }]
};

// by <a href="...">Orson Welles</a>
NSString *rendering = [template render:data];
```

Since this pattern should be common, the library ships with the `GRMustacheDynamicPartial` class, which is less verbose:

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

### Variable helper example: have a variable expand into a template string

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


### Variable helper example: have a variable expand into a partial template

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


### Variable helper example: have objects able to "render themselves"

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
```


[up](introduction.md), [next](filters.md)
