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

#import <Foundation/Foundation.h>
#import "GRMustacheTemplateDelegate.h"

@protocol GRMustacheTemplateDelegate;
@class GRMustacheTemplate;
@class GRMustacheToken;

#if !defined(NS_BLOCK_ASSERTIONS)
/**
 * This global variable is used by GRPreventNSUndefinedKeyExceptionAttackTest.
 */
extern BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

@interface GRMustacheRuntime : NSObject {
    BOOL _parentHasContext;
    BOOL _parentHasFilter;
    BOOL _parentHasTemplateDelegate;
    GRMustacheRuntime *_parent;
    GRMustacheTemplate *_template;
    id<GRMustacheTemplateDelegate> _templateDelegate;
    id _contextObject;
    id _filterObject;
}
+ (void)preventNSUndefinedKeyExceptionAttack;
+ (id)valueForKey:(NSString *)key inObject:(id)object;

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObject:(id)contextObject;
+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObjects:(NSArray *)contextObjects;
- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate;
- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject;
- (GRMustacheRuntime *)runtimeByAddingFilterObject:(id)filterObject;

- (id)contextValueForKey:(NSString *)key;
- (id)filterValueForKey:(NSString *)key;
- (id)currentContextValue;

- (void)delegateValue:(id)value fromToken:(GRMustacheToken *)token interpretation:(GRMustacheInterpretation)interpretation usingBlock:(void(^)(id value))block;

@end
