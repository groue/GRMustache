[up](../../../../GRMustache#documentation), [next](template_repositories.md)

Patterns For Feeding GRMustache Templates
=========================================

ViewModel Objects
-----------------

GRMustache fetches values with the [keyed subscripting](http://clang.llvm.org/docs/ObjectiveCLiterals.html#dictionary-style-subscripting) `objectForKeyedSubscript:` method and the [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) `valueForKey:` method. Any compliant object can provide values to templates. Dictionaries are, and generally all your objects (see the [Runtime Guide](runtime.md) for more information):

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];

// Arthur
[template renderObject:@{ @"name": @"Arthur" } error:NULL];

// Bernard
[template renderObject:[Person personWithName:@"Bernard"] error:NULL];
```

The rendered object is sometimes called, in the Mustache lingo, a *ViewModel*.

This is because its methods and properties define an interface to the template to be rendered. It's a model of the template, just as your Person class is a model of an actual person. A method or key `name` matches a `{{ name }}` tag just as it matches a person's name. And because a template belongs to the View realm, we eventually settle on the "ViewModel" name.


Custom ViewModel Classes
------------------------

In practice, the ViewModel concept is pretty fuzzy. It's very common to reuse an existing class, such as an all too plain Controller or Model object, as the ViewModel of a template. The controller or the model object has not been particularly designed to fit a template. Rather you write the template with carefully chosen keys that match your object's method.

However, templates sometimes need some very specific data that are uneasy to fit in those objects:

- values derived from others, such as formatted numbers and dates, or custom properties.
- default values when one is missing.

A dedicated ViewModel class eventually comes to the mind. For example, consider the following template:

`Document.mustache`

    {{# user }}
        {{ name }} ({{ age }})
        Member since {{ fullDateFormat(joinDate) }}
    {{/ user }}

Let's design a custom ViewModel for it.

`Document.h`

```objc
/**
 * The Document class is the interface to the Document.mustache template.
 *
 * Declare properties for all the keys used from the template, so that
 * GRMustache can access them.
 */
@interface Document : NSObject
@property (nonatomic, strong) User *user;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger age;
@property (nonatomic, readonly) NSDateFormatter *fullDateFormat;
@end
```

`Document.m`

```objc
@implementation Document

// Some users don't have any name.
// Provides a default name for those anonymous users.
- (NSString *)name
{
    return @"Anonymous";
}

// The User class does not have any `age` property.
// Instead, it defines a `birthDate` property.
- (NSUInteger)age
{
    NSDate *birthDate = self.user.birthDate;
    return /* clever computation based on user's birth date */;
}

// The `fullDateFormat` filter.
- (NSDateFormatter *)fullDateFormat
{
    NSDateFormatter *fullDateFormat = [[NSDateFormatter alloc] init];
    fullDateFormat.dateStyle = NSDateFormatterLongStyle;
    return fullDateFormat;
}

@end
```

(Check the [NSFormatter Guide](NSFormatter.md) about formatting abilities of NSFormatter classes.)

The rendering:

```objc
// Load Document.mustache
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];

// Initialize Document object
Document *document = [[Document alloc] init];
document.user = self.user;

// Render
NSString *rendering = [template renderObject:document error:NULL];
```


Default values
--------------

When you know the name of the key you want to provide a default value to, just implement a property with the same name in your ViewModel object.

For exemple, let's provide a default name for the following template, which render some users' names:

`Document.mustache`

    {{# users }}
        - {{ name }}
    {{/ users }}

```objc
@interface Document : NSObject
// Declare properties for all the keys used from the template, so that
// GRMustache can access them.
@property (nonatomic, readonly) NSString *name;
@property (nonatomic) NSArray *users;
@end

@implementation Document

// Provides a default name
- (NSString *)name
{
    return @"Anonymous";
}

@end

// Initialize Document object
Document *document = [[Document alloc] init];
document.users = ...;

// Render
NSString *rendering = [template renderObject:document error:NULL];
```

The Document class will provide the default `Anonymous` name because Mustache rendering looks for an object in the current [context stack](runtime.md#the-context-stack) for the first one providing the required key. If a user has no name, GRMustache will dig in the context stack, and eventually find the root Document object, which will provide the name.

**Warning**: A `{{ user.name }}` tag would not trigger the `name` property of the Document object. Instead, the `name` key would be fetched right from the very object given for `user`, even if user is nil or has no name. That is the behavior of Mustache compound expressions.

In order to provide a default value for all expressions that feed Mustache tags, `{{ name }}`, `{{ user.name }}`, `{{ format(last(events).date) }}`, etc., you need to implement the `GRMustacheTagDelegate` protocol. Go check the [Tag Delegates Guide](delegate.md#default-values).

Providing a default value for unknown keys also requires using the `GRMustacheTagDelegate` protocol. This is because GRMustache would not, for security reasons, render values for non-declared properties.

Check the [Runtime](Guides/runtime.md), [Security](Guides/security.md#safe-key-access) and [Tag Delegates](delegate.md#default-values) Guides for more information.


Compatibility with other Mustache implementations
-------------------------------------------------

[Many Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) foster the ViewModel concept, and encourage you to write your custom subclasses.

By subclassing GRMustacheContext, you'll get a behavior that is as close as possible to the [canonical Ruby implementation](https://github.com/defunkt/mustache).

However, this topic is not mentioned in the [Mustache specification](https://github.com/mustache/spec).

**If your goal is to design ViewModels that remain compatible with other Mustache implementations, check their documentation.**


[up](../../../../GRMustache#documentation), [next](template_repositories.md)
