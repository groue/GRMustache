// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRMustacheRendering_private.h"
#import "GRBoolean_private.h"


@interface GRMustacheTemplate()
- (id)initWithElements:(NSArray *)theElems;
@end

@implementation GRMustacheTemplate
@synthesize elems;


+ (id)parseString:(NSString *)templateString error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:[NSBundle mainBundle]]
			parseString:templateString
			error:outError];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
	id loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[url URLByDeletingLastPathComponent] extension:[url pathExtension]];
	NSAssert([loader isKindOfClass:[GRMustacheDirectoryURLTemplateLoader class]], @"");
	return [(GRMustacheDirectoryURLTemplateLoader *)loader parseContentsOfURL:url error:outError];
}
#endif

+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError {
	id loader = [GRMustacheTemplateLoader templateLoaderWithDirectory:[path stringByDeletingLastPathComponent] extension:[path pathExtension]];
	NSAssert([loader isKindOfClass:[GRMustacheDirectoryPathTemplateLoader class]], @"");
	return [(GRMustacheDirectoryPathTemplateLoader *)loader parseContentsOfFile:path error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle]
			parseTemplateNamed:name
			error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle extension:ext]
			parseTemplateNamed:name
			error:outError];
}

+ (id)templateWithElements:(NSArray *)elems {
	return [[[self alloc] initWithElements:elems] autorelease];
}

- (id)initWithElements:(NSArray *)theElems {
	if ((self = [self init])) {
		self.elems = theElems;
	}
	return self;
}

- (void)dealloc {
	[elems release];
	[super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (outError != NULL) [*outError retain];
    [pool drain];
	if (outError != NULL) [*outError autorelease];
	return [result autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfURL:url error:outError];
	NSString *result = [[template renderObject:object] retain];
	if (outError != NULL) [*outError retain];
    [pool drain];
	if (outError != NULL) [*outError autorelease];
	return [result autorelease];
}
#endif

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfFile:path error:outError];
	NSString *result = [[template renderObject:object] retain];
	if (outError != NULL) [*outError retain];
    [pool drain];
	if (outError != NULL) [*outError autorelease];
	return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name bundle:bundle error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (outError != NULL) [*outError retain];
    [pool drain];
	if (outError != NULL) [*outError autorelease];
	return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle error:outError];
    NSString *result = [[template renderObject:object] retain];
	if (outError != NULL) [*outError retain];
    [pool drain];
	if (outError != NULL) [*outError autorelease];
	return [result autorelease];
}

- (NSString *)render {
	return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object {
	return [self renderContext:[GRMustacheContext contextWithObject:object]];
}

- (NSString *)renderObjects:(id)object, ... {
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    NSMutableString *result = [NSMutableString string];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (id<GRMustacheRenderingElement> elem in elems) {
        [result appendString:[elem renderContext:context]];
    }
    [pool drain];
    return result;
}

+ (BOOL)objectIsFalseValue:(id)object {
	return (object == nil ||
			object == [NSNull null] ||
			object == [GRNo no] ||
			(void *)object == (void *)kCFBooleanFalse ||
			([object isKindOfClass:[NSString class]] && ((NSString*)object).length == 0));
}

+ (GRMustacheObjectKind)objectKind:(id)object {
	if ([self objectIsFalseValue:object]) {
		return GRMustacheObjectKindFalseValue;
	}
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		return GRMustacheObjectKindTrueValue;
	}
	
	if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
		return GRMustacheObjectKindEnumerable;
	}
	
	// TODO: why can't we test for protocol on iOS?
	// if ([object conformsToProtocol:@protocol(GRMustacheHelper)]) -> tests fails on iOS
	if ([object respondsToSelector:@selector(renderObject:withSection:)]) {
		return GRMustacheObjectKindLambda;
	}
	
	return GRMustacheObjectKindTrueValue;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
    NSMutableString *result = [NSMutableString string];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (id<GRMustacheRenderingElement> elem in elems) {
        [result appendString:[elem renderContext:context]];
    }
    [pool drain];
    return result;
}

@end
