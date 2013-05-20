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


Dynamic Properties of GRMustacheContext Subclasses
--------------------------------------------------

The Document class above is a GRMustacheContext subclass. As such, it can define its own configuration API, and provide its own keys to templates:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) UIColor *bodyColor;
@end

@implementation Document
@dynamic bodyColor;

- (NSString *)cssBodyColor
{
    return /* clever computation based on self.bodyColor */;
}

@end
```

Note that the `bodyColor` property is declared `@dynamic`.


### Dynamic Properties and the Context Stack

GRMustacheContext synthesize accessors for the properties that you declare `@dynamic`.

Those accessors give them direct access to the [rendering context stack](runtime.md#the-context-stack). The storage of those properties *is* the context stack.

Generally speaking, when a GRMustacheContext object, or an instance of a subclass, is asked for the value that should render for `{{ name }}`, it renders the value returned by `[document valueForMustacheKey:@"name"]`.

Your custom properties, such as `document.name`, return the very same value.

After you have set a read/write property to some value, this value is inherited by derived contexts, and overriden as soon as an object that redefines this key enters the context stack:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) NSString *name;
@end

@implementation Document
@dynamic name;
@end

Document *document = [[Document alloc] init];
document.name = @"DefaultName";
document.name; // Returns @"DefaultName"

// A new context is derived when a section gets rendered:
document = [document contextByAddingObject:@{ @"age": @39 }];
document.name; // Returns @"DefaultName" (inherited)

// A new context is again derived when another inner section gets rendered:
document = [document contextByAddingObject:[User userWithName:@"Arthur"]];
document.name; // Returns @"Arthur" (@"DefaultName" has been overriden)
```


### Example

For instance, consider the following template snippet, and ViewModel:

    ...
    {{# user }}{{ age }}{{/ user }}                                // (1) (2)
    ...

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;                          // (1)
@end

@implementation Document
@dynamic user;                                                     // (1)

- (NSInteger)age                                                   // (2)
{
    // When this method is invoked, the {{ age }} tag is being rendered.
    //
    // Since we are inside the {{# user }}...{{/ user }} section, the user
    // object is at the top of the context stack. If we look for the
    // `birthDate` key, we'll get the user's one:
    
    NSDate *birthDate = [self valueForMustacheKey:@"birthDate"];    // (2)
    return /* clever calculation based on birthDate */;
}

@end

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
Document *document = [[Document alloc] init];
document.user = ...;                                                // (1)
[template renderObject:document error:NULL];
```

1. The `user` property matches the name of the `{{# user }}` section. Thanks to it @dynamic declaration, the user given to the document object is transfered to the template, accross the context stack.

2. The `age` method matches the name of the `{{ age }}` tag. It reads the birth date that is available in the current section through the `valueForMustacheKey:` method.


Mustache Expressions
--------------------

When the `valueForMustacheKey:` method is able to evaluate a simple key, you may need to fetch the value of more complex Mustache expressions such as `user.name` or `uppercase(user.name)`.

Use `valueForMustacheExpression:error:`:

```objc
GRMustacheContext *context = [GRMustacheContext contextWithObject:[GRMustache standardLibrary]];
context = [context contextByAddingObject:[User userWithName:@"Benoît"]];

// Returns BENOÎT
id value = [context valueForMustacheExpression:@"uppercase(name)" error:NULL];
```

Error handling follows [Cocoa conventions](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/CreateCustomizeNSError/CreateCustomizeNSError.html). Especially:

> Success or failure is indicated by the return value of the method. [...] You should always check that the return value is nil or NO before attempting to do anything with the NSError object.

Possible errors are parse errors (for invalid expressions), or filter errors (missing or invalid filter).


Mustache Keys and Expressions vs. Key-Value Coding
--------------------------------------------------

The GRMustacheContext and your ViewModel subclasses do not change the semantics of Key-Value Coding methods such as `valueForKey:`, `valueForKeyPath:`, and `setValue:forKey:`.

In some cases those methods do not have the same result as `valueForMustacheKey:` and `valueForMustacheExpression:error:`. We'll see how below.

**The rule of thumb** is simple: to get the value that would be rendered by a tag `{{ ... }}`, use `valueForMustacheKey:` and `valueForMustacheExpression:error:`.

### The difference between the context stack and KVC

Here is a ViewModel that exhibits how Mustache and KVC may differ, and how GRMustache "does not change the semantics of Key-Value Coding".

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;
@end

@implementation
@dynamic user;

- (NSString *)name {
    return @"DefaultName";
}
@end
```

Quite a simple ViewModel. It provides templates with a user through its dynamic property. It also provides a default value for the `name` key.


#### Difference 1: Behavior regarding missing keys

An unknown key would have KVC methods raise exception, while Mustache accessors simply return nil:

```objc
Document *document = [[Document alloc] init];
[document valueForMustacheKey:@"missing"];      // Returns nil
[document valueForKey:@"missing"];              // Raises a regular KVC exception
```


#### Difference 2: Behavior regarding keys defined by objects entering the context stack

The exhibition of the second difference needs some setup. Please follow us:

Known keys such as `name`, here made available by the `name` method, are available for templates:

```objc
// Render a simple {{ name }} template
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{ name }}" error:NULL];
Document *document = [[Document alloc] init];

// Renders "DefaultName"
NSString *rendering = [template renderObject:document error:NULL];
```

So far, so good.

Now, objects that enter the context stack override keys. That's the whole point of Mustache, after all:

```objc
// Render {{# user }}{{ name }}{{/ user }}
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{# user }}{{ name }}{{/ user }}" error:NULL];
Document *document = [[Document alloc] init];
document.user = [User userWithName:@"Cyrille"];

// Renders "Cyrille"
NSString *rendering = [template renderObject:document error:NULL];
```

The rendering is "Cyrille", because the `name` key was provided by the user. The `name` method of the Document object has not been called.

This means that `valueForMustacheKey:@"name"` would return "Cyrille", when `valueForKey:@"name"` would return "DefaultName".

So, remember: to get the value that would be rendered by a tag `{{ ... }}`, use `valueForMustacheKey:` and `valueForMustacheExpression:error:`.


Compatibility with other Mustache implementations
-------------------------------------------------

[Many Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) foster the ViewModel concept, and encourage you to write your custom subclasses.

However, this topic is not mentioned in the [Mustache specification](https://github.com/mustache/spec).

**If your goal is to design ViewModels that remain compatible with other Mustache implementations, check their documentation.**


[up](../../../../GRMustache#documentation), [next](configuration.md)
