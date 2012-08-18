[up](../../../../GRMustache), [next](templates.md)

GRMustache introduction
=======================

Make sure you get familiar with the Mustache syntax and features first: http://mustache.github.com/mustache.5.html.

Features
--------

### Core Mustache

- **variables**, as `{{name}}` and `{{{name}}}` (HTML-escaped or not)
- **sections** (boolean, loop, lambda, inverted), as `{{#name}}...{{/name}}` and `{{^name}}...{{/name}}`
- **partial templates inclusion**, including recursive partials, as `{{> partial}}`
- **comments**, as `{{! comment }}`
- "**set delimiter**" tags, as `{{=<% %>=}}`

### Overlooked Mustache

Those features are not documented in [mustache.5.html](http://mustache.github.com/mustache.5.html), despite their inclusion in the [Mustache specification](https://github.com/mustache/spec):

- **key paths**, as `{{ person.pet.name }}`
- "**implicit iterator**", as `{{.}}`, that you may use when rendering each string in an array, for instance.

### GRMustache extensions

Genuine Mustache falls short on a few topics. GRMustache implements features that are not yet in the specification:

- "**anchored key paths**", as `{{ .name }}`, which prevents the lookup of the `name` key in the context stack built by Mustache sections, and guarantees that the `name` key will be fetched from the very current context.
    
    If you are not familiar with the "context stack" and the key lookup mechanism, check [Guides/runtime/context_stack.md](runtime/context_stack.md).
    
    This extension is backed on the discussions at [mustache/spec#10](https://github.com/mustache/spec/issues/10) and [mustache/spec#52](https://github.com/mustache/spec/issues/52).
    
- "**filters**", as `{{ uppercase(name) }}`.
    
    This extension is backed on the discussion at [mustache/spec#41](https://github.com/mustache/spec/issues/41)

### GRMustache tools

- **hooks** and **template debugging**: the library helps you observe a template rendering, in order to catch rendering bugs or to extend the raw Mustache features.


Getting started
---------------

You'll generally gather a template string and a data object that will fill the "holes" in the template.

The shortest way to render a template is to mix a literal template string and a dictionary:

```objc
#import "GRMustache.h"

// Render "Hello Arthur!"

NSDictionary *person = @{ @"name": @"Arthur" };
NSString *templateString = @"Hello {{name}}!";
NSString *rendering = [GRMustacheTemplate renderObject:person fromString:templateString error:NULL];
```

However, generally speaking, your templates will be stored as *resources* in your application bundle, and your data will come from your *model objects*. It turns out the following code should be more common:

```objc
#import "GRMustache.h"

// Render a profile document from the `Profile.mustache` resource

Person *person = [Person personWithName:@"Arthur"];
NSString *profile = [GRMustacheTemplate renderObject:person fromResource:@"Profile" bundle:nil error:NULL];
```

Finally, should you render a single template several times, you will spare CPU cycles by using a single GRMustacheTemplate instance:

```objc
#import "GRMustache.h"

// Initialize a template from the `Profile.mustache` resource:
GRMustacheTemplate *profileTemplate = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:NULL];

// Render two profile documents
NSString *arthurProfile = [profileTemplate renderObject:arthur];
NSString *barbieProfile = [profileTemplate renderObject:barbie];
```

If the library makes it handy to render templates stored as resources, you may have other needs. Check [Guides/templates.md](templates.md) for a thorough documentation.

Advanced Mustache
-----------------

### Lambda sections

Mustache "lambda sections" allow you to inject your code and process a portion of a template.

A very simple example could be writing a lambda section that wraps its content:

Template:

    {{#wrapped}}
      {{name}} is awesome.
    {{/wrapped}}

Data:

```objc
NSDictionary *data = @{
    @"name": @"Arthur",
    @"wrapped": [GRMustacheHelper helperWithBlock:^(GRMustacheSection *section) {
                    NSString *rawRendering = [section render];
                    return [NSString stringWithFormat=@"<b>%@</b>", rawRendering];
                }]};
```

Render:

```objc
// @"<b>Arthur is awesome.</b>"
NSString *rendering = [template renderObject:data];
```

Lambda sections are fully documented in [Guides/helpers.md](helpers.md).

### Filters

GRMustache "filters" allow you to inject your code (again), but this time in order to process values.

Let's use one of the built-in filters: `uppercase`. Given the template:

    {{%FILTERS}}{{! Filters are not in the specification yet, so we need to opt in with this special tag. }}
    Hello {{ uppercase(name) }}

Rendering "Hello ARTHUR" is as simple as:

```objc
Person *arthur = [Person personWithName:@"Arthur"];
NSString *rendering = [template renderObject:arthur];
```

Filters are fully documented in [Guides/filters.md](filters.md).

### Debugging templates and extending GRMustache

You may provide your templates a *delegate*. This object is able to observe and alter a template rendering.

Check [Guides/delegate.md](delegate.md) for documentation and sample code.

More documentation
------------------

### Mustache syntax

- http://mustache.github.com/mustache.5.html

### Guides

Basic Mustache:

- [templates.md](templates.md): how to load, parse, and render templates from various sources.
- [runtime.md](runtime.md): how to provide data to templates.

Advanced Mustache:

- [helpers.md](helpers.md): how to process the template canvas before it is rendered with Mustache "lambda sections".
- [filters.md](filters.md): how to process data before it is rendered with "filters".
- [delegate.md](delegate.md): how to hook into template rendering.

Sample code:

- [sample_code](../../../tree/master/Guides/sample_code): because some tasks are easier to do with some guidelines.

### Reference

- [Reference](http://groue.github.com/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).

### Internals

- [forking.md](forking.md): the forking guide tells you everything about GRMustache organization.

[up](../../../../GRMustache), [next](templates.md)
