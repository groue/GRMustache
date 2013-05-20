ViewModels vs. Key-Value Coding
===============================

The GRMustacheContext and your ViewModel subclasses do not change the semantics of Key-Value Coding methods such as `valueForKey:`, `valueForKeyPath:`, and `setValue:forKey:`.

In some cases those methods do not have the same result as `valueForMustacheKey:` and `valueForMustacheExpression:error:`. We'll see how below.

**The rule of thumb** is simple: to get the value that would be rendered by a tag `{{ ... }}`, use `valueForMustacheKey:` and `valueForMustacheExpression:error:`.

Why did GRMustache introduce `valueForMustacheKey:`? Why didn't it just make `valueForKey:` work?

Let's look at the undesired situations that would emerge in three hypothetic cases:

- A: `valueForKey:` is not overriden, and `valueForMustacheKey:` would not exist in the API.
- B: `valueForKey:` is overriden: it returns sometimes the result of `valueForMustacheKey:`, sometimes some other value.
- C: `valueForKey:` is overriden: it always returns the result of `valueForMustacheKey:`

Case A is easily dismissed, because there would be no API for looking up the context stack. And I want to provide such an API: good bye, case A.

Case B is easily dismissed, because it is unreliable. Only users who find, read, learn and remember their manual would know what value they would get. This is not what I call a nice API: so long, case B.

Case C is not easily dismissed. We'll see how below.

Eventually, we had to leave `valueForKey:` untouched, and to introduce `valueForMustacheKey:`.


### The difference between the context stack and KVC

Here is a ViewModel that exhibits how Mustache and KVC may differ, and how and why GRMustache "does not change the semantics of Key-Value Coding".

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

*This was the description of the implemented behavior.*

Let's now evaluate our hypothetic case C: `valueForKey:` is overriden in order to return the result of `valueForMustacheKey:`.

`[document valueForKey:@"missing"]` would return nil. Actually this would be OK, since the documentation would state that `[context valueForKey:@"missing"]` returns the value that would render for `{{ missing }}`.


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

This means that `valueForMustacheKey:@"name"` would return "Cyrille", when `valueForKey:@"name"` would find the `name` method, and return "DefaultName".

*This was the description of the implemented behavior.*

Let's now evaluate our hypothetic case C: `valueForKey:` is overriden in order to return the result of `valueForMustacheKey:`.

```objc
Document *document = [[Document alloc] init];
document.user = [User userWithName:@"Dimitri"];

// Direct access to the `name` method returns "DefaultName".
document.name;

// "DefaultName" again, because `{{ name }}` would render defaultName.
[document valueForKey:@"name"];

// Direct access to the `name` method returns Dimitri.
document.user;

// Dimitri again, because `{{# user }}...{{/ user }}` would place Dimitri
// in the context stack.
[document valueForKey:@"user"];
```

OK, everything is consistent. Still no problem here.


#### Difference 3: non-managed properties

Let's add a regular property to our Document class. A regular one, non dynamic, non managed by GRMustache:

```objc
@interface Document : GRMustacheContext
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) int age;
@end

@implementation
@dynamic user;
// Have the compiler synthesize the `age` property.
@end
```

Why would you add a synthesized property in a ViewModel? I don't know. But why should I prevent you from doing so?

Non-managed properties play oddly with rendering:

```objc
// Render a simple {{# user }}{{ age }}{{/ user }} template
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{# user }}{{ age }}{{/ user }}" error:NULL];

Document *document = [[Document alloc] init];
document.user = [User userWithAge:25];
document.age = 39;

// Renders "25".
NSString *rendering = [template renderObject:document error:NULL];
```

The rendering is "25", and not "39", because the context that renders inside the `{{# user }}{{ age }}{{/ user }}` loads the age from the context stack, and the user is at the top of it.

The context inside the question is derived from the original document:

```objc
Document *innerContext = [document contextByAddingObject:document.user];
```

`innerContext.age` would return 0, because the property is not managed, and is not inherited from parent.

`[innerContext valueForKey:@"age"]` would return 0 as well, because `valueForKey:` would find the age property.

`[innerContext valueForMustacheKey:@"age"]` would return 25, because that is the value that is rendered by the `{{ age }}` tag when the user is at the top of the context stack.

*This was the description of the implemented behavior.*

Let's now evaluate our hypothetic case C: `valueForKey:` is overriden in order to return the result of `valueForMustacheKey:`.

`document.age` would return 25, because `age` is a regular, non-managed, property.

`[document valueForKey:@"age"]` would also return 25, because that is the value that would be rendered by the `{{ age }}` tag.

However,

`innerContext.age` would return 0, because `age` is a regular, non-managed, non-inherited, property.

`[innerContext valueForKey:@"age"]` would return 25, because that is the value that is rendered by the `{{ age }}` tag when the user is at the top of the context stack.

**Ouch**. This object has a really weird relationship to KVC...

Of course, it could be made acceptable through explanation and documentation. NSDictionary, NSArray are examples of classes that have funny implementations of `valueForKey:`.

But NSDictionary and NSArray are used everyday. Mustache templates are not. I can't expect users to find, read, learn and remember the funny rules of ViewModels regarding KVC. I can't expect users to blame themselves when their program has a bug because of an object such as `innerContext` above exhibits its funny behavior. For them it would just be a bug in GRMustache.

That's why the hypothetic case C was ditched for good, and why GRMustache does not override `valueForKey:`, and exposes `valueForMustacheKey:` instead.
