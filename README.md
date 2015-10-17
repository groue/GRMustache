GRMustache
==========

GRMustache is a [Mustache](http://mustache.github.io) template engine written in Objective-C, for both MacOS Cocoa and iOS.

It ships with built-in goodies and extensibility hooks that let you avoid the strict minimalism of the genuine Mustache language when you need it.

**April 22, 2015: GRMustache 7.3.2 is out.** [Release notes](CHANGELOG.md)


Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).


Features
--------

- Support for the full [Mustache syntax](http://mustache.github.io/mustache.5.html)
- Filters, as `{{ uppercase(name) }}`
- Template inheritance, as in [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).
- Built-in [goodies](Docs/Guides/goodies.md)


Requirements
------------

- iOS 7.0+ / OSX 10.9+
- Xcode 7

[GRMustache 7.3.2](https://github.com/groue/GRMustache/tree/v7.3.2) used to support older systems and Xcode versions.

**Swift developers**: You can use GRMustache from Swift, with a limitation: you can only render Objective-C objects. Instead, consider using [GRMustache.swift](https://github.com/groue/GRMustache.swift), a pure Swift implementation of GRMustache.


Usage
-----

`document.mustache`:

```mustache
Hello {{name}}
Your beard trimmer will arrive on {{format(date)}}.
{{#late}}
Well, on {{format(realDate)}} because of a Martian attack.
{{/late}}
```

```objc
@import GRMustache;

// Load the `document.mustache` resource of the main bundle
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"document" bundle:nil error:NULL];

// Let template format dates with `{{format(...)}}`
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
dateFormatter.dateStyle = NSDateFormatterMediumStyle;
[template extendBaseContextWithObject:@{ @"format": dateFormatter }];

// The rendered data
id data = @{
    @"name": @"Arthur",
    @"date": [NSDate date],
    @"realDate": [[NSDate date] dateByAddingTimeInterval:60*60*24*3],
    @"late": @YES,
};

// The rendering: "Hello Arthur..."
NSString *rendering = [template renderObject:data error:NULL];
```


Installation
------------

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Xcode projects.

To use GRMustache with Cocoapods, specify in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'GRMustache', '~> 8.0'
```


### Carthage

[Carthage](https://github.com/Carthage/Carthage) is another dependency manager for Xcode projects.

To use GRMustache with Carthage, specify in your Cartfile:

```
github "groue/GRMustache" ~> 8.0
```


### Manually

Download a copy of GRMustache, embed the `GRMustache.xcodeproj` project in your own project, and add the `GRMustacheOSX` or `GRMustacheiOS` target as a dependency of your own target.




TO BE CONTINUED
--------------------------------------------------------------------------



How To
------

### 1. Setup your Xcode project

You have three options, from the simplest to the hairiest:

- [CocoaPods](Guides/installation.md#option-1-cocoapods)
- [Static Library](Guides/installation.md#option-2-static-library)
- [Compile the raw sources](Guides/installation.md#option-3-compiling-the-raw-sources)


### 2. Start rendering templates

```objc
#import "GRMustache.h"
```

One-liners:

```objc
// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" } fromString:@"Hello {{name}}!" error:NULL];
```

```objc
// Renders the `Profile.mustache` resource of the main bundle
NSString *rendering = [GRMustacheTemplate renderObject:user fromResource:@"Profile" bundle:nil error:NULL];
```

Reuse templates in order to avoid parsing the same template several times:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:nil];
rendering = [template renderObject:arthur error:NULL];
rendering = [template renderObject:barbara error:NULL];
rendering = ...
```


Documentation
-------------

If you don't know Mustache, start here: http://mustache.github.io/mustache.5.html

- [Guides](Guides/README.md): a guided tour of GRMustache
- [Reference](http://groue.github.io/GRMustache/Reference/): all classes & protocols
- [Troubleshooting](Guides/troubleshooting.md)
- [FAQ](Guides/faq.md)


License
-------

Released under the [MIT License](LICENSE).


Other Nifty Libraries
---------------------

- [groue/GRMustache.swift](http://github.com/groue/GRMustache.swift): Flexible Mustache templates for Swift 1.2 and 2.
- [groue/GRDB.swift](http://github.com/groue/GRDB.swift): SQLite toolkit for Swift 2.
- [groue/GRValidation](http://github.com/groue/GRDB.swift): Validation toolkit for Swift 2.
