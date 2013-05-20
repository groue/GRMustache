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

@implementation Document
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

// When rendering the `{{# user }}{{ name }}{{/ user }}` section, a new context
// is derived from document, with the user at the top of the context stack:
Document *innerContext = [document contextByAddingObject:document.user];

// Direct access to the `name` method returns "DefaultName".
innerContext.name;

// "Dimitri", because `{{ name }}` would render the name of the user at the top
// of the context stack: Dimitri.
[innerContext valueForKey:@"name"];
```

**Ouch**. `innerContext.name` and `[innerContext valueForKey:@"name"]` are inconsistent. This object has a really weird relationship to KVC...

Is is so bad?

- "The code above, that exhibits the inconsistency between `innerContext.name` and `[innerContext valueForKey:@"name"]`, is rather contrieved. No library user would ever find himself in such a situation. It just looks that you complain about a bug in the internal guts of your library. Who cares, as long as everyday code just works?"

    Yes, the `contextByAddingObject:` method that derives new contexts and is able to generate funny objects is not used very often by the end user.
    
    But it is in the API for a reason. You'll see it in the [Collection Indexes Sample Code](sample_code/indexes.md). "Rare" does not mean "contrieved". Some users will get funny objects such as `innerContext` above. Among them, some users will get bitten by the inconsistency.

- "OK. But it could be made acceptable through explanation and documentation. NSDictionary, NSArray are examples of classes that have funny implementations of `valueForKey:`."

    Yes, but NSDictionary and NSArray are used everyday. Mustache templates are not.
    
    I can't expect users to find, read, learn and remember the funny rules of ViewModels regarding KVC. I can't expect users to blame themselves when their program has a bug because of an object such as `innerContext` above exhibits its funny behavior. For them it would just be a bug in GRMustache.

That's why the hypothetic case C was ditched for good, and why GRMustache does not override `valueForKey:`, and exposes `valueForMustacheKey:` instead.
