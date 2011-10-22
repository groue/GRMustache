// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"


/**
 `GRMustacheSection` is a class that is involved in mustache lambdas definition.
 
 ## Mustache lambdas
 
 Mustache lambdas allow you to execute custom code when rendering a mustache section such as:
 
    {{#name}}...{{/name}}
 
 GRMustache provides you with two ways in order to define your lambdas. The first one requires some selectors to be implemented, the second uses Objective-C blocks.
 
 For the purpose of demonstration, we'll implement a lambda that translates, via `NSLocalizedString`, the content of the section.
 
 For instance, one will expect `{{#localize}}Delete{{/localize}}` to output `Supprimer` when the locale is French.
 
 ### Implementing lambdas with methods
 
 If the context used for mustache rendering implements the `localizeSection:withContext:` selector (generally, a method whose name is the name of the section, to which you append `Section:withContext:`), then this method will be called when rendering the section.
 
 The choice of the class that should implement this selector is up to you, as long as it can be reached when rendering the template, just as regular values.
 
 For instance, provided with the following template snippet:

    {{#cart}}
        {{#items}}
            {{quantity}} × {{name}}
            {{#localize}}Delete{{/localize}}
        {{/items}}
    {{/cart}}
 
 The `localize` section is rendered with a context containing an item object, an items collection, a cart object, plus any surrounding objects.
 
 If the item object implements the `localizeSection:withContext:` selector, then its implementation will be called. Otherwise, the selector will be looked up in the items collection. Since this collection is likely an `NSArray` instance, the lookup will continue with the cart and its surrounding context, until some object is found that implements the `localizeSection:withContext:` selector.
 
 In order to have a reusable `localize` lambda, we'll isolate it in a specific class, `LocalizeMustacheHelper`, and make sure this helper is provided to GRMustache when rendering our template.

 Let's first declare our helper class:
 
    @interface LocalizeMustacheHelper: NSObject
 
 Since our helper doesn't carry any state, let's declare our `localizeSection:withContext:` selector as a class method:
 
        + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context;
    @end
 
 #### The raw inner content
 
 Now up to the first implementation. The _section_ argument is a `GRMustacheSection` object, which represents the section being rendered: `{{#localize}}Delete{{/localize}}`.
 
 This _section_ object has a templateString property, which returns the raw inner content of the section. It will return `@"Delete"` in our specific example. This looks like a perfect argument for `NSLocalizedString`:

    @implementation LocalizeMustacheHelper
    + (NSString *)localizeSection:(GRMustacheSection *)section withContext:(id)context
    {
        return NSLocalizedString(section.templateString, nil);
    }
    @end
 
 So far, so good, this works as expected.
 
 #### Rendering the inner content
 
 Yet the application keeps on evolving, and now comes this new template snippets:
 
    {{#buttons}}
        <a href="{{url}}">{{#localize}}{{name}}{{/localize}}</a>
    {{/buttons}}
 
 We still have to localize strings, but those strings now come from button objects, not from the template itself.
 
 Our first `LocalizeMustacheHelper` implementation will call `NSLocalizedString` on `@"{{name}}"`, not on the buttons' names, and will fail.
 
 This is because we now need to provide to `NSLocalizedString` the mustache rendering of the inner content, not the raw inner content.
 
 Fortunately, we have:
 
 - the _context_ parameter, which is the current rendering context, containing a button, a button collection, and any surrouding objects.
 - the renderObject: method of `GRMustacheSection`, which renders the content of the receiver with the provided object. 
 
 Now we can fix our implementation:
 
    @implementation LocalizeMustacheHelper
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
 
 Let's now render, with two objects: our `LocalizeMustacheHelper` class that will provide the `localize` lambda, and `self` that will provide the `cart`:
 
    [template renderObjects:[LocalizeMustacheHelper class], self, nil];
 
 @since v1.3
 */
@interface GRMustacheSection: NSObject {
@private
	NSString *name;
	NSString *baseTemplateString;
    NSRange range;
	BOOL inverted;
	NSArray *elems;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the raw inner content
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the raw inner content of the section, with unprocessed mustache `{{tags}}`.
 
 @since v1.3
 */
@property (nonatomic, readonly) NSString *templateString AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Rendering the inner content
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Renders the inner content of the receiver with a context object.
 
 @return A string containing the rendered inner content.
 @param object A context object used for interpreting Mustache tags.
 
 @since v1.3
 */
- (NSString *)renderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER;

/**
 Renders the inner content of the receiver with a context objects.
 
 @return A string containing the rendered inner content.
 @param object, ... A comma-separated list of objects used for interpreting Mustache tags, ending with nil.
 
 @since v1.5
 */
- (NSString *)renderObjects:(id)object, ... AVAILABLE_GRMUSTACHE_VERSION_1_5_AND_LATER;

@end
