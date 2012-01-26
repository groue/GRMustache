[up](../runtime.md), [next](../forking.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say have your own code executed when GRMustache renders a section such as `{{#name}}...{{/name}}`.

## Overview

In GRMustache, the rendering is controlled by the data objects you provide to rendering methods. This topic is covered in detail in ([guides/runtime.md](runtime.md)).

The principles covered here will thus always be the same: it's a matter of providing the rendering methods of GRMustache with data objects which have code attached to specific template keys.

We'll cover below three techniques:

- specific selectors: one of your data objects implements a selector that matches a section name.
- block helpers: one of your data objects returns a block through `valueForKey;`.
- dedicated helper classes: one of your data objects returns a `<GRMustacheHelper>` object through `valueForKey:`.

The first two techniques are easily implemented, but rather ad-hoc. The latest provides higher encapsulation and reusability, but you'll have to write a full Objective-C class.

## Helpers in action: implementing a localizing helper

For the purpose of demonstration, we'll implement a helper that translates, via `NSLocalizedString`, the content of the section: one will expect `{{#localize}}Delete{{/localize}}` to output `Effacer` when the locale is French.

### Implementing helpers with specific selectors

If the context used for mustache rendering implements the `localizeSection:withContext:` selector (generally, a method whose name is the name of the section, to which you append `Section:withContext:`), then this method will be called when rendering the section.

The choice of the class that should implement this selector is up to you, as long as it can be reached when rendering the template, just as regular values (see ([guides/runtime.md](runtime.md))).

For instance, let's focus on the following template snippet:

    {{#cart}}
      {{#items}}
        {{quantity}} × {{name}}
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

When the `localize` section is rendered, the context contains an item object, an items collection, a cart object, plus any surrounding objects.

If the item object implements the `localizeSection:withContext:` selector, then its implementation will be called. Otherwise, the selector will be looked up in the items collection. Since this collection is likely an `NSArray` instance, the lookup will continue with the cart and its surrounding context, until some object is found that implements the `localizeSection:withContext:` selector.

In order to have a reusable `localize` helper, we'll isolate it in a specific class, `MustacheHelper`, and make sure this helper is provided to GRMustache when rendering our template.

Let's first declare our helper class:

    @interface MustacheHelper: NSObject
    @end

Since our helper doesn't carry any state, let's declare our `localizeSection:withContext:` selector as a class method:

      + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context;

#### The literal inner content

Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.

This _section_ object has a `templateString` property, which returns the literal inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

    @implementation MustacheHelper
    + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
    {
      return NSLocalizedString(section.templateString, nil);
    }
    @end

So far, so good, this would work as expected.

#### Rendering the inner content

Yet the application keeps on evolving, and it appears that the item names should also be localized. The template snippet now reads:

    {{#cart}}
      {{#items}}
        {{quantity}} × {{#localize}}{{name}}{{/localize}}
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

Now the strings we have to localize may be:

- literal strings from the template: `Delete`
- strings coming from cart items : `{{name}}`

Our first `MustacheHelper` will fail, since it will return `NSLocalizedString(@"{{name}}", nil)` when localizing item names.

Actually we now need to feed `NSLocalizedString` with the _rendering_ of the inner content, not the _literal_ inner content.

Fortunately, we have:

- the `renderObject:` method of `GRMustacheSection`, which renders the content of the receiver with the provided object. 
- the _context_ parameter, which is the current rendering context, containing a cart item, an item collection, a cart, and any surrouding objects.

`[section renderObject:context]` is exactly what we need: the inner content rendered in the current context.

Now we can fix our implementation:

    @implementation MustacheHelper
    + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
    {
      NSString *renderedContent = [section renderObject:context];
      return NSLocalizedString(renderedContent, nil);
    }
    @end

#### Using the helper object

Now that our helper class is well defined, let's use it.

Assuming:

- `orderConfirmation.mustache` is a mustache template resource,
- `self` has a `cart` property suitable for our template rendering,

Let's first parse the template:

    GRMustacheTemplate *template = [GRMustacheTemplate parseResource:@"orderConfirmation" bundle:nil error:NULL];

Let's now render, with two objects: our `MustacheHelper` class that will provide the `localize` helper, and `self` that will provide the `cart`:

    [template renderObjects:[MustacheHelper class], self, nil];

### Implementing helpers with blocks

Starting MacOS6 and iOS4, blocks are available to the Objective-C language. GRMustache provides a block-based helper API.

This technique does not involve declaring any special selector. But when asked for the `localized` key, your context will return a GRMustacheBlockHelper instance, built in the same fashion as the helper methods seen above:

    id localizeHelper = [GRMustacheBlockHelper helperWithBlock:(^(GRMustacheSection *section, id context) {
      NSString *renderedContent = [section renderObject:context];
      return NSLocalizedString(renderedContent, nil);
    }];

See how the block implementation is strictly identical to the helper method discussed above.

Actually, your only concern is to make sure your values and helper code can be reached by GRMustache when rendering your templates. Implementing `localizeSection:withContext` or returning a GRMustacheBlockHelper instance for the `localize` key is strictly equivalent.

However, unlike the selector technique seen above, our code is not yet bound to the section name, `localize`. And actually, we need some container object. Let's go with a dictionary:

    id mustacheHelper = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

And now the rendering is done as usual:

    [template renderObjects:mustacheHelper, self, nil];


### Implementing helpers with classes conforming to the `GRMustacheHelper` protocol

Now that we have a nice working localizing helper, we may well want to reuse it in some other projects. Unfortunately, the two techniques seen above don't help us that much achieving this goal:

- the selector technique binds the helper code to the section name, thus making impossible to share the helper code between various sections of various templates.
- the block technique provides no way to cleanly encapsulate the helper code.

The `GRMustacheHelper` protocol aims at giving you a way to create helper classes, with all expected benefits: encapsulation and reusability.

In our case, here would be the implementation of our localizing helper:

    @interface LocalizedStringHelper: NSObject<GRMustacheHelper>
    @end
    
    @implementation LocalizedStringHelper
    // The renderSection:inContext method is required by the GRMustacheHelper protocol
    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
    {
      NSString *renderedContent = [section renderObject:context];
      return NSLocalizedString(renderedContent, nil);
    }
    @end

We, again, need some container object, in order to attach our helper to the `localize` key:

    LocalizedStringHelper *localizeHelper = [[[LocalizedStringHelper alloc] init] autorelease];
    id mustacheHelper = [NSDictionary dictionaryWithObject:localizeHelper forKey:@"localize"];

And now the rendering is done as usual:

    [template renderObjects:mustacheHelper, self, nil];

Speaking of encapsulation, our `LocalizedStringHelper` can even now support localization tables. This is left as an exercise for the reader :-)

## Usages of helpers

Helpers can be used for whatever you may find relevant.

You may implement filters, as we have seen above.

You may also implement caching:

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      if (self.cache == nil) {
        self.cache = [section renderObject:context];
      }
      return self.cache;
    };

You may render an extended context:

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      return [section renderObjects:context, ..., nil];
    });

You may render a totally different context (note that this is the base technique for the [GRMustacheNumberFormatterHelper](number_formatting.md) and [GRMustacheDateFormatterHelper](date_formatting.md) helpers that ship with GRMustache):

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      return [section renderObject:...];
    });

You may implement debugging sections:

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      NSLog(section.templateString);         // log the unrendered section 
      NSLog([section renderObject:context]); // log the rendered section 
      return nil;                            // don't render anything
    });

[up](../runtime.md), [next](../forking.md)
