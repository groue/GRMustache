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
#import "GRMustacheToken_private.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKey

/**
 * Private subclass of GRMustacheInvocation that deals with single-key
 * invocations, for tags such as `{{name}}`.
 */
@interface GRMustacheInvocationKey:GRMustacheInvocation {
@private
    BOOL _implicitIterator;
    NSString *_key;
}
- (id)initWithKey:(NSString *)key;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKeyPath

/**
 * Private subclass of GRMustacheInvocation that deals with compound keys
 * invocations, for tags such as `{{person.name}}`.
 */
@interface GRMustacheInvocationKeyPath:GRMustacheInvocation {
@private
    BOOL *_actualKey;
    NSArray *_keys;
    NSString *_lastUsedKey;
}
- (id)initWithKeys:(NSArray *)keys;
@end


// =============================================================================
#pragma mark - GRMustacheInvocation

@implementation GRMustacheInvocation
@synthesize token=_token;
@synthesize returnValue=_returnValue;
@dynamic key;

+ (id)invocationWithKeys:(NSArray *)keys
{
    if (keys.count > 1) {
        return [[[GRMustacheInvocationKeyPath alloc] initWithKeys:keys] autorelease];
    } else {
        return [[[GRMustacheInvocationKey alloc] initWithKey:[keys lastObject]] autorelease];
    }
}

- (void)dealloc
{
    [_token release];
    [_returnValue release];
    [super dealloc];
}

- (NSString *)description
{
    NSAssert(_token, @"Token not set");
    if (_token.templateID) {
        return [NSString stringWithFormat:@"%@ at line %lu of template %@", _token.templateSubstring, (unsigned long)_token.line, _token.templateID];
    } else {
        return [NSString stringWithFormat:@"%@ at line %lu", _token.templateSubstring, (unsigned long)_token.line];
    }
}

- (NSArray *)keys
{
    NSAssert(NO, @"abstract method");
    return nil;
}

- (void)invokeWithContext:(GRMustacheContext *)context
{
    NSAssert(NO, @"abstract method");
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKey

@implementation GRMustacheInvocationKey

- (void)dealloc
{
    [_key release];
    [super dealloc];
}

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = [key retain];
        _implicitIterator = [_key isEqualToString:@"."];
    }
    return self;
}

- (NSString *)key
{
    return [[_key retain] autorelease];
}

- (NSArray *)keys
{
    return [NSArray arrayWithObject:_key];
}

- (void)invokeWithContext:(GRMustacheContext *)context
{
    if (_implicitIterator) {
        self.returnValue = context.object;
    } else {
        self.returnValue = [context valueForKey:_key scoped:NO];
    }
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKeyPath

@implementation GRMustacheInvocationKeyPath
@synthesize keys=_keys;

- (void)dealloc
{
    [_keys release];
    free(_actualKey);
    [super dealloc];
}

- (id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        _keys = [keys retain];
        BOOL *actualKey = _actualKey = malloc(_keys.count*sizeof(BOOL));
        for (NSString *key in _keys) {
            *(actualKey++) = ![key isEqualToString:@"."];
        }
    }
    return self;
}

- (NSString *)key
{
    return [[_lastUsedKey retain] autorelease];
}

- (void)invokeWithContext:(GRMustacheContext *)context
{
    BOOL scoped = NO;
    BOOL *actualKey = _actualKey;
    for (_lastUsedKey in _keys) {
        if (*(actualKey++)) {
            context = [GRMustacheContext contextWithObject:[context valueForKey:_lastUsedKey scoped:scoped]];
        }
        if (!context) {
            self.returnValue = nil;
            return;
        }
        scoped = YES;
    }
    self.returnValue = context.object;
}

@end

