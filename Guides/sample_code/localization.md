[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Localization
============

Overview
--------

Mustache and GRMustache have no built-in localization feature. It is thus a matter of injecting our own application code into the template rendering, some code that localizes its input.

[Mustache lambda sections](../helpers.md) are our vector. We'll eventually render the following template:

    {{#localize}}
        Hello {{name1}}, do you know {{name2}}?
    {{/localize}}

Into the various renderings below, depending on the current locale:

    Hello Arthur, do you know Barbara ?
    Bonjour Arthur, est-ce que tu connais Barbara ?
    Hola Arthur, sabes Barbara?

Yet this will be quite a smartish sample code, and it's better starting with more simple cases. We'll see how to localize:

1. a section of a template
    
        {{#localize}}Hello{{/localize}}
    
2. a value
    
        {{#localize}}{{greeting}}{{/localize}}
    
3. a portion of a template *with arguments*, as above:
    
        {{#localize}}Hello {{name1}}, do you know {{name2}}?{{/localize}}

Of course, we'll always eventually use the standard `NSLocalizedString` function.

Localizing a template section
-----------------------------

Let's localize the following template:

    {{#localize}}Hello{{/localize}}

And render, depending on the current locale:

    Hello
    Bonjour
    Hola

We'll execute our localizing code by attaching to the `localize` section an object that conforms to the `GRMustacheHelper` protocol.

The shortest way to build a helper is the `[GRMustacheHelper helperWithBlock:]` method. Its block is given a `GRMustacheSection` object whose `innerTemplateString` property suits perfectly our needs:

    ```objc
    id data = @{
        @"localize": [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
            return NSLocalizedString(section.innerTemplateString, nil);
        }]
    };
    
    NSString *templateString = @"{{#localize}}Hello{{/localize}}";
    
    // Bonjour, Hola, Hello
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:templateString
                                                     error:NULL];
    ```

`GRMustacheHelper` and `innerTemplateString` are documented in the [helpers.md](../helpers.md) guide.


Localizing a value
------------------

Template:

    {{#localize}}{{greeting}}{{/localize}}

Data:

    { greeting: "Hello" }

Rendering:

    Hello
    Bonjour
    Hola

Again, we'll execute our localizing code by attaching to the `localize` section an object that conforms to the `GRMustacheHelper` protocol.

However, this time, we are not localizing a raw portion of the template. Instead, we are localizing a value that comes from the rendered data.

Fortunately, `GRMustacheSection` objects are able to provide helpers with the rendering of their inner content, `"Hello"` in our case, with their `render` method:

    ```objc
    id data = @{
        @"greeting": @"Hello",
        @"localize": [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
            return NSLocalizedString([section render], nil);
        }]
    };
    
    NSString *templateString = @"{{#localize}}{{greeting}}{{/localize}}";
    
    // Bonjour, Hola, Hello
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:templateString
                                                     error:NULL];
    ```

`GRMustacheHelper` and `[GRMustacheSection render]` are documented in the [helpers.md](../helpers.md) guide.


[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
