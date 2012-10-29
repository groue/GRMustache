[up](../../../../GRMustache#documentation), [next](delegate.md)

Rendering Objects
=================

Overview
--------

Let's first confess a lie: here and there in this documentation, you have been reading that Mustache tags renders objects in a way or another: variable tags output values HTML-escaped, sections tags loop over arrays, etc.

This is plain wrong. Actually, objects render themselves.

`NSNumber` *does* render as a string for `{{ number }}`, and decides if `{{# condition }}...{{/}}` should render.

`NSArray` *does* render the `{{# items }}...{{/}}` tag for each of its items.

etc.

Let's have a precise look at the rendering of a tag, say: `{{ uppercase(person.name) }}`.

First the `uppercase(person.name)` expression is evaluated. This evaluation is based on the invocation of `valueForKey:` on your data object (see the [Runtime Guide](runtime.md) for details). Eventually, *you* decide who is the person, what is his name, and which filter should apply. Let's say the expression evaluates to "ARTHUR".

Second, [tag delegates](delegate.md) enter the game. Tag delegates can change the value before it is rendered. For the purpose of demonstration, let's admit that a pirate delegate was there: "ARRRRRRRTHUR".

Finally, the "ARRRRRRRTHUR" string is asked to render for the `{{ uppercase(person.name) }}` tag. It is a variable tag, so the string simply renders itself.

You see that from the start, your application code decides what will be eventully be rendered. Let's imagine that instead of "ARRRRRRRTHUR", you had provided an object that conforms to the `GRMustacheRendering` protocol:

GRMustacheRendering protocol
----------------------------

This protocol declares the method that all rendering objects must implement. NSArray does implement it, so does NSNumber, and NSString. Your objects can, as well:

```objc
@protocol GRMustacheRendering <NSObject>

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error;

@end
```

- The _tag_ represents the tag you must render for. It may be a variable tag `{{ name }}`, a section tag `{{# name }}...{{/}}`, etc.

- The _context_ represents the [context stack](runtime/context_stack.md), and all information that tags need to render.

- _HTMLSafe_ is a pointer to a BOOL: upon return, it must be set to YES or NO, depending on the safety of the string you render. If you forget to set it, it is of course assumed to be NO.

- _error_ is... the eventual error. You can return nil without setting any error: in this case, everything happens as if you returned the empty string.

You may declare and implement your own conforming classes. The `+[GRMustache renderingObjectWithBlock:]` method comes in handy for creating a rendering object without declaring any class:

```objc
id renderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return @"I'm rendered!";
    }];
```

Examples
--------

### Wrapping the content of a section tag

Let's write a rendering object which wraps a section in a `<strong>` HTML tag.

We will use the `-[GRMustacheTag renderContentWithContext:HTMLSafe:error]` method:

```objc
@interface GRMustacheTag: NSObject

/**
 * Returns the rendering of the tag's inner content, rendering all inner
 * Mustache tags with the rendering context argument.
 *
 * Note that variable tags such as `{{ name }}` have no inner content, and
 * return the empty string.
 *
 * @param context   A context for rendering inner tags.
 * @param HTMLSafe  Upon return contains YES if the result is HTML-safe.
 * @param error     If there is an error rendering the tag, upon return contains
 *                  an NSError object that describes the problem.
 *
 * @return The rendering of the tag's inner content.
 */
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error;

@end
```

Perfect: we'll ask the section tag to render its content, and simply wrap it:

```objc
NSString *templateString = @"{{#strong}}"
                           @"{{name}} is awesome."
                           @"{{/strong}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

id strongRenderingObject = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
    NSString *rawRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    if (!rawRendering) return nil;  // let errors out
    return [NSString stringWithFormat:@"<strong>%@</strong>", rawRendering];
}];

id data = @{
    @"name": @"Arthur",
    @"strong": strongRenderingObject,
};

// <b>Arthur is awesome.</b>
NSString *rendering = [template renderObject:data error:NULL];
```

`strongRenderingObject` performs a *double-pass rendering*: it first has the section tag render its inner content (that is to say: `Arthur is awesome.`), and then wraps the result.



### An example: NSString rendering

Let's see, for example, the actual NSString rendering code. You remember that strings simply render themselves in variable tags as `{{ name }}`. Depending on their length, they trigger or omit section tags as `{{# name }}...{{/}}` and `{{^ name }}...{{/}}`.

```objc
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            *HTMLSafe = NO;
            return self;
            
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# string }}...{{/}}
            // {{$ string }}...{{/}}
            if (self.length > 0) {
                context = [context contextByAddingObject:self];
                return [tag renderContentWithContext:context
                                     HTMLSafe:HTMLSafe
                                        error:error];
            } else {
                return @"";
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ string }}...{{/}}
            if (self.length > 0) {
                return @"";
            } else {
                return [tag renderContentWithContext:context
                                     HTMLSafe:HTMLSafe
                                        error:error];
            }
    }
}
```

See how the [context stack](runtime/context_stack.md) is *explicitely* extended, with the `-[GRMustacheContext contextByAddingObject:]` method. Without it, it would be impossible to perform conditional rendering such as `{{#title}}<h1>{{.}}</h1>{{/title}}`.

See also how the section tags provide the `-[GRMustacheTag renderContentWithContext:HTMLSafe:error:]` method, that renders their inner content, and set the `HTMLSafe` and `error` arguments for you.

### GRMustacheTag, GRMustacheContext

Below is the full APIs that are available to your rendering objects. We'll see a few examples next after.

```objc
/**
 * GRMustacheTag instances represent Mustache tags that render values, such as
 * a variable tag {{ name }}, or a section tag {{# name }}...{{/}).
 */
@interface GRMustacheTag: NSObject

/**
 * The type of the tag
 */
@property (nonatomic, readonly) GRMustacheTagType type;

/**
 * The template repository that did provide the template string from which the
 * receiver has been extracted.
 */
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository;

/**
 * The literal and unprocessed inner content of the tag, the `...` in
 * `{{# name }}...{{/}}`.
 *
 * Is is nil for variable tags such as `{{ name }}`.
 */
@property (nonatomic, readonly) NSString *innerTemplateString;

/**
 * Returns the rendering of the inner content of the receiver, given a rendering
 * context.
 *
 * Is is empty for variable tags such as `{{ name }}`.
 *
 * @param context   A rendering context.
 * @param HTMLSafe  Upon return contains YES if the result is HTML-safe.
 * @param error     If there is an error rendering the tag, upon return contains
 *                  an NSError object that describes the problem.
 *
 * @return The rendering of the tag.
 */
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error;

@end


/**
 * The GRMustacheContext represents a Mustache rendering context: it internally
 * maintains two stacks:
 *
 * - a *context stack*, that makes it able to provide the current context
 *   object, and to perform key lookup.
 * - a *tag delegate stack*, so that tag delegates are notified when a Mustache
 *   tag is rendered.
 *
 * You may derive new rendering contexts when you implement *rendering objects*,
 * using the contextByAddingObject: and contextByAddingTagDelegate: methods.
 */
@interface GRMustacheContext : NSObject

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the context stack.
 *
 * If _object_ conforms to the GRMustacheTemplateDelegate protocol, it is also
 * added at the top of the tag delegate stack.
 *
 * @param object  An object
 *
 * @return A new rendering context.
 */
- (GRMustacheContext *)contextByAddingObject:(id)object;

/**
 * Returns a new rendering context that is the copy of the receiver, and the
 * given object added at the top of the tag delegate stack.
 *
 * @param tagDelegate  A tag delegate
 *
 * @return A new rendering context.
 */
- (GRMustacheContext *)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate;

@end


typedef enum {
    // The type for variable tags such as {{ name }}
    GRMustacheTagTypeVariable = 1 << 1,
    
    // The type for section tags such as {{# name }}...{{/}}
    GRMustacheTagTypeSection = 1 << 2,
    
    // The type for overridable section tags such as {{$ name }}...{{/}}
    GRMustacheTagTypeOverridableSection = 1 << 3,
    
    // The type for inverted section tags such as {{^ name }}...{{/}}
    GRMustacheTagTypeInvertedSection = 1 << 4,
} GRMustacheTagType;

```


[up](../../../../GRMustache#documentation), [next](delegate.md)
