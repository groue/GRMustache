[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Indexes
=======

Mustache is a simple template language. Its [specification](https://github.com/mustache/spec) does not provide any built-in access to loop indexes. It does not provide any way to render a section at the beginning of the loop, and another section at the end. It does not help you render different sections for odd and even indexes.

If your goal is to design your templates so that they are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), the best way to render indices and provide custom looping logic is to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

For instance, instead of `[ { name:'Alice' }, { name:'Bob' } ]`, you would provide: `[ { name:'Alice', index:0, first:true, last:false, even:false }, { name:'Bob', index:1, first:false, last:true, even:true } ]`.

GRMustache solution: proxy objects
----------------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

The [GRMustacheTemplateDelegate](../delegate.md) protocol can help you extend the mustache language, and avoid preparing your data.

Below we'll implement the special keys `index`, `first`, and `even`. We'll render the following template:

    <ul>
    {{#people}}
        <li class="{{#even}}even{{/even}} {{#first}}first{{/first}}">
            {{index}}:{{name}}
        </li>
    {{/people}}
    </ul>

We expect, on output, the following rendering:

    <ul>
        <li class="even first">
            0: Alice
        </li>
        <li class="">
            1: Bob
        </li>
        <li class="even">
            2: Craig
        </li>
    </ul>

Here is the rendering code:

```objc
@implementation Document

- (NSString *)render
{
    /**
     * First, let's attach an array of people to the `people` key, so that they
     * are sequentially rendered by the `{{#people}}...{{/people}}` sections.
     * 
     * We'll use a NSDictionary for storing the data, but you can use any other
     * KVC-compliant container.
     */
    
    Person *alice = [Person personWithName:@"Alice"];
    Person *bob = [Person personWithName:@"Bob"];
    Person *craig = [Person personWithName:@"Craig"];
    NSArray *people = [NSArray arrayWithObjects: alice, bob, craig, nil];
    NSDictionary *data = [NSDictionary dictionaryWithObject:people forKey:@"people"];
    
    /**
     Render. The rendering of indices will happen in the
     GRMustacheTemplateDelegate methods, hereafter.
     */
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"template" bundle:nil error:NULL];
    template.delegate = self;
    return [template renderObject:data];
}
```

The people will provide the `name` key needed by the template. But we haven't told yet how the `index`, `first` and `even` keys will be implemented.

Here is the trick: we'll actually intercept arrays before they are rendered by GRMustache. We'll replace them with arrays of proxy objects which will forward to the original elements all keys, such as `name`, but the `index`, `first` and `even` keys.

Let's first declare our proxy class, we'll implement it later:

```objc
@interface ArrayElementProxy : NSObject
- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array;
@end
```

We don't need to declare more: this is enough for us to create proxies and make sure they have all the information they need to perform their job.

Now let's replace array elements with proxies before they are rendered:

```objc
@interface Document() <GRMustacheTemplateDelegate>
@end

@implementation Document()

/**
 * This method is called when the template is about to render a tag.
 */
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * The invocation object tells us which object is about to be rendered.
     */
    
    if ([invocation.returnValue isKindOfClass:[NSArray class]]) {
        
        /**
         * If it is an NSArray, create a new array containing proxies.
         */
        
        NSArray *array = invocation.returnValue;
        NSMutableArray *proxiesArray = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ArrayElementProxy *proxy = [[ArrayElementProxy alloc] initWithObjectAtIndex:idx inArray:array];
            [proxiesArray addObject:proxy];
        }];
        
        /**
         * Now set the invocation's returnValue to the array of proxies: it will
         * be rendered instead.
         */
        
        invocation.returnValue = proxiesArray;
    }
}

@end
```

We're soon done.

The implementation of ArrayElementProxy is straightforward, as long as one remembers that GRMustache fetches values with the `valueForKey:` method, and renders values returned by the `description` method. See [Guides/runtime.md](../runtime.md) for more information.

```objc
@interface ArrayElementProxy()
@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) NSArray *array;
@end

@implementation ArrayElementProxy
@synthesize index=_index;
@synthesize array=_array;

- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.index = index;
        self.array = array;
    }
    return self;
}

// Support for `{{.}}`, not used in our sample template, but a honest proxy
// should implement it.
- (NSString *)description
{
    id originalObject = [self.array objectAtIndex:self.index];
    return [originalObject description];
}

- (id)valueForKey:(NSString *)key
{
    // support for `{{index}}`
    if ([key isEqualToString:@"index"]) {
        return [NSNumber numberWithUnsignedInteger:self.index];
    }

    // support for `{{#first}}` and `{{^first}}`
    if ([key isEqualToString:@"first"]) {
        return [NSNumber numberWithBool:(self.index == 0)];
    }

    // support for `{{#even}}` and `{{^even}}`
    if ([key isEqualToString:@"even"]) {
        return [NSNumber numberWithBool:((self.index % 2) == 0)];
    }

    // for all other keys, forward to original array element
    id originalObject = [self.array objectAtIndex:self.index];
    return [originalObject valueForKey:key];
}

@end
```

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)