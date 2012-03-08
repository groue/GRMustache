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
#pragma mark - Invocation functions

typedef void (*GRMustacheInvocationFunction)(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext);

static void invokeImplicitIteratorKey(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext) {
    *inOutScoped = YES;
}

static void invokePopKey(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext) {
    *inOutScoped = NO;
    *inOutContext = (*inOutContext).parent;
}

static void invokeOtherKey(NSString *key, BOOL *inOutScoped, GRMustacheContext **inOutContext) {
    *inOutContext = [*inOutContext contextForKey:key scoped:*inOutScoped];
    *inOutScoped = YES;
}


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKey

@interface GRMustacheInvocationKey:GRMustacheInvocation {
@private
    GRMustacheInvocationFunction _invocationFunction;
    NSString *_key;
}
- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId key:(NSArray *)keys;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKeyPath

@interface GRMustacheInvocationKeyPath:GRMustacheInvocation {
@private
    GRMustacheInvocationFunction *_invocationFunctions;
    NSArray *_keys;
    NSString *_lastUsedKey;
}
- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId keys:(NSArray *)keys;
@end


// =============================================================================
#pragma mark - GRMustacheInvocation

@interface GRMustacheInvocation()
- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId;
- (GRMustacheInvocationFunction)invocationFunctionForKey:(NSString *)key;
@end

@implementation GRMustacheInvocation
@synthesize returnValue=_returnValue;
@dynamic key;

+ (id)invocationWithToken:(GRMustacheToken *)token templateId:(id)templateId keys:(NSArray *)keys
{
    if (keys.count > 1) {
        return [[[GRMustacheInvocationKeyPath alloc] initWithToken:token templateId:templateId keys:keys] autorelease];
    } else {
        return [[[GRMustacheInvocationKey alloc] initWithToken:token templateId:templateId key:[keys objectAtIndex:0]] autorelease];
    }
}

- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId
{
    self = [self init];
    if (self) {
        _token = [token retain];
        _templateId = [templateId retain];
    }
    return self;
}

- (void)dealloc
{
    [_token release];
    [_templateId release];
    [_returnValue release];
    [super dealloc];
}

- (NSString *)description
{
    if (_templateId) {
        return [NSString stringWithFormat:@"%@ at line %d of template %@", [_token.templateString substringWithRange:_token.range], _token.line, _templateId];
    } else {
        return [NSString stringWithFormat:@"%@ at line %d", [_token.templateString substringWithRange:_token.range], _token.line];
    }
}

- (void)invokeWithContext:(GRMustacheContext *)context
{
    // abstract method
}

#pragma mark Private

- (GRMustacheInvocationFunction)invocationFunctionForKey:(NSString *)key
{
    if ([key isEqualToString:@"."] || [key isEqualToString:@"this"]) {
        return invokeImplicitIteratorKey;
    } else if ([key isEqualToString:@".."]) {
        return invokePopKey;
    } else {
        return invokeOtherKey;
    }
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

- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId key:(NSString *)key
{
    self = [self initWithToken:token templateId:templateId];
    if (self) {
        _key = [key retain];
        _invocationFunction = [self invocationFunctionForKey:key];
    }
    return self;
}

- (NSString *)key
{
    return [[_key retain] autorelease];
}

- (void)invokeWithContext:(GRMustacheContext *)context
{
    BOOL scoped = NO;
    _invocationFunction(_key, &scoped, &context);
    self.returnValue = context.object;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheInvocationKeyPath

@implementation GRMustacheInvocationKeyPath

- (void)dealloc
{
    [_keys release];
    free(_invocationFunctions);
    [super dealloc];
}

- (id)initWithToken:(GRMustacheToken *)token templateId:(id)templateId keys:(NSArray *)keys
{
    self = [self initWithToken:token templateId:templateId];
    if (self) {
        _keys = [keys retain];
        GRMustacheInvocationFunction *f = _invocationFunctions = malloc(keys.count*sizeof(GRMustacheInvocationFunction));
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
    GRMustacheInvocationFunction *f = _invocationFunctions;
    for (_lastUsedKey in _keys) {
        (*(f++))(_lastUsedKey, &scoped, &context);
        if (!context) {
            self.returnValue = nil;
            return;
        }
    }
    self.returnValue = context.object;
}

@end

