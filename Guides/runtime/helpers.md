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
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    return ...;
}
@end
```

That `renderSection:withContext:` method will be invoked when GRMustache renders the sections attached to our helper. It should return the string that should be rendered.

#### The literal inner content

Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.

This _section_ object has a `templateString` property, which returns the literal inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

```objc
@implementation LocalizedStringHelper
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    return NSLocalizedString(section.templateString, nil);
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

Actually we now need to feed `NSLocalizedString` with the _rendering_ of the inner content, not the _literal_ inner content.

Fortunately, we have:

- the `renderObject:` method of `GRMustacheSection`, which renders the content of the receiver with the provided object. 
- the _context_ parameter, which represents the current rendering context stack, containing a cart item, an item collection, a cart, and any surrouding objects.

`[section renderObject:context]` is exactly what we need: the inner content rendered in the current context.

Now we can fix our implementation:

```objc
@implementation LocalizedStringHelper
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    NSString *renderedContent = [section renderObject:context];
    return NSLocalizedString(renderedContent, nil);
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

// Prepare helper
GRMustacheBlockHelper *localizeHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
    NSString *renderedContent = [section renderObject:context];
    return NSLocalizedString(renderedContent, nil);
}];
NSDictionary *helpers = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

// Render
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
NSString *rendering = [template renderObjects:helpers, data, nil];
```

## GRMustache helpers vs Mustache lambdas

GRMustache helpers are more expressive than required by the [Mustache specification v1.1.2](https://github.com/mustache/spec).

**Warning: If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use the features exposed below with great care.**

You may extend the set of rendered keys inside a section.

In the example below, the `{{foo}}` tags embedded in the section will render as `bar`, even though no model object provides any `foo` key:

```objc
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"];
    return [section renderObjects:context, dictionary, nil];
});
```

You may even provide a totally different context:

In the example below, the `{{foo}}` tags embedded in the section will be the only ones that will be rendered:

```objc
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"];
    return [section renderObject:dictionary];
});
```

[up](../runtime.md), [next](../delegate.md)
