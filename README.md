GRMustache
==========

GRMustache is a production-ready implementation of [Mustache](http://mustache.github.com/) templates for MacOS Cocoa and iOS.

**August 6th, 2012: GRMustache 4.3.2 is out.** [Release notes](GRMustache/blob/master/RELEASE_NOTES.md)

Breaking news on Twitter: http://twitter.com/GRMustache

How To
------

### 1. Download and add to your Xcode project

    $ git clone https://github.com/groue/GRMustache.git

- For MacOS development, add `include/GRMustache.h` and `lib/libGRMustache4-MacOS.a` to your project.
- For iOS development, add `include/GRMustache.h` and `lib/libGRMustache4-iOS.a` to your project.

Alternatively, you may use [CocoaPods](https://github.com/CocoaPods/CocoaPods): append `dependency 'GRMustache'` to your Podfile.

GRMustache targets MacOS down to 10.6 Snow Leopard, iOS down to version 3, and only depends on the Foundation framework.

### 2. Import "GRMustache.h" and start rendering templates

```objc
#import "GRMustache.h"

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];

// Renders from a resource
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                          fromResource:@"Profile"  // loads `Profile.mustache`
                                                bundle:nil
                                                 error:NULL];
```


Documentation
-------------

Documentation starts here: [Guides/introduction.md](GRMustache/blob/master/Guides/introduction.md).


FAQ
---

- **Q: How do I render array indexes?**
    
    A: Check [Guides/sample_code/indexes.md](GRMustache/blob/master/Guides/sample_code/indexes.md)

- **Q: How do I format numbers and dates?**
    
    A: Check [Guides/sample_code/number_formatting.md](GRMustache/blob/master/Guides/sample_code/number_formatting.md)

- **Q: How do I localize templates?**

    A: Check [Guides/sample_code/localization.md](GRMustache/blob/master/Guides/sample_code/localization.md)

- **Q: Does GRMustache provide any layout facility?**
    
    A: No. But there is a [sample Xcode project](GRMustache/tree/master/Guides/sample_code/layout) that demonstrates how to do that.

- **Q: How do I render default values for missing keys?**

    A: This can be done by providing your template a delegate: check [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md).

- **Q: I have a bunch of templates and partials that live in memory / a database / the cloud / wherever.**
    
    A: Check [Guides/template_repositories.md](GRMustache/blob/master/Guides/template_repositories.md).

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).

- **Q: Why does GRMustache need JRSwizzle?**

    A: GRMustache will [swizzle](http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html) the implementation of `valueForUndefinedKey:` in the NSObject and NSManagedObject classes when you invoke `[GRMustache preventNSUndefinedKeyExceptionAttack]`. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md). The dreadful swizzling happens in [src/classes/GRMustacheNSUndefinedKeyExceptionGuard.m](GRMustache/blob/master/src/classes/GRMustacheNSUndefinedKeyExceptionGuard.m).


Contribution wish-list
----------------------

I wish somebody would review my non-native English, and clean up the guides, if you ask.


Forking
-------

Please fork. You'll learn useful information in [Guides/forking.md](GRMustache/blob/master/Guides/forking.md).


License
-------

Released under the [MIT License](GRMustache/blob/master/LICENSE).
