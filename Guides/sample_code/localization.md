[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Localization
============

We'll see how to localize portions of your templates, and eventually render the following template:

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

Mustache and GRMustache have no built-in localization feature. It is thus a matter of injecting our own application code into the template rendering, some code that localize its input.

[Mustache lambda sections](../helpers.md) are our vector. We render them by attaching to a section an object that conforms to the `GRMustacheHelper` protocol. This object will execute the localization task.

Let's use the `[GRMustacheHelper helperWithBlock:]` method, and the `innerTemplateString` property of the section object that the helper is given:

    ```objc
    // A template with a `localize` section:
    NSString *templateString = @"{{#localize}}Hello{{/localize}}";
    
    // A helper that returns the localized version of the inner template string
    // of a section:
    id localizeHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
        return NSLocalizedString(section.innerTemplateString, nil);
    }];
    
    // A dictionary that attaches the helper to the `localize` key:
    id data = @{ @"localize": localizeHelper };
    
    // Render "Bonjour" for the French locale
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

Here we are not localizing a raw portion of the template. Instead, we are localizing a value that comes from the rendered data.

Fortunately, GRMustacheSection objects are able to provide the helper with the rendering of their inner content: `Hello` in our case:

    ```objc
    // A template with a `localize` section:
    NSString *templateString = @"{{#localize}}{{greeting}}{{/localize}}";
    
    // A helper that returns the localized version of the section's rendering:
    id localizeHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
        // [section render] would return "Hello",
        // the rendering of "{{greeting}}".
        return NSLocalizedString([section render], nil);
    }];
    
    // A dictionary that attaches the helper to the `localize` key, and "Hello"
    // to the `greeting` key:
    id data = @{
        @"greeting": @"Hello",
        @"localize": localizeHelper
    };
    
    // Render "Bonjour" for the French locale
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:templateString
                                                     error:NULL];
    ```

`GRMustacheHelper` and `[GRMustacheSection render]` are documented in the [helpers.md](../helpers.md) guide.


[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
