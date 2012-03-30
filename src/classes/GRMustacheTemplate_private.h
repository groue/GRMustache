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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustache_private.h"
#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheRenderingElement_private.h"

typedef enum {
    GRMustacheObjectKindFalseValue,
    GRMustacheObjectKindTrueValue,
    GRMustacheObjectKindEnumerable,
    GRMustacheObjectKindLambda,
} GRMustacheObjectKind;

@interface GRMustacheTemplate: NSObject<GRMustacheRenderingElement> {
@private
    NSArray *_elems;
    GRMustacheTemplateOptions _options;
    id<GRMustacheTemplateDelegate> _delegate;
}

#pragma mark Objects kinds

+ (void)object:(id)object kind:(GRMustacheObjectKind *)outKind boolValue:(BOOL *)outBoolValue GRMUSTACHE_API_INTERNAL;

#pragma mark Delegate

@property (nonatomic, assign) id<GRMustacheTemplateDelegate> delegate GRMUSTACHE_API_PUBLIC;

#pragma mark Template elements

@property (nonatomic, retain) NSArray *elems GRMUSTACHE_API_INTERNAL;
+ (id)templateWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_INTERNAL;

#pragma mark String template

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark File template

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark Resource template

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark URL template

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (id)templateFromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

#pragma mark Rendering

- (NSString *)renderObject:(id)object GRMUSTACHE_API_PUBLIC;
- (NSString *)renderObjects:(id)object, ... GRMUSTACHE_API_PUBLIC;
- (NSString *)render GRMUSTACHE_API_PUBLIC;

@end
