[up](../runtime.md), [next](../delegate.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say have your own code executed when GRMustache renders a section such as `{{#name}}...{{/name}}`.

## Overview

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](context_stack.md), using the standard Key-Value Coding `valueForKey:` method. GRMustache may find a string, an [array](loops.md), a [boolean](booleans.md), whatever, or a helper. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

GRMustache recognizes a helper when it finds an object that conforms to the `GRMustacheHelper` protocol.

## Helpers in action: implementing a localizing helper

For the purpose of demonstration, we'll implement a helper that translates, via `NSLocalizedString`, the content of the section.

For instance, let's focus on the following template snippet:

    {{#cart}}
      {{#items}}
        {{quantity}} × {{name}}
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

One will expect `{{#localize}}Delete{{/localize}}` to output `Effacer` when the locale is French.

### Declaring our localizing helper

We need an object that conforms to the `GRMustacheHelper` protocol, so we'll declare a new class.

```objc
@interface LocalizedStringHelper: NSObject<GRMustacheHelper>
@end

@implementation LocalizedStringHelper
- (NSString *)renderSection:(GRMustacheSection *)section
{
    return ...;
}
@end
```

That `renderSection:withContext:` method will be invoked when GRMustache renders the sections attached to our helper. It returns the raw string that should be rendered.

#### The literal inner content

Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.

This _section_ object has a `innerTemplateString` property, which returns the literal inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

```objc
@implementation LocalizedStringHelper
- (NSString *)renderSection:(GRMustacheSection *)section
{
    return NSLocalizedString(section.innerTemplateString, nil);
}
@end
```

So far, so good, this would work as expected.

#### Rendering the inner content

Yet the application keeps on evolving, and it appears that the item names should also be localized. The template snippet now reads:

    {{#cart}}
      {{#items}}
        {{quantity}} × {{#localize}}{{name}}{{/localize}}  <-- OMG
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

Now the strings we have to localize may be:

- literal strings from the template: `Delete`
- strings coming from cart items : `{{name}}`

Our first implementation will fail, since it will return `NSLocalizedString(@"{{name}}", nil)` when localizing item names.

Fortunately, we have the `render` method of `GRMustacheSection`, which returns the rendering of the receiver's inner content, in the current context. It would return `Delete`, or an item name, in our specific case.

Now we can fix our implementation:

```objc
@implementation LocalizedStringHelper
- (NSString *)renderSection:(GRMustacheSection *)section
{
    return NSLocalizedString([section render], nil);
}
@end
```

#### Attaching the helper to the `localize` key

Now we have to have GRMustache find our helper when rendering the `{{#localize}}` sections.

We could have one of our model objects implement a `localize` property. But this feature is not really tied to any of them. Instead, we'll provide our helper aside, thanks to the `renderObjects:` (with an s) method.

```objc
// Prepare data
id data = ...;

// Prepare helper
LocalizedStringHelper *localizeHelper = [[[LocalizedStringHelper alloc] init] autorelease];
NSDictionary *helpers = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

// Render
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
NSString *rendering = [template renderObjects:helpers, data, nil];
```

`renderObjects:` is documented in [Guides/templates.md](../templates.md).


### Implementing helpers with blocks

Starting iOS4 and MacOS 10.6, the Objective-C language provides us with blocks. This can relieve the burden of declaring a full class for each helper:

```objc
// Prepare data
id data = ...;

// Prepare helper (no need for a specific class)
GRMustacheHelper *localizeHelper = [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
    return NSLocalizedString([section render], nil);
}];
NSDictionary *helpers = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

// Render
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
NSString *rendering = [template renderObjects:helpers, data, nil];
```

## GRMustache helpers vs. Mustache lambdas

**Warning: If your goal is to design GRMustache helpers that remain compatible with Mustache lambdas of [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), read the following with great care.**

The strings returned by GRMustache helpers are directly inserted in the final rendering, without any further processing.

However, the specification [states](https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml#L90) that "Lambdas used for sections should have their results parsed" (read, processed as a Mustache template, and rendered in the current context).

GRMustache helpers allow you to comply with the genuine Mustache behavior:

```objc
@implementation BoldHelper
- (NSString *)renderSection:(GRMustacheSection *)section
{
    // build the genuine Mustache lambda template string...
    NSString *templateString = [NSString stringWithFormat:@"<b>%@</b>", section.innerTemplateString];
    
    // ...and render it in a specification-compliant way:
    return [GRMustacheTemplate renderObject:section.renderingContext fromString:templateString error:NULL];
}
@end
```

[up](../runtime.md), [next](../delegate.md)
