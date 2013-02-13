[up](../../../../GRMustache#documentation), [next](protected_contexts.md)

Rendering Objects
=================

Overview
--------

Let's first confess a lie: here and there in this documentation, you have been reading that Mustache tags renders objects in a way or another: variable tags output values HTML-escaped, sections tags loop over arrays, etc.

This is an illusion. Data objects actually have full control on their rendering:

`NSArray` *does* render the `{{# items }}...{{/}}` tag for each of its items.

`NSNumber` *does* render as a string for `{{ number }}`, and decides if `{{# condition }}...{{/}}` should render or not.

etc.

Your objects that conform to the GRMustacheRendering protocol also take full control of their rendering.


GRMustacheRendering protocol
----------------------------

This protocol declares the method that all rendering objects must implement. NSArray does implement it, so does NSNumber, and NSString. Your objects can, as well:

```objc
@protocol GRMustacheRendering <NSObject>

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error;

@end
```

- The _tag_ represents the tag you must render for. It may be a variable tag `{{ name }}`, a section tag `{{# name }}...{{/}}`, etc.

- The _context_ represents the [context stack](runtime.md), and all information that tags need to render.

- _HTMLSafe_ is a pointer to a BOOL: upon return, it must be set to YES or NO, depending on the safety of the string you render. If you forget to set it, it is of course assumed to be NO. Returning NO would have GRMustache HTML-escape the returned string before inserting it in the final rendering of HTML templates (see the [HTML vs. Text Templates Guide](html_vs_text.md) for more information).

- _error_ is... the eventual error. You can return nil without setting any error: in this case, everything happens as if you returned the empty string.

You may declare and implement your own conforming classes. The `+[GRMustache renderingObjectWithBlock:]` method comes in handy for creating a rendering object without declaring any class:

```objc
id renderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    return @"I'm rendered!";
}];
```

Example: Wrapping the content of a section tag
----------------------------------------------

Let's write a rendering object which wraps a section in a `<strong>` HTML tag:

`Document.mustache`:

    {{#strong}}
        {{name}} is awesome.
    {{/strong}}

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

    {{#twice}}
        Mustache is awesome!
    {{/twice}}

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

    {{#link}}{{firstName}} {{lastName}}{{/link}}

`Render.m`:

```objc
id link = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // Build an alternate template string by wrapping the inner content of
    // the section in a `<a>` HTML tag:
    //
    // We'll get `<a href="{{url}}">{{firstName}} {{lastName}}</a>`
    
    NSString *innerTemplateString = tag.innerTemplateString;
    NSString *format = @"<a href=\"{{url}}\">%@</a>";
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

You can derive new template strings from this raw content, even by appending new tags to it (the `{{url}}` tag, above).

From those template strings, you create template objects, just as you usually do. Their `renderContentWithContext:HTMLSafe:error:` method render in the given context.

It also sets the `HTMLSafe` boolean for you, so that you do not have to worry about it. GRMustache templates render HTML by default, so `HTMLSafe` will generally be YES. There are also text templates (see the [HTML vs. Text Templates Guide](html_vs_text.md)): in this case, `HTMLSafe` would be NO. Depending on how reusable you want your rendering object to be, you may have to deal with it.


Example: Dynamic partials, take 1
---------------------------------

When a `{{> name }}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

Such partials are *hard-coded*.

You can still choose the rendered partial at runtime, with simple variable tags:

`Document.mustache`:

    {{#items}}
    - {{link}}
    {{/items}}

`Movie.mustache`:

    <a href="{{url}}">{{title}}</a>

`Person.mustache`:

    <a href="{{url}}">{{firstName}} {{lastName}}</a>

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


Example: Dynamic partials, take 2
---------------------------------

`Document.mustache`:

    {{# items }}
    - {{ render(partial) }}
    {{/ items }}

`Movie.mustache`:

    <a href="{{url}}">{{title}}</a>

`Person.mustache`:

    <a href="{{url}}">{{firstName}} {{lastName}}</a>

`Render.m`:

```objc
id data = @{
    @"items": @[
        @{
            @"title": @"Citizen Kane",
            @"url":@"/movies/321",
            @"partial": @"Movie",
        },
        @{
            @"firstName": @"Orson",
            @"lastName": @"Welles",
            @"url":@"/people/123",
            @"partial": @"Person",
        },
    ],
    @"render": [GRMustacheFilter filterWithBlock:^id(id value) {
        return [GRMustacheTemplate templateFromResource:value bundle:nil error:NULL];
    }],
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

Well, filters that return rendering objects are awesome.

The above example is somewhat contrived, but you'll see a much more useful example in the [Indexes Sample Code](sample_code/indexes.md).


Example: Dynamic partials, take 3: objects that "render themselves"
-------------------------------------------------------------------

Let's implement something similar to Ruby on Rails's `<%= render @movie %>`:

`Document.mustache`:

    {{movie}}

`Movie.mustache`:

    {{title}} by {{director}}
    
`Person.mustache`:

    {{firstName}} {{lastName}}

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

Many useful things.

1. *`GRMustacheRendering` is a protocol*.
    
    Surely `+[GRMustache renderingObjectWithBlock:]` is convenient since it lets us create rendering objects from scratch. Yet the protocol is available for you to use on your custom classes.

2. *The tag provides a template repository*.
    
    This object lets you load partials from the same set of templates as the "main" rendering template, the one that did provide the rendered tag (check the [Template Repositories Guide](template_repositories.md) if you haven't yet).

    This does not make much difference when all templates are loaded from your main bundle. But some of you manage their sets of templates differently.
    
    Caveat: Make sure you own (retain) template repositories. Don't use templates returned by methods like `[GRMustacheTemplate templateFrom...]`: they return autoreleased templates with an implicit autoreleased repository that will eventually be deallocated when your rendering object tries to access it.

3. *Rendering objects manage the context stack*.
    
    When GRMustache renders `{{ name }}`, it looks for the `name` key in the [context stack](runtime.md): for the title and names of our movies and people to render, movies and people must enter the context stack. This is the reason for the derivation of new contexts, using the `contextByAddingObject:` method, before partials are rendered.
    
    There is also a `contextByAddingTagDelegate:` method, that is illustrated in the [Delegates Guide](delegate.md).


Example: Render collections of objects
--------------------------------------

Using the same Movie and Person class introduced above, we can easily render a list of movies, just as Ruby on Rails's <%= render @movies %>:


`Document.mustache`:

    {{movies}}  {{! one movie is not enough }}

`Movie.mustache`:

    {{title}} by {{director}}
    
`Person.mustache`:

    {{firstName}} {{lastName}}

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


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concept of "rendering objects".

However, many of the techniques seen above can be compared to "Mustache lambdas".

You *can* write specification-compliant "Mustache lambdas" with rendering objects. However those are more versatile.

**As a consequence, if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use `GRMustacheRendering` with great care.**


Sample code
-----------

The [Collection Indexes Sample Code](sample_code/indexes.md) uses the `GRMustacheRendering` protocol for rendering indexes of an array items.

The `localize` helper of the [standard library](standard_library.md) uses the protocol to localize full template sections, as in `{{# localize }}Hello {{name}}{{/ localize }}`.

[up](../../../../GRMustache#documentation), [next](protected_contexts.md)
