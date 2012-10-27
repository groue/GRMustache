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
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheTemplateComponent_private.h"

@class GRMustacheExpression;
@class GRMustacheTemplateRepository;
@class GRMustacheContext;

// Documented in GRMustacheTag.h
typedef enum {
    GRMustacheTagTypeVariable = 1 << 1,
    GRMustacheTagTypeSection = 1 << 2,
    GRMustacheTagTypeOverridableSection = 1 << 3,
    GRMustacheTagTypeInvertedSection = 1 << 4,
} GRMustacheTagType;

// Documented in GRMustacheTag.h
@interface GRMustacheTag: NSObject<GRMustacheTemplateComponent> {
    GRMustacheExpression *_expression;
    GRMustacheTemplateRepository *_templateRepository;
}

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTagType type GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

/**
 * TODO
 */
@property (nonatomic, readonly) BOOL escapesHTML GRMUSTACHE_API_INTERNAL;

/**
 * TODO
 */
@property (nonatomic, retain, readonly) GRMustacheExpression *expression GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheTag.h
- (NSString *)renderContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error GRMUSTACHE_API_PUBLIC;

/**
 * TODO
 */
- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression GRMUSTACHE_API_INTERNAL;
@end
