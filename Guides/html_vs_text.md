[up](../../../../GRMustache#documentation), [next](standard_library.md)

HTML vs. Text Templates
=======================

The Mustache language has a big focus on HTML: it provides HTML-escaping of values by default.

However, GRMustache supports both *HTML templates*, and *text templates*.

HTML templates return HTML: their `{{ name }}` variable tags escape their input. Their `{{{ name }}}` triple mustache variable tags assume HTML input, and do not perform HTML-escape.

Text templates return text: their `{{ name }}` and `{{{ name }}}` tags do not escape their input: they have identical rendering.

The [GRMustacheConfiguration](configuration.md) class is your vector to text & HTML templates.


Global configuration
--------------------

The default configuration `[GRMustacheConfiguration defaultConfiguration]`
applies to all GRMustache rendering unless specified otherwise:

```objc
// Have GRMustache templates render text by default,
// and do not HTML-escape their input.
[GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
```

The `contentType` property of the default configuration can take a value among:

```objc
typedef enum {
    GRMustacheContentTypeHTML,
    GRMustacheContentTypeText,
} GRMustacheContentType;
```

GRMustache is a Mustache engine: templates are HTML by default, and you do not have to explicitly require it.


Template Repository Configuration
---------------------------------

[Template repositories](template_repositories.md) can be given a specific configuration, that will only apply to the templates built by this repository.

```objc
// All templates loaded from the bash_script_templates directory will be
// rendered as text, and will not HTML-escape their input.
NSString *path = @"/path/to/bash_script_templates";
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:path];
repository.configuration.contentType = GRMustacheContentTypeText;

// Render
GRMustacheTemplate *template = [repository templateNamed:...];
NSString *rendering = [template renderObject:...];
````

Template repository configuration has higher priority than the default configuration.

Content Type Of Individual Templates
------------------------------------

Templates can also be given a specific content type:

Insert those pragma tags right in the content of your templates:

- `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
- `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.

For example:

    {{! This template renders a bash script. }}
    {{% CONTENT_TYPE:TEXT }}
    export LANG={{ENV.LANG}}
    ...

Pragma tags have higher priority than repository and default configurations.

Mixing HTML And Text Templates
------------------------------

Text templates return text. They get HTML-escaped when they get embedded in HTML templates:

### Embedding via a partial tag

`Document.mustache`:

    <pre>
    {{> BashScript }}
    </pre>

`BashScript.mustache`:

    {{% CONTENT_TYPE:TEXT }}
    cd {{path}} && {{command}}

Rendering code:

    id data = @{
        @"path": @"/path/",
        @"command": @"echo \"yeah\"" ,
    };
    
    // the script, alone
    NSString *script = [GRMustacheTemplate renderObject:data fromResource:@"BashScript" bundle:nil error:NULL];
    
    // the document
    NSString *document = [GRMustacheTemplate renderObject:data fromResource:@"Document" bundle:nil error:NULL];

script:

    cd /path/ && echo "yeah"

document:

    <pre>
    cd /path/ &amp;&amp; echo &quot;yeah&quot;
    </pre>

### Embedding a dynamic partial

`Document.mustache`:

    <pre>
    {{ bash_script }}
    </pre>

`BashScript.mustache`:

    {{% CONTENT_TYPE:TEXT }}
    cd {{path}} && {{command}}

Rendering code:

    id data = @{
        @"path": @"/path/",
        @"command": @"echo \"yeah\"" ,
        @"bash_script": [GRMustacheTemplate templateFromResource:@"BashScript" bundle:nil error:NULL]
    };
    
    NSString *document = [GRMustacheTemplate renderObject:data fromResource:@"Document" bundle:nil error:NULL];

document:

    <pre>
    cd /path/ &amp;&amp; echo &quot;yeah&quot;
    </pre>

See the [Rendering Objects Guide](rendering_objects.md) for more information about inclusion of partials chosen at runtime.

Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of "text template".

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use {{{ triple }}} mustache tags, and don't mix text with HTML.**

[up](../../../../GRMustache#documentation), [next](standard_library.md)
