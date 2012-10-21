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


#pragma mark - Proxy

// Support for optional methods of protocols used by GRMustache:
// NSFastEnumeration, GRMustacheSectionTagHelper, GRMustacheVariableTagHelper, GRMustacheTemplateDelegate
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.delegate respondsToSelector:aSelector];
}

// Support for NSNull
- (BOOL)isKindOfClass:(Class)aClass
{
    if ([super isKindOfClass:aClass]) {
        return YES;
    }
    return [self.delegate isKindOfClass:aClass];
}

// Support for optional methods of protocols used by GRMustache:
// NSFastEnumeration, GRMustacheSectionTagHelper, GRMustacheVariableTagHelper, GRMustacheTemplateDelegate
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    if ([super conformsToProtocol:aProtocol]) {
        return YES;
    }
    return [self.delegate conformsToProtocol:aProtocol];
}

// https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/nsobject_Class/Reference/Reference.html
//
// > This method is used in the implementation of protocols. This method is also
// > used in situations where an NSInvocation object must be created, such as
// > during message forwarding. If your object maintains a delegate or is
// > capable of handling messages that it does not directly implement, you
// > should override this method to return an appropriate method signature.
- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [self.delegate methodSignatureForSelector:aSelector];
    }
    return signature;
}

// Support for optional methods of protocols used by GRMustache:
// NSFastEnumeration, GRMustacheSectionTagHelper, GRMustacheVariableTagHelper, GRMustacheTemplateDelegate
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    id delegate = self.delegate;
    if ([delegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:delegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

// Support for {{ proxy }}
- (NSString *)description
{
    return [self.delegate description];
}

// Support for {{ proxy.key }}
- (id)valueForKey:(NSString *)key
{
    // First perform a lookup in self (using the NSObject implementation of valueForKey:)
    id value = [GRMustacheRuntime valueForKey:key inSuper:&(struct objc_super){ self, [NSObject class] }];
    if (value) {
        return value;
    }
    
    // ... and on failure, ask delegate
    return [self.delegate valueForKey:key];
}

@end

