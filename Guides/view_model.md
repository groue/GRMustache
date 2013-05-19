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

The Document class above is a GRMustacheContext subclass. As such, it can define its own configuration API, and provide its own keys to templates:

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

Note that the `bodyColor` property is declared `@dynamic`.


### Dynamic Properties, Key-Value Coding, and the Context Stack

GRMustacheContext synthesize accessors for the properties that you declare `@dynamic`.

Those accessors give them direct access to the [rendering context stack](runtime.md#the-context-stack). The storage of those properties *is* the context stack.

Generally speaking, when a GRMustacheContext object, or an instance of a subclass, is asked for the value that should render for `{{ name }}`, it renders the value returned by `[document valueForKey:@"name"]`.

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


### Round Up

For instance, consider the following template snippet, and ViewModel:

    ...
    {{# user }}{{ age }}{{/ user }}                         // (1) (2)
    ...

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;                   // (1)
@end

@implementation Document
@dynamic user;                                              // (1)

- (NSInteger)age                                            // (2)
{
    // When this method is invoked, the {{ age }} tag is being rendered.
    //
    // Since we are inside the {{# user }}...{{/ user }} section, the user
    // object is at the top of the context stack. If we look for the
    // `birthDate` key, we'll get the user's one:
    
    NSDate *birthDate = [self valueForKey:@"birthDate"];    // (2)
    return /* clever calculation based on birthDate */;
}

@end

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
Document *document = [[Document alloc] init];
document.user = ...;                                         // (1)
[template renderObject:document error:NULL];
```

1. The `user` property matches the name of the `{{# user }}` section. Thanks to it @dynamic declaration, the user given to the document object is transfered to the template, accross the context stack.

2. The `age` method matches the name of the `{{ age }}` tag. It reads the birth date that is available in the current section through the `valueForKey:` method.

[up](../../../../GRMustache#documentation), [next](configuration.md)
