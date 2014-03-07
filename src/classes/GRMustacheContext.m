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
#import <pthread.h>
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheTagDelegate.h"

#define GRMUSTACHE_STACK_RELEASE(stackName) \
    [GRMUSTACHE_STACK_TOP_IVAR(stackName) release]; \
    [GRMUSTACHE_STACK_PARENT_IVAR(stackName) release]

#define GRMUSTACHE_STACK_INIT(stackName, context, object) \
    GRMUSTACHE_STACK_TOP(stackName, context) = [object retain]

#define GRMUSTACHE_STACK_COPY(stackName, sourceContext, targetContext) \
    GRMUSTACHE_STACK_TOP(stackName, targetContext) = [GRMUSTACHE_STACK_TOP(stackName, sourceContext) retain]; \
    GRMUSTACHE_STACK_PARENT(stackName, targetContext) = [GRMUSTACHE_STACK_PARENT(stackName, sourceContext) retain]

#define GRMUSTACHE_STACK_PUSH(stackName, sourceContext, targetContext, object) \
    if (object) { \
        if (GRMUSTACHE_STACK_TOP(stackName, sourceContext)) { \
            GRMUSTACHE_STACK_PARENT(stackName, targetContext) = [sourceContext retain]; \
        } \
        GRMUSTACHE_STACK_TOP(stackName, targetContext) = [object retain]; \
    } else { \
        GRMUSTACHE_STACK_PARENT(stackName, targetContext) = [sourceContext retain]; \
    }

#define GRMUSTACHE_STACK_TOP(stackName, context) context->GRMUSTACHE_STACK_TOP_IVAR(stackName)

#define GRMUSTACHE_STACK_PARENT(stackName, context) context->GRMUSTACHE_STACK_PARENT_IVAR(stackName)

#define GRMUSTACHE_STACK_BEGIN_FOR(stackName, context) \
    if (GRMUSTACHE_STACK_TOP_IVAR(stackName) || GRMUSTACHE_STACK_PARENT_IVAR(stackName)) { \
        GRMustacheContext *context = self; \
        while (context && GRMUSTACHE_STACK_TOP(stackName, context) == nil) context = GRMUSTACHE_STACK_PARENT(stackName, context); \
        for (; context; context = GRMUSTACHE_STACK_PARENT(stackName, context)) { \
            if (GRMUSTACHE_STACK_TOP(stackName, context)) { \

#define GRMUSTACHE_STACK_END_FOR }}}

// =============================================================================
#pragma mark - GRMustacheTagDelegate conformance

static pthread_key_t GRTagDelegateClassesKey;
void freeTagDelegateClasses(void *objects) {
    CFRelease((CFMutableDictionaryRef)objects);
}
#define setupTagDelegateClasses() pthread_key_create(&GRTagDelegateClassesKey, freeTagDelegateClasses)
#define getCurrentThreadTagDelegateClasses() (CFMutableDictionaryRef)pthread_getspecific(GRTagDelegateClassesKey)
#define setCurrentThreadTagDelegateClasses(classes) pthread_setspecific(GRTagDelegateClassesKey, classes)

static BOOL objectConformsToTagDelegateProtocol(id object)
{
    if (object == nil) {
        return NO;
    }
    
    CFMutableDictionaryRef classes = getCurrentThreadTagDelegateClasses();
    if (!classes) {
        classes = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        setCurrentThreadTagDelegateClasses(classes);
    }
    
    Class klass = [object class];
    intptr_t conform = (intptr_t)CFDictionaryGetValue(classes, klass);
    if (conform == 0) {
        conform = [klass conformsToProtocol:@protocol(GRMustacheTagDelegate)] ? 1 : 2;
        CFDictionarySetValue(classes, klass, (void *)conform);
    }
    return (conform == 1);
}


// =============================================================================
#pragma mark - GRMustacheContext

@implementation GRMustacheContext
@synthesize allowsAllKeys=_allowsAllKeys;

+ (void)initialize
{
    setupTagDelegateClasses();
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    GRMUSTACHE_STACK_BEGIN_FOR(partialOverrideStack, context) {
        component = [GRMUSTACHE_STACK_TOP(partialOverrideStack, context) resolveTemplateComponent:component];
    } GRMUSTACHE_STACK_END_FOR
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
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(contextStack, context, object);
    if (objectConformsToTagDelegateProtocol(object)) {
        GRMUSTACHE_STACK_INIT(tagDelegateStack, context, object);
    }
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(protectedContextStack, context, object);
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    GRMUSTACHE_STACK_INIT(tagDelegateStack, context, tagDelegate);
    return context;
}

- (void)dealloc
{
    GRMUSTACHE_STACK_RELEASE(contextStack);
    GRMUSTACHE_STACK_RELEASE(protectedContextStack);
    GRMUSTACHE_STACK_RELEASE(hiddenContextStack);
    GRMUSTACHE_STACK_RELEASE(tagDelegateStack);
    GRMUSTACHE_STACK_RELEASE(partialOverrideStack);
    [super dealloc];
}


// =============================================================================
#pragma mark - Deriving Contexts

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [GRMustacheContext context];
    context->_allowsAllKeys = _allowsAllKeys;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(partialOverrideStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(tagDelegateStack, self, context, tagDelegate);
    
    return context;
}

- (instancetype)newContextByAddingObject:(id)object
{
    GRMustacheContext *context = [[GRMustacheContext alloc] init];
    context->_allowsAllKeys = _allowsAllKeys;
    
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(partialOverrideStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(contextStack, self, context, object);
    
    if (objectConformsToTagDelegateProtocol(object)) {
        GRMUSTACHE_STACK_PUSH(tagDelegateStack, self, context, object);
    } else {
        GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    }
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    return [[self newContextByAddingObject:object] autorelease];
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    GRMustacheContext *context = [GRMustacheContext context];
    context->_allowsAllKeys = _allowsAllKeys;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(partialOverrideStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(protectedContextStack, self, context, object);
    
    return context;
}

- (instancetype)contextByAddingHiddenObject:(id)object
{
    GRMustacheContext *context = [GRMustacheContext context];
    context->_allowsAllKeys = _allowsAllKeys;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(partialOverrideStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(hiddenContextStack, self, context, object);
    
    return context;
}

- (instancetype)contextByAddingPartialOverride:(GRMustachePartialOverride *)partialOverride
{
    GRMustacheContext *context = [GRMustacheContext context];
    context->_allowsAllKeys = _allowsAllKeys;
    
    GRMUSTACHE_STACK_COPY(contextStack, self, context);
    GRMUSTACHE_STACK_COPY(protectedContextStack, self, context);
    GRMUSTACHE_STACK_COPY(hiddenContextStack, self, context);
    GRMUSTACHE_STACK_COPY(tagDelegateStack, self, context);
    
    GRMUSTACHE_STACK_PUSH(partialOverrideStack, self, context, partialOverride);
    
    return context;
}


// =============================================================================
#pragma mark - Context Stack

- (id)topMustacheObject
{
    GRMUSTACHE_STACK_BEGIN_FOR(contextStack, context) {
        return [[GRMUSTACHE_STACK_TOP(contextStack, context) retain] autorelease];
    } GRMUSTACHE_STACK_END_FOR
    return nil;
}

- (id)valueForMustacheKey:(NSString *)key
{
    return [self valueForMustacheKey:key protected:NULL];
}

- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected
{
    // First look for in the protected context stack
    
    GRMUSTACHE_STACK_BEGIN_FOR(protectedContextStack, context) {
        id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:GRMUSTACHE_STACK_TOP(protectedContextStack, context) allowsAllKeys:context->_allowsAllKeys];
        if (value != nil) {
            if (protected != NULL) {
                *protected = YES;
            }
            return value;
        }
    } GRMUSTACHE_STACK_END_FOR
    
    
    // Then look for in the regular context stack
    
    GRMUSTACHE_STACK_BEGIN_FOR(contextStack, context) {
        // First check for contextObject:
        //
        // context = [GRMustacheContext contextWithObject:@{key:value}];
        // assert([context valueForKey:key] == value);
        id contextObject = GRMUSTACHE_STACK_TOP(contextStack, context);
        BOOL hidden = NO;
        GRMUSTACHE_STACK_BEGIN_FOR(hiddenContextStack, hiddenContext) {
            if (contextObject == GRMUSTACHE_STACK_TOP(hiddenContextStack, hiddenContext)) {
                hidden = YES;
                break;
            }
        } GRMUSTACHE_STACK_END_FOR
        if (hidden) { continue; }
        id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:contextObject allowsAllKeys:context->_allowsAllKeys];
        if (value != nil) {
            if (protected != NULL) {
                *protected = NO;
            }
            return value;
        }
    } GRMUSTACHE_STACK_END_FOR
    
    
    // OK give up now
    
    return nil;
}

- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)string error:(NSError **)error
{
    GRMustacheExpressionParser *parser = [[[GRMustacheExpressionParser alloc] init] autorelease];
    GRMustacheExpression *expression = [parser parseExpression:string empty:NULL error:error];
    return [expression hasValue:value withContext:self protected:NULL error:error];
}


// =============================================================================
#pragma mark - Tag Delegates Stack

- (NSArray *)tagDelegateStack
{
    NSMutableArray *tagDelegateStack = nil;

    GRMUSTACHE_STACK_BEGIN_FOR(tagDelegateStack, context) {
        if (!tagDelegateStack) {
            tagDelegateStack = [NSMutableArray array];
        }
        [tagDelegateStack insertObject:GRMUSTACHE_STACK_TOP(tagDelegateStack, context) atIndex:0];
    } GRMUSTACHE_STACK_END_FOR
    
    return tagDelegateStack;
}

@end
