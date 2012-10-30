[up](../../../../GRMustache#documentation), [next](template_repositories.md)

Partial templates
=================

When a `{{> name }}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

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
- Relatively to the URL of the including template, with the same extension:
    - `templateFromContentsOfURL:error:`
- Relatively to the path of the including template, with the same extension:
    - `templateFromContentsOfFile:error:`

Check the [Template Repositories Guide](template_repositories.md) for more partial loading strategies.


Partials in the file system
---------------------------

When you identify a template through a URL or a file path (see the [Templates Guide](templates.md)), you are able to navigate through a hierarchy of directories and partial files.

The partial tag `{{> name }}` interprets the *name* as a *relative path*, and loads the partial template relatively to the embedding template. For example, given the following hierarchy:

    - templates
        - a.mustache
        - partials
            - b.mustache

The a.mustache template can embed b.mustache with the `{{> partials/b }}` tag, and b.mustache can embed a.mustache with the `{{> ../a }}` tag.

*Never use file extensions in your partial tags.* `{{> partials/b.mustache }}` would try to load the `b.mustache.mustache` file which does not exist: you'd get an error of domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeTemplateNotFound`.

### Absolute paths to partials

When your templates are stored in a hierarchy of directories, you sometimes need to refer to a partial template in an absolute way, that does not depend on the location of the embedding template.

Compare:

    `{{> partials/header }}`
    `{{> /partials/header }}`   {{! with a leading slash }}

The first partial tag provides a *relative path*, and refers to a different template, depending on the path of the including template.

The latter always references the same partial, with an *absolute path*.

Absolute partial paths need a root, and the objects that set this root are `GRMustacheTemplateRepository` objects. The rest of the story is documented at [Template Repositories Guide](template_repositories.md).


Overriding portions of partials
-------------------------------

Partials may contain *overridable sections*. Those sections start with a dollar instead of a pound. For example, let's consider the following partial:

`page_layout.mustache`:

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

`article_page.mustache`:

    {{<page_layout}}
    
        {{! override page_title }}
        {{$page_title}}{{article.title}}{{/page_title}}
        
        {{! override page_content }}
        {{$page_content}}
            {{#article}}
                {{body}}
                by {{author}}
            {{/article}}
        {{/page_content}}
        
    {{/page_layout}}

When you render `article.mustache`, you will get a full HTML page.

### Concatenation of overriding sections

In Ruby on Rails, multiple `<% content_for :foo do %>...<% end %>` provide multiple contents for a single `<%= yield :foo %>`. You can achieve the same effect:

`article_page.mustache`:

    {{<page}}
        {{$layout_javascript}}
            <script type="text/javascript" src="article.js"></script>
        {{/layout_javascript}}

        {{$page_content}}
            article content
        {{/page_content}}
    {{/page}}

`page.mustache`:

    {{<layout}}
        {{$layout_javascript}}
            <script type="text/javascript" src="page.js"></script>
        {{/layout_javascript}}

        {{>page_header}}

        {{$layout_content}}
            {{$page_content}}
            {{/page_content}}
        {{/layout_content}}
    
        {{$layout_content}}
            page footer
        {{/layout_content}}

    {{/layout}}

`page_header.mustache`:

    {{$layout_javascript}}
        <script type="text/javascript" src="header.js"></script>
    {{/layout_javascript}}
    {{$layout_content}}
        page header
    {{/layout_content}}

`layout.mustache`:

    <html>
    <head>
        {{$layout_javascript}}{{/layout_javascript}}
    </head>
    <body>
        {{$layout_content}}{{/layout_content}}
    </body>
    </html>

`Render.m`:

    NSString *rendering = [GRMustacheTemplate renderObject:nil fromResource:@"article_page" bundle:nil error:NULL];

Final rendering:

    <html>
    <head>
        <script type="text/javascript" src="page.js"></script>
        <script type="text/javascript" src="header.js"></script>
        <script type="text/javascript" src="article.js"></script>
    </head>
    <body>
        page header
        article content
        page footer
    </body>
    </html>


Dynamic partials
----------------

Partial templates identified with a partial tag such as `{{> name }}` are *hard-coded*. Such a tag always renders the same partial template.

You may want to choose the rendered partial at runtime: this use case is covered in the [Rendering Objects Guide](rendering_objects.md).


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concepts of relative vs. absolute partial paths, overridable sections, or dynamic partials.

**As a consequence, if your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use those features with great care.**


[up](../../../../GRMustache#documentation), [next](template_repositories.md)

