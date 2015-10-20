[up](../../../../GRMustache#documentation), [next](template_inheritance.md)

Partial templates
=================

When a `{{> name }}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

You can write recursive partials. Just avoid infinite loops in your context objects.

- [Sources of partials](#sources-of-partials)
- [Partials in the file system](#partials-in-the-file-system)
- [Dynamic partials](#dynamic-partials)
- [Compatibility with other Mustache implementations](#compatibility-with-other-mustache-implementations)


Sources of partials
-------------------

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

When you identify a template through a URL, a file path, or a bundle resource name (see the [Templates Guide](templates.md)), you are able to navigate through a hierarchy of directories and partial files.

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


Dynamic partials
----------------

Partial templates identified with a partial tag such as `{{> name }}` are *hard-coded*. Such a tag always renders the same partial template.

You may want to choose the rendered partial at runtime: this use case is covered in the [Rendering Objects Guide](rendering_objects.md).


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concepts of relative vs. absolute partial paths, or dynamic partials.

**As a consequence, if your goal is to design templates that are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use those features with great care.**


[up](../../../../GRMustache#documentation), [next](template_inheritance.md)

