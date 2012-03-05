GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

The Mustache syntax: http://mustache.github.com/mustache.5.html (not wrong, but somewhat outdated).

A list of Mustache implementations in other languages: http://mustache.github.com/

Breaking news on Twitter: http://twitter.com/GRMustache


What you get
------------

**MacOS 10.6+, iPhoneOS 3.0, iOS 4.0+ support**

**An ARC-compatible static library**, that will run on your computers, devices, simulators.

**Compatibility with other Mustache implementations**: [Mustache specification v1.1.2](https://github.com/mustache/spec) conformance.
    
**Compatibility with previous GRMustache versions**: update GRMustache, enjoy [performance improvements](https://github.com/groue/GRMustacheBenchmark) and bugfixes, and don't change a line of your code. You may get harmless deprecation warnings, though. Check the [release notes](GRMustache/blob/master/RELEASE_NOTES.md).

**Expressiveness**: GRMustache lets you break out of Mustache limits, in conscience, when you need.

**Documentation**: GRMustache online documentation is provided as guides and sample code:

- [guides/embedding.md](GRMustache/blob/master/guides/embedding.md): how to embed GRMustache in your Xcode projects
- [guides/templates.md](GRMustache/blob/master/guides/templates.md): how to parse and render templates
- [guides/runtime.md](GRMustache/blob/master/guides/runtime.md): how to provide data to templates
- [guides/delegate.md](GRMustache/blob/master/guides/delegate.md): how to hook into template rendering
- [guides/sample_code.md](GRMustache/blob/master/guides/sample_code.md): because some tasks are easier to do with some guidelines.
- [guides/forking.md](GRMustache/blob/master/guides/forking.md): how GRMustache is organized

Usage
-----

GRMustache rendering is the combination of a template string and of an object that will provide the data.

You can render templates on the fly:

```objc
#import "GRMustache.h"

NSString *templateString = @"Hello {{name}}!";
Person *arthur = [Person personWithName:@"Arthur"];

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:arthur fromString:templateString error:NULL];
```

You can also parse a template once, and render it many times.

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
rendering = [template renderObject:arthur];
rendering = [template renderObject:...];
```

Speaking of templates, GRMustache eats many kinds of them: files and bundle resources as well as raw strings. For more information, check [guides/templates.md](GRMustache/blob/master/guides/templates.md).

Regarding the data objects, GRMustache fetches values with the standard Key-Value Coding `valueForKey:` method. Check [guides/runtime.md](GRMustache/blob/master/guides/runtime.md).


Forking
-------

Please fork. You'll learn useful information in [guides/forking.md](GRMustache/blob/master/guides/forking.md).


License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2012 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

