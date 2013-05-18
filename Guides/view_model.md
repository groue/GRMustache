[up](../../../../GRMustache#documentation), [next](configuration.md)

ViewModel Classes
=================

Mustache templates rendering belong to the "View" side of the Model-View-Controller pattern. They often requires specific keys to be defined, and those keys do not belong to any of your model or controller classes.

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

However, this may get tedious after a while. The number of specific keys can get very big. Without compiler support, you may do typos in the key names, leading to unexpected renderings. And since there is no easy way to define high-level accessor for those specific keys, you often end up preparing raw HTML snippets right in your controller, when obviously this should be done in some View class.

Wouldn't it be great if we could write instead:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
Document *document = [[Document alloc] init];
document.bodyColor = [UIColor redColor];
...
[template renderObject:document error:NULL];
```


GRMustacheContext subclass
--------------------------

The Document class above is a GRMustacheContext subclass. As such, it can provide its own keys to templates, and also fetch values from the [rendering context stack](runtime.md) (more on that later).

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

### Read only properties

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


### Read/write properties

Read/write properties have constraints:

- They must be declared @dynamic, and you must not provide custom getters and setters. You do not have to release them in your dealloc method.

- Weak properties are not supported at the moment.


[up](../../../../GRMustache#documentation), [next](configuration.md)
