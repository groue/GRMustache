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

enum {
    GRMustacheTemplateOptionNone = 0,
    GRMustacheTemplateOptionMustacheSpecCompatibility = 0x01,
};

typedef NSUInteger GRMustacheTemplateOptions;

extern GRMustacheTemplateOptions GRMustacheDefaultTemplateOptions;

typedef struct {
    int major;
    int minor;
    int patch;
} GRMustacheVersion;

@interface GRMustache: NSObject

+ (GRMustacheVersion)version GRMUSTACHE_API_PUBLIC;
+ (BOOL)strictBooleanMode GRMUSTACHE_API_PUBLIC;
+ (void)setStrictBooleanMode:(BOOL)aBool GRMUSTACHE_API_PUBLIC;
+ (void)preventNSUndefinedKeyExceptionAttack GRMUSTACHE_API_PUBLIC;
+ (GRMustacheTemplateOptions)defaultTemplateOptions GRMUSTACHE_API_PUBLIC;
+ (void)setDefaultTemplateOptions:(GRMustacheTemplateOptions)templateOptions GRMUSTACHE_API_PUBLIC;

@end
