GRMustache Release Notes
========================

You can compare the performances of GRMustache versions at https://github.com/groue/GRMustacheBenchmark.

## v6.9.2

[Fix](https://github.com/groue/GRMustache/pull/70) for a crash on arm64 devices.


## v6.9.1

[Fix](https://github.com/groue/GRMustache/pull/67) for a crash in enumeration rendering.


## v6.9.0

GRMustache now supports [keyed subscripting](http://clang.llvm.org/docs/ObjectiveCLiterals.html#dictionary-style-subscripting): the `objectForKeyedSubscript:` method is preferred to the classic Key-Value-Coding `valueForKey:` method, when extracting values from your view models.

This change fixes the issue [#66](https://github.com/groue/GRMustache/issues/66).


## v6.8.4

Thread-safety of non-mutating methods is guaranteed.


## v6.8.3

The static library lib/libGRMustache6-iOS.a now includes slices for both x86_64 and arm64 architectures.


## v6.8.2

Fix design bugs introduced by v6.8.1. `HTML.escape`, `javascript.escape` and `URL.escape` are no longer able to escape the rendering of your custom rendering objects: they must be given plain strings.


## v6.8.1

Bug fixes:

- `HTML.escape`, `javascript.escape` and `URL.escape` are now able to escape the rendering of your custom rendering objects.


## v6.8

This version introduces a few convenience APIs, and deprecates a flawed method.

### New APIs:

```objc
@interface GRMustacheTemplate
- (void)extendBaseContextWithObject:(id)object;
- (void)extendBaseContextWithProtectedObject:(id)object;
- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate;
@end

@interface GRMustacheConfiguration
- (void)extendBaseContextWithObject:(id)object;
- (void)extendBaseContextWithProtectedObject:(id)object;
- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate;
@end

@interface GRMustacheContext
- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)expression error:(NSError **)error;
@end
```

Full documentation of the new APIs: [GRMustacheTemplate](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTemplate.html), [GRMustacheConfiguration](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheConfiguration.html) and [GRMustacheContext](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html).

### Deprecated APIs:

```objc
@interface GRMustacheContext
// Use the new hasValue:forMustacheExpression:error: method instead
- (id)valueForMustacheExpression:(NSString *)expression error:(NSError **)error;
@end
```

## v6.7.5

Fix for issue [#56](https://github.com/groue/GRMustache/issues/56) (nil template strings have GRMustache return an error instead of crashing).

## v6.7.4

Bug fixes:

- NSUndefinedKeyException prevention used not to work under a Garbage Collector-enabled OSX application.
- Some custom setters of GRMustacheContext managed properties could prevent proper management of those properties.

## v6.7.3

More performance improvements.

## v6.7.2

Fix [issue #38](https://github.com/groue/GRMustache/issues/38).

## v6.7.1

Bug fixes regarding GRMustacheContext.

## v6.7

### Performance improvements

Many thanks to [Alex Reid](https://github.com/AlexJReid) who could setup benchmarks revealing performance problems.

### More ViewModel

- `-[GRMustacheContext topMustacheObject]` gives you access to the top of the rendering stack
- `-[GRMustacheContext valueForUndefinedMustacheKey:]` let your subclasses define default values for any key.

Check the [ViewModel Guide](Guides/view_model.md) for more information.

## v6.6

`-[GRMustacheContext valueForMustacheKey:]` allows your ViewModels to dig in the [context stack](Guides/runtime.md#the-context-stack).

`-[GRMustacheContext valueForMustacheExpression:error:]` allows your ViewModels to perform the same computations as Mustache tags, such as `{{ uppercase(user.name) }}`.

Check the [ViewModel Guide](Guides/view_model.md) for more information.

## v6.5.1

Robustness of ViewModel classes.

## v6.5

### ViewModel classes

ViewModel classes are havens for your template-specific keys. To be discovered in the [ViewModel Guide](Guides/view_model.md).


## v6.4.1

Bugfixes:

- Avoid leaked memory warnings (thanks [@oleganza](https://github.com/oleganza)).
- The `localize` helper now lets you localize sections whose content contains `%@`.

## v6.4.0

### Integration in your Xcode project

The GRMustache static libraries now require that you add the `-ObjC` option in the "Other Linker Flags" of your targets ([how to](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).

### Configuration

The [GRMustacheConfiguration](Guides/configuration.md) class now lets you specify a base rendering context, and the Mustache tag delimiters.

### Standard Library

The [standard library](Guides/standard_library.md) sports new services. Localization support is now built-in, as well as various escaping tools.

### NSFormatter

NSFormatter and subclasses such as NSDateFormatter and NSNumberFormatter are now first citizen of GRMustache. Check the [NSFormatter Guide](Guides/NSFormatter.md).


## v6.3.0

GRMustache does no longer raise an exception when a template can't evaluate a filter expression such as `{{ f(x) }}`.

Instead, an error is returned, with new GRMustache error code `GRMustacheErrorCodeRenderingError`.


## v6.2.0

**Text templates**

Text templates render text, and do not HTML-escape their input.

Check the [HTML vs. Text Templates Guide](Guides/html_vs_text.md).

## v6.1.4

Garbage collection support.

## v6.1.3

The parser now rejects expressions identifiers that start with a reserved Mustache character: `{}<>&#^$/` (those are the characters that start Mustache tags).

This will help the most daring of you who try to push Mustache off limits:

- `{{ >foo }}` looks a lot like a partial tag, but is not. It will now yield a parse error (because `>foo` turns out to be an invalid expression for a variable tag).
- `{{{#foo}}}...{{{/foo}}}` looks a lot like an "unescaped section tag", but there is no such tag in Mustache. This string will now yield a parse error (because `#foo` and `/foo` turn out to be invalid expressions for triple-mustache unescaped variable tags).

## v6.1.2

Improved template debugging: errors are logged when you do not handle them.

## v6.1.1

**[Performance improvements](https://github.com/groue/GRMustacheBenchmark)**

## v6.1

### "Else"

You don't have to close a regular section if it is immediately followed by its inverted form: `{{#name}}...{{^name}}...{{/name}}`
    
The short form `{{#name}}...{{^}}...{{/}}` is accepted, as well as the "unless" form `{{^name}}...{{#}}...{{/}}`.


## v6.0.1

Robustness of protected contexts. Check the ["Protected namespaces"](Guides/protected_contexts.md#protected-namespaces) section of the Protected Contexts Guide.


## v6.0.0

### Major refactoring and simplification

GRMustache has recently been suffering of overengineering and API bloat. GRMustache 6 drastically reduces the surface of the interface.

**Removed APIs**:

- `GRMustacheDynamicPartial`, `GRMustacheProxy`, `GRMustacheSectionTagHelper`, `GRMustacheVariableTagHelper`, and their companion classes have all been gathered in the `GRMustacheRendering` protocol, covered in the [Rendering Objects Guide](Guides/rendering_objects.md).

- `GRMustacheInvocation` and `GRMustacheTemplateDelegate` have been replaced by `GRMustacheTagDelegate`, covered in the [Tag Delegates Guide](Guides/rendering_objects.md).

- The `GRMustacheTemplate` and `GRMustacheTemplateRepository` classes have lost many methods that used to cripple the autocompletion menu of Xcode. All removed shortcut are still eventually available through template repositories.

**New rendering engine behavior**:

- The sections of overridable partials behave more like Ruby on Rails' `<% content_for(:foo) do %>...<% end %>`: multiple overriding sections are now concatenated, when GRMustache 5 used to render the last one only. See the [Partials Guide](Guides/partials.md).

- [Filters](Guides/filters.md) are no longer provided in a separate container (the `renderObject:withFilters:` method is removed). All objects that enter the context stack can now provide filters (and supersede filters defined in parent contexts). You may want to check the [Protected Contexts Guide](Guides/protected_contexts.md) if you want to protect your filter keys.


## v5.5.2

**Bug fixes**

[Variadic filters](Guides/filters.md) can now return filters, just as filters with a single argument.

## v5.5.1

**Niceties and bug fixes**

The `count` method of NSArray, NSSet and NSOrderedSet can now be queried in templates: `{{collection.count}}` renders as expected, and `{{#collection.count}}...{{/}}` can conditionally render a section if and only if the collection is not empty. See [Guides/runtime/context_stack.md](Guides/runtime/context_stack.md#nsarray-nsset-nsorderedset) for a detailed explanation.

[Variadic filters](Guides/filters.md) that return nil used to not play well with boolean sections.

[GRMustacheProxy](Guides/proxies.md) cooperates with `NSUndefinedKeyException` prevention, and keeps its delegate quiet after you have invoked `[GRMustache preventNSUndefinedKeyExceptionAttack]`.

[GRMustacheProxy](Guides/proxies.md) refuses `nil` delegate, since it can not pose as `nil`. You must use [NSNull null] instead.

## v5.5

### Variadic filters

Filters can now take several arguments: `{{ f(a,b) }}`. Check [Guides/filters.md](Guides/filters.md).

### GRMustacheProxy

Proxies are a tool for the developer who wants to write reusable and robust filters, helpers, and template delegates that extend the abilities of the rendered data. Check [Guides/proxies.md](Guides/proxies.md).

The [array indexes.md](Guides/sample_code/indexes.md) sample code now uses proxies. The visible benefit is that the sample code is shorter. It is also more robust. Before proxies were introduced, we used not to be able to properly render indexes for "special" array items such as NSNull, false booleans, or helpers. Proxies are really all about robustness.


## v5.4.4

- Fix a memory leak in [overridable partials](Guides/partials.md).
- Until this version, GRMustache would not trigger delegate methods for objects conforming to both GRMustacheVariableHelper and GRMustacheTemplateDelegate protocols.

## v5.4.3

Until this version, GRMustache would not trigger section tag helpers, variable tag helpers and tag delegates in a few corner cases.

## v5.4.2

Until this version, filters could not return filters. This useless inconsistency is considered a bug, and has been fixed. Check [Guides/filters.md](Guides/filters.md).

## v5.4.1

Fix some corner cases in the handling of [overridable partials](Guides/partials.md), should your templates include conflicting overriding sections. Basically, the last one wins:

`{{<layout}} {{$content}}Not rendered{{/content}} {{$content}}Rendered{{/content}} {{/layout}}`.


## v5.4.0

### Support for templates and partials stored in a hierarchy of directories

When your templates are stored in a hierarchy of directories, you need to refer to [partial templates](Guides/partials.md) in both relative and absolute ways, depending on the context.

Your [variable tag helpers](Guides/variable_tag_helpers.md) and your [section tag helpers](Guides/section_tag_helpers.md) will typically use absolute paths, in order to always include the same partial template, regardless of the hierarchical position of the templates that use them.

Relative partial paths look like regular Mustache partial tags: `{{> header }}`, `{{> partials/header }}`.

GRMustache v5.4.0 brings absolute paths, that start with a slash: `{{> /partials/header }}`. 

The full story starts at [Guides/partials.md](Guides/partials.md#partials-in-the-file-system).

## v5.3.0

### API cleanup

The introduction of variable tag helpers in v5.1.0 introduced many confusing APIs. Those are still there, but deprecated.

No new feature has been added, but semantics have been much improved. Many thanks to [@pierlo](https://github.com/pierlo) for his help.

**Helpers API changes**

`GRMustacheVariableTagHelper` replaces `GRMustacheVariableHelper`. See [Guides/variable_tag_helpers.md](Guides/variable_tag_helpers.md).

```objc
@protocol GRMustacheVariableTagHelper<NSObject>
@required
- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context;
@end

@interface GRMustacheVariableTagRenderingContext : NSObject
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
- (NSString *)renderTemplateNamed:(NSString *)name error:(NSError **)outError;
@end
```

`GRMustacheSectionTagHelper` replaces `GRMustacheSectionHelper`. See [Guides/section_tag_helpers.md](Guides/section_tag_helpers.md).

```objc
@protocol GRMustacheSectionTagHelper<NSObject>
@required
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context;
@end

@interface GRMustacheSectionTagRenderingContext: NSObject
@property (nonatomic, readonly) NSString *innerTemplateString;
- (NSString *)render;
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
@end
```

**GRMustacheTemplateDelegate API changes**

In the `GRMustacheInterpretation` enumeration, `GRMustacheSectionTagInterpretation` replaces `GRMustacheInterpretationSection`, and `GRMustacheVariableTagInterpretation` replaces `GRMustacheInterpretationVariable`.

**GRMustacheTemplate API changes**

`[GRMustacheTemplate renderObjectsFromArray:]` and `[GRMustacheTemplate renderObjectsFromArray:withFilters:]` replace `[GRMustacheTemplate renderObjectsInArray:]` and `[GRMustacheTemplate renderObjectsInArray:withFilters:]`.

## v5.2.0

**Overridable partials**

Inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java), GRMustache now supports "template inheritance". Precisely, your templates can embed as many partials as before, but now you can override portions of those partials.

Overridable partials are documented as [Guides/partials.md](Guides/partials.md).

The [layout](../../tree/master/Guides/sample_code/layout) sample code has been updated to take profit of overridable partials. There is not much left of it :-).


## v5.1.0

### Dropped support for armv6

libGRMustache5-iOS.a is now compiled with Xcode 4.5, and does not longer embed the armv6 slice.

For armv6 support, use [GRMustache 5.0.1](https://github.com/groue/GRMustache/tree/v5.0.1).

### Array rendering

The Mustache specification does not specify how a collection of objects should be rendered. For instance, the rendering of `{{items}}` is unspecified if items is an array.

GRMustache 5.1 renders an array as the concatenation of the rendering of its individual items.

This makes GRMustache able to render `{{items}}` just as Ruby on Rails renders `<%= render @items %>`. Keep on reading.

### Variable helpers and dynamic partials

The library was missing support for "Mustache variable lambdas", that let you execute code when rendering a plain `{{variable}}` tag.

Support for variable lambdas is there now, through the `GRMustacheVariableHelper` protocol.

Variable helpers are the base for "dynamic partials", that is to say the ability to defer the choice of a template partial until the actual rendering. Now your context objects can choose which partial should be rendered.

Variable helpers can also help objects being able to "render themselves", and have `{{item}}` and `{{items}}` rendering controlled by these items themselves.

All of those new features are documented at [Guides/variable_helpers.md](Guides/variable_helpers.md).

New APIs:

```objc
// The name of exceptions raised whenever the rendering could not be completed.
extern NSString * const GRMustacheRenderingException;

// Base protocol for "variable lambdas".
@protocol GRMustacheVariableHelper<NSObject>
@required
- (NSString *)renderVariable:(GRMustacheVariable *)variable;
@end

// Convenience class in order to avoid implementing a full class that conforms
// to the GRMustacheVariableHelper protocol
@interface GRMustacheVariableHelper: NSObject<GRMustacheVariableHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block;
@end

// Convenience class for building variable helpers that render the content of a
// template partial.
@interface GRMustacheDynamicPartial: NSObject<GRMustacheVariableHelper>
+ (id)dynamicPartialWithName:(NSString *)name;
@end

// Allows you to implement variable helpers through the GRMustacheVariableHelper
// protocol.
@interface GRMustacheVariable : NSObject
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
- (NSString *)renderTemplateNamed:(NSString *)name error:(NSError **)outError;
@end

// This protocol is identical to the deprecated GRMustacheHelper protocol.
@protocol GRMustacheSectionHelper<NSObject>
@required
- (NSString *)renderSection:(GRMustacheSection *)section;
@end

// This class is identical to the deprecated GRMustacheHelper class.
@interface GRMustacheSectionHelper: NSObject<GRMustacheSectionHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block;
@end
```

Deprecated APIs:

```objc
// Use GRMustacheRenderingException instead
extern NSString * GRMustacheFilterException;

// Use GRMustacheSectionHelper protocol instead
@protocol GRMustacheHelper
@end

// Use GRMustacheSectionHelper class instead
@interface GRMustacheHelper
@end
```


## v5.0.1

Bug fixes:

- [Section delegates](Guides/delegate.md) used not to be given the rendered template as expected.
- [Helpers](Guides/helpers.md) used not to be able to render partial templates when rendering alternate template strings.


## v5.0.0

**[Performance improvements](https://github.com/groue/GRMustacheBenchmark), and fix for flaws in the GRMustacheDelegate API.**

Besides the removal of already deprecated methods, the changes introduced in this version are very unlikely to introduce incompatibilities in your code:

- Dropped support for iOS3.
- Before v5.0.0, [template delegates](Guides/delegate.md) could know that the value `Arthur` was provided by the key `name` when the tag `{{name}}` is rendered. Delegates are now only provided with the value.
- Before v5.0.0, a tag containing a filter expression like `{{uppercase(name)}}` would have a template delegate invoked with the raw `Arthur` value, not the filter result: `ARTHUR`. In v5.0.0, delegate callbacks are given always given the value GRMustache is about to render.

Removed APIs:

```objc
@interface GRMustacheInvocation : NSObject
// Removed without deprecation warning
@property (nonatomic, readonly) NSString *key;
@end

@interface GRMustacheSection: NSObject
// Deprecated in v4.3.0
@property (nonatomic, retain, readonly) id renderingContext;
@end

@interface GRMustacheTemplate: NSObject
// Deprecated in v4.3.0
- (NSString *)renderObjects:(id)object, ...;
@end

// Removed without deprecation warning
GRMustacheInterpretationFilterArgument // was part of the GRMustacheInterpretation enum.

@protocol GRMustacheTemplateDelegate<NSObject>
// Deprecated in v4.1.0
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
@end
```


## v4.3.4

Restored compatibility with iOS3 and OSX6 (thanks [@Bertrand](https://github.com/Bertrand)).


## v4.3.3

Fix a memory leak.


## v4.3.2

Bugfix: Avoid the default `valueForKey:` implementation of Fundation collection classes like NSArray, NSSet and NSOrderedSet, which would return another collection. Fixes [issue #21](https://github.com/groue/GRMustache/issues/21).


## v4.3.1

Bugfix: this release restores the delegate callbacks while rendering alternate template strings in [helpers](Guides/helpers.md).


## v4.3.0

### Filters

[Filters](Guides/filters.md) allow you to process values before they are rendered, and supersede "section delegates" as the preferred way to filter values. The [number formatting](Guides/sample_code/number_formatting.md) and [array indexes.md](Guides/sample_code/indexes.md) sample codes have been updated accordingly.

**New APIs**:

```objc
@interface GRMustacheSection: NSObject
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError;
@end

@interface GRMustacheTemplate: NSObject
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError;
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfFile:(NSString *)path error:(NSError **)outError;
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfURL:(NSURL *)url error:(NSError **)outError;
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;
- (NSString *)renderObject:(id)object withFilters:(id)filters;
- (NSString *)renderObjectsInArray:(NSArray *)objects;
- (NSString *)renderObjectsInArray:(NSArray *)objects withFilters:(id)filters;
@end
```

**Deprecated APIs**:

```objc
@interface GRMustacheSection: NSObject
// Use renderTemplateString:error: instead.
@property (nonatomic, retain, readonly) id renderingContext;
@end

@interface GRMustacheTemplate: NSObject
// Use renderObjectsInArray: instead.
- (NSString *)renderObjects:(id)object, ...;
@end
```

## v4.2.0

### Section delegates

When an object that is attached to a Mustache section conforms to the [GRMustacheDelegate protocol](Guides/delegate.md), it can observe and alter the rendering of the inner content of the section, just like the template's delegate.

This provides you with a better way to encapsulate behaviors that, with previous versions of GRMustache, would bloat the one and only delegate of a template.

Section delegates are used in the [number formatting sample code](Guides/sample_code/number_formatting.md), where the NSNumberFormatter class is given the opportunity to render formatted numbers.

## v4.1.1

### Total inline documentation

Headers contain documentation for every exposed API.

An online reference, automatically generated from inline documentation by appledoc can be read at http://groue.github.io/GRMustache/Reference/.

## v4.1.0

### GRMustacheDelegate protocol

A template's delegate is now able to know how a value will be interpreted by GRMustache.

New APIs:

```objc
typedef enum {
    GRMustacheInterpretationSection,
    GRMustacheInterpretationVariable,
} GRMustacheInterpretation;

@protocol GRMustacheTemplateDelegate<NSObject>
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation;
@end
```

Deprecated APIs:

```objc
@protocol GRMustacheTemplateDelegate<NSObject>
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation;
@end
```

GRMustacheDelegate is documented in [Guides/delegate.md](Guides/delegate.md).

### GRMustacheTemplateRepositoryDataSource protocol

The return type of `-[GRMustacheTemplateRepositoryDataSource templateRepository:templateIDForName:relativeToTemplateID:]` as changed from `id` to `id<NSCopying>`.

GRMustacheTemplateRepositoryDataSource is documented in [Guides/template_repositories.md](Guides/template_repositories.md).

### Errors

GRMustache used to output badly formatted errors. They are now easier to read.

## v4.0.0

### Zero numbers are false

GRMustache now considers all `NSNumber` instances whose `boolValue` is `NO` as false, when considering whether a section should render or not.

Previously, GRMustache used to consider only `[NSNumber numberWithBool:NO]` as false.

This change lets you extend the mustache language with proxy objects (objects that implement language extensions, and forward other keys to some other object) in GRMustache rendering.

See [Guides/sample_code/indexes.md](Guides/sample_code/indexes.md) for a discussion on proxy objects.

### Total NSUndefinedException swallowing

Whenever GRMustache performs some key lookup and `valueForKey:` raises a NSUndefinedException, GRMustache swallows it and keep on looking for the key up the context stack.

Previously, GRMustache used to swallow only exceptions that explicitely came from the inquired object, and for the inquired key.

This change lets you extend the mustache language with proxy objects (objects that implement language extensions, and forward other keys to some other object) in GRMustache rendering.

See [Guides/sample_code/indexes.md](Guides/sample_code/indexes.md) for a discussion on proxy objects.

### Support for `.name` keys

Keys prefixed by a dot prevent GRMustache to look up the [context stack](Guides/runtime/context_stack.md).

Beware this feature is not in the mustache specification. If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), don't use this syntax.

See [issue #19](https://github.com/groue/GRMustache/issues/19) and https://github.com/mustache/spec/issues/10.

## v3.0.1

Restored intended architectures: armv6+armv7+i386 for libGRMustache3-iOS, i386+x86_64 for libGRMustache3-MacOS.

## v3.0.0

### There is no option

Removed APIs:

```objc
enum {
    GRMustacheTemplateOptionNone,
    GRMustacheTemplateOptionStrictBoolean
};

typedef NSUInteger GRMustacheTemplateOptions;

@interface GRMustacheTemplate: NSObject {
+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
@end

@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithOptions:(GRMustacheTemplateOptions)options;
@end
```

## v2.0.0

### API simplification

**New APIs**

```objc
enum {
    // New option for processing `BOOL` and `char` properties as numbers
    GRMustacheTemplateOptionStrictBoolean = 1
}

@protocol GRMustacheHelper<NSObject>
@required
// New required method
- (NSString *)renderSection:(GRMustacheSection *)section;
@end

// New GRMustacheHelper class
@interface GRMustacheHelper: NSObject<GRMustacheHelper>
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block;
@end

// New GRMustacheSection properties and methods
@interface GRMustacheSection: NSObject
@property (nonatomic, readonly) NSString *innerTemplateString;
@property (nonatomic, readonly) id renderingContext;
- (NSString *)render;
@end
```

**Removed APIs and behaviors**

```objc
enum {
    // GRMustache is now compliant by default to the Mustache specification:
    GRMustacheTemplateOptionMustacheSpecCompatibility = 1
}

// NSErrors with GRMustacheErrorDomain now store the line number in localizedDescription.
extern NSString* const GRMustacheErrorLine;

@interface GRMustache: NSObject
// This global state has been replaced by the GRMustacheTemplateOptionStrictBoolean option:
+ (BOOL)strictBooleanMode:
+ (void)setStrictBooleanMode:(BOOL)strictBooleanMode;
@end

@protocol GRMustacheHelper<NSObject>
@required
// Replaced by renderSection: method
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context;
@end

// Replaced by the GRMustacheHelper class:
@interface GRMustacheBlockHelper: NSObject<GRMustacheHelper> {
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block;
@end

@interface GRMustacheSection: NSObject
// Replaced by the innerTemplateString property
@property (nonatomic, readonly) NSString *templateString;
// See the new render method
- (NSString *)renderObject:(id)object;
- (NSString *)renderObjects:(id)object, ...;
@end
```

GRMustache1 used to parse and interpret [Handlebars](http://handlebarsjs.com/) tags such as `{{../foo/bar}}`. GRMustache2 does no longer parse those tags.

GRMustache1 used to parse and interpret `this` identifier is tags such as `{{this.foo}}`. GRMustache2 does no longer parse the `this` identifier.

GRMustache1 used to look for implementations of the `localizeSection:inContext:` selector when rendering a `{{#localize}}...{{/localize}}` section. GRMustache2 relies on the GRMustacheHelper protocol only when rendering Mustache lambda sections.


## v1.13.1

The deprecated class GRMustacheTemplateLoader was broken by 1.13.0. Deprecated does not mean unavailable: it is restored.

## v1.13.0

Deprecated class (use [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:], or the new GRMustacheTemplateRepositoryDataSource protocol instead):

- `GRMustacheTemplateLoader`

New class:

- `GRMustacheTemplateRepository`

```objc
@interface GRMustacheTemplateRepository : NSObject
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource;

+ (id)templateRepository;
+ (id)templateRepositoryWithOptions:(GRMustacheTemplateOptions)options;

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

+ (id)templateRepositoryWithDirectory:(NSString *)path;
+ (id)templateRepositoryWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary;
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options;

- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError;
```

New protocol:

- `GRMustacheTemplateRepositoryDataSource`

```objc
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
@required
- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID;
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError;
@end
```

## v1.12.2

Restore parsing performances of v1.12.0

## v1.12.1

Easier template debugging with `[GRMustacheInvocation description]`

## v1.12

- **GRMustacheTemplateDelegate protocol**

Deprecated classes:

- `GRMustacheNumberFormatterHelper`
- `GRMustacheDateFormatterHelper`

## v1.11.2

BOOL property custom getters can be used to control boolean sections.

## v1.11.1

Avoid deprecation warning in GRMustache headers.

## v1.11

**API cleanup**

New GRMustacheTemplateLoader methods:

```objc
- (GRMustacheTemplate *)templateWithName:(NSString *)name error:(NSError **)outError;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError;
```

New GRMustacheTemplate methods:

```objc
+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError;
+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError;
+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)outError;
+ (id)templateFromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
```

Deprecated GRMustacheTemplateLoader methods (use `templateWithName:error:` and `templateFromString:error:` instead):

```objc
- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError;
- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError;
```

Deprecated GRMustacheTemplate methods (replace `parse` with `templateFrom`):

```objc
+ (id)parseString:(NSString *)templateString error:(NSError **)outError;
+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError;
+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;
+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;
+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError;
+ (id)parseContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
```

## v1.10.3

Upgrade GRMustache, and get deprecation warnings when you use deprecated APIs. Your code will keep on running fine, though.

## v1.10.2

**[Performance improvements](https://github.com/groue/GRMustacheBenchmark)**

## v1.10.1

**[Performance improvements](https://github.com/groue/GRMustacheBenchmark)**

## v1.10

**Improved Handlebars.js support**

Now `{{foo/bar}}` and `{{foo.bar}}` syntaxes are both supported.

## v1.9

- **Better lambda encapsulation with classes conforming to the GRMustacheHelper protocol.**
- **Format all numbers in a section with GRMustacheNumberFormatterHelper**
- **Format all dates in a section with GRMustacheDateFormatterHelper**

New protocol:

- `GRMustacheHelper`

```objc
@protocol GRMustacheHelper<NSObject>
@required
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context;
@end
```

New classes:

- `GRMustacheNumberFormatterHelper`
- `GRMustacheDateFormatterHelper`

```objc
@interface GRMustacheNumberFormatterHelper : NSObject<GRMustacheHelper>
@property (nonatomic, readonly, retain) NSNumberFormatter *numberFormatter;
+ (id)helperWithNumberFormatter:(NSNumberFormatter *)numberFormatter;
@end

@interface GRMustacheDateFormatterHelper : NSObject<GRMustacheHelper>
@property (nonatomic, readonly, retain) NSDateFormatter *dateFormatter;
+ (id)helperWithDateFormatter:(NSDateFormatter *)dateFormatter;
@end
```

## v1.8.6

Fixed bug in [GRMustacheTemplate renderObjects:...]

## v1.8.5

Added missing symbols from lib/libGRMustache1-ios3.a

## v1.8.4

Added missing symbols from lib/libGRMustache1-ios3.a and lib/libGRMustache1-ios4.a

## v1.8.3

Availability fixes.

## v1.8.2

Better testing of public API thanks to availability macros.

## v1.8.1

Bug fixes

## v1.8

**GRMustache now supports the [Mustache specification v1.1.2](https://github.com/mustache/spec).**

New type and enum:

```objc
enum {
    GRMustacheTemplateOptionNone = 0,
    GRMustacheTemplateOptionMustacheSpecCompatibility = 0x01,
};

typedef NSUInteger GRMustacheTemplateOptions;
```

New GRMustache methods:

```objc
+ (GRMustacheTemplateOptions)defaultTemplateOptions;
+ (void)setDefaultTemplateOptions:(GRMustacheTemplateOptions)templateOptions;
```

New GRMustacheTemplate methods:

```objc
+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError;
```

New GRMustacheTemplateLoader methods:

```objc
+ (id)templateLoaderWithBaseURL:(NSURL *)url options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
```


## v1.7.4

Bug fix: avoid crashing when one provides uninitialized NSError* to GRMustache.

## v1.7.3

One no longer needs to add `-all_load` to the "Other Linker Flags" target option tu use GRMustache static libraries.

## v1.7.2

- Fixed [issue #6](https://github.com/groue/GRMustache/issues/6)
- `[GRMustache preventNSUndefinedKeyExceptionAttack]` no longer prevents the rendering of `nil`.

## v1.7.1

Added missing header file

## v1.7.0

**GRMustache now ships as a static library.**

See the [Embedding](https://github.com/groue/GRMustache/wiki/Embedding) wiki page in order to see how to embed GRMustache in your project.

Besides, the NSUndefinedKeyException silencing is no longer activated by the DEBUG macro. You now have to explicitely call the `[GRMustache preventNSUndefinedKeyExceptionAttack]` method. For more details, see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page.

## v1.6.2

**LLVM3 compatibility**

## v1.6.1

The NSUndefinedKeyException silencing activated by the DEBUG macro applies to NSManagedObject instances (see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page).

## v1.6.0

**Reduced memory footprint**

New GRMustacheTemplateLoader methods:

```objc
+ (id)templateLoaderWithDirectory:(NSString *)path;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
```

Deprecated GRMustacheTemplateLoader methods (replace `BasePath` with `Directory`):

```objc
+ (id)templateLoaderWithBasePath:(NSString *)path;
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext;
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
```

Bug fixes around the NSUndefinedKeyException handling when the `DEBUG` macro is set (thanks to [Mike Ash](http://www.mikeash.com/)).

## v1.5.2

The `DEBUG` macro makes GRMustache raise much less NSUndefinedKeyException (see the [Avoid the NSUndefinedKeyException attack](https://github.com/groue/GRMustache/wiki/Avoid-the-NSUndefinedKeyException-attack) wiki page).

## v1.5.1

Bug fixes

## v1.5.0

**API simplification**

New GRMustacheTemplate method:

- `- (NSString *)renderObjects:(id)object, ...;`

New GRMustacheSection method:

- `- (NSString *)renderObjects:(id)object, ...;`

New class:

- `GRMustacheBlockHelper`

Deprecated class (use `id` instead when refering to a context, and use `renderObjects:` methods instead of instanciating one):

- `GRMustacheContext`

Deprecated function (use GRMustacheBlockHelper instead):

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

## v1.4.0

**iOS 3.0 support**

New `GRMustacheTemplate` methods:

- `+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError;`
- `+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError;`

New `GRMustacheTemplateLoader` methods:

- `+ (id)templateLoaderWithBasePath:(NSString *)path;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;`

## v1.3.3

Bug fixes

## v1.3.2

Bug fixes

## v1.3.1

Bug fixes

## v1.3.0

**Block-less API for helpers.**

New classes:

- `GRMustacheContext`
- `GRMustacheSection`

New functions:

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

Deprecated functions (use GRMustacheLambdaBlockMake instead):

- `GRMustacheLambda GRMustacheLambdaMake(NSString *(^block)(NSString *(^)(id object), id, NSString *));`

## v1.2.0

**iOS 4.0 support**

Deprecated class (use `[NSNumber numberWithBool:YES]` instead of `[GRYes yes]`):

- `GRYes`

Deprecated class (use `[NSNumber numberWithBool:NO]` instead of `[GRNo no]`):

- `GRNo`

## v1.1.6

GRMustacheTemplateLoader subclasses can now rely on an immutable `extension` property.

## v1.1.5

Bug fixes

## v1.1.4

Bug fixes

## v1.1.3

**Rendering performance improvement**

## v1.1.2

**Parsing performance improvement**

## v1.1.1

Bug fixes

## v1.1.0

New methods:

- `[GRYes yes]` responds to `boolValue`
- `[GRNo no]` responds to `boolValue`

## v1.0.0

**First versioned release**
