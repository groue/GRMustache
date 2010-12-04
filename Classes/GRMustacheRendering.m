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

#import "GRMustacheRendering_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustache_private.h"


@implementation GRMustacheSectionElement(Rendering)

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	NSMutableString *buffer= [NSMutableString stringWithCapacity:1024];
	
	switch([GRMustache objectKind:value]) {
		case GRMustacheObjectKindFalseValue:
			if (inverted) {
				for (id<GRMustacheRenderingElement> elem in elems) {
					[buffer appendString:[elem renderContext:context]];
				}
			}
			break;
			
		case GRMustacheObjectKindTrueValue:
			if (!inverted) {
				GRMustacheContext *innerContext = [GRMustacheContext contextWithObject:value parent:context];
				for (id<GRMustacheRenderingElement> elem in elems) {
					[buffer appendString:[elem renderContext:innerContext]];
				}
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
					for (id<GRMustacheRenderingElement> elem in elems) {
						[buffer appendString:[elem renderContext:context]];
					}
				}
			} else {
				for (id object in value) {
					GRMustacheContext *innerContext = [GRMustacheContext contextWithObject:object parent:context];
					for (id<GRMustacheRenderingElement> elem in elems) {
						[buffer appendString:[elem renderContext:innerContext]];
					}
				}
			}
			break;
			
		case GRMustacheObjectKindLambda:
			if (!inverted) {
				GRMustacheRenderer renderer = ^(id object){
					GRMustacheContext *renderedContext;
					if ([object isKindOfClass:[GRMustacheContext class]]) {
						renderedContext = object;
					} else {
						renderedContext = [GRMustacheContext contextWithObject:object parent:context];
					}
					NSMutableString *result = [NSMutableString stringWithCapacity:1024];
					for (id<GRMustacheRenderingElement> elem in elems) {
						[result appendString:[elem renderContext:renderedContext]];
					}
					return (NSString *)result;
				};
				[buffer appendString:[(GRMustacheLambdaBlockWrapper *)value renderObject:context
																			  fromString:templateString
																				renderer:renderer]];
			}
			break;
			
		default:
			// should not be here
			NSAssert(NO, nil);
	}
	
	return buffer;
}

@end

@implementation GRMustacheTemplate(Rendering)

- (NSString *)renderContext:(GRMustacheContext *)context {
	if (elems == nil) {
		return @"";
	}
	NSMutableString *buffer = [NSMutableString string];
	for (id<GRMustacheRenderingElement> elem in elems) {
		[buffer appendString:[elem renderContext:context]];
	}
	return buffer;
}

@end

@implementation GRMustacheTextElement(Rendering)

- (NSString *)renderContext:(GRMustacheContext *)context {
	return text;
}

@end

@implementation GRMustacheVariableElement(Rendering)

- (NSString *)htmlEscape:(NSString *)string {
	NSMutableString *result = [NSMutableString stringWithCapacity:5 + ceilf(string.length * 1.1)];
	[result appendString:string];
	[result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	return result;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	if ([GRMustache objectIsFalseValue:value]) {
		return @"";
	}
	if (raw) {
		return [value description];
	}
	return [self htmlEscape:[value description]];
}

@end

