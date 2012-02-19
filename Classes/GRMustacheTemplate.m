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

#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplate+RenderingElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRBoolean_private.h"

@interface GRMustacheTemplate()
@property (nonatomic) GRMustacheTemplateOptions options;
- (id)initWithElements:(NSArray *)theElems options:(GRMustacheTemplateOptions)options;
@end

@implementation GRMustacheTemplate
@synthesize elems;
@synthesize options;

+ (id)templateWithOptions:(GRMustacheTemplateOptions)options
{
    static GRMustacheTemplate *emptyTemplate = nil;
    if (emptyTemplate == nil) {
        emptyTemplate = [[GRMustacheTemplate templateWithElements:nil options:options] retain];
    }
    return emptyTemplate;
}

+ (id)parseString:(NSString *)templateString error:(NSError **)outError {
    return [GRMustacheTemplate parseString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:[NSBundle mainBundle] options:options];
	return [loader parseString:templateString error:outError];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
    return [GRMustacheTemplate parseContentsOfURL:url options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
	GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[url URLByDeletingLastPathComponent] extension:[url pathExtension] options:options];
	NSAssert([loader isKindOfClass:[GRMustacheDirectoryURLTemplateLoader class]], @"");
	return [(GRMustacheDirectoryURLTemplateLoader *)loader parseContentsOfURL:url error:outError];
}
#endif

+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError {
    return [GRMustacheTemplate parseContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
	GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithDirectory:[path stringByDeletingLastPathComponent] extension:[path pathExtension] options:options];
	NSAssert([loader isKindOfClass:[GRMustacheDirectoryPathTemplateLoader class]], @"");
	return [(GRMustacheDirectoryPathTemplateLoader *)loader parseContentsOfFile:path error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate parseResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:bundle options:options];
	return [loader parseTemplateNamed:name error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:bundle extension:ext options:options];
	return [loader parseTemplateNamed:name error:outError];
}

+ (id)templateWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options {
	return [[[self alloc] initWithElements:elems options:options] autorelease];
}

- (void)dealloc {
	[elems release];
	[super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError {
    return [self renderObject:object fromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (!template && outError != NULL) [*outError retain];
    [pool drain];
	if (!template && outError != NULL) [*outError autorelease];
	return [result autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError {
    return [self renderObject:object fromContentsOfURL:url options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfURL:url options:options error:outError];
	NSString *result = [[template renderObject:object] retain];
	if (!template && outError != NULL) [*outError retain];
    [pool drain];
	if (!template && outError != NULL) [*outError autorelease];
	return [result autorelease];
}
#endif

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError {
    return [self renderObject:object fromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfFile:path options:options error:outError];
	NSString *result = [[template renderObject:object] retain];
	if (!template && outError != NULL) [*outError retain];
    [pool drain];
	if (!template && outError != NULL) [*outError autorelease];
	return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [self renderObject:object fromResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name bundle:bundle options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (!template && outError != NULL) [*outError retain];
    [pool drain];
	if (!template && outError != NULL) [*outError autorelease];
	return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [self renderObject:object fromResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (!template && outError != NULL) [*outError retain];
    [pool drain];
	if (!template && outError != NULL) [*outError autorelease];
	return [result autorelease];
}

- (NSString *)render {
	return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object {
	return [self renderContext:[GRMustacheContext contextWithObject:object]];
}

- (NSString *)renderObjects:(id)object, ... {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    NSString *result = [[self renderContext:context] retain];
    [pool drain];
    return [result autorelease];
}

+ (void)object:(id)object kind:(GRMustacheObjectKind *)outKind boolValue:(BOOL *)outBoolValue
{
    if (object == nil ||
        object == [NSNull null] ||
        object == [GRNo no] ||
        (void *)object == (void *)kCFBooleanFalse ||
        ([object isKindOfClass:[NSString class]] && ((NSString*)object).length == 0))
    {
        if (outKind != NULL) {
            *outKind = GRMustacheObjectKindFalseValue;
        }
        if (outBoolValue != NULL) {
            *outBoolValue = NO;
        }
    } else {
        if (outKind != NULL) {
            if ([object conformsToProtocol:@protocol(GRMustacheHelper)]) {
                *outKind = GRMustacheObjectKindLambda;
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                *outKind = GRMustacheObjectKindTrueValue;
            } else if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
                *outKind = GRMustacheObjectKindEnumerable;
            } else {
                *outKind = GRMustacheObjectKindTrueValue;
            }
        }
        if (outBoolValue != NULL) {
            *outBoolValue = YES;
        }
    }
}

#pragma mark - Private

- (id)initWithElements:(NSArray *)theElems options:(GRMustacheTemplateOptions)theOptions {
	if ((self = [self init])) {
		self.elems = theElems;
        self.options = theOptions;
	}
	return self;
}

@end
