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

#import "GRMustacheInvocation_private.h"
#import "GRMustacheContext_private.h"

@interface GRMustacheInvocation()
- (id)initWithKeys:(NSArray *)keys;
@end

@implementation GRMustacheInvocation

+ (id)invocationWithKeys:(NSArray *)keys
{
    return [[[GRMustacheInvocation alloc] initWithKeys:keys] autorelease];
}

- (void)dealloc
{
    [keys release];
    [super dealloc];
}

- (id)initWithKeys:(NSArray *)theKeys
{
    self = [super init];
    if (self) {
        keys = [theKeys retain];
    }
    return self;
}

- (id)invokeWithContext:(GRMustacheContext *)context
{
    BOOL scoped = NO;
    for (NSString *key in keys) {
        if ([key isEqualToString:@"."] || [key isEqualToString:@"this"]) {
            scoped = YES;
        } else if ([key isEqualToString:@".."]) {
            context = context.parent;
            scoped = NO;
        } else {
            context = [context contextForKey:key scoped:scoped];
            scoped = YES;
        }
        if (!context) {
            break;
        }
    }
    return context.object;
}

@end
