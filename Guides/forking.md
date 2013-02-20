[up](../../../../GRMustache#documentation)

# Forking GRMustache

After you have forked groue/GRMustache, you might want to change stuff, test, and then build the library.

You'll find below some useful information on each of those topics.

## Change GRMustache

### Classes at a glance

The library features are described in the [guides](introduction.md). This section describes the classes that implement those features. They are organized in a few big domains:

- **Parsing**
    - `GRMustacheTemplateRepository`
    - `<GRMustacheTemplateRepositoryDataSource>` (protocol)
    
    *Template repositories* are objects that load template strings from various sources.
    
    GRMustache ships with various template repositories that are able to load templates from the file system, and from a dictionary of template strings. The library user can also provide a *data source* to a template repository, in order to load template strings from unimagined locations.
    
    - `GRMustacheParser`
    - `GRMustacheToken`
    
    The *parser* is able to produce a [parse tree](http://en.wikipedia.org/wiki/Parse_tree) of *tokens* out of a template string.
    
    For instance, a parser generates three tokens from `Hello {{name}}!`: two text tokens and a variable token.
    
    - `GRMustacheExpression`
    - `GRMustacheFilteredExpression`
    - `GRMustacheIdentifierExpression`
    - `GRMustacheImplicitIteratorExpression`
    - `GRMustacheScopedExpression`
    
    Some tokens contain an *expression*. Expressions will go live during the rendering of a template (see below), being able to compute rendered values:
    
    - `{{ name }}` contains an *identifier expression*.
    - `{{ . }}` contains an *implicit iterator expression*.
    - `{{ person.name }}` contains a *scoped expression*.
    - `{{ uppercase(name) }}` contains a *filtered expression*.

- **Compiling**
    - `GRMustacheConfiguration`
    - `GRMustacheCompiler`
    - `GRMustacheAST`
    - `<GRMustacheTemplateComponent>` (protocol)
    
    The *compiler* consumes a parse tree of tokens and outputs an *AST* ([abstract syntax tree](http://en.wikipedia.org/wiki/Abstract_syntax_tree)) of *template components*. The *configuration* tells the compiler whether the AST should represent a HTML or a text template.
    
    Template components are actually able to provide the rendering expected by the library user:

    - `GRMustacheTemplate`
    - `GRMustacheTemplateOverride`
    - `GRMustacheTextComponent`
    - `GRMustacheTag`
    
    *Templates* render full templates and partials, *tags* render user data, *text elements* render raw text, and *template overrides* render overridable partial tags.
    
    For instance, from the tokens parsed from `Hello {{name}}!`, a compiler outputs an AST made of two text elements and a tag element.
    
    There are three subclasses of GRMustacheTag:
    
    - `GRMustacheSectionTag`
    - `GRMustacheVariableTag`
    - `GRMustacheAccumulatorTag`
    
    *Section tags* and *Variable tags* represent their "physical" counterpart `{{#^$ name}}...{{/name}}` and `{{name}}` respectively.
    
    *Accumulator tags* are actually created during the rendering, not during the compilation phase. They are involved in the concatenation of multiple overridable sections `{{$name}}...{{/name}}`.

- **Runtime**
    - `GRMustacheContext`
    
    A *rendering context* implements a state of four different stacks:
    
    - a *context stack*.
    - a *protected context stack*.
    - a *tag delegate stack*.
    - a *template override stack*, that grows when a template override element renders.
    
    A rendering context is able to provide the value for an identifier such as `name` found in a `{{name}}` tag. However, runtime is not directly responsible for providing values that should be rendered. Expressions built at the parsing phase are. They query the context in order to compute their values.

    - `<GRMustacheTagDelegate>` (protocol)

    Tags iterate all *tag delegates* in a rendering context and let them observe or alter their rendering.
    
    - `<GRMustacheRendering>` (protocol)

    The library user can implement his own *rendering objects* in order to perform custom rendering.

    - `<GRMustacheFilter>` (protocol)
    - `GRMustacheFilter` (class)
    
    The library user can implement her own *filters*, that will add to the built-in ones.
    
    

### Project organisation

Objective-C files that make GRMustache are stored in the `src/classes` folder. They are added to both `GRMustache6-MacOS` and `GRMustache6-iOS` targets of the `src/GRMustache.xcodeproj` project.

Headers are splitted in two categories:

- public headers
- private headers

#### Public headers

Public headers must contain only declarations for APIs that are exposed to the GRMustache users. They must not import or include any private header.

Methods and functions declared in public headers must be decorated with the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. Check existing public headers for inspiration.

`src/classes/GRMustacheAvailabilityMacros.h` is generated by `src/bin/buildGRMustacheAvailabilityMacros`.

#### Private headers

Private headers have names ending in `_private.h`. They must not import or include any public header. The set of public APIs must be duplicated in both public and private headers.


## Test GRMustache

Before running the tests, make sure git submodules are downloaded:

    $ git submodule update --init

There are two kinds of tests, all stored in the `src/tests` folder.

- tests of private APIs
- tests of public APIs

When a file is added or removed from the `src/tests` folder, both `GRMustache6-MacOSTests` and `GRMustache6-iOSTests` targets of the `src/GRMustache.xcodeproj` project are updated.

### Tests of private APIs

Tests of private internals are stored in the `src/tests/Private` folder, and are all subclasses of `GRMustachePrivateAPITest`.

The implementation files of those tests must not include any public header.

### Tests of public APIS

Tests of public GRMustache API are versionned: the `src/tests/Public/v4.0` folder contains tests for features introduced in the version 4.0 of the library. `src/tests/Public/v4.1` contains tests for the version 4.1, etc.

Those tests are all subclasses of `GRMustachePublicAPITest`. Their implementation files must not include any private header.

You will use the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. They help the tests acheiving three goals:

- use only APIs that are available in the GRMustache version they test against,
- emit deprecation warning when they use deprecated GRMustache APIs,
- help GRMustache achieve full backward compatibility.

For instance, all header files for public API tests in `src/tests/Public/v4.1` would begin with:

    #define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_1
    #import "GRMustachePublicAPITest.h"

When you add a test for a public API, make sure you place it in the folder that introduced the API (check the release notes), and NOT in the version that will include the new code. For instance, if version 4.6 introduces a fix for an API that was introduced in version 4.2, the version 4.6 will then ship with new tests in the src/tests/Public/v4.2 folder.

## Building

Building GRMustache is building the `/lib` and `/include` folders, which contain public headers and static libraries for iOS and MacOS.

In order to build them: make sure git submodules are downloaded first:

    $ git submodule update --init

Then, issue the following command:

    $ make clean && make

[up](../../../../GRMustache#documentation)
