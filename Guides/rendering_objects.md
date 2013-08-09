[up](../../../../GRMustache#documentation), [next](delegate.md)

Rendering Objects
=================

Overview
--------

The [Runtime Guide](runtime.md) describes what happens whenever a tag such as `{{ name }}` or `{{# items }}...{{/ items }}` gets rendered. Strings are HTML-escaped, arrays are iterated, numbers control boolean sections, etc.

But sometimes you need something more dynamic, you need to inject your own code into the template rendering, and extend the language. Orthodox Mustache provides with "lambda sections". [Handlebars.js]((http://handlebarsjs.com), an extended Mustache engine, has introduced "helpers".

Let us introduce GRMustache "rendering objects".

### Examples

Rendering objects are quite versatile. Let's look at a few examples:

    {{# localize }}...{{/ }}

`localize` is part of the [standard library](standard_library.md#localize). It performs a custom rendering by localizing the inner content of the section it renders.

    {{> partial }} vs. {{ template }}

The `{{> partial }}` tag renders a hard-coded template, identified by its name. By providing instead a GRMustacheTemplate object to a tag, which performs its own custom rendering, you can render a "dynamic partial".

    {{# dateFormat }}...{{ birthDate }}...{{ joinDate }}...{{/ }}

[NSDateFormatter](NSFormatter.md) is a rendering object able to format all dates in a section.

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.

`pluralize` is a filter that returns an object able to pluralize the content of the section (see sample code in [issue #50](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912)).

    {{# withPosition(items) }}{{ position }}: {{ name }}{{/ }}

`withPosition` is a filter that returns an object that performs a custom rendering of arrays, by defining the `position` key (see the [Indexes Sample Code](sample_code/indexes.md)).

----

All examples above are built using public GRMustache APIs, even the ones that use built-in objects such as `localize` or the date formatter: your own rendering objects are not artificially limited.

The last two examples involve [filters](filters.md). Filters themselves do not provide custom rendering: they just transform values. However, when they return objects that provide custom rendering, the fun can begin. This two-fold pattern is how GRMustache let you implement [Handlebars-like helpers](http://handlebarsjs.com/block_helpers.html).

Let's begin the detailed tour.


GRMustacheRendering protocol
----------------------------

This protocol declares the method that all rendering objects must implement:

```objc
@protocol GRMustacheRendering <NSObject>

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error;

@end
```

- The _tag_ represents the tag you must render for. It may be a variable tag `{{ name }}`, a section tag `{{# name }}...{{/}}`, etc.

- The _context_ represents the [context stack](runtime.md#the-context-stack), and all information that tags need to render.

- _HTMLSafe_ is a pointer to a BOOL: upon return, it must be set to YES or NO, depending on the safety of the string you render. If you forget to set it, it is of course assumed to be NO. Returning NO would have GRMustache HTML-escape the returned string before inserting it in the final rendering of HTML templates (see the [HTML vs. Text Templates Guide](html_vs_text.md) for more information).

- _error_ is... the eventual error. You can return nil without setting any error: in this case, everything happens as if you returned the empty string.

See the [GRMustacheTag Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html) and [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of GRMustacheTag and GRMustacheContext.

You may declare and implement your own conforming classes. The `+[GRMustache renderingObjectWithBlock:]` method comes in handy for creating a rendering object without declaring any class:

```objc
id renderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    return @"I'm rendered!";
}];
```

The _tag_ and _context_ parameters help you perform your custom rendering. Check their references ([GRMustacheTag](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html), [GRMustacheContext](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html)) for a full documentation of their classes. This guide will illustrate how to use those objects with a few examples.


Trivial Example
---------------

`Document.mustache`:

    {{ name }}
    {{{ name }}}

`Render.m`:

```objc
id nameRenderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    return @"Arthur & Cie";
}];

id data = @{ @"name": nameRenderingObject };

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    Arthur &amp; Cie
    Arthur & Cie

### What did we learn here?

Rendering objects are not difficult to trigger: when you know how to have a tag `{{ name }}` render a regular value, you know how to have it handled by a rendering object.

The HTML escaping is negociated between the tag and the rendering object: `{{ name }}` escapes HTML, when `{{{ name }}}` does not. Since the rendering object does not explicitly set the _HTMLSafe_ parameter to YES, the first tag escapes the result.


Example: Wrapping the content of a section tag
----------------------------------------------

Let's write a rendering object which wraps a section in a `<strong>` HTML tag:

`Document.mustache`:

    {{# strong }}
        {{ name }} is awesome.
    {{/ strong }}

`Render.m`:

```objc
id strong = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // First perform a raw rendering of the tag, using its
    // `renderContentWithContext:HTMLSafe:error` method.
    //
    // We'll get `Arthur is awesome.`
    
    NSString *rawRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];

    // Return the raw rendering, wrapped in a <strong> HTML tag:
    
    return [NSString stringWithFormat:@"<strong>%@</strong>", rawRendering];
}];

id data = @{
    @"name": @"Arthur",
    @"strong": strong,
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    <strong>Arthur is awesome.</strong>

### What did we learn here?

Variable tags such as `{{ name }}` don't have much inner content. But section tags do: `{{# name }} inner content {{/ name }}`.

The `renderContentWithContext:HTMLSafe:error:` method returns the rendering of the inner content, processing all the inner tags with the provided context.

It also sets the `HTMLSafe` boolean for you, so that you do not have to worry about it. GRMustache templates render HTML by default, so `HTMLSafe` will generally be YES. There are also text templates (see the [HTML vs. Text Templates Guide](html_vs_text.md)): in this case, `HTMLSafe` would be NO. Depending on how reusable you want your rendering object to be, you may have to deal with it.

Your rendering objects can thus delegate their rendering to the tag they are given. They can render the tag once or many times:

`Document.mustache`:

    {{# twice }}
        Mustache is awesome!
    {{/ twice }}

`Render.m`:

```objc
id data = @{
    @"twice": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
        NSMutableString *buffer = [NSMutableString string];
        [buffer appendString:[tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error]];
        [buffer appendString:[tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error]];
        return buffer;
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    Mustache is awesome!
    Mustache is awesome!


Example: Have a section render an alternate template string
-----------------------------------------------------------

Let's write a rendering object that wraps a section in a HTML link. The URL of the link will be fetched with the `url` key:

`Document.mustache`:

    {{# link }}{{ firstName }} {{ lastName }}{{/ link }}

`Render.m`:

```objc
id link = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // Build an alternate template string by wrapping the inner content of
    // the section in a `<a>` HTML tag:
    //
    // We'll get `<a href="{{ url }}">{{ firstName }} {{ lastName }}</a>`
    
    NSString *innerTemplateString = tag.innerTemplateString;
    NSString *format = @"<a href=\"{{ url }}\">%@</a>";
    NSString *templateString = [NSString stringWithFormat:format, innerTemplateString];
    
    // Build a new template, and return its rendering:
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    return [template renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}];

id data = @{
    @"firstName": @"Orson",
    @"lastName": @"Welles",
    @"url": @"/people/123",
    @"link": link,
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    <a href="/people/123">Orson Welles</a>

### What did we learn here?

Again, variable tags such as `{{ name }}` don't have much inner content, but section tags do: `{{# name }} inner content {{/ name }}`.

The `innerTemplateString` property returns the raw content of the section, with Mustache tags left untouched.

You can derive new template strings from this raw content, even by appending new tags to it (the `{{ url }}` tag, above).

From those template strings, you create template objects, just as you usually do. Their `renderContentWithContext:HTMLSafe:error:` method render in the given context.

The template also sets the `HTMLSafe` boolean for you, so that you do not have to worry about it. GRMustache templates render HTML by default, so `HTMLSafe` will generally be YES (see the [HTML vs. Text Templates Guide](html_vs_text.md)).

Not all of you load their templates from the main bundle. If you use [template repositories](template_repositories.md), consider replacing the following line:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
```

by this one:

```objc
GRMustacheTemplate *template = [tag.templateRepository templateFromString:templateString error:NULL];
```

This is because the section that should be wrapped in a link may embed a partial tag `{{> partial }}`. Our code will be more robust if we make sure that we use the same template repository as the one that did provide the original template. Check the [GRMustacheTag Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html#//api/name/templateRepository) for more information.


Example: Dynamic partials, take 1
---------------------------------

When a `{{> name }}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

Such partials are *hard-coded*.

You can still choose the rendered partial at runtime, with simple variable tags:

`Document.mustache`:

    {{# items }}
    - {{ link }}
    {{/ items }}

`Movie.mustache`:

    <a href="{{ url }}">{{ title }}</a>

`Person.mustache`:

    <a href="{{ url }}">{{ firstName }} {{ lastName }}</a>

`Render.m`:

```objc
id data = @{
    @"items": @[
        @{
            @"title": @"Citizen Kane",
            @"url":@"/movies/321",
            @"link": [GRMustacheTemplate templateFromResource:@"Movie" bundle:nil error:nil],
        },
        @{
            @"firstName": @"Orson",
            @"lastName": @"Welles",
            @"url":@"/people/123",
            @"link": [GRMustacheTemplate templateFromResource:@"Person" bundle:nil error:nil],
        },
    ],
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    - <a href="/movies/123">Citizen Kane</a>
    - <a href="">Orson Welles</a>

### What did we learn here?

Let's say a handy technique: we haven't use the `GRMustacheRendering` protocol here, because `GRMustacheTemplate` does it for us.


Example: Dynamic partials, take 2: objects that "render themselves"
-------------------------------------------------------------------

Let's implement something similar to Ruby on Rails's `<%= render @movie %>`:

`Document.mustache`:

    {{ movie }}

`Movie.mustache`:

    {{ title }} by {{ director }}
    
`Person.mustache`:

    {{ firstName }} {{ lastName }}

`Render.m`:

```objc
Person *director = [Person personWithFirstName:@"Orson" lastName:@"Welles"];
Movie *movie = [Movie movieWithTitle:@"Citizen Kane" director:director];
id data = @{ @"movie": movie };

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    &lt;Movie: 0x1011052a0&gt;

Oops. GRMustache is written in Objective-C, not Ruby: there is no built-in automagic rendering of an object with a partial, through some conversion from a class name to a partial name.

We have to explicitely have our Movie and Person classes render with their dedicated Movie.mustache and Person.mustache partials:

```objc
// Declare categories on our classes so that they conform to the
// GRMustacheRendering protocol:

@interface Movie(GRMustache)<GRMustacheRendering>
@end

@interface Person(GRMustache)<GRMustacheRendering>
@end


// Now implement the protocol:

@implementation Movie(GRMustache)

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    // Extract the "Movie.mustache" partial from the original templateRepository:
    GRMustacheTemplate *partial = [tag.templateRepository templateNamed:@"Movie" error:NULL];

    // Add self to the top of the context stack, so that the partial
    // can access our keys:
    context = [context contextByAddingObject:self];

    // Return the rendering of the partial
    return [partial renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}

@end

@implementation Person(GRMustache)

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    // Extract the "Person.mustache" partial from the original templateRepository:
    GRMustacheTemplate *partial = [tag.templateRepository templateNamed:@"Person" error:NULL];

    // Add self to the top of the context stack, so that the partial
    // can access our keys:
    context = [context contextByAddingObject:self];

    // Return the rendering of the partial
    return [partial renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}

@end
```

Final rendering:

    Citizen Kane by Orson Welles

### What did we learn here?

Two useful things:

1. *`GRMustacheRendering` is a protocol*.
    
    Surely `+[GRMustache renderingObjectWithBlock:]` is convenient since it lets us create rendering objects from scratch. Yet the GRMustacheRendering protocol is available for you to use on your custom classes.
    
    You can even mix it with the [GRMustacheFilter protocol](filters.md). The conformance to both protocols gives you objects with multiple facets. For example, the [NSFormatter](NSFormatter.md) class takes this opportunity to format values, as in `{{ format(value) }}`, and to format all variable tags in a section, when used as in `{{# format }}...{{ value1 }}...{{ value2 }}...{{/ }}`.

2. *Rendering objects manage the context stack*.
    
    When GRMustache renders `{{ name }}`, it looks for the `name` key in the [context stack](runtime.md#the-context-stack): for the title and names of our movies and people to render, movies and people must enter the context stack. This is the reason for the derivation of new contexts, using the `contextByAddingObject:` method, before partials are rendered.
    
See the [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of the GRMustacheContext class.


Example: Render collections of objects
--------------------------------------

Using the same Movie and Person class introduced above, we can easily render a list of movies, just as Ruby on Rails's `<%= render @movies %>`:


`Document.mustache`:

    {{ movies }}  {{! one movie is not enough }}

`Movie.mustache`:

    {{ title }} by {{ director }}
    
`Person.mustache`:

    {{ firstName }} {{ lastName }}

`Render.m`:

```objc
id data = @{
    @"movies": @[
        [Movie movieWithTitle:@"Citizen Kane"
                     director:[Person personWithFirstName:@"Orson" lastName:@"Welles"]],
        [Movie movieWithTitle:@"Some Like It Hot"
                     director:[Person personWithFirstName:@"Billy" lastName:@"Wilder"]],
    ]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    Citizen Kane by Orson Welles
    Some Like It Hot by Billy Wilder

### What did we learn here?

A new perspective on the fact that arrays render the concatenation of their items.


Example: A Handlebars.js Helper
-------------------------------

From [http://handlebarsjs.com/block_helpers.html](http://handlebarsjs.com/block_helpers.html):

> For instance, let's create an iterator that creates a `<ul>` wrapper, and wraps each resulting element in an `<li>`.
> 
>     {{#list nav}}
>       <a href="{{url}}">{{title}}</a>
>     {{/list}}

Let's build this "helper" with GRMustache:

`Document.mustache`:

    {{# list(nav) }}
      <a href="{{url}}">{{title}}</a>
    {{/ }}

`Render.m`:

```objc
// Load the template

GRMustacheTemplate *template = [GRMustacheTemplate fromResource:@"Document" bundle:nil error:NULL];


// Extend the base context of the template, so that the "list" helper gets
// registered for all renderings.

id customHelperLibrary = @{
    // `list` is a filter that takes an array, and returns a rendering object:
    @"list": [GRMustacheFilter filterWithBlock:^id(NSArray *items) {
        
        return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
            
            NSMutableString *buffer = [NSMutableString string];
            
            // Open the <ul> element.
            [buffer appendString:@"<ul>"];
            
            // Append a <li> element for each item.
            for (id item in items) {
                
                // Have each item enter the context stack on its turn...
                GRMustacheContext *itemContext = [context contextByAddingObject:item];
                
                // ... and render the inner content of the section.
                NSString *itemRendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
                
                // Wrap in a <li> element.
                [buffer appendString:[NSString stringWithFormat:@"<li>%@</li>", itemRendering]];
            }
            
            // Close the <ul> tag, and return.
            [buffer appendString:@"</ul>"];
            return buffer;
        }];
    }]
};
[template extendBaseContextWithObject:customHelperLibrary];


// Set up rendered data, and render

id obj = @{
    @"nav": @[
        @{ @"url": @"http://mustache.github.io", @"title": @"Mustache" },
        @{ @"url": @"http://github.com/groue/GRMustache", @"title": @"GRMustache" },
    ]
};
NSString *rendering = [template renderObject:obj error:NULL];
```

Final rendering:

    <ul>
        <li><a href="http://mustache.github.io">Mustache</a></li>
        <li><a href="http://github.com/groue/GRMustache">GRMustache</a></li>
    </ul>

The implementation of the Handlebars helper is fundamentally identical:

```javascript
Handlebars.registerHelper('list', function(context, options) {
    
    // Open the <ul> element.
    var ret = "<ul>";
    
    // Append a <li> element for each item.
    for(var i=0, j=context.length; i<j; i++) {
        
        // Render item
        var itemRendering = options.fn(context[i]);
        
        // Wrap in a <li> element.
        ret = ret + "<li>" + itemRendering + "</li>";
    }
    
    // Close the <ul> tag, and return.
    return ret + "</ul>";
});
```

### What did we learn here?

A fundamental technique for advanced rendering: [filters](filters.md) that return rendering objects.

You have more sample code in [issue #50](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912), which shows a helper able to pluralize the inner content of its section:

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.


Sample code
-----------

The [Collection Indexes Sample Code](sample_code/indexes.md) uses the `GRMustacheRendering` protocol for rendering indexes of an array items.

The `localize` helper of the [standard library](standard_library.md) uses the protocol to localize full template sections, as in `{{# localize }}Hello {{ name }}{{/ localize }}`.

NSFormatter instances are rendering objets as well, so that `{{# decimal }}{{ x }} + {{ y }} = {{ sum }}{{/ decimal }}` would render nice decimal numbers. Check the [NSFormatter Guide](NSFormatter.md).

[Issue #50](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912) contains sample code for pluralizing the inner content of a section.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concept of "rendering objects".

However, many of the techniques seen above can be compared to "Mustache lambdas".

You *can* write specification-compliant "Mustache lambdas" with rendering objects. However those are more versatile.

**As a consequence, if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use `GRMustacheRendering` with great care.**


[up](../../../../GRMustache#documentation), [next](delegate.md)
