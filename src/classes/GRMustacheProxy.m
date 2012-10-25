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

#import "GRMustacheProxy_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustache_private.h"

@implementation GRMustacheProxy

- (void)dealloc
{
    [_delegate release];
    [super dealloc];
}

- (id)init
{
    return [super init];
}

- (id)initWithDelegate:(id)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)loadDelegate
{
    // do nothing
}

- (id)delegate
{
    if (!_delegate) {
        [self loadDelegate];
        if (!_delegate) {
            [NSException raise:NSInternalInconsistencyException format:@"-[GRMustacheProxy delegate]: expected loadDelegate to set the delegate."];
        }
    }
    return _delegate;
}

- (void)setDelegate:(id)delegate
{
    if (!delegate) {
        [NSException raise:NSInvalidArgumentException format:@"-[GRMustacheProxy setDelegate:]: delegate cannot be nil. Use [NSNull null] instead."];
    }
    
    if (delegate != _delegate) {
        [_delegate release];
        _delegate = [delegate retain];
    }
}

- (id)valueForKey:(NSString *)key
{
    // First perform a lookup in self (using the NSObject implementation of
    // valueForKey:, not this method).
    id value = [GRMustacheRuntime valueForKey:key inSuper:&(struct objc_super){ self, [NSObject class] }];
    if (value) {
        return value;
    }
    
    // ... and on failure, ask delegate (using GRMustacheRuntime support for
    // NSUndefinedKeyException prevention):
    return [GRMustacheRuntime valueForKey:key inObject:self.delegate];
}


#pragma mark - <GRMustacheRenderingObject>

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    id<GRMustacheRenderingObject> renderingObject = [GRMustache renderingObjectForValue:self.delegate];
    runtime = [runtime runtimeByAddingContextObject:self];
    return [renderingObject renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
}

@end

