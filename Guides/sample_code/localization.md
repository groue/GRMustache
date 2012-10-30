[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Localization
============

Overview
--------

Mustache and GRMustache have no built-in localization feature. It is thus a matter of injecting our own application code into the template rendering, some code that localizes its input.

[Rendering objects](../rendering_objects.md) are our vector. We'll eventually render the following template:

    {{#localize}}
        {{name1}} and {{name2}}
        {{#count}}
            {{! at least one mutual friend }}
            have
            {{#isPlural(count)}}
                {{! several mutual friend }}
                {{count}} mutual friends
            {{/}}
            {{^isPlural(count)}}
                {{! single mutual friend }}
                one mutual friend
            {{/}}
        {{/}}
        {{^count}}
            {{! no mutual friend }}
            have no mutual friend
        {{/}}.
    {{/localize}}

Into the various renderings below, depending on the current locale:

    Arthur and Barbara have no mutual friend.
    Craig et Dennis ont un ami commun.
    Eugene y Fiona tiene 5 amigos en común.

Yet this will be quite a smartish sample code, and it's better starting with simpler cases. We'll see how to localize:

1. a section of a template
    
        {{#localize}}Hello{{/localize}}
    
2. a value
    
        {{#localize}}{{greeting}}{{/localize}}
    
3. a portion of a template *with arguments*, as above:
    
        {{#localize}}Hello {{name1}}, do you know {{name2}}?{{/localize}}

4. a portion of a template with arguments and *conditions*, as above:
    
        {{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}

Of course, we'll always eventually use the standard `NSLocalizedString` function.

Localizing a template section
-----------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

`Document.mustache`:

    {{#localize}}Hello{{/localize}}

`Render.m`:

```objc
id data = @{
    @"localize": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
        return NSLocalizedString(tag.innerTemplateString, nil);
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

Final rendering depends on the current locale:

    Hello
    Bonjour
    Hola

`+[GRMustache renderingObjectWithBlock:]` and `-[GRMustacheTag innerTemplateString]` are documented in the [Rendering Objects Guide](../rendering_objects.md).


Localizing a value
------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

`Document.mustache`:

    {{#localize}}{{greeting}}{{/localize}}

`Render.m`:

```objc
id data = @{
    @"greeting": @"Hello",
    @"localize": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return NSLocalizedString(rendering, nil);
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

Rendering:

    Hello
    Bonjour
    Hola

`+[GRMustache renderingObjectWithBlock:]` and `-[GRMustacheTag renderContentWithContext:HTMLSafe:error:]` are documented in the [Rendering Objects Guide](../rendering_objects.md).


Localizing a template section with arguments
--------------------------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

Template:

    {{#localize}}
        Hello {{name1}}, do you know {{name2}}?
    {{/localize}}

Data:

    {
      name1: "Arthur",
      name2: "Barbara"
    }

Rendering:

    Hello Arthur, do you know Barbara?
    Bonjour Arthur, est-ce que tu connais Barbara ?
    Hola Arthur, sabes Barbara?

Before diving in the sample code, let's first describe out strategy:

1. We'll build the following string, the *localizable format*:

    `Hello %@, do you know %@?`

2. We'll gather the *format arguments*:
    - `Arthur`
    - `Barbara`
    
3. We'll localize the localizable format with `NSLocalizedString`, that will give us the *localized format*:
    - `Hello %@, do you know %@?`
    - `Bonjour %@, est-ce que tu connais %@ ?`
    - `Hola %@, sabes %@?`

4. We'll finally use `[NSString stringWithFormat:]`, with the localized format, and format arguments:
    - `Hello Arthur, do you know Barbara?`
    - `Bonjour Arthur, est-ce que tu connais Barbara ?`
    - `Hola Arthur, sabes Barbara?`

The tricky part is building the *localizable format* and extracting the *format arguments*. We could most certainly "manually" parse the inner template string of the section, `Hello {{name1}}, do you know {{name2}}?`. However, we'll take a more robust and reusable path.

The [GRMustacheDelegate](../delegate.md) protocol is a nifty tool: it lets you know what GRMustache is about to render, and replace it with whatever value you want.

This looks like a nice way to build our format arguments and the localizable format in a single strike: instead of letting GRMustache render `Arthur` and `Barbara`, we'll put those values away, and tell the library to render `%@` instead.

We'll thus now attach to the `localize` section an object that conforms to *both* the `GRMustacheSectionTagHelper` and `GRMustacheTemplateDelegate` protocols. As in the previous example, we'll perform a "double-pass" rendering: the first rendering will use the delegate facet, build the localizable format, and fill the format arguments. The second rendering will simply mix the format and the arguments.

Now the convenient `[GRMustacheSectionTagHelper helperWithBlock:]` method is not enough. Let's go for a full class:

```objc
@interface LocalizingHelper : NSObject<GRMustacheSectionTagHelper, GRMustacheTemplateDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
@end

@implementation LocalizingHelper

/**
 * GRMustacheSectionTagHelper method
 */

- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    /**
     * Let's perform a first rendering of the section, invoking
     * [context render].
     *
     * This method returns the rendering of the section:
     * "Hello {{name1}}! Do you know {{name2}}?" in our specific example.
     *
     * Normally, it would return "Hello Arthur! Do you know Barbara?", which
     * we could not localize.
     *
     * But we are also a GRMustacheTemplateDelegate, and as such, GRMustache
     * will tell us when it is about to render a value.
     *
     * In the template:willInterpretReturnValueOfInvocation:as: delegate method,
     * we'll tell GRMustache to render "%@" instead of the actual values
     * "Arthur" and "Barbara".
     *
     * The rendering of the section will thus be "Hello %@! Do you know %@?",
     * which is a string that is suitable for localization.
     *
     * We still need the format arguments to fill the format: "Arthur", and
     * "Barbara".
     *
     * They also be gathered in the delegate method, that will fill the
     * self.formatArguments array, here initialized as an empty array.
     */

    self.formatArguments = [NSMutableArray array];
    NSString *localizableFormat = [context render]; // triggers delegate callbacks


    /**
     * Now localize the format.
     */

    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);


    /**
     * Render!
     *
     * [NSString stringWithFormat:] unfortunately does not accept an array of
     * formatArguments to fill the format. Let's support up to 3 arguments:
     */
    
    NSString *rendering = nil;
    switch (self.formatArguments.count) {
        case 0:
            rendering = localizedFormat;
            break;
        
        case 1:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0]];
            break;
            
        case 2:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1]];
            break;
            
        case 3:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1],
                         [self.formatArguments objectAtIndex:2]];
            break;
    }


    /**
     * Cleanup and return the rendering
     */

    self.formatArguments = nil;
    return rendering;
}


/**
 * GRMustacheTemplateDelegate method
 */

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * invocation.returnValue is "Arthur" or "Barbara".
     *
     * Fill self.formatArguments so that we have arguments for
     * [NSString stringWithFormat:].
     */

    [self.formatArguments addObject:invocation.returnValue ?: [NSNull null]];


    /**
     * Render "%@" instead of the value.
     */

    invocation.returnValue = @"%@";
}

@end
```

With such a helper, the rendering is easy:

```objc
id data = @{
    @"name1": @"Arthur",
    @"name2": @"Barbara",
    @"localize": [[LocalizingHelper alloc] init]
};

NSString *templateString = @"{{#localize}}Hello {{name1}}! Do you know {{name2}}?{{/localize}}";

// Hello Arthur, do you know Barbara?
// Bonjour Arthur, est-ce que tu connais Barbara ?
// Hola Arthur, sabes Barbara?
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**


Localizing a template section with arguments and conditions
-----------------------------------------------------------

Download the [GRMustacheLocalization Xcode project](../../../../tree/master/Guides/sample_code/localization): it provides tiny modifications to the `LocalizingHelper` class, in order to have the following code work:

```objc
id filters = @{ @"isPlural" : [GRMustacheFilter filterWithBlock:^id(NSNumber *count) {
    if ([count intValue] > 1) {
        return @YES;
    }
    return @NO;
}]};

NSString *templateString = @"{{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

{
    id data = @{
    @"name1": @"Arthur",
    @"name2": @"Barbara",
    @"count": @(0),
    @"localize": [[LocalizingHelper alloc] init]
    };
    
    // Arthur and Barbara have no mutual friend.
    // Arthur et Barbara n’ont pas d’ami commun.
    // Arthur y Barbara no tienen ningún amigo en común.
    
    NSString *rendering = [template renderObject:data withFilters:filters];
}

{
    id data = @{
    @"name1": @"Craig",
    @"name2": @"Dennis",
    @"count": @(1),
    @"localize": [[LocalizingHelper alloc] init]
    };
    
    
    // Craig and Dennis have one mutual friend.
    // Craig et Dennis ont un ami commun.
    // Craig y Dennis tiene un amigo en común.
    
    NSString *rendering = [template renderObject:data withFilters:filters];
}

{
    id data = @{
    @"name1": @"Eugene",
    @"name2": @"Fiona",
    @"count": @(5),
    @"localize": [[LocalizingHelper alloc] init]
    };
    
    // Eugene and Fiona have 5 mutual friends.
    // Eugene et Fiona ont 5 amis communs.
    // Eugene y Fiona tiene 5 amigos en común.
    
    NSString *rendering = [template renderObject:data withFilters:filters];
}
```

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
