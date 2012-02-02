[up](../runtime.md), [next](../number_formatting.md)

Helpers
=======

GRMustache helpers allow you to implement "Mustache lambdas", that is to say have your own code executed when GRMustache renders a section such as `{{#name}}...{{/name}}`.

## Overview

When GRMustache renders a section `{{#name}}...{{/name}}`, it looks for the `name` key in the [context stack](context_stack.md). GRMustache may find a string, an [array](loops.md), a [boolean](booleans.md), whatever, or a helper. It's here a matter of attaching code, instead of regular values, to the keys of your data objects.

We'll cover below two techniques:

- specific selectors: one of your data objects implements a selector that matches a section name.
- dedicated helper classes: one of your data objects returns a `<GRMustacheHelper>` object through `valueForKey:`.

The selector technique is easily implemented, but rather ad-hoc. The latest provides higher encapsulation and reusability, but you'll have to write a full Objective-C class.

## Helpers in action: implementing a localizing helper

For the purpose of demonstration, we'll implement a helper that translates, via `NSLocalizedString`, the content of the section: one will expect `{{#localize}}Delete{{/localize}}` to output `Effacer` when the locale is French.

### Implementing helpers with specific selectors

If the context used for mustache rendering implements the `localizeSection:withContext:` selector (generally, a method whose name is the name of the section, to which you append `Section:withContext:`), then this method will be called when rendering the section.

The choice of the class that should implement this selector is up to you, as long as it can be reached in the [context stack](context_stack.md).

For instance, let's focus on the following template snippet:

    {{#cart}}
      {{#items}}
        {{quantity}} × {{name}}
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

When the `localize` section is rendered, the context stack contains an item object, an items collection, a cart object, plus any other objects provided to the template.

In order to have a template-wide `localize` helper, we won't attach it to any specific model. Instead, we'll isolate it in a specific class, `TemplateUtils`, and make sure this class is provided to GRMustache when rendering our template.

Since we don't need to carry any state, let's declare our `localizeSection:withContext:` selector as a class method:

    @interface TemplateUtils: NSObject
    + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context;
    @end



#### The literal inner content

Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.

This _section_ object has a `templateString` property, which returns the literal inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

    @implementation TemplateUtils
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
        {{quantity}} × {{#localize}}{{name}}{{/localize}}  <-- OMG
        {{#localize}}Delete{{/localize}}
      {{/items}}
    {{/cart}}

Now the strings we have to localize may be:

- literal strings from the template: `Delete`
- strings coming from cart items : `{{name}}`

Our first `TemplateUtils` will fail, since it will return `NSLocalizedString(@"{{name}}", nil)` when localizing item names.

Actually we now need to feed `NSLocalizedString` with the _rendering_ of the inner content, not the _literal_ inner content.

Fortunately, we have:

- the `renderObject:` method of `GRMustacheSection`, which renders the content of the receiver with the provided object. 
- the _context_ parameter, which represents the current rendering context stack, containing a cart item, an item collection, a cart, and any surrouding objects. It is noteworthy that its `valueForKey:` method performs a stack lookup. But we won't use this nifty feature here.

`[section renderObject:context]` is exactly what we need: the inner content rendered in the current context.

Now we can fix our implementation:

    @implementation TemplateUtils
    + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
    {
      NSString *renderedContent = [section renderObject:context];
      return NSLocalizedString(renderedContent, nil);
    }
    @end

#### Injecting the helper

Now let's render. Our template needs two objects: our `TemplateUtils` class for the `localize` key, and another for the `cart`:

    NSString *rendering = [template renderObjects:[TemplateUtils class], data, nil];

### Implementing helpers with classes conforming to the `GRMustacheHelper` protocol

Now that we have a nice working localizing helper, we may well want to reuse it in some other projects. Unfortunately, the above selector technique doesn't help us that much achieving this goal: it binds the helper code to the section name, thus making impossible to share the helper code between various sections of various templates.

The `GRMustacheHelper` protocol aims at giving you a way to create helper classes, with all expected benefits: encapsulation and reusability.

In our case, here would be the implementation of our localizing helper:

    @interface LocalizedStringHelper: NSObject<GRMustacheHelper>
    @end
    
    @implementation LocalizedStringHelper
    // required by the GRMustacheHelper protocol
    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
    {
      NSString *renderedContent = [section renderObject:context];
      return NSLocalizedString(renderedContent, nil);
    }
    @end

This time, we need to explicitely attach our helper to the `localize` key. Let's go with a dictionary:
    
    id localizeHelper = [[[LocalizedStringHelper alloc] init] autorelease];
    NSString *rendering = [template renderObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   localizeHelper, @"localize",
                                                   data.cart,      @"cart",
                                                   nil]];

Did you notice? Our `LocalizedStringHelper` can now support localization tables. This is left as an exercise for the reader :-)

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

You may render a totally different context (note that this is the base technique for the [GRMustacheNumberFormatterHelper](../number_formatting.md) and [GRMustacheDateFormatterHelper](../date_formatting.md) helpers that ship with GRMustache):

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      return [section renderObject:...];
    });

You may implement debugging sections:

    - (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context {
      NSLog(section.templateString);         // log the unrendered section 
      NSLog([section renderObject:context]); // log the rendered section 
      return nil;                            // don't render anything
    });

[up](../runtime.md), [next](../number_formatting.md)
