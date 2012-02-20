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

#import "GRMustacheSection+RenderingElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheTemplate_private.h"

@implementation GRMustacheSection (RenderingElement)

- (NSString *)renderContext:(GRMustacheContext *)context {
    NSString *result = nil;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id value = [invocation invokeWithContext:context];
    GRMustacheObjectKind kind;
    [GRMustacheTemplate object:value kind:&kind boolValue:NULL];
    switch(kind) {
        case GRMustacheObjectKindFalseValue:
            if (inverted) {
                result = [[NSMutableString string] retain];
                for (id<GRMustacheRenderingElement> elem in elems) {
                    [(NSMutableString *)result appendString:[elem renderContext:context]];
                }
            }
            break;
            
        case GRMustacheObjectKindTrueValue:
            if (!inverted) {
                GRMustacheContext *innerContext = [context contextByAddingObject:value];
                result = [[NSMutableString string] retain];
                for (id<GRMustacheRenderingElement> elem in elems) {
                    [(NSMutableString *)result appendString:[elem renderContext:innerContext]];
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
                    result = [[NSMutableString string] retain];
                    for (id<GRMustacheRenderingElement> elem in elems) {
                        [(NSMutableString *)result appendString:[elem renderContext:context]];
                    }
                }
            } else {
                result = [[NSMutableString string] retain];
                for (id object in value) {
                    GRMustacheContext *innerContext = [context contextByAddingObject:object];
                    for (id<GRMustacheRenderingElement> elem in elems) {
                        [(NSMutableString *)result appendString:[elem renderContext:innerContext]];
                    }
                }
            }
            break;
            
        case GRMustacheObjectKindLambda:
            if (!inverted) {
                result = [[(id<GRMustacheHelper>)value renderSection:self withContext:context] retain];
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
