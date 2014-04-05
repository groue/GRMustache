GRMustache 7.0 Migration Guide
==============================

GRMustache 7.0 introduces several changes to the previous release, focusing on security, compatibility with other Mustache implementations, and API simplification. Those changes may break your existing applications.

This guide is provided in order to ease your transition to GRMustache 7.0:

- [New requirements](#new-requirements)
- [Deprecated methods](#deprecated-methods)
- [Safe Key Access](#safe-key-access)
- [Default values](#default-values)
- [GRMustacheContext does no longer support subclassing](#grmustachecontext-does-no-longer-support-subclassing)
- [Template Inheritance](#template-inheritance)


New requirements
----------------

GRMustache does no longer support garbage collection.

The last version of the library which supports garbage collection is [GRMustache v6.9.2](https://github.com/groue/GRMustache/tree/v6.9.2).


Deprecated methods
------------------

When compiling your code, you may get deprecation warnings. Those warnings are harmless: your application is not broken.

In order to restore the pristine warning-free state of your project, read the upgrade path from those deprecated methods in the GRMustache headers.


Safe Key Access
---------------

GRMustache does no longer blindly evaluate `valueForKey:` on your objects.

Instead, only keys that are declared as properties (with `@property`), or Core Data attributes (for managed objects) are evaluated.

This default behavior can be customized to fit your needs: see the [Security Guide](security.md).

The easiest way to restore the previous behavior of the library is to evaluate the following code prior to any rendering:

```objc
GRMustacheConfiguration *configuration = [GRMustacheConfiguration defaultConfiguration];
configuration.baseContext = [configuration.baseContext contextWithUnsafeKeyAccess];
```


Default values
--------------

Safe key access may affect your existing code which provide default values for missing keys. Please read the updated [View Model Guide](view_model.md#default-values).


GRMustacheContext does no longer support subclassing
----------------------------------------------------

Previous versions of the library would let you subclass `GRMustacheContext`, and declare properties with direct access to the context stack. This is no longer the case: GRMustacheContext is no longer suitable for subclassing.

Should you rely on this dropped feature, and experiment difficulties migrating to the latest version of the library, please open an issue: we'll fix it together.


Template Inheritance
--------------------

GRMustache implementation of inheritable templates is now closer from [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java) (see the [Compatibility Guide](compatibility.md#template-inheritance)):

- Inheritable sections are no longer evaluated against your data: `{{$ item }}...{{/ item }}` does no longer load the `item` key from the context stack.
- Your objects conforming to the GRMustacheTagDelegate and GRMustacheRendering protocols can no longer perform custom rendering of inheritable sections.
- Inheritable sections that are overridden several times are no longer concatenated.

Should your code rely on discontinued behavior, please open an issue: we'll fix it together.



