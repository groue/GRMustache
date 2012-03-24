// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheError.h"

NSString* const GRMustacheDefaultExtension = @"mustache";


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

@interface GRMustacheTemplateRepositoryBaseURL : GRMustacheTemplateRepository {
@private
    NSURL *_baseURL;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
@end

#endif /* !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

@interface GRMustacheTemplateRepositoryDirectory : GRMustacheTemplateRepository {
@private
    NSString *_directoryPath;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

@interface GRMustacheTemplateRepositoryBundle : GRMustacheTemplateRepository {
@private
    NSBundle *_bundle;
    NSString *_directoryPath;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension directory:(NSString *)directoryPath encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryPartialsDictionary

@interface GRMustacheTemplateRepositoryPartialsDictionary : GRMustacheTemplateRepository {
@private
    NSDictionary *_partialsDictionary;
}
- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options;
@end


// =============================================================================
#pragma mark - GRMustacheTemplateRepository

@interface GRMustacheTemplateRepository()<GRMustacheTemplateParserDataSource>
- (GRMustacheTemplate *)templateForName:(NSString *)name relativeToTemplateID:(id)templateID error:(NSError **)outError;
- (NSArray *)renderingElementsFromString:(NSString *)templateString error:(NSError **)outError;
@end

@implementation GRMustacheTemplateRepository
@synthesize dataSource=_dataSource;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:encoding options:options] autorelease];
}


#endif /* !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateRepositoryWithDirectory:(NSString *)path
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:encoding options:options] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:GRMustacheDefaultExtension directory:nil encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:GRMustacheDefaultExtension directory:nil encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:nil encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:nil encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:subpath encoding:NSUTF8StringEncoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:subpath encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:subpath encoding:encoding options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext directory:subpath encoding:encoding options:options] autorelease];
}

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary
{
    return [[[GRMustacheTemplateRepositoryPartialsDictionary alloc] initWithPartialsDictionary:partialsDictionary options:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepositoryPartialsDictionary alloc] initWithPartialsDictionary:partialsDictionary options:options] autorelease];
}

+ (id)templateRepository
{
    return [[[GRMustacheTemplateRepository alloc] initWithOptions:GRMustacheDefaultTemplateOptions] autorelease];
}

+ (id)templateRepositoryWithOptions:(GRMustacheTemplateOptions)options
{
    return [[[GRMustacheTemplateRepository alloc] initWithOptions:options] autorelease];
}

// designated initializer
- (id)initWithOptions:(GRMustacheTemplateOptions)options
{
    self = [super init];
    if (self) {
        _templateForTemplateID = [[NSMutableDictionary alloc] init];
        _options = options;
    }
    return self;
}

- (void)dealloc
{
    [_templateForTemplateID release];
    [super dealloc];
}

- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError
{
    return [self templateForName:name relativeToTemplateID:nil error:outError];
}

- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    NSArray *renderingElements = [self renderingElementsFromString:templateString error:outError];
    if (!renderingElements) {
        return nil;
    }
    return [GRMustacheTemplate templateWithElements:renderingElements options:_options];
}

#pragma mark GRMustacheTemplateParserDataSource

- (id<GRMustacheRenderingElement>)templateParser:(GRMustacheTemplateParser *)templateParser renderingElementForPartialName:(NSString *)name error:(NSError **)outError
{
    return [self templateForName:name relativeToTemplateID:_currentlyParsedTemplateID error:outError];
}

- (GRMustacheInvocation *)templateParser:(GRMustacheTemplateParser *)templateParser invocationWithToken:(GRMustacheToken *)token keys:(NSArray *)keys
{
    return [GRMustacheInvocation invocationWithToken:token templateID:_currentlyParsedTemplateID keys:keys];
}

#pragma mark Private

- (NSArray *)renderingElementsFromString:(NSString *)templateString error:(NSError **)outError
{
    NSArray *renderingElements = nil;
    @autoreleasepool {
        // setup parser
        GRMustacheTemplateParser *parser = [GRMustacheTemplateParser templateParserWithOptions:_options];
        parser.dataSource = self;
        
        // tokenize
        GRMustacheTokenizer *tokenizer = [[[GRMustacheTokenizer alloc] init] autorelease];
        tokenizer.delegate = parser;
        [tokenizer parseTemplateString:templateString];
        
        // extract rendering elements
        renderingElements = [[parser renderingElementsReturningError:outError] retain];
        
        // make sure outError is not released by autoreleasepool
        if (!renderingElements && outError != NULL) [*outError retain];
    }
    if (!renderingElements && outError != NULL) [*outError autorelease];
    return [renderingElements autorelease];
}

- (GRMustacheTemplate *)templateForName:(NSString *)name relativeToTemplateID:(id)templateID error:(NSError **)outError
{
    templateID = [self.dataSource templateRepository:self templateIDForName:name relativeToTemplateID:templateID];
    if (templateID == nil) {
        if (outError != NULL) {
            *outError = [NSError errorWithDomain:GRMustacheErrorDomain
                                            code:GRMustacheErrorCodeTemplateNotFound
                                        userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
                                                                             forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    
    GRMustacheTemplate *template = [_templateForTemplateID objectForKey:templateID];
    
    if (template == nil) {
        // templateRepository:templateStringForTemplateID:error: is a dataSource method.
        // We are not sure the dataSource will set error when not returning any templateString.
        // We thus have to take extra care of error handling here.
        NSError *templateStringError = nil;
        NSString *templateString = [self.dataSource templateRepository:self templateStringForTemplateID:templateID error:&templateStringError];
        if (!templateString) {
            if (outError != NULL) {
                // make sure we return an error
                if (templateStringError == nil) {
                    templateStringError = [NSError errorWithDomain:GRMustacheErrorDomain
                                                              code:GRMustacheErrorCodeTemplateNotFound
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
                                                                                               forKey:NSLocalizedDescriptionKey]];
                }
                *outError = templateStringError;
            }
            return nil;
        }
        
        // store an empty template before parsing, so that we support recursive partials
        template = [GRMustacheTemplate templateWithElements:nil options:_options];
        [_templateForTemplateID setObject:template forKey:templateID];
        
        // parse
        id previousParsedTemplateID = _currentlyParsedTemplateID;
        _currentlyParsedTemplateID = templateID; // prepare for GRMustacheTemplateParserDataSource methods
        NSArray *renderingElements = [self renderingElementsFromString:templateString error:outError];
        _currentlyParsedTemplateID = previousParsedTemplateID;        // OK, parsing done
        
        if (renderingElements) {
            template.elems = renderingElements;
        } else {
            [_templateForTemplateID removeObjectForKey:templateID];
            template = nil;
        }
    }
    
    return template;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

@interface GRMustacheTemplateRepositoryBaseURL()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryBaseURL

- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [self initWithOptions:options];
    if (self) {
        _baseURL = [baseURL retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_baseURL release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    if (templateID) {
        NSAssert([templateID isKindOfClass:[NSURL class]], @"");
        if (_templateExtension.length == 0) {
            return [[NSURL URLWithString:name relativeToURL:(NSURL *)templateID] URLByStandardizingPath];
        }
        return [[NSURL URLWithString:[name stringByAppendingPathExtension:_templateExtension] relativeToURL:(NSURL *)templateID] URLByStandardizingPath];
    }
    if (_templateExtension.length == 0) {
        return [[_baseURL URLByAppendingPathComponent:name] URLByStandardizingPath];
    }
    return [[[_baseURL URLByAppendingPathComponent:name] URLByAppendingPathExtension:_templateExtension] URLByStandardizingPath];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    NSAssert([templateID isKindOfClass:[NSURL class]], @"");
    return [NSString stringWithContentsOfURL:(NSURL *)templateID encoding:_encoding error:outError];
}

@end

#endif /* !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

@interface GRMustacheTemplateRepositoryDirectory()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryDirectory

- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [self initWithOptions:options];
    if (self) {
        _directoryPath = [directoryPath retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_directoryPath release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    if (templateID) {
        NSAssert([templateID isKindOfClass:[NSString class]], @"");
        NSString *basePath = [(NSString *)templateID stringByDeletingLastPathComponent];
        if (_templateExtension.length == 0) {
            return [[basePath stringByAppendingPathComponent:name] stringByStandardizingPath];
        }
        return [[basePath stringByAppendingPathComponent:[name stringByAppendingPathExtension:_templateExtension]] stringByStandardizingPath];
    }
    if (_templateExtension.length == 0) {
        return [[_directoryPath stringByAppendingPathComponent:name] stringByStandardizingPath];
    }
    return [[[_directoryPath stringByAppendingPathComponent:name] stringByAppendingPathExtension:_templateExtension] stringByStandardizingPath];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    NSAssert([templateID isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString *)templateID encoding:_encoding error:outError];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

@interface GRMustacheTemplateRepositoryBundle()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryBundle

- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension directory:(NSString *)directoryPath encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [self initWithOptions:options];
    if (self) {
        if (bundle == nil) {
            bundle = [NSBundle mainBundle];
        }
        _bundle = [bundle retain];
        _directoryPath = [directoryPath retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_bundle release];
    [_directoryPath release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    if (templateID) {
        NSAssert([templateID isKindOfClass:[NSString class]], @"");
        NSString *basePath = [(NSString *)templateID stringByDeletingLastPathComponent];
        if (_templateExtension.length == 0) {
            return [[basePath stringByAppendingPathComponent:name] stringByStandardizingPath];
        }
        return [[basePath stringByAppendingPathComponent:[name stringByAppendingPathExtension:_templateExtension]] stringByStandardizingPath];
    }

    if (_directoryPath) {
        return [_bundle pathForResource:name ofType:_templateExtension inDirectory:_directoryPath];
    } else {
        return [_bundle pathForResource:name ofType:_templateExtension];    // not sure inDirectory:nil would produce the same result
    }
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    NSAssert([templateID isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString *)templateID encoding:_encoding error:outError];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

@interface GRMustacheTemplateRepositoryPartialsDictionary()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryPartialsDictionary

- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options
{
    self = [self initWithOptions:options];
    if (self) {
        _partialsDictionary = [partialsDictionary retain];
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_partialsDictionary release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    return name;
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    return [_partialsDictionary objectForKey:templateID];
}

@end


