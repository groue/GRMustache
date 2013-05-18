[up](../../../../GRMustache#documentation), [next](configuration.md)

ViewModel Classes
=================

Mustache rendering lies on the "View" side of the Model-View-Controller pattern. Templates often require specific keys to be defined, and those keys do not belong to any of your model or controller classes.

For instance, a template needs to be given a `cssBodyColor`, so that it can render `body { background-color: {{ cssBodyColor }}; }`.

A very simple way to achieve this goal is to provide the `cssBodyColor` in a dictionary:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
id data = @{
    @"cssBodyColor" = @"#ff0000",
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


GRMustacheContext Subclasses
----------------------------

The Document class above is a GRMustacheContext subclass. As such, it can provide its own keys to templates, and also fetch values from the [rendering context stack](runtime.md#the-context-stack) (more on that later).

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) UIColor *bodyColor;
@property (nonatomic, readonly) NSString *cssBodyColor;
@end

@implementation Document
@dynamic bodyColor;

- (NSString *)cssBodyColor
{
    return /* clever computation based on self.bodyColor */;
}

@end
```

### Read-Only Properties

Obviously, you write custom getters for read-only properties.

From them, you can read other properties, and also values from the current context stack. For instance, consider the following template snippet:

    {{# user }}{{ age }}{{/ user }}

The user object has no `age` property. Instead, it has a `birthDate`. Well, the ViewModel can access the user's birth date through the `valueForKey:` method:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;
@property (nonatomic, readonly) NSUInteger age;
@end

@implementation Document
@dynamic user;

- (NSInteger)age
{
    // When this method is invoked, the {{ age }} tag is being rendered.
    //
    // Since we are inside the {{# user }}...{{/ user }} section, the user
    // object is at the top of the context stack. If we look for the
    // `birthDate` key, we'll get the user's one:
    
    NSDate *birthDate = [self valueForKey:@"birthDate"];
    return /* clever calculation based on birthDate */;
}

@end

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
Document *document = [[Document alloc] init];
document.user = ...;
[template renderObject:document error:NULL];
```


### Read/Write Properties and Key-Value Coding

Read/write properties have constraints:

- They must be declared @dynamic, and you must not provide custom getters and setters. You do not have to release them in your dealloc method.

- Non-retained (weak, assign, unsafe_unretained) properties are not supported at the moment.

Those properties give direct access to the [rendering context stack](runtime.md#the-context-stack). Their storage *is* the context stack. This is why GRMustache provides custom accessors for them, and doesn't rely on ivars and synthesized accessors.

Generally speaking, when a GRMustacheContext object, or an instance of a subclass, is asked for the value that should render for `{{ name }}`, it renders the value returned by `[context valueForKey:@"name"]`.

Your custom properties, such as `document.name`, return the same value as [document valueForKey:@"name"], the very value that would be rendered for `{{ name }}`. This allows you to reliably implement properties that depend on other values from the context stack (such as the `age` property above).

After you have set a custom property to some value, this value is inherited by derived contexts, and overriden as soon as an object that redefines this key enters the context stack:

```objc
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

[up](../../../../GRMustache#documentation), [next](configuration.md)
