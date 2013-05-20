[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)

Patterns For Feeding GRMustache Templates
=========================================

You'll learn here a few practical techniques for feeding your templates. The loading of templates is covered in the [Templates Guide](templates.md). The [Runtime Guide](runtime.md) covers how GRMustache processes your data.

Summary
-------

**Rendering your raw model objects is fine.**

Objective-C categories, GRMustache filters and [rendering objects](rendering_objects.md) (not covered here but quite useful as well) are there to help you render complex graphs of model objects.

GRMustache ships with [sample code](../../../tree/master/Guides/sample_code) that covers common developer needs. Don't miss them, and run the sample projects.

**Ambitious templates may need ViewModel objects.**

When templates render data that can not be extracted from the model in a straightforward manner, ViewModel objects will act as a clean interface, keeping your application modular and testable.


Rendering raw application models
--------------------------------

If you are lucky, your templates can render your models directly. Given the following template:

    {{< page }}
    {{$ page_content }}
        <h1>{{firstName}} {{lastName}}</h1>
        <ul>
        {{# pets }}
            <li>{{name}}</li>
        {{/ pets }}
        </ul>
    {{/ page_content }}
    {{/ page }}

It's likely that your `User` class has the `firstName`, `lastName` and `pets` properties, and that the Pet class has its `name` property. The rendering is as simple as:

```objc
[self.template renderObject:user error:NULL];
```

(side note: this template uses a common `page` layout partial. Check the [Partials Guide](partials.md) for more information.)

On the edge of the trivial zone
-------------------------------

Now the template should render the age of each pet:

    ...
    {{# pets }}
        <li>{{name}}, {{age}} year(s)</li>
    {{/ pets }}
    ...

Of course, your Pet class has no `age` property.

Instead it has a `birthDate` property or type NSDate, or even maybe a `birthDateComponents` property of type NSDateComponents, which can't be messed up with any time zone.

How should we feed this `{{age}}` tag?

We'll see several options below. Each one has its advantages, and its drawbacks. The goal of this guide is to show that GRMustache supports many patterns. So let's start the journey.

Ad-Hoc Properties
-----------------

Quickly done, quite efficient, is the technique that adds an `age` property to the Pet class.

**Ad-Hoc Properties Benefits**: Done in five minutes, mostly spent in Xcode user interface.

**Ad-Hoc Properties Drawbacks**: The Pet class now has a property dedicated to a Mustache template it should know nothing about: the separation of concerns advocated by MVC has been trampled over.

If hell doesn't burn too much, here is how you could do it:

`Pet+GRMustache.h`

```objc
#import "Pet.h"

// Category on Pet dedicated to Mustache rendering.
@interface Pet(GRMustache)
@property (nonatomic, readonly) NSInteger age;
@end
```

`Pet+GRMustache.m`

```objc
#import "Pet+GRMustache.h"
@implementation Pet(GRMustache)
- (NSInteger)age
{
    return /* clever calculation based on self.birthDate */;
}
@end
```

The rendering code still reads:

```objc
[self.template renderObject:user error:NULL];
```

Dedicated ViewModel class
-------------------------

Many Mustache libraries let you create a dedicated class that defines template-specific keys. Those classes are called "View Models".

In [Ruby Mustache](https://github.com/defunkt/mustache), for instance, we would write:

```ruby
# Dedicated ViewModel subclass
class Document < Mustache
  attr_accessor :firstName
  attr_accessor :lastName
  attr_accessor :pets
  def age
    # Assume the key `birthDate` is defined somewhere in the context stack, and
    # return clever computation based on self[:birthDate]
  end
end

# Render
document = Document.new
document.firstName = ...
document.render
```

GRMustache let you do the same, by subclassing the GRMustacheContext class:

```objc
@interface Document : GRMustacheContext
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSArray *pets;
@end

@implementation Document
@dynamic firstName, lastName, pets;

- (NSInteger)age
{
    // When this method is invoked, the {{ age }} tag is being rendered.
    //
    // Since we are inside the {{# pets }}...{{/ pets }} section, each pet
    // on its turn gets at the top of the context stack. If we look for the
    // `birthDate` key, we'll get the current pet's one:
    
    NSDate *birthDate = [self valueForMustacheKey:@"birthDate"];
    return /* clever calculation based on birthDate */;
}
@end
```

**NB**: The custom properties are declared `@dynamic`. This is required by GRMustache. Check the [ViewModel Guide](view_model.md) for more information.

The rendering is straightforward:

```objc
Document *document = [[Document alloc] init];
document.firstName = ...;
[self.template renderObject:document error:NULL];
```

**ViewModel Benefits**: Conceptually clean, model objects remain pristine, good base for testing, compatible with most other Mustache implementations.

**ViewModel Drawbacks**: The ViewModel implementation is very tied to the template content and the structure of provided data. For instance, the `age` key is forever bound to the `birthDate` key. This may make it difficult to make the template evolve.


Filters
-------

GRMustache [filters](filters.md) are a nice way to transform data.

Below is our template rewritten with filters.

    ...
    {{# pets }}
        <li>{{name}}, {{ age(birthDate) }} year(s)</li>
    {{/ pets }}
    ...

The rendering code now reads:

```objc
// Prepare template filters
id filters = @{
    @"age": [GRMustacheFilter filterWithBlock:^id(NSDate* date) {
        return /* clever calculation based on the date */;
    }]
};

// Render user with filters
[self.template renderObjectsFromArray:@[filters, user] error:NULL];
```

**Filter Benefits**: Done in five minutes. Conceptually clean, model objects remain pristine. Filters are reusable.

**Filter Drawbacks**: The template is not compatible with other Mustache implementations, because filters are a GRMustache-specific addition. Help developers of other platforms: [spread the good news](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations)!


### Private and future-proof filters

You may want to "hide" the `age` filter in your template. This is the case, for example, when the template is shared between several objects, and that you don't want them to take care of feeding the template with filters.

This is how it can be done:

```objc
// Extend the base context of our template, so that the `age` filter is
// always available:
id filters = @{
    @"age": [GRMustacheFilter filterWithBlock:^id(NSDate* date) {
        return /* clever calculation based on the date */;
    }]
};
self.template.baseContext = [self.template.baseContext contextByAddingProtectedObject:filters];

// Render some users
[self.template renderObject:user1 error:NULL];
[self.template renderObject:user2 error:NULL];
```

The base context of a template provides keys that are always available for the template rendering. It contains all the ready for use tools of the [standard library](standard_library.md), for example, and now our `age` filter.

Here we have added the `age` filter as a *protected* object. This means that GRMustache will always resolve the `age` identifier to our filter. This makes our template future-proof: if the Pet class eventually gets an `age` property, the template will not suddenly resolve `age` as a number, which could not be used to compute the `age(birthDate)` expression.

Contexts are detailed in the [Rendering Objects](rendering_objects.md) and [Protected Contexts](protected_contexts) Guides.


[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)
