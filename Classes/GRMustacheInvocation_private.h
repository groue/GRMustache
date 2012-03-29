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
#import "GRMustache_private.h"

@class GRMustacheContext;
@class GRMustacheToken;

@interface GRMustacheInvocation : NSObject {
@private
    id _returnValue;
    GRMustacheToken *_token;
    id _templateID;
@protected
    GRMustacheTemplateOptions _options;
}
@property (nonatomic, readonly) NSString *key GRMUSTACHE_API_PUBLIC;
@property (nonatomic, retain) id returnValue GRMUSTACHE_API_PUBLIC;
@property (nonatomic, retain, readonly) NSString *description GRMUSTACHE_API_PUBLIC;
+ (id)invocationWithToken:(GRMustacheToken *)token templateID:(id)templateID keys:(NSArray *)keys options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_INTERNAL;
- (void)invokeWithContext:(GRMustacheContext *)context GRMUSTACHE_API_INTERNAL;
@end
