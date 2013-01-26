[up](../../../../GRMustache#documentation), [next](runtime.md)

Configuration
=============

The only configuration available so far is the content type of templates. There are *HTML*, and *text templates*:

HTML templates return HTML: their `{{ name }}` variable tags escape their input. Their `{{{ name }}}` triple mustache variable tags assume HTML input, and do not perform HTML-escape.

Text templates return text: their `{{ name }}` and `{{{ name }}}` tags do not escape their input: they have identical rendering.

Let's see how to configure your templates.


Global configuration
--------------------

The default configuration `[GRMustacheConfiguration defaultConfiguration]`
applies to all GRMustache rendering unless specified otherwize:

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
// Create a configuration for text rendering
GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
configuration.contentType = GRMustacheContentTypeText;

// All templates loaded from the bash_script_templates directory will be
// rendered as text, and will not HTML-escape their input.
NSString *path = @"/path/to/bash_script_templates";
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:path];
repository.configuration = configuration;

// Render
GRMustacheTemplate *template = [repository templateNamed:...];
NSString *rendering = [template renderObject:...];
````

Template repository configuration has higher priority than the default configuration.

Template Configuration
----------------------

Templates can also be given a specific content type:

Insert those pragma tags right in the content of your templates:

- `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
- `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.

For example:

    {{! This template renders a bash script. }}
    {{% CONTENT_TYPE:TEXT }}
    export LANG={{ENV.LANG}}
    ...


[up](../../../../GRMustache#documentation), [next](runtime.md)
