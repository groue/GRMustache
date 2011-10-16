// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheProperty_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheContextStrategy_private.h"
#import "GRMustacheTemplate_private.h"

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;
static const NSString *GRMustacheContextStrategyStackKey = @"GRMustacheContextStrategyStackKey";


@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
+ (GRMustacheContextStrategy *)currentContextStrategy;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef;
@end


@implementation GRMustacheContext
@synthesize object;
@synthesize parent;

+ (void)resetContextStrategyStack
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    [threadDictionary removeObjectForKey:GRMustacheContextStrategyStackKey];
}

+ (void)pushContextStrategy:(GRMustacheContextStrategy *)contextStrategy
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *contextStrategyStack = [threadDictionary objectForKey:GRMustacheContextStrategyStackKey];
    if (!contextStrategyStack) {
        contextStrategyStack = [NSMutableArray array];
        [threadDictionary setObject:contextStrategyStack forKey:GRMustacheContextStrategyStackKey];
    }
    [contextStrategyStack addObject:contextStrategy];
}

+ (void)popContextStrategy
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *contextStrategyStack = [threadDictionary objectForKey:GRMustacheContextStrategyStackKey];
    NSAssert(contextStrategyStack.count > 0, @"poping from empty context strategy stack");
    [contextStrategyStack removeLastObject];
}

+ (GRMustacheContextStrategy *)currentContextStrategy
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *contextStrategyStack = [threadDictionary objectForKey:GRMustacheContextStrategyStackKey];
    NSUInteger count = contextStrategyStack.count;
    NSAssert(count > 0, @"empty context strategy stack");
    return [[[contextStrategyStack objectAtIndex:count-1] retain] autorelease];
}

+ (void)preventNSUndefinedKeyExceptionAttack {
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object {
	if ([object isKindOfClass:[GRMustacheContext class]]) {
		return object;
	}
	return [[[self alloc] initWithObject:object parent:nil] autorelease];
}

+ (id)contextWithObjects:(id)object, ... {
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *result = [self contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    return result;
}

+ (id)contextWithObject:(id)object andObjectList:(va_list)objectList {
    GRMustacheContext *context = nil;
    if (object) {
        context = [GRMustacheContext contextWithObject:object];
        id eachObject;
        va_list objectListCopy;
        va_copy(objectListCopy, objectList);
        while ((eachObject = va_arg(objectListCopy, id))) {
            context = [context contextByAddingObject:eachObject];
        }
        va_end(objectListCopy);
    } else {
        context = [self contextWithObject:nil];
    }
    return context;
}

- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent {
	if ((self = [self init])) {
		object = [theObject retain];
		parent = [theParent retain];
	}
	return self;
}

- (GRMustacheContext *)contextByAddingObject:(id)theObject {
	return [[[GRMustacheContext alloc] initWithObject:theObject parent:self] autorelease];
}

- (id)valueForKey:(NSString *)key
{
    return [[GRMustacheContext currentContextStrategy] valueForKey:key inContext:self];
}

- (void)dealloc {
	[object release];
	[parent release];
	[super dealloc];
}

- (id)valueForKeyComponent:(NSString *)key {
	// value by selector
	
	SEL renderingSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Section:withContext:", key]);
	if ([object respondsToSelector:renderingSelector]) {
		return [GRMustacheSelectorHelper helperWithObject:object selector:renderingSelector];
	}
	
	// value by KVC
	
	id value = nil;
	
    if (object) {
        @try {
            if (preventingNSUndefinedKeyExceptionAttack) {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:object];
            } else {
                value = [object valueForKey:key];
            }
        }
        @catch (NSException *exception) {
            if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
                [[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
                ![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
            {
                // that's some exception we are not related to
                [exception raise];
            }
        }
    }
	
	// value interpretation
	
	if (value != nil) {
		CFBooleanRef booleanRef;
		if ([self shouldConsiderObjectValue:value forKey:key asBoolean:&booleanRef]) {
			return (id)booleanRef;
		}
		return value;
	}
	
	// parent value
	
	if (parent == nil) { return nil; }
	return [parent valueForKeyComponent:key];
}

- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef {
	if ((CFBooleanRef)value == kCFBooleanTrue ||
		(CFBooleanRef)value == kCFBooleanFalse)
	{
		if (outBooleanRef) {
			*outBooleanRef = (CFBooleanRef)value;
		}
		return YES;
	}
	
	if ([value isKindOfClass:[NSNumber class]] &&
		![GRMustache strictBooleanMode] &&
		[GRMustacheProperty class:[object class] hasBOOLPropertyNamed:key])
	{
		if (outBooleanRef) {
			*outBooleanRef = [(NSNumber *)value boolValue] ? kCFBooleanTrue : kCFBooleanFalse;
		}
		return YES;
	}
	
	return NO;
}

@end

