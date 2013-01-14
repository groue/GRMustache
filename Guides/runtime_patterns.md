Patterns for feeding GRMustache
===============================

GRMustache is a Mustache engine, with a few extra features, and a strong focus on flexibility. A template engine is a tool: it should help you having the job done, without falling short right at the moment your application leaves the trivial zone.

This guide describes a few usage patterns.

Rendering raw application models
--------------------------------

Quite often, your templates can render your models directly. Given the following template:

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
[self.template renderObject:self.user error:NULL];
```

(side note: this template uses a common `page` layout partial. Check the [Partials Guide](partials.md) for more information.)

Leaving the trivial zone
------------------------

Now the template should render the pets' age:

    ...
    {{# pets }}
        <li>{{name}}, {{age}}</li>
    {{/ pets }}
    ...

Of course, your Pet class has no `age` property.

Instead it has a `birthDate` or type NSDate, or even maybe a `birthDateComponents` of type NSDateComponents, which can't be messed up with any time zone.

How should we feed this `{{age}}` tag?

We'll see several options below. Each one has its advantages, and its drawbacks. The goal of this guide is to show that GRMustache supports many patterns. So let's start the journey.

### Ad-Hoc Properties

Quickly done, quite efficient, is the technique that adds an `age` property to the Pet class.

**Ad-Hoc Properties Benefits**: Done in five minutes.

**Ad-Hoc Properties Drawbacks**: The template can not be tested without a full-blown Person and Pet object graph. The Pet class now has a property dedicated to a Mustache template it should know nothing about, the separation of concerns advocated by MVC has been trampled over.

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
    [self.template renderObject:self.user error:NULL];
```

### Filters

If the dedicated property doesn't fit your coding standards, let us introduce GRMustache [filters](filters.md). Filters are a nice way to transform data. They do not cross the MVC barriers, and the Pet class can remain pristine.

Obviously, if the Pet class doesn't help, the template has to help itself: below is our template rewritten with filters.

    ...
    {{# pets }}
        <li>{{name}}, {{ age(birthDate) }}</li>
    {{/ pets }}
    ...

.

The rendering code now reads:

```objc
// Prepare template filters
id filters = @{
    @"age": [GRMustacheFilter filterWithBlock:^id(NSDate* date) {
        return /* clever calculation based on the date */;
    }]
};

[self.template renderObjectsFromArray:@[filters, self.user] error:NULL];
```

**Filter Benefits**: Done in five minutes. Conceptually clean.

**Filter Drawbacks**: The template can not be tested without a full-blown Person and Pet object graph. The template is not compatible with other Mustache implementations, because filters are a GRMustache-specific addition. Help developers of other platforms: [spread the good news](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations)!


### ViewModel

This technique is compatible with other Mustache implementations. It is also more verbose. And heartfully supported by GRMustache.

You setup *ViewModel* objects that fit our particular template, and gets rendered by GRMustache instead of the raw model.

The role of those ViewModel objects is to encapsulate the template interface, the set of Mustache tags that should be fed, and to translate raw model values into values that get rendered.

This ViewModel can be a set of classes, or a dedicated dictionary built by some specific method. Let's look at how it can be done with whole classes.

`PersonMustache.h`

```objc
@class Person;

// The PersonMustache class is dedicated at feeding the person-related tags
// of a Mustache template with person-related data.
@interface PersonMustache:NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSArray *pets;    // array of PetMustache objects

// Convenience method for filling a PersonMustache object from a Person.
- (void)updateFromPerson:(Person *)person;

@end
```

`PetMustache.h`

```objc
@class Pet;

// The PetMustache class is dedicated at feeding the pet-related tags
// of a Mustache template with pet-related data.
@interface PetMustache:NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger age;

// Convenience method for filling a PetMustache object from a Pet.
- (void)updateFromPet:(Pet *)pet;

@end
```

`PersonMustache.m`

```objc
#import "PersonMustache.h"
#import "PetMustache.h"
#import "Person.h"

@implementation PersonMustache

- (void)updateFromPerson:(Person *)person
{
    self.firstName = person.firstName;
    self.lastName = person.lastName;
    self.pets = [NSMutableArray array];
    for (Pet *pet in person.pets) {
        PetMustache *petMustache = [PetMustache new];
        [petMustache updateFromPet:pet];
        [self.pets addObject:petMustache];
    }
}

@end
```

`PetMustache.m`

```objc
#import "PetMustache.h"
#import "Pet.h"

@implementation PetMustache

- (void)updateFromPet:(Pet *)pet
{
    self.name = pet.name;
    self.age = /* clever calculation based on pet.birthDate */;
}

@end
```

Rendering code:

```objc
PersonMustache *personMustache = [PersonMustache new];
[personMustache updateFromPerson:self.user];
[self.template renderObject:personMustache error:NULL];
```

Of course, it's hard to believe that a simple `{{age}}` tag can have you write so much code. Well, this guide is not here to judge. It's here to show you a few techniques for rendering your data.

**ViewModel Benefits**: The template can be tested without creating a full graph of person and pets.

**ViewModel Drawbacks**: Not done in five minutes. May look overdesigned.

