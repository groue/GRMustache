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
#import "GRBoolean.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheLambda_private.h"

static inline void appendRenderingElementsWithContext(NSMutableString *buffer, NSArray *elems, GRMustacheContext *context) {
    for (id<GRMustacheRenderingElement> elem in elems) {
        [buffer appendString:[elem renderContext:context]];
    }
}

@implementation GRMustacheSection(PrivateRendering)

- (NSString *)renderContext:(GRMustacheContext *)context {
    NSMutableString *result = nil;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	id value = [context valueForKey:name];
	switch([GRMustacheTemplate objectKind:value]) {
		case GRMustacheObjectKindFalseValue:
			if (inverted) {
                result = [[NSMutableString string] retain];
                appendRenderingElementsWithContext(result, elems, context);
			}
			break;
			
		case GRMustacheObjectKindTrueValue:
			if (!inverted) {
                result = [[NSMutableString string] retain];
                appendRenderingElementsWithContext(result, elems, [context contextByAddingObject:value]);
            }
			break;
			
		case GRMustacheObjectKindEnumerable:
			if (inverted) {
				BOOL empty = YES;
				for (id object in value) {
					empty = NO;
					break;
				}
				if (empty) {
                    result = [[NSMutableString string] retain];
                    appendRenderingElementsWithContext(result, elems, context);
				}
			} else {
                result = [[NSMutableString string] retain];
				for (id object in value) {
                    appendRenderingElementsWithContext(result, elems, [context contextByAddingObject:object]);
				}
			}
			break;

		case GRMustacheObjectKindLambda:
			if (!inverted) {
                result = [[(id<GRMustacheHelper>)value renderObject:context withSection:self] mutableCopy];
            }
			break;
			
		default:
			// should not be here
			NSAssert(NO, @"");
	}
    [pool drain];
    if (!result) {
        return @"";
    }
    return [result autorelease];
}

@end

// support for deprecated [GRNo no];
@interface GRNo()
+ (GRNo *)_no;
@end

@implementation GRMustacheTemplate(PrivateRendering)

+ (BOOL)objectIsFalseValue:(id)object {
	return (object == nil ||
			object == [NSNull null] ||
			object == [GRNo _no] ||
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
    appendRenderingElementsWithContext(result, elems, context);
    [pool drain];
    return result;
}

@end

@implementation GRMustacheTextElement(PrivateRendering)

- (NSString *)renderContext:(GRMustacheContext *)context {
	return text;
}

@end

@implementation GRMustacheVariableElement(PrivateRendering)

- (NSString *)htmlEscape:(NSString *)string {
	NSMutableString *result = [NSMutableString stringWithString:string];
	[result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	return result;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	if ([GRMustacheTemplate objectIsFalseValue:value]) {
		return @"";
	}
	if (raw) {
		return [value description];
	}
	return [self htmlEscape:[value description]];
}

@end

@implementation GRMustacheTemplate(Rendering)

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
    appendRenderingElementsWithContext(result, elems, context);
    [pool drain];
    return result;
}

@end

@implementation GRMustacheSection(Rendering)

- (NSString *)renderObject:(id)object {
    NSMutableString *result = [NSMutableString string];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    appendRenderingElementsWithContext(result, elems, [GRMustacheContext contextWithObject:object]);
    [pool drain];
    return result;
}

- (NSString *)renderObjects:(id)object, ... {
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    NSMutableString *result = [NSMutableString string];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    appendRenderingElementsWithContext(result, elems, context);
    [pool drain];
    return result;
}

@end

