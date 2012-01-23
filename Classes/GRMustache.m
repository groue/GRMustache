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

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRBoolean_private.h"
#import "GRMustacheVersion.h"

static BOOL strictBooleanMode = NO;
GRMustacheTemplateOptions GRMustacheDefaultTemplateOptions = GRMustacheTemplateOptionNone;

@implementation GRMustache

+ (BOOL)strictBooleanMode {
	return strictBooleanMode;
}

+ (void)setStrictBooleanMode:(BOOL)aBool {
	strictBooleanMode = aBool;
}

+ (void)preventNSUndefinedKeyExceptionAttack {
	[GRMustacheContext preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)version {
	return (GRMustacheVersion){
		.major = GRMUSTACHE_MAJOR_VERSION,
		.minor = GRMUSTACHE_MINOR_VERSION,
		.patch = GRMUSTACHE_PATCH_VERSION };
}

+ (GRMustacheTemplateOptions)defaultTemplateOptions
{
    return GRMustacheDefaultTemplateOptions;
}

+ (void)setDefaultTemplateOptions:(GRMustacheTemplateOptions)templateOptions
{
    GRMustacheDefaultTemplateOptions = templateOptions;
}

+ (BOOL)booleanValue:(id)object {
    if (object == nil) {
        return NO;
    } else if (object == [NSNull null]) {
        return NO;
    } else if (object == [GRNo no]) {
        return NO;
    } else if ((void *)object == (void *)kCFBooleanFalse) {
        return NO;
    } else if ([object isKindOfClass:[NSString class]] && ((NSString*)object).length == 0) {
        return NO;
    } else if ([object conformsToProtocol:@protocol(NSFastEnumeration)] && ![object isKindOfClass:[NSDictionary class]]) {
        BOOL empty = YES;
        for (id item in object) {
            empty = NO;
            break;
        }
        return !empty;
    }
	return YES;
}

@end
