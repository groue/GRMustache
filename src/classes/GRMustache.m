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

#import "GRMustache_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheVersion.h"
#import "GRMustacheError.h"

@implementation GRMustache

+ (void)load
{
    // We need to initialize GRMustacheFilterException, which is deprecated.
    //
    // We'll temporarily disable deprecation warnings when assigning it.
    //
    // But make sure we do not disable deprecating warnings for
    // GRMustacheRenderingException.
    
    NSString *exception = GRMustacheRenderingException;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GRMustacheFilterException = exception;
#pragma clang diagnostic pop
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    [GRMustacheRuntime preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)version
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

@end
