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
    @"localize": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return NSLocalizedString(tag.innerTemplateString, nil);
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
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
    @"localize": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return NSLocalizedString(rendering, nil);
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering depends on the current locale:

    Hello
    Bonjour
    Hola

`+[GRMustache renderingObjectWithBlock:]` and `-[GRMustacheTag renderContentWithContext:HTMLSafe:error:]` are documented in the [Rendering Objects Guide](../rendering_objects.md).


Localizing a template section with arguments
--------------------------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

`Document.mustache`:

    {{#localize}}
        Hello {{name1}}, do you know {{name2}}?
    {{/localize}}

`Rendering.m`:

```objc
id data = @{
    @"name1": @"Arthur",
    @"name2": @"Barbara",
    @"localize": [LocalizingHelper new],
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering depends on the current locale:

    Hello Arthur, do you know Barbara?
    Bonjour Arthur, est-ce que tu connais Barbara ?
    Hola Arthur, sabes Barbara?

Before diving in the sample code, let's first describe out strategy:

1. When rendering the section, we'll build the *localizable format*:

    `Hello %@, do you know %@?`

2. We'll also gather the *format arguments*:
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

The [GRMustacheTagDelegate](../delegate.md) protocol is a nifty tool: not only does it tell you know what value GRMustache is about to render, but you can also decide what value should eventually be rendered.

This looks like a nice way to build our format arguments and the localizable format in a single strike: instead of letting `Arthur` and `Barbara` render, we'll instead put those values away, and tell the library to render `%@`.

Our `LocalizingHelper` class will thus conform to *both* the `GRMustacheRendering` and `GRMustacheTemplateDelegate` protocols. Now the convenient `[GRMustache renderingObjectWithBlock:]` method is not enough. Let's go for a full class:

```objc
@interface LocalizingHelper: NSObject<GRMustacheRendering, GRMustacheTagDelegate>
@property (nonatomic) NSMutableArray *formatArguments;
@end

@implementation LocalizingHelper

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError *__autoreleasing *)error
{
    /**
     * Add self as a tag delegate, so that we know when tag will and did render.
     */
    context = [context contextByAddingTagDelegate:self];
    
    
    /**
     * Perform a first rendering of the section tag, that will set
     * localizableFormat to "Hello %@! Do you know %@?".
     *
     * Our mustacheTag:willRenderObject: implementation will tell the tags to
     * render "%@" instead of the regular values, "Arthur" or "Barbara". This
     * behavior is trigerred by the nil value of self.formatArguments.
     */
    
    self.formatArguments = nil;
    NSString *localizableFormat = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Perform a second rendering that will fill our formatArguments array with
     * HTML-escaped tag renderings.
     *
     * Our mustacheTag:willRenderObject: implementation will now let the regular
     * values through ("Arthur" or "Barbara"), so that our
     * mustacheTag:didRenderObject:as: method can fill self.formatArguments.
     * This behavior is not the same as the previous one, and is trigerred by
     * the non-nil value of self.formatArguments.
     */
    
    self.formatArguments = [NSMutableArray array];
    [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Localize the format, and render.
     *
     * Unfortunately, [NSString stringWithFormat:] does not accept an array of
     * formatArguments to fill the format. Let's support up to 3 arguments:
     */
    
    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);
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
            
        default:
            NSAssert(NO, @"Not implemented");
            break;
    }
    
    
    /**
     * Cleanup and return
     */
    
    self.formatArguments = nil;
    return rendering;
}

- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    /**
     * We behave as stated in renderForMustacheTag:context:HTMLSafe:error:
     */
    
    if (self.formatArguments) {
        return object;
    }

    return @"%@";
}

- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering
{
    /**
     * We behave as stated in renderForMustacheTag:context:HTMLSafe:error:
     */
    
    [self.formatArguments addObject:rendering];
}

@end
```

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**


Localizing a template section with arguments and conditions
-----------------------------------------------------------

Download the [GRMustacheLocalization Xcode project](../../../../tree/master/Guides/sample_code/localization): it provides tiny modifications to the `LocalizingHelper` class, in order to deal with Mustache boolean sections, and have the following code work:

```objc
id localizingHelper = [LocalizingHelper new];
id isPluralFilter = [GRMustacheFilter filterWithBlock:^id(NSNumber *count) {
    if ([count intValue] > 1) {
        return @YES;
    }
    return @NO;
}];

NSString *templateString = @"{{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

{
    id data = @{
        @"name1": @"Arthur",
        @"name2": @"Barbara",
        @"count": @(0),
        @"localize": localizingHelper,
        @"isPlural": isPluralFilter,
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
        @"localize": localizingHelper,
        @"isPlural": isPluralFilter,
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
        @"localize": localizingHelper,
        @"isPlural": isPluralFilter,
    };
    
    // Eugene and Fiona have 5 mutual friends.
    // Eugene et Fiona ont 5 amis communs.
    // Eugene y Fiona tiene 5 amigos en común.
    
    NSString *rendering = [template renderObject:data withFilters:filters];
}
```

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
