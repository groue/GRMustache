[up](../../../../GRMustache#documentation)

# Forking GRMustache

After you have forked groue/GRMustache, you might want to change stuff, test, and then build the library.

You'll find below some useful information on each of those topics.

## Change GRMustache

### Classes at a glance

The library features are described in the [guides](introduction.md). This section describes the classes that implement those features. They are organized in a few big domains:

- **Parsing**
    - `GRMustacheTemplateParser`
    - `GRMustacheToken`
    
    The *template parser* parses a template string, and emits *tokens*. For example, `Hello {{name}}!` yields a text token, a variable token, and a final text token.
    
    - `GRMustacheExpressionParser`
    
    The *expression parser* parses *expressions* such as `name` or `each(user.friends)`.

- **Compiling**
    
    - `GRMustacheCompiler`
    - `GRMustacheTemplateAST`
    - `GRMustacheTemplateASTNode`
    
    The *compiler* consumes parsed *tokens* to build an *abstract syntax tree* (AST) made of *nodes*.
    
    Nodes are either:
    
    - `GRMustacheInheritablePartialNode`: `{{< partial }}...{{/}}`
    - `GRMustacheInheritableSectionNode`: `{{$ name }}...{{/}}`
    - `GRMustachePartialNode`: `{{> partial }}`
    - `GRMustacheSectionTag`: `{{# expression }}...{{/}}`
    - `GRMustacheTextNode`: `text`
    - `GRMustacheVariableTag`: `{{ expression }}`
    
    Section and variable tags are both subclasses of `GRMustacheTag`, tags which gets rendered by evaluating *expressions*:
    
    - `GRMustacheFilteredExpression`: `identifier(expression, ...)`
    - `GRMustacheIdentifierExpression`: `identifier`
    - `GRMustacheImplicitIteratorExpression`: `.`
    - `GRMustacheScopedExpression`: `identifier.identifier`
    
    AST nodes and expressions can be consumed by *visitors*:
    
    - `GRMustacheTemplateASTNodeVisitor`
    - `GRMustacheExpressionVisitor`
    
- **Rendering**
    
    - `GRMustacheRenderingEngine`
    
    The *rendering engine* is the AST visitor that renders templates. It renders each AST node on its turn, and uses *expression invocations* to evaluate tag expressions:
    
    - `GRMustacheExpressionInvocation`
    - `GRMustacheContext`
    - `GRMustacheKeyAccess`
    - `GRMustacheSafeKeyAccess`
    
    *Expression invocation* is the expression visitor that evaluates expressions against *contexts*. It uses `GRMustacheKeyAccess` for extracting values out of user-provided values. `GRMustacheSafeKeyAccess` is the protocol that lets the user escape the default secure behavior of `GRMustacheKeyAccess`.
    
    - `GRMustacheRendering`
    
    `GRMustacheRendering` is a public protocol that users can implement to provide custom rendering.
    
    The private implementation of GRMustache makes all objects, starting from NSObject, implement this protocol: `GRMustacheRendering.m` provides the rendering implementation for `nil`, `NSNull`, `NSNumber`, `NSFastEnumeration`, `NSString`, and `NSObject`.
    
    - `GRMustacheFilter`
    
    *Filter* is both a protocol, and a class. The protocol allows any class to evaluate filter expressions such as `f(x)`. The class provides ways to build filters by providing a block.

- **Templates**
    
    - `GRMustacheTemplate`
    - `GRMustacheTemplateRepository`
    - `GRMustacheTemplateRepositoryDataSource`

    *Template repositories* are objects that load template strings from various sources.
    
    GRMustache ships with various template repositories that are able to load templates from the file system, and from a dictionary of template strings. The library user can also provide a *data source* to a template repository, in order to load template strings from unimagined locations.
    
    Template repositories emit *templates*.

- **Configuration*

    - `GRMustacheConfiguration`
    
    A *configuration* allows the user to customize the parsing and the rendering of templates.
    
- **Services**
    
    - `NSFormatter+GRMustache`
    - `NSValueTransformer+GRMustache`
    
    Those categories allows formatters and value transformers to evaluate filter expressions such as `dateFormat(date)` and format all values in a section such a `{{#dateFormat}}...{{date}}...{{/}}`.
    
    - `GRMustacheEachFilter`
    - `GRMustacheHTMLLibrary`
    - `GRMustacheJavascriptLibrary`
    - `GRMustacheLocalizer`
    - `GRMustacheStandardLibrary`
    - `GRMustacheURLLibrary`
    
    Those classes provide implementations for the various tools of the *standard library*.


### Project organisation

Objective-C files that make GRMustache are stored in the `src/classes` folder. They are added to both `GRMustache7-MacOS` and `GRMustache7-iOS` targets of the `src/GRMustache.xcodeproj` project.

Headers are splitted in two categories:

- public headers
- private headers

#### Public headers

Public headers must contain only declarations for APIs that are exposed to the GRMustache users. They must not import or include any private header.

Methods and functions declared in public headers must be decorated with the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. Check existing public headers for inspiration.

`src/classes/Shared/GRMustacheAvailabilityMacros.h` is generated by `src/bin/buildGRMustacheAvailabilityMacros`.

#### Private headers

Private headers have names ending in `_private.h`. They must not import or include any public header. The set of public APIs must be duplicated in both public and private headers.


## Test GRMustache

Before running the tests, make sure git submodules are downloaded:

    $ git submodule update --init

There are two kinds of tests, all stored in the `src/tests` folder.

- tests of private APIs
- tests of public APIs

When a file is added or removed from the `src/tests` folder, both `GRMustache7-MacOSTests` and `GRMustache7-iOSTests` targets of the `src/GRMustache.xcodeproj` project are updated.

### Tests of private APIs

Tests of private internals are stored in the `src/tests/Private` folder, and are all subclasses of `GRMustachePrivateAPITest`.

The implementation files of those tests must not include any public header.

### Tests of public APIS

Tests of public GRMustache API are versionned: the `src/tests/Public/v7.0` folder contains tests for features introduced in the version 7.0 of the library. `src/tests/Public/v7.2` contains tests for the version 7.2, etc.

Those tests are all subclasses of `GRMustachePublicAPITest`. Their implementation files must not include any private header.

You will use the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. They help the tests acheiving three goals:

- use only APIs that are available in the GRMustache version they test against,
- emit deprecation warning when they use deprecated GRMustache APIs,
- help GRMustache achieve full backward compatibility.

For instance, all header files for public API tests in `src/tests/Public/v7.2` would begin with:

    #define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_2
    #import "GRMustachePublicAPITest.h"

When you add a test for a public API, make sure you place it in the folder that introduced the API (check the release notes), and NOT in the version that will include the new code. For instance, if version 7.6 introduces a fix for an API that was introduced in version 7.2, the version 7.6 will then ship with new tests in the src/tests/Public/v7.2 folder.

## Building

Building GRMustache is building the `/lib` and `/include` folders, which contain public headers and static libraries for iOS and MacOS.

In order to build them: make sure git submodules are downloaded first:

    $ git submodule update --init

Then, issue the following command:

    $ make clean && make

[up](../../../../GRMustache#documentation)
