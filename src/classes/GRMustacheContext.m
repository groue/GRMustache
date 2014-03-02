// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

#import <objc/runtime.h>
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheTagDelegate.h"


// =============================================================================
#pragma mark - GRMustacheContext

@interface GRMustacheContext()

// `depthsForAncestors` returns a dictionary where keys are ancestor context
// objects, and values depth numbers: self has depth 0, parent has depth 1,
// grand-parent has depth 2, etc.
@property (nonatomic, readonly) NSDictionary *depthsForAncestors;

// `ancestors` returns an array of ancestor contexts.
// First context in the array is the root context.
// Last context in the array is self.
@property (nonatomic, readonly) NSArray *ancestors;

@end


@implementation GRMustacheContext

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    if (_partialOverride) {
        for (GRMustacheContext *context = self; context; context = context->_partialOverrideParent) {
            component = [context->_partialOverride resolveTemplateComponent:component];
        }
    }
    return component;
}


// =============================================================================
#pragma mark - Creating Contexts

+ (instancetype)context
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)contextWithObject:(id)object
{
    if ([object isKindOfClass:[GRMustacheContext class]]) {
        // The rule is: contexts derived from class A should be instances of class A as well.
        if (![object isKindOfClass:self]) {
            [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of %@: can not extend context.", [object class], self];
        }
        return object;
    }
    
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize context stack
    context->_contextObject = [object retain];
        
    // initialize tag delegate stack
    if ([self objectIsTagDelegate:object]) {
        context->_tagDelegate = [object retain];
    }
    
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize protected context stack
    context->_protectedContextObject = [object retain];
    
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize tag delegate stack
    context->_tagDelegate = [tagDelegate retain];
    
    return context;
}

- (void)dealloc
{
    [_contextParent release];
    [_contextObject release];
    [_protectedContextParent release];
    [_protectedContextObject release];
    [_hiddenContextParent release];
    [_hiddenContextObject release];
    [_tagDelegateParent release];
    [_tagDelegate release];
    [_partialOverrideParent release];
    [_partialOverride release];
    [_depthsForAncestors release];
    [super dealloc];
}


// =============================================================================
#pragma mark - Deriving Contexts

+ (instancetype)newContextWithParent:(GRMustacheContext *)parent addedObject:(id)object
{
    if (object == nil) {
        return [parent retain];
    }
    
    GRMustacheContext *context = nil;
    
    if ([object isKindOfClass:[GRMustacheContext class]])
    {
        // Extend parent with a context
        //
        // Contexts are immutable stacks: we duplicate all ancestors of context,
        // in order to build a new context stack.
        
        context = parent;
        for (GRMustacheContext *ancestor in ((GRMustacheContext *)object).ancestors) {
            
            // The rule is: contexts derived from class A should be instances of class A as well.
            if (![ancestor isKindOfClass:[context class]]) {
                [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of %@: can not extend context.", [ancestor class], [context class]];
            }
            
            GRMustacheContext *extendedContext = [[[[ancestor class] alloc] init] autorelease];
            
            extendedContext->_contextParent = [context retain];
            extendedContext->_contextObject = [ancestor->_contextObject retain];
            extendedContext->_protectedContextParent = [ancestor->_protectedContextParent retain];
            extendedContext->_protectedContextObject = [ancestor->_protectedContextObject retain];
            extendedContext->_hiddenContextParent = [ancestor->_hiddenContextParent retain];
            extendedContext->_hiddenContextObject = [ancestor->_hiddenContextObject retain];
            extendedContext->_tagDelegateParent = [ancestor->_tagDelegateParent retain];
            extendedContext->_tagDelegate = [ancestor->_tagDelegate retain];
            extendedContext->_partialOverrideParent = [ancestor->_partialOverrideParent retain];
            extendedContext->_partialOverride = [ancestor->_partialOverride retain];
            
            context = extendedContext;
        };
        
        [context retain];
    }
    else
    {
        // Extend parent with a regular object
        
        context = [[[self class] alloc] init];
        
        // copy identical stacks
        context->_protectedContextParent = [parent->_protectedContextParent retain];
        context->_protectedContextObject = [parent->_protectedContextObject retain];
        context->_hiddenContextParent = [parent->_hiddenContextParent retain];
        context->_hiddenContextObject = [parent->_hiddenContextObject retain];
        context->_partialOverrideParent = [parent->_partialOverrideParent retain];
        context->_partialOverride = [parent->_partialOverride retain];
        
        // Update context stack
        context->_contextParent = [parent retain];
        context->_contextObject = [object retain];
        
        // update or copy tag delegate stack
        if ([GRMustacheContext objectIsTagDelegate:object]) {
            if (parent->_tagDelegate) { context->_tagDelegateParent = [parent retain]; }
            context->_tagDelegate = [object retain];
        } else {
            context->_tagDelegateParent = [parent->_tagDelegateParent retain];
            context->_tagDelegate = [parent->_tagDelegate retain];
        }
    }
    
    return context;
}

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update tag delegate stack
    if (_tagDelegate) { context->_tagDelegateParent = [self retain]; }
    context->_tagDelegate = [tagDelegate retain];
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    return [[[self class] newContextWithParent:self addedObject:object] autorelease];
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update protected context stack
    if (_protectedContextObject) { context->_protectedContextParent = [self retain]; }
    context->_protectedContextObject = [object retain];
    
    return context;
}

- (instancetype)contextByAddingHiddenObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update hidden context stack
    if (_hiddenContextObject) { context->_hiddenContextParent = [self retain]; }
    context->_hiddenContextObject = [object retain];
    
    return context;
}

- (instancetype)contextByAddingPartialOverride:(GRMustachePartialOverride *)partialOverride
{
    if (partialOverride == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    
    // update partial override stack
    if (_partialOverride) { context->_partialOverrideParent = [self retain]; }
    context->_partialOverride = [partialOverride retain];
    
    return context;
}

- (NSArray *)ancestors
{
    return [[self depthsForAncestors] keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *depth1, NSNumber *depth2) {
        return -[depth1 compare:depth2];
    }];
}

- (NSDictionary *)depthsForAncestors
{
    if (_depthsForAncestors == nil) {
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys, but manages values (depth numbers)
        CFMutableDictionaryRef depthsForAncestors = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        
        // self has depth 0
        CFDictionarySetValue(depthsForAncestors, self, [NSNumber numberWithUnsignedInteger:0]);
        
        void (^fill)(id key, id obj, BOOL *stop) = ^(GRMustacheContext *ancestor, NSNumber *depth, BOOL *stop) {
            NSUInteger currentDepth = [(NSNumber *)CFDictionaryGetValue(depthsForAncestors, ancestor) unsignedIntegerValue];
            if (currentDepth < [depth unsignedIntegerValue] + 1) {
                CFDictionarySetValue(depthsForAncestors, ancestor, [NSNumber numberWithUnsignedInteger:[depth unsignedIntegerValue] + 1]);
            }
        };
        [[_contextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_protectedContextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_hiddenContextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_tagDelegateParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_partialOverrideParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        
        _depthsForAncestors = (NSDictionary *)depthsForAncestors;
    }
    
    return [[_depthsForAncestors retain] autorelease];
}


// =============================================================================
#pragma mark - Context Stack

- (id)topMustacheObject
{
    for (GRMustacheContext *context = self; context; context = context->_contextParent) {
        if (context->_contextObject) {
            return [[context->_contextObject retain] autorelease];
        }
    }
    return nil;
}

- (id)valueForUndefinedMustacheKey:(NSString *)key
{
    return nil;
}

- (id)valueForMustacheKey:(NSString *)key
{
    return [self valueForMustacheKey:key protected:NULL];
}

- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected
{
    // First look for in the protected context stack
    
    if (_protectedContextObject) {
        for (GRMustacheContext *context = self; context; context = context->_protectedContextParent) {
            id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:context->_protectedContextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = YES;
                }
                return value;
            }
        }
    }
    
    
    // Then look for in the regular context stack
    
    for (GRMustacheContext *context = self; context; context = context->_contextParent) {
        // First check for contextObject:
        //
        // context = [GRMustacheContext contextWithObject:@{key:value}];
        // assert([context valueForKey:key] == value);
        id contextObject = context->_contextObject;
        if (contextObject) {
            BOOL hidden = NO;
            if (_hiddenContextObject) {
                for (GRMustacheContext *hiddenContext = self; hiddenContext; hiddenContext = hiddenContext->_hiddenContextParent) {
                    if (contextObject == hiddenContext->_hiddenContextObject) {
                        hidden = YES;
                        break;
                    }
                }
            }
            if (hidden) { continue; }
            id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:contextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }
    
    
    // Then try valueForUndefinedMustacheKey:
    
    id value = [self valueForUndefinedMustacheKey:key];
    if (value) {
        if (protected != NULL) {
            *protected = NO;
        }
        return value;
    }
    
    
    // OK give up now
    
    return nil;
}

- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)string error:(NSError **)error
{
    GRMustacheExpressionParser *parser = [[[GRMustacheExpressionParser alloc] init] autorelease];
    GRMustacheExpression *expression = [parser parseExpression:string empty:NULL error:error];
    return [expression hasValue:value withContext:self protected:NULL error:error];
}

- (id)valueForMustacheExpression:(NSString *)string error:(NSError **)error
{
    // This deprecated method is flawed: it may return a valid nil result.
    // Let's make sure error is set to nil in this case.
    
    id value = nil;
    if (![self hasValue:&value forMustacheExpression:string error:error]) {
        return nil;
    }
    if (error) { *error = nil; }
    return value;
}


// =============================================================================
#pragma mark - Tag Delegates Stack

- (NSArray *)tagDelegateStack
{
    NSMutableArray *tagDelegateStack = nil;
    
    if (_tagDelegate) {
        tagDelegateStack = [NSMutableArray array];
        for (GRMustacheContext *context = self; context; context = context->_tagDelegateParent) {
            [tagDelegateStack insertObject:context->_tagDelegate atIndex:0];
        }
    }
    
    // If self is a GRMustacheContext subclass and conforms to
    // GRMustacheTagDelegate, self behaves as the first tag delegate in the
    // stack (before all section delegates).
    
    if (object_getClass(self) != [GRMustacheContext class] && [GRMustacheContext objectIsTagDelegate:self]) {
        if (!tagDelegateStack) {
            return [NSArray arrayWithObject:self];
        } else {
            [tagDelegateStack insertObject:self atIndex:0];
        }
    }
    
    return tagDelegateStack;
}

+ (BOOL)objectIsTagDelegate:(id)object
{
    return [object conformsToProtocol:@protocol(GRMustacheTagDelegate)];
}


// =============================================================================
#pragma mark - Key-Value Coding

- (BOOL)isValidMustacheKey:(NSString *)key
{
    return YES;
}

@end
