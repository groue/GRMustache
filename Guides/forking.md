[up](introduction.md)

# Forking GRMustache

After you have forked groue/GRMustache, you might want to change stuff, test, and then build the library.

You'll find below some useful information on each of those topics.

## Change GRMustache

### Classes in a glance

The library features are described in the [guides](introduction.md). This section describes the classes that implement those features. They are organized in a few big domains:

- **Parsing**
    - `GRMustacheTemplateRepository`
    - `GRMustacheTemplateRepositoryDataSource`
    - `GRMustacheParser`
    - `GRMustacheToken`
    - `GRMustacheExpression`
    - `GRMustacheFilteredExpression`
    - `GRMustacheIdentifierExpression`
    - `GRMustacheImplicitIteratorExpression`
    - `GRMustacheScopedExpression`
    
    *Template repositories* are objects that load template strings from various sources.
    
    GRMustache ships with various template repositories that are able to load templates from the file system, and from a dictionary of template strings. The library user can also provide a *data source* to a template repository, in order to load template strings from unimagined locations.
    
    The *parser* is able to produce a [parse tree](http://en.wikipedia.org/wiki/Parse_tree) of *tokens* out of a template string.
    
    For instance, a parser generates three tokens from `Hello {{name}}!`: two text tokens and a variable token.
    
    Some tokens contain an *expression*. Expressions will go live during the rendering of a template (see below), being able to compute rendered values:
    
    - `{{ name }}` contains an *identifier expression*.
    - `{{ . }}` contains an *implicit iterator expression*.
    - `{{ person.name }}` contains a *scoped expression*.
    - `{{ uppercase(name) }}` contains a *filtered expression*.

- **Compiling**
    - `GRMustacheCompiler`
    - `GRMustacheRenderingElement`
    - `GRMustacheSectionElement`
    - `GRMustacheTemplate`
    - `GRMustacheTextElement`
    - `GRMustacheVariableElement`
    
    The *compiler* consumes a parse tree of tokens and outputs an [abstract syntax tree](http://en.wikipedia.org/wiki/Abstract_syntax_tree) of *rendering elements*.
    
    Rendering elements are actually able to provide the rendering expected by the library user. *Templates* render full templates and partials, *section elements* render Mustache section tags, *text elements* render raw text, and *variable elements* render Mustache variable tags.
    
    For instance, from the tokens parsed from `Hello {{name}}!`, a compiler outputs an AST made of one template containing two text elements and a variable element.

- **Runtime**
	- `GRMustacheInvocation`
    - `GRMustacheRuntime`
	- `GRMustacheTemplateDelegate`
    
    A *runtime* implements a state of three different stacks:
	
	- a *context stack*, initialized with the initial object that the library user provides in order to "fill" the template. Section elements create new runtime objects with an extended context stack.
	- a *filter stack*, that is initialized with the *filter library* (see below). Templates extend this filter stack with user's custom filters.
	- a *delegate stack*, initialized with a template's delegate. Section elements create new runtime objects with an extended delegate stack whenever they render objects that conform to the GRMustacheTemplateDelegate protocol.
    
    A runtime is able to provide the value for an identifier such as `name` found in a `{{name}}` tag. However, runtime is not responsible for providing values that should be rendered. Expressions built at the parsing phase are. They query the runtime in order to compute their values.

    *Invocations* are created by runtime objects, and exposed to *delegates*, so that the library user inspect or override rendered values.
    
- **Lambdas Sections**
    - `GRMustacheSectionTagHelper`
    - `GRMustacheSectionTagRenderingContext`

    The library user can implement *section tag helpers* in order to have some section tags behave as "Mustache lambdas". In order to be able to perform the job described by the Mustache specification, they are provided with *rendering context* objects that provide the required information and tools.

- **Lambdas Variables**
    - `GRMustacheVariableTagHelper`
    - `GRMustacheVariableTagRenderingContext`

    The library user can implement *variable tag helpers* in order to have some variable tags behave as "Mustache lambdas". In order to be able to perform the job described by the Mustache specification, they are provided with *rendering context* objects that provide the required information and tools.

- **Filters**
    - `GRMustacheFilter`
    - `GRMustacheFilterLibrary`
    
    The *filter library* provides with built-in filters.
    
    The library user can implement her own *filters*, that will add to the built-in ones.
    
- **Misc**
    - `GRMustache`
    - `GRMustacheNSUndefinedKeyExceptionGuard`
    
    *GRMustache* provides with library configuration.
    
    *GRMustacheNSUndefinedKeyExceptionGuard* is a funny tool that allows the library user to avoid his debugger to stop on every NSUndefinedKeyException raised by the template rendering.
    
    

### Project organisation

Objective-C files that make GRMustache are stored in the `src/classes` folder. They are added to both `GRMustache5-MacOS` and `GRMustache5-iOS` targets of the `src/GRMustache.xcodeproj` project.

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

When a file is added or removed from the `src/tests` folder, both `GRMustache5-MacOSTests` and `GRMustache5-iOSTests` targets of the `src/GRMustache.xcodeproj` project are updated.

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

[up](introduction.md)
