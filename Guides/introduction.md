[up](../../../../GRMustache), [next](templates.md)

GRMustache introduction
=======================

Make sure you get familiar with the Mustache syntax and features first: http://mustache.github.com/mustache.5.html.

Features
--------

### Core Mustache

- **variable tags**, as `{{name}}` and `{{{name}}}` (HTML-escaped or not)
- **section tags** (boolean, loop, lambda, inverted), as `{{#name}}...{{/name}}` and `{{^name}}...{{/name}}`
- **partial tags**, as `{{> partial}}`
- **comment tag**, as `{{! comment }}`
- "**set delimiter tags**", as `{{=<% %>=}}`

### Overlooked Mustache

Those features are not documented in [mustache.5.html](http://mustache.github.com/mustache.5.html), despite their inclusion in the [Mustache specification](https://github.com/mustache/spec):

- **Key paths**, as `{{ person.name }}`, for direct access to an object's property.
- "**Implicit iterator**", aka `{{.}}`, directly renders the current object (useful when looping over strings, for instance).
- "**Mustache lambdas for sections tags**", allow section tags such as `{{#name}}...{{/name}}` to perform custom rendering. Those are documented at [section_tag_helpers.md](section_tag_helpers.md).
- "**Mustache lambdas for variable tags**", that allow variable tags like `{{item}}` to perform custom rendering. You may think of Ruby on Rails' `<%= render @item %>`. Those are documented at [variable_tag_helpers.md](variable_tag_helpers.md).

### Language extensions

Genuine Mustache falls short on a few topics. GRMustache implements features that are not in the specification:

- "**filters**", as `{{ uppercase(name) }}`.
    
    Filters are documented in [filters.md](filters.md).

- **support for partial templates in a file system hierarchy**.
    
    Use relative or absolute paths to your partial templates in your partial tags: see [partials.md](partials.md).

- "**overridable partials**", aka "template inheritance", as in [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java).
    
    Overridable partials are documented in [partials.md](partials.md).

- **loops in variable tags**: in GRMustache, a simple variable tag `{{items}}` renders as the concatenation of the rendering of each individual items. You may think of Ruby on Rails' `<%= render @items %>`.

- "**anchored key paths**", as `{{ .name }}` which prevents the lookup of the `name` key in the context stack built by Mustache sections, and guarantees that the `name` key will be fetched from the very current context.
    
    If you are not familiar with the "context stack" and the key lookup mechanism, check [Guides/runtime/context_stack.md](runtime/context_stack.md).
    

### Template delegate

All the nice Objective-C classes you know allow for observation and customization through delegates. GRMustache will not let you down.

Template delegates are documented in [delegate.md](delegate.md).


Getting started
---------------

### Rendering dictionaries from template strings

You'll generally gather a template string and a data object that will fill the "holes" in the template.

The shortest way to render a template is to mix a literal template string and a dictionary:

```objc
#import "GRMustache.h"

// Render "Hello Arthur!"

NSDictionary *person = @{ @"name": @"Arthur" };
NSString *templateString = @"Hello {{name}}!";
NSString *rendering = [GRMustacheTemplate renderObject:person fromString:templateString error:NULL];
```

`+[GRMustacheTemplate renderObject:fromString:error:]` is documented in [Guides/templates.md](templates.md).

### Rendering model objects from template resources

However, generally speaking, your templates will be stored as *resources* in your application bundle, and your data will come from your *model objects*. It turns out the following code should be more common:

```objc
#import "GRMustache.h"

// Render a profile document from the `Profile.mustache` resource

Person *person = [Person personWithName:@"Arthur"];
NSString *profile = [GRMustacheTemplate renderObject:person fromResource:@"Profile" bundle:nil error:NULL];
```

`+[GRMustacheTemplate renderObject:fromString:error:]` is documented in [Guides/templates.md](templates.md).

### Reusing templates

Finally, should you render a single template several times, you will spare CPU cycles by using a single GRMustacheTemplate instance:

```objc
#import "GRMustache.h"

// Initialize a template from the `Profile.mustache` resource:
GRMustacheTemplate *profileTemplate = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:NULL];

// Render two profile documents
NSString *arthurProfile = [profileTemplate renderObject:arthur];
NSString *barbieProfile = [profileTemplate renderObject:barbie];
```

`+[GRMustacheTemplate templateFromResource:bundle:error:]` and `-[GRMustacheTemplate renderObject:]` are documented in [Guides/templates.md](templates.md).

### Other use cases

Examples above are common use cases for MacOS and iOS applications. The library does [much more](../../../../GRMustache#documentation).

[up](../../../../GRMustache), [next](templates.md)
