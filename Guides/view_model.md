[up](../../../../GRMustache#documentation), [next](configuration.md)

Patterns For Feeding GRMustache Templates
=========================================

ViewModels
----------

GRMustache fetches values with the [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) `valueForKey:` method. Any compliant object can provide values to templates. Dictionaries are, and generally all your objects (see the [Runtime Guide](runtime.md) for more information):

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

In practice, it's very common to reuse an existing class, such as an all too plain Controller or Model object, as the ViewModel of a template. The controller or the model object has not been particularly designed to fit a template. Rather you write the template with carefully chosen keys that match your object's method.

However, eventually, templates need some very specific data that are uneasy to fit in those objects:

- values derived from others, such as formatted numbers and dates, or custom properties.
- default values when one is missing.

For instance, consider the following template:

`Document.mustache`

    {{# user }}
        {{ name }} ({{ age }})
        Member since {{ fullDateFormat(joinDate) }}
    {{/ user }}

Let's design a custom ViewModel class:

`Document.h`

```objc
// Public interface to the Document.mustache template
@interface Document : NSObject
@property (nonatomic, strong) User *user;   // The rendered user
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
// Instead, they have a `birthDate` property.
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

The rendering:

```objc
- (NSString *)rendering
{
    // Load Document.mustache
    GRMustacheTemplate *template = [GRMsutacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];
    
    // Initialize Document object
    Document *document = [[Document alloc] init];
    document.user = self.user;
    
    // Render
    return [template renderObject:document error:NULL];
}
```

Subclasses of GRMustacheContext
-------------------------------

The Document class above was a plain subclass of NSObject.

You may also subclass `GRMustacheContext`, and have access to a few extra features:

1. more flexibility for computing derived values.
2. default value for any key.
3. easier template debugging.

Let's consider this other template, and see what we can do with GRMustacheContext subclasses.

`Document.mustache`

    {{# user }}
        {{ name }} ({{ age }})
        
        {{ #pets }}
        - {{ name }} ({{ age }})
        {{ /pets }}
    {{/ user }}


### Deriving Values From the Context Stack

The [context stack](runtime.md#the-context-stack) is the stack of objects that are available for providing values to templates.

Inside the `{{# user }}...{{/ user }}` section, the user is at the top of the context stack: he will provide template keys.

Inside the `{{# pets }}...{{/ pets }}` section, which is rendered as many times as the user has pets, each pet on its turn gets at the top of the context stack: it will provide its own keys.

GRMustacheContext subclasses can load values for the context stack. When our previous NSObject-based Document class could only access its user's birth date, a GRMustacheContext subclass can easily load both user's and pets':

`Document.h`

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;   // The current user
@end
```

`Document.m`

```objc
@implementation Document
@dynamic user;      // more on that below

- (NSUInteger)age
{
    // Load current birth date, from user or pet:
    NSDate *birthDate = [self valueForMustacheKey:@"birthDate"];
    return /* clever computation based on the birth date */;
}

@end
```

`valueForMustacheKey:` looks in the context stack for an object that provides the given key, and returns this value. It returns nil if the key could not be resolved. Generally speaking, it returns the value that would be rendered by a tag containing a single identifier: `[context valueForMustacheKey:@"xxx"]` returns the value rendered by `{{ xxx }}`.

You may also need to fetch the value of more complex Mustache expressions such as `user.name` or `uppercase(user.name)`. This is the job of the `valueForMustacheExpression:error:` method.


### Managed properties

When implementing a GRMustacheContext subclass, the properties that are available to the templates, such as the `user` property above, *must* be declared as @dynamic.

Think of Core Data properties: they are also declared @dynamic, because Core Data manages their storage (the underlying database). The same goes for GRMustacheContext properties: their storage is the context stack, and they are managed by GRMustache.

Unlike regular NSObject's synthesized properties, whose value is stable once set, the value of managed properties comes for the context stack, just as the values returned by the `valueForMustacheKey:` method. Any object that comes at the top of the context stack overrides their value, as long as it provides the matching key.

Let's give an example to make this clear, and rewrite the class above by accessing the current `birthDate` through a dynamic property.

This property will return the user's birth date, or a pet's birth date, depending on the moment it is invoked by the GRMustache runtime (inside the `user` section, or inside the `pets` section):

`Document.h`

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;           // The current user
@property (nonatomic, readonly) NSDate *birthDate;  // The current birth date
@end
```

`Document.m`

```objc
@implementation Document
@dynamic user, birthDate;

- (NSUInteger)age
{
    // self.birthDate is the current birth date, loaded
    // from the user, or from a pet.
    return /* clever computation based on the self.birthDate */;
}

@end
```

### Default values for any key

The `valueForUndefinedMustacheKey:` method lets you provide a default value for any key. It is triggered when no object in the context stack would provide a value for a given key.

`Document.m`

```objc
@implementation Document

- (id)valueForUndefinedMustacheKey:(NSString *)key
{
    return [NSString stringWithFormat:@"<default %@>", key];
}

@end
```

### Template debugging

TODO


### A note about Key-Value Coding

GRMustacheContext does not mess with Key-Value Coding, and leaves `valueForKey:` untouched.

**The rule of thumb** is simple: to get the value that would be rendered by a tag `{{ ... }}`, avoid `valueForKey:`, and use `valueForMustacheKey:` or `valueForMustacheExpression:error:`.

Some readers may think:

> Why did he introduce this weird valueForMustacheKey: method? Why didn't he just override valueForKey:? Key-Value Coding is sooo cool, this looks like a missed opportunity.

Well, I have tried, really hard, to inject Mustache into KVC, and throw a nonchalant "just use valueForKey:" is this Guide.

But the [rule of least surprise](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2878339) eventually gets broken. The most daring readers, and the [future me](http://xkcd.com/302/), will be interested in this [detailed rationale](view_model_vs_kvc.md).


Compatibility with other Mustache implementations
-------------------------------------------------

[Many Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) foster the ViewModel concept, and encourage you to write your custom subclasses.

GRMustache implementation follows closely the behavior of the [canonical Ruby implementation](https://github.com/defunkt/mustache).

However, this topic is not mentioned in the [Mustache specification](https://github.com/mustache/spec).

**If your goal is to design ViewModels that remain compatible with other Mustache implementations, check their documentation.**


[up](../../../../GRMustache#documentation), [next](configuration.md)
