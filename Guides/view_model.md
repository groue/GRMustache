[up](../../../../GRMustache#documentation), [next](configuration.md)

ViewModel Classes
=================

Mustache rendering lies on the "View" side of the Model-View-Controller pattern. Templates often require specific keys to be defined, and those keys do not belong to any of your model or controller classes.

For instance, a template needs to be given a `cssBodyColor`, so that it can render `body { background-color: {{ cssBodyColor }}; }`.

A very simple way to achieve this goal is to provide the `cssBodyColor` in a dictionary:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
id data = @{
    @"cssBodyColor": @"#ff0000",
    ...
};
[template renderObject:data error:NULL];
```

However, this may get tedious after a while. The number of specific keys can get very big. Without compiler support, you may do typos in the key names, leading to unexpected renderings. And since there is no easy way to define high-level accessors for those specific keys, you often end up preparing raw HTML snippets right in your controller, when obviously this should be done in some View class.

Wouldn't it be great if we could write instead:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
Document *document = [[Document alloc] init];
document.bodyColor = [UIColor redColor];
...
[template renderObject:document error:NULL];
```

This Document class would be defined as below:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) UIColor *bodyColor;
@end

@implementation Document
@dynamic bodyColor;     // more on that below

- (NSString *)cssBodyColor
{
    return /* clever computation based on self.bodyColor */;
}

@end
```


ViewModels are Subclasses of GRMustacheContext
----------------------------------------------

The ViewModel Document class above is a GRMustacheContext subclass.

As such:

- All its methods are available to templates.
- It can peek at the [context stack](runtime.md#the-context-stack), and compute values derived from other objects available to the template
- It can define custom properties for injecting values into the templates, and reading from them.


### Peeking at the Context Stack

GRMustacheContext provides two methods for fetching values from the [context stack](runtime.md#the-context-stack): `valueForMustacheKey:` and `valueForMustacheExpression:error:`.

`valueForMustacheKey:` returns the value that would be rendered by a tag containing a single identifier: `[context valueForMustacheKey:@"name"]` returns the value that would be rendered by the `{{ name }}` tag. It looks in the context stack for an object that provides the given key, and returns this value. It returns nil if the key could not be resolved.

You may also need to fetch the value of more complex Mustache expressions such as `user.name` or `uppercase(user.name)`. This is the job of the `valueForMustacheExpression:error:` method.

For example:

```objc
@interface Document : GRMustacheContext
@end

@implementation Document

// {{ capitalizedName1 }} should render the capitalized version of the name
// that would render for {{ name }}.
- (NSString *)capitalizedName1
{
    return [[self valueForMustacheKey:@"name"] capitalizedString];
}

// {{ capitalizedName2 }} should render the capitalized version of the name
// that would render for {{ name }}.
- (NSString *)capitalizedName2
{
    return [self valueForMustacheExpression:@"uppercase(name)" error:NULL];
}

@end
```

(The `uppercase` filter is part of the [Standard Library](standard_library.md)).

`valueForMustacheExpression:error:` may return parse errors (for invalid expressions), or filter errors (missing or invalid filter). Error handling follows [Cocoa conventions](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/CreateCustomizeNSError/CreateCustomizeNSError.html). Especially:

> Success or failure is indicated by the return value of the method. [...] You should always check that the return value is nil or NO before attempting to do anything with the NSError object.

See the [Runtime Guide](runtime.md) for more information about the way GRMustache resolves identifiers and expressions.


### Dynamic Properties

GRMustacheContext synthesize accessors for the properties that you declare `@dynamic`.

Those accessors give them direct access to the [rendering context stack](runtime.md#the-context-stack). The storage of those properties *is* the context stack.

Your dynamic properties, such as `document.name`, return the value that should render for `{{ name }}`. They have the same value as `[document valueForMustacheKey:@"name"]`.

When you set the value of a read/write property, that value becomes available for `{{ name }}` tags in templates. This value is inherited by derived contexts as Mustache sections are rendered. It is overriden as soon as a section renders an object that redefines this key:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *name;
@end

@implementation Document
@dynamic user;
@dynamic name;
@end

Document *document = [[Document alloc] init];
document.user = [User userWithName:@"Fulgence"];
document.name = @"DefaultName";

// Render {{ name }}, {{# user }}{{ name }}{{/ user }}
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{ name }}, {{# user }}{{ name }}{{/ user }}" error:NULL];

// Returns "DefaultName, Fulgence"
[template renderObject:document error:NULL];
```

See how the user name sneaks in, as soon as the user enters the top of the context stack, inside the `{{# user }}...{{/ user }}` section.


A note about Key-Value Coding
-----------------------------

GRMustache does not mess with Key-Value Coding, and leaves `valueForKey:` untouched.

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
