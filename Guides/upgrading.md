GRMustache 7.0 Migration Guide
==============================

New requirements
----------------

GRMustache does no longer support garbage collection.

The last version of the library which supports garbage collection is [GRMustache v6.9.2](https://github.com/groue/GRMustache/tree/v6.9.2).


Safe Key Access
---------------

GRMustache does no longer blindly evaluate `valueForKey:` on your objects.

The default behavior now only fetches keys that are declared as properties (with `@property`), or Core Data attributes (for managed objects).

Consider the following ViewModel class:

```objc
@interface Document: NSObject
@property (nonatomic) User *user;
@end

@implementation Document

- (NSDateFormatter *)dateFormat
{
  return [NSDateFormatter ...];
}

@end
```

You need to add a `dateFormat` property so that this key can be used from your templates:

```objc
@interface Document : NSObject
@property (nonatomic) User *user;
@property (nonatomic, readonly) NSDateFormatter *dateFormat;
@end
```

Without this property, `{{ dateFormat(user.joinDate )}}` would yield a rendering error, due to the missing (unreachable) `dateFormat` filter.


### Customizing key access

You can, if you want, customize the list of safe keys, or restore the previous behavior of the library: see the [Security Guide](Guides/security.md).


### Default values

Should your existing code provide default values for missing keys, please read the updated [View Model Guide](Guides/view_model.md#default-values).


### GRMustacheContext does no longer support subclassing

Previous versions of the library would let you subclass `GRMustacheContext`, and declare properties with direct access to the context stack. This is no longer the case: GRMustacheContext is no longer suitable for subclassing.

Should you rely on this dropped feature, and experiment difficulties migrating to the latest version of the library, please open an issue: we'll fix it together.

Let's give an example, though. The Document class below is derived from GRMustacheContext. It defines an `age` key which renders a value computed from the current context object, a User, or a Pet:

`Document.mustache`

  {{# user }}
    {{ name }} (age {{ age }}) has {{ pets.count }} pets:
    {{# pets }}
    - {{ name }} (age {{ age }})
    {{/ pets }}
  {{/ user }}

`Document.h/m`

```objc
@interface Document : GRMustacheContext
@property (nonatomic) User *user;
@end

@implementation Document
@dynamic user;

- (NSInteger)age
{
    // Age is computed from the current birthdate, which comes from either
    // the current user, or the current pet:
    
    NSDate *birthdate = [self valueForMustacheKey:@"birthdate"];
    return /* clever calculation based on birthdate */;
}

@end
```

Its refactored implementation would look like:

```objc
// It is no more a subclass of GRMustacheContext:
@interface Document : NSObject
@property (nonatomic) User *user;
// It declares properties for keys exposed to the template:
@property (nonatomic, readonly) id age;
@end

@implementation Document
// Properties are no longer dynamic

- (id)age
{
    // Age is computed from the current birthdate, which comes from either
    // the current user, or the current pet.
    //
    // Document has no idea of the current user or pet: we need to return
    // a rendering object. It will be able to look into the context stack
    // when it gets rendered, and compute our age.
    
    return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSDate *birthdate = [context valueForMustacheKey:@"birthdate"];
        NSInteger age =  /* clever calculation based on birthdate */;
        return [NSString stringWithFormat:@"\d", age];
    }];
}

@end
```

