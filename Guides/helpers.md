[up](../../../../GRMustache), [next](filters.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say have your own code executed when GRMustache renders a section such as `{{#name}}...{{/name}}`.

## Overview

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](runtime/context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](runtime/loops.md), a [boolean](runtime/booleans.md), whatever, or a helper. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a helper when it finds an object that conforms to the `GRMustacheHelper` protocol.


## Helpers in action: rendering alternate template strings

For the purpose of demonstration, we'll implement a helper that turns a portion of a template into a HTML link.

For instance, let's focus on the following template snippets:
    
    {{#movie}}
      {{#link}}{{title}}{{/link}}
      {{#director}}
          by {{#link}}{{firstName}} {{lastName}}{{/link}}
      {{/director}}
    {{/movie}}

One will expect it to render as:

    <a href="/movies/123">Citizen Kane</a> by <a href="/people/321">Orson Welles</a>

We see here that the `link` sections were able to output HTML links that were not visible in the template. The content of the links, however, namely the title of the movie, and the names of the director, were defined in the template.

### Declaring our linking helper

We need an object that conforms to the `GRMustacheHelper` protocol, so we'll declare a new class.

```objc
@interface LinkHelper: NSObject<GRMustacheHelper>
@end

@implementation LinkHelper
- (NSString *)renderSection:(GRMustacheSection *)section
{
    return ...;
}
@end

id linkHelper = [[LinkHelper alloc] init];
```

That `renderSection:withContext:` method will be invoked when GRMustache renders the sections attached to our helper. It returns the raw string that should be rendered.

Starting iOS4 and MacOS 10.6, the Objective-C language provides us with blocks. This can relieve the burden of declaring a full class for each helper:

```objc
id linkHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    return ...;
}];
```

The two techniques are equivalent, though.

### The rendering

Now up to the implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#link}}{{title}}{{/link}}`, or `{{#link}}{{firstName}} {{lastName}}{{/link}}`.

This _section_ object has a `innerTemplateString` property, which returns the literal inner content of the section. It will return `{{title}}` or `{{firstName}} {{lastName}}` in our specific example.

Let's wrap this inner template string with `<a href="{{url}}">` and `</a>` in order to build a new template string, and ask the section to render it instead of its regular content:

```objc
id linkHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    // Build a new template string with the section's inner string...
    NSString *templateString = [NSString stringWithFormat:@"<a href=\"{{url}}\">%@</a>", section.innerTemplateString];
    
    // ...and render it:
    return [section renderTemplateString:templateString error:NULL];
}];
```

Assuming the movies and the people have a `url` property, this will work like a charm.

### Attaching the helper to the `link` key

Now we have to have GRMustache find our helper when rendering the `{{#link}}` sections.

We could have one of our model objects implement a `link` property. But this feature is not really tied to any of them. Instead, we'll provide our helper aside, thanks to the `renderObjectsInArray:` method.

```objc
// Prepare data
id data = ...;

// Prepare helper
id linkHelper = ...;
NSDictionary *helpers = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"link"];

// Render
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
NSArray *renderedObjects = [NSArray arrayWithObjects:helpers, data, nil];
NSString *rendering = [template renderObjectsInArray:renderedObjects];
```


## Helpers in action: implementing a localizing helper

Let's now implement a helper that translates, via `NSLocalizedString`, the content of the section.

    {{#items}}
      {{quantity}} × {{name}}
      {{#localize}}Delete{{/localize}}
    {{/items}}

One will expect `{{#localize}}Delete{{/localize}}` to output `Effacer` when the locale is French.

### Declaring our localizing helper

We again need an object that conforms to the `GRMustacheHelper` protocol, but let's keep using the easier block syntax:

```objc
id localizedStringHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    return ...;
}];
```

Our first implementation will use the `innerTemplateString` property of the section, described above. It would return `Delete` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

```objc
id localizedStringHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    return NSLocalizedString(section.innerTemplateString, nil);
}];
@end
```

So far, so good, this would work as expected.

#### Rendering the inner content

Yet the application keeps on evolving, and it appears that the item names should also be localized. The template snippet now reads:

    {{#items}}
      {{quantity}} × {{#localize}}{{name}}{{/localize}}  <-- OMG
      {{#localize}}Delete{{/localize}}
    {{/items}}

Now the strings we have to localize may be:

- literal strings from the template: `Delete`
- strings coming from items : `{{name}}`

Our first implementation will fail, since it would return `NSLocalizedString(@"{{name}}", nil)` instead of localizing item names.

Fortunately, we have the `render` method of `GRMustacheSection`, which returns the rendering of the receiver's inner content. It would return `Delete`, or an item name, in our specific case.

Now we have our final implementation:

```objc
id localizedStringHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    return NSLocalizedString([section render], nil);
}];
```


## GRMustache helpers vs. Mustache lambdas

**Warning: If your goal is to design GRMustache helpers that remain compatible with Mustache lambdas of [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), read the following with great care.**

The strings returned by GRMustache helpers are directly inserted in the final rendering, without any further processing.

However, the specification [states](https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml#L90) that "Lambdas used for sections should have their results parsed" (read, processed as a Mustache template, and rendered in the current context).

In order to comply with the genuine Mustache behavior, a helper must return the result of the `renderTemplateString:` method of the section, as the linking helper seen above. The localizing helper, however, is not specification-compliant.


[up](../../../../GRMustache), [next](filters.md)
