[up](../../../../GRMustache#documentation), [next](delegate.md)

Rendering Objects
=================

Overview
--------

Let's first confess a lie: here and there in this documentation, you have been reading that Mustache tags renders objects in a way or another: variable tags output values HTML-escaped, sections tags loop over arrays, etc.

This is plain wrong. Actually, objects render themselves.

`NSNumber` *does* render as a string for `{{ number }}`, and decides if `{{# condition }}...{{/}}` should render.

`NSArray` *does* render the `{{# items }}...{{/}}` tag for each of its items.

etc.

Let's have a precise look at the rendering of a tag, say: `{{ uppercase(person.name) }}`.

First the `uppercase(person.name)` expression is evaluated. This evaluation is based on the invocation of `valueForKey:` on your data object (see the [Runtime Guide](runtime.md) for details). Eventually, *you* decide who is the person, what is his name, and which filter should apply. Let's say the expression evaluates to "ARTHUR".

Second, [tag delegates](delegate.md) enter the game. Tag delegates can change the value before it is rendered. For the purpose of demonstration, let's admit that a pirate delegate was there: "ARRRRRRRTHUR".

Finally, the "ARRRRRRRTHUR" string is asked to render for the `{{ uppercase(person.name) }}` tag. It is a variable tag, so the string simply renders itself.

You see that from the start, your application code decides what will be eventully be rendered. Let's imagine that instead of "ARRRRRRRTHUR", you had provided an object that conforms to the `GRMustacheRendering` protocol:

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

- The _context_ represents the [context stack](runtime/context_stack.md), and all information that tags need to render.

- _HTMLSafe_ is a pointer to a BOOL: upon return, it must be set to YES or NO, depending on the safety of the string you render. If you forget to set it, it is of course assumed to be NO.

- _error_ is... the eventual error. You can return nil without setting any error: in this case, everything happens as if you returned the empty string.

You may declare and implement your own conforming classes. The `+[GRMustache renderingObjectWithBlock:]` method comes in handy for creating a rendering object without declaring any class:

    ```objc
    id renderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
    {
        return @"I'm rendered!";
    }];
    ```

Examples
--------

### Wrapping the content of a section tag

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

    <b>Arthur is awesome.</b>


### Have a section render an alternate template string

Let's write a rendering object that wraps a section in a HTML link. The URL of the link will be fetched with the `url` key:

`Document.mustache`:

    {{#link}}{{firstName}} {{lastName}}{{/link}}

`Render.m`:

    ```objc
    id link = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error)
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
        @"url": @"/people/1",
        @"link": link,
    };
    
    NSString *rendering = [GRMustacheTemplate renderObject:data fromResource:@"Document" bundle:nil error:NULL];
    ```

Final rendering:

    <a href="/people/1">Orson Welles</a>

[up](../../../../GRMustache#documentation), [next](delegate.md)
