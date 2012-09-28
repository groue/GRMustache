[up](introduction.md), [next](template_repositories.md)

Partial templates
=================

When a `{{>name}}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

You can write recursive partials. Just avoid infinite loops in your context objects.


Source of partials
------------------

Depending on the method which has been used to create the original template, partials will be searched in different places :

- In the main bundle, with ".mustache" extension:
    - `renderObject:fromString:error:`
    - `templateFromString:error:`
- In the specified bundle, with ".mustache" extension:
    - `renderObject:fromResource:bundle:error:`
    - `templateFromResource:bundle:error:`
- In the specified bundle, with the provided extension:
    - `renderObject:fromResource:withExtension:bundle:error:`
    - `templateFromResource:withExtension:bundle:error:`
- Relatively to the URL of the including template, with the same extension:
    - `renderObject:fromContentsOfURL:error:`
    - `templateFromContentsOfURL:error:`
- Relatively to the path of the including template, with the same extension:
    - `renderObject:fromContentsOfFile:error:`
    - `templateFromContentsOfFile:error:`

Check [Guides/template_repositories.md](template_repositories.md) for more partial loading strategies.


Partials in the file system
---------------------------

When you identify a template through a URL or a file path (see [templates.md](templates.md)), you are able to navigate through a hierarchy of directories and partial files.

The partial tag `{{>name}}` actually interprets the *name* as a *path*, and loads the template *relatively* to the embedding template. For example, given the following hierarchy:

    - templates
        - a.mustache
        - partials
            - b.mustache

The a.mustache template can embed b.mustache with the `{{> partials/b }}` tag, and b.mustache can embed a.mustache with the `{{> ../a }}` tag.

Never use file extensions in your partial tags. `{{> partials/b.mustache }}` would have you get an error of domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeTemplateNotFound`. 

### Absolute paths to partials

When your templates are stored in a hierarchy of directories, you sometimes need to refer to a partial template in an absolute way, that does not depend of the location of the embedding template.

Compare:

    `{{> partials/header }}`
    `{{> /partials/header }}`   {{! with a leading slash }}

The first partial tag provides a *relative path*, and refers to a different template, depending on the path of the including template.

The latter always references the same partial, with an *absolute path*.

Absolute partial paths need a root, and the objects that set this root are `GRMustacheTemplateRepository` objects. The rest of the story is documented at [template_repositories.md](template_repositories.md).

### Template Hierarchy in an NSBundle

Bundles provide a flat, non-hierarchical, resource storage. Hence this hierarchy of partials is not available to templates stored as bundle resources.

However, You can embed a full directory and its contents as a bundle resource, and fall back to URL-based of file path-based APIs:

```objc
// URL of the templates directory resource
NSString *templatesPath = [[NSBundle mainBundle] pathForResource:@"templates" ofType:nil];

// Render a.mustache
NSString *aPath = [templatesPath stringByAppendingPathComponent:@"a.mustache"];
GRMustacheTemplate *aTemplate = [GRMustacheTemplate templateFromContentsOfFile:aPath error:NULL];
[aTemplate render...];

// Render b.mustache
NSString *bPath = [templatesPath stringByAppendingPathComponent:@"partials/b.mustache"];
GRMustacheTemplate *bTemplate = [GRMustacheTemplate templateFromContentsOfFile:bPath error:NULL];
[bTemplate render...];
```

You may also use the `GRMustacheTemplateRepository` class, that is documented in [template_repositories.md](template_repositories.md):

```objc
// Repository of templates stored in templates directory resource:
NSString *templatesPath = [[NSBundle mainBundle] pathForResource:@"templates" ofType:nil];
GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesPath];

// Render a.mustache
GRMustacheTemplate *aTemplate = [repository templateForName:@"a" error:NULL];
[aTemplate render...];

// Render b.mustache
GRMustacheTemplate *bTemplate = [repository templateForName:@"partials/b" error:NULL];
[bTemplate render...];
```

Overriding portions of partials
-------------------------------

Partials may contain *overridable sections*. Those sections start with a dollar instead of a pound. For example, let's consider the following partial:

    page_layout.mustache
    <html>
    <head>
        <title>{{$page_title}}Default title{{/page_title}}</title>
    </head>
    <body>
        <h1>{{$page_title}}Default title{{/page_title}}</h1>
        {{$page_content}
            Default content
        {{/page_content}}}
    </body>
    </html>

You can embed such an overridable partial, and override its sections with the `{{<partial}}...{{/partial}}` syntax:

    article_page.mustache
    {{<page_layout}}
    
        {{! override page_title }}
        {{$page_title}}{{article.title}}{{/page_title}}
        
        {{! override page_content }}
        {{$page_content}}
            {{$article}}
                {{body}}
                by {{author}}
            {{/article}}
        {{/page_content}}
        
    {{/page_layout}}

When you render `article.mustache`, you will get a full HTML page.

You can override a section with attached data, as well:

    anonymous_article.mustache
    {{<article_page}}
        {{$article}}
            {{body}}
            by anonymous coward
        {{/article}}
    {{/article_page}}

[up](introduction.md), [next](template_repositories.md)

