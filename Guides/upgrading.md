GRMustache 7.0 Migration Guide
==============================

GRMustache 7.0 introduces several changes to the previous release, focusing on security, compatibility with other Mustache implementations, and API simplification. Those changes may break your existing applications.

This guide is provided in order to ease your transition to GRMustache 7.0:

- [New requirements](#new-requirements)
- [Safe Key Access](#safe-key-access)
- [Default values](#default-values)
- [GRMustacheContext does no longer support subclassing](#grmustachecontext-does-no-longer-support-subclassing)
- [Template Inheritance](#template-inheritance)


New requirements
----------------

GRMustache does no longer support garbage collection.

The last version of the library which supports garbage collection is [GRMustache v6.9.2](https://github.com/groue/GRMustache/tree/v6.9.2).


Safe Key Access
---------------

GRMustache does no longer blindly evaluate `valueForKey:` on your objects. This topic is fully described in the [Security Guide](security.md).

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

Without any `dateFormat` property, `{{ dateFormat(user.joinDate )}}` will yield a rendering error, due to the missing (unreachable) `dateFormat` filter.

The fix is to add a `dateFormat` property:

```objc
@property (nonatomic, readonly) NSDateFormatter *dateFormat;
```


### Customizing key access

You can, if you want, customize the list of safe keys, or restore the previous behavior of the library: see the [Security Guide](Guides/security.md).


Default values
--------------

Safe key access may affect your existing code which provide default values for missing keys. Please read the updated [View Model Guide](Guides/view_model.md#default-values).


GRMustacheContext does no longer support subclassing
----------------------------------------------------

Previous versions of the library would let you subclass `GRMustacheContext`, and declare properties with direct access to the context stack. This is no longer the case: GRMustacheContext is no longer suitable for subclassing.

Should you rely on this dropped feature, and experiment difficulties migrating to the latest version of the library, please open an issue: we'll fix it together.


Template Inheritance
--------------------

GRMustache implementation of inheritable templates is now closer from [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java) (see the [Compatibility Guide](Guides/compatibility.md#template-inheritance)):

- Inheritable sections are no longer evaluated against your data: `{{$ item }}...{{/ item }}` does no longer load the `item` key from the context stack.
- Your objects conforming to the GRMustacheTagDelegate and GRMustacheRendering protocols can no longer perform custom rendering of inheritable sections.
- Inheritable sections that are overridden several times are no longer concatenated.

Should your code rely on discontinued behavior, please open an issue: we'll fix it together.



