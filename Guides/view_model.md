[up](../../../../GRMustache#documentation), [next](configuration.md)

Patterns For Feeding GRMustache Templates
=========================================

ViewModels
----------

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

A genuine ViewModel class eventually comes to the mind. For example, consider the following template:

`Document.mustache`

    {{# user }}
        {{ name }} ({{ age }})
        Member since {{ fullDateFormat(joinDate) }}
    {{/ user }}

Let's design a custom ViewModel for it:

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
- (NSString *)rendering
{
    // Load Document.mustache
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Document" bundle:nil error:NULL];
    
    // Initialize Document object
    Document *document = [[Document alloc] init];
    document.user = self.user;
    
    // Render
    return [template renderObject:document error:NULL];
}
```

### Default values

The `name` method above would provide a default value for the `name` key only.

Override `valueForUndefinedKey:` when you want to provide a default value for any key.

`Document.m`

```objc
@implementation Document

- (id)valueForUndefinedKey:(NSString *)key
{
    return [NSString stringWithFormat:@"<default %@>", key];
}

@end
```

Note that a `{{ user.name }}` tag would not trigger the `name`, nor the `valueForUndefinedKey:` method, even if the user have no name. The GRMustache [runtime](Runtime.md) would extract the `name` key right from the very object given for `user`. That is the behavior of compound expressions.

If you want to provide a default value for all expressions that feed Mustache tags, `{{ name }}`, `{{ user.name }}`, `{{ format(last(events).date) }}`, etc., you need the GRMustacheTagDelegate protocol. Go check the [Tag Delegates Guide](delegate.md#default-values).

Subclasses of GRMustacheContext
-------------------------------

The Document class above was a plain subclass of NSObject.

You may also subclass `GRMustacheContext`, and be granted more access to the context stack.

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

See the [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of the GRMustacheContext class.


### Managed properties

When implementing a GRMustacheContext subclass, the properties that are available to the templates, such as the `user` property above, **must** be declared as @dynamic.

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

By subclassing GRMustacheContext, you'll get a behavior that is as close as possible to the [canonical Ruby implementation](https://github.com/defunkt/mustache).

However, this topic is not mentioned in the [Mustache specification](https://github.com/mustache/spec).

**If your goal is to design ViewModels that remain compatible with other Mustache implementations, check their documentation.**


[up](../../../../GRMustache#documentation), [next](configuration.md)
