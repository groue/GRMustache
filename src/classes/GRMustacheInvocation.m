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

@interface GRMustacheInvocationKey:GRMustacheInvocation {
@private
    BOOL _implicitIterator;
    NSString *_key;
}
- (id)initWithToken:(GRMustacheToken *)token key:(NSArray *)keys;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKeyPath

typedef void (*GRMustacheInvocationKeyPathFunction)(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext);

@interface GRMustacheInvocationKeyPath:GRMustacheInvocation {
@private
    GRMustacheInvocationKeyPathFunction *_invocationFunctions;
    NSArray *_keys;
    NSString *_lastUsedKey;
}
- (id)initWithToken:(GRMustacheToken *)token keys:(NSArray *)keys;
- (GRMustacheInvocationKeyPathFunction)invocationFunctionForKey:(NSString *)key;
@end


// =============================================================================
#pragma mark - GRMustacheInvocation

@interface GRMustacheInvocation()
- (id)initWithToken:(GRMustacheToken *)token;
@end

@implementation GRMustacheInvocation
@synthesize returnValue=_returnValue;
@dynamic key;

+ (id)invocationWithToken:(GRMustacheToken *)token keys:(NSArray *)keys
{
    if (keys.count > 1) {
        return [[[GRMustacheInvocationKeyPath alloc] initWithToken:token keys:keys] autorelease];
    } else {
        return [[[GRMustacheInvocationKey alloc] initWithToken:token key:[keys objectAtIndex:0]] autorelease];
    }
}

- (id)initWithToken:(GRMustacheToken *)token
{
    self = [self init];
    if (self) {
        _token = [token retain];
    }
    return self;
}

- (void)dealloc
{
    [_token release];
    [_returnValue release];
    [super dealloc];
}

- (NSString *)description
{
    if (_token.templateID) {
        return [NSString stringWithFormat:@"%@ at line %d of template %@", [_token.templateString substringWithRange:_token.range], _token.line, _token.templateID];
    } else {
        return [NSString stringWithFormat:@"%@ at line %d", [_token.templateString substringWithRange:_token.range], _token.line];
    }
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

- (id)initWithToken:(GRMustacheToken *)token key:(NSString *)key
{
    self = [self initWithToken:token];
    if (self) {
        _key = [key retain];
        _implicitIterator = [key isEqualToString:@"."];
    }
    return self;
}

- (NSString *)key
{
    return [[_key retain] autorelease];
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

static void invokeImplicitIteratorKeyPath(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext) {
    *inOutScoped = YES;
}

static void invokeOtherKeyPath(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext) {
    *inOutContext = [*inOutContext contextForKey:key scoped:*inOutScoped];
    *inOutScoped = YES;
}

@implementation GRMustacheInvocationKeyPath

- (void)dealloc
{
    [_keys release];
    free(_invocationFunctions);
    [super dealloc];
}

- (id)initWithToken:(GRMustacheToken *)token keys:(NSArray *)keys
{
    self = [self initWithToken:token];
    if (self) {
        _keys = [keys retain];
        GRMustacheInvocationKeyPathFunction *f = _invocationFunctions = malloc(keys.count*sizeof(GRMustacheInvocationKeyPathFunction));
        for (NSString *key in _keys) {
            *(f++) = [self invocationFunctionForKey:key];
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
    GRMustacheInvocationKeyPathFunction *f = _invocationFunctions;
    for (_lastUsedKey in _keys) {
        (*(f++))(_lastUsedKey, &scoped, &context);
        if (!context) {
            self.returnValue = nil;
            return;
        }
    }
    self.returnValue = context.object;
}


#pragma mark Private

- (GRMustacheInvocationKeyPathFunction)invocationFunctionForKey:(NSString *)key
{
    if ([key isEqualToString:@"."]) {
        return invokeImplicitIteratorKeyPath;
    } else {
        return invokeOtherKeyPath;
    }
}
@end

