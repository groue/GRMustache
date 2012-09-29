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
#import "GRMustacheCompiler_private.h"
#import "GRMustacheError.h"

static NSString* const GRMustacheDefaultExtension = @"mustache";


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a base URL.
 */
@interface GRMustacheTemplateRepositoryBaseURL : GRMustacheTemplateRepository {
@private
    NSURL *_baseURL;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a directory identified by its path.
 */
@interface GRMustacheTemplateRepositoryDirectory : GRMustacheTemplateRepository {
@private
    NSString *_directoryPath;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a bundle.
 */
@interface GRMustacheTemplateRepositoryBundle : GRMustacheTemplateRepository {
@private
    NSBundle *_bundle;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryPartialsDictionary

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a dictionary.
 */
@interface GRMustacheTemplateRepositoryPartialsDictionary : GRMustacheTemplateRepository {
@private
    NSDictionary *_partialsDictionary;
}
- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary;
@end


// =============================================================================
#pragma mark - GRMustacheTemplateRepository

@interface GRMustacheTemplateRepository()

/**
 * Returns a template or a partial template, given its name.
 * 
 * @param name            The name of the template
 * @param baseTemplateID  The template ID of the enclosing template, or nil.
 * @param outError        If there is an error loading or parsing template and
 *                        partials, upon return contains an NSError object that
 *                        describes the problem.
 *
 * @return a template
 */
- (GRMustacheTemplate *)templateForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID error:(NSError **)outError;

/**
 * Parses templateString and returns rendering elements.
 * 
 * @param templateString  A Mustache template string.
 * @param templateID      The template ID of the template, or nil if the
 *                        template string is not tied to any identified template.
 * @param outError        If there is an error, upon return contains an NSError
 *                        object that describes the problem.
 *
 * @return an array of objects conforming to the GRMustacheRenderingElement protocol.
 * 
 * @see GRMustacheTemplateRepository
 */
- (NSArray *)renderingElementsFromString:(NSString *)templateString templateID:(id)templateID error:(NSError **)outError;

@end

@implementation GRMustacheTemplateRepository
@synthesize dataSource=_dataSource;

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:encoding] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:encoding] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext encoding:encoding] autorelease];
}

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary
{
    return [[[GRMustacheTemplateRepositoryPartialsDictionary alloc] initWithPartialsDictionary:partialsDictionary] autorelease];
}

+ (id)templateRepository
{
    return [[[GRMustacheTemplateRepository alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        _templateForTemplateID = [[NSMutableDictionary alloc] init];
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
    return [self templateForName:name relativeToTemplateID:_currentlyParsedTemplateID error:outError];
}

- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    NSArray *renderingElements = [self renderingElementsFromString:templateString templateID:nil error:outError];
    if (!renderingElements) {
        return nil;
    }
    return [GRMustacheTemplate templateWithInnerElements:renderingElements];
}

#pragma mark Private

- (NSArray *)renderingElementsFromString:(NSString *)templateString templateID:(id)templateID error:(NSError **)outError
{
    NSArray *renderingElements = nil;
    @autoreleasepool {
        // Create a Mustache compiler
        GRMustacheCompiler *compiler = [[[GRMustacheCompiler alloc] init] autorelease];
        
        // We tell the compiler where provide the partials
        compiler.templateRepository = self;
        
        // Create a Mustache parser
        GRMustacheParser *parser = [[[GRMustacheParser alloc] init] autorelease];
        
        // The parser feeds the compiler
        parser.delegate = compiler;
        
        // Parse
        [parser parseTemplateString:templateString templateID:templateID];
        
        // Extract rendering elements from the compiler
        renderingElements = [[compiler renderingElementsReturningError:outError] retain];
        
        // make sure outError is not released by autoreleasepool
        if (!renderingElements && outError != NULL) [*outError retain];
    }
    if (!renderingElements && outError != NULL) [*outError autorelease];
    return [renderingElements autorelease];
}

- (GRMustacheTemplate *)templateForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID error:(NSError **)outError
{
    id templateID = nil;
    if (name) {
       templateID = [self.dataSource templateRepository:self templateIDForName:name relativeToTemplateID:baseTemplateID];
    }
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
        
        
        // store an empty template before compiling, so that we support
        // recursive partials
        
        template = [GRMustacheTemplate templateWithInnerElements:nil];
        [_templateForTemplateID setObject:template forKey:templateID];
        
        
        // We are about to compile templateString. GRMustacheCompiler may
        // invoke [self templateForName:error:] when compiling partial tags
        // {{> name }}. Since partials are relative, we need to know the ID of
        // the currently parsed template.
        //
        // And since partials may embed other partials, we need to handle the
        // currently parsed template ID in a recursive way.
        
        NSArray *renderingElements = nil;
        {
            id previousParsedTemplateID = _currentlyParsedTemplateID;
            _currentlyParsedTemplateID = templateID;
            renderingElements = [self renderingElementsFromString:templateString templateID:templateID error:outError];
            _currentlyParsedTemplateID = previousParsedTemplateID;
        }
        
        
        // compiling done
        
        if (renderingElements) {
            template.innerElements = renderingElements;
        } else {
            // forget invalid empty template
            [_templateForTemplateID removeObjectForKey:templateID];
            template = nil;
        }
    }
    
    return template;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

@interface GRMustacheTemplateRepositoryBaseURL()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryBaseURL

- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
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

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    // Rebase template names starting with a /
    if ([name characterAtIndex:0] == '/') {
        name = [name substringFromIndex:1];
        baseTemplateID = nil;
    }
    
    if (name.length == 0) {
        return nil;
    }
    
    if (baseTemplateID) {
        NSAssert([baseTemplateID isKindOfClass:[NSURL class]], @"");
        if (_templateExtension.length == 0) {
            return [[NSURL URLWithString:name relativeToURL:(NSURL *)baseTemplateID] URLByStandardizingPath];
        }
        return [[NSURL URLWithString:[name stringByAppendingPathExtension:_templateExtension] relativeToURL:(NSURL *)baseTemplateID] URLByStandardizingPath];
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


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

@interface GRMustacheTemplateRepositoryDirectory()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryDirectory

- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
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

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    // Rebase template names starting with a /
    if ([name characterAtIndex:0] == '/') {
        name = [name substringFromIndex:1];
        baseTemplateID = nil;
    }
    
    if (name.length == 0) {
        return nil;
    }
    
    if (baseTemplateID) {
        NSAssert([baseTemplateID isKindOfClass:[NSString class]], @"");
        NSString *basePath = [(NSString *)baseTemplateID stringByDeletingLastPathComponent];
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

- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        if (bundle == nil) {
            bundle = [NSBundle mainBundle];
        }
        _bundle = [bundle retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_bundle release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    return [_bundle pathForResource:name ofType:_templateExtension];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    NSAssert([templateID isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString *)templateID encoding:_encoding error:outError];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryPartialsDictionary

@interface GRMustacheTemplateRepositoryPartialsDictionary()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryPartialsDictionary

- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary
{
    self = [super init];
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

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    return name;
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    return [_partialsDictionary objectForKey:templateID];
}

@end


