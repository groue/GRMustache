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

#import <Foundation/Foundation.h>
#import "GRMustacheRendering_private.h"
#import "GRMustacheEnvironment.h"

typedef enum {
	GRMustacheObjectKindTrueValue,
	GRMustacheObjectKindFalseValue,
	GRMustacheObjectKindEnumerable,
	GRMustacheObjectKindLambda,
} GRMustacheObjectKind;

@interface GRMustacheTemplate: NSObject<GRMustacheRenderingElement> {
@private
	NSArray *elems;
}
@property (nonatomic, retain) NSArray *elems;

+ (BOOL)objectIsFalseValue:(id)object;

+ (GRMustacheObjectKind)objectKind:(id)object;

+ (id)templateWithElements:(NSArray *)elems;

+ (id)parseString:(NSString *)templateString error:(NSError **)outError;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError;
#endif

+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError;

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError;
#endif

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError;

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;

- (NSString *)renderObject:(id)object;

- (NSString *)renderObjects:(id)object, ...;

- (NSString *)render;

@end
