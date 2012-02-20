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

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheProperty_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheTemplate_private.h"

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;


@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef;
- (id)valueForKey:(NSString *)key scoped:(BOOL)scoped;
@end


@implementation GRMustacheContext
@synthesize object=_object;
@synthesize parent=_parent;

+ (void)preventNSUndefinedKeyExceptionAttack {
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object {
    if (object == nil) {
        return nil;
    }
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
    context = [GRMustacheContext contextWithObject:object];
    id eachObject;
    va_list objectListCopy;
    va_copy(objectListCopy, objectList);
    while ((eachObject = va_arg(objectListCopy, id))) {
        context = [context contextByAddingObject:eachObject];
    }
    va_end(objectListCopy);
    return context;
}

- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent {
    if ((self = [self init])) {
        _object = [object retain];
        _parent = [parent retain];
    }
    return self;
}

- (GRMustacheContext *)contextByAddingObject:(id)theObject {
    return [[[GRMustacheContext alloc] initWithObject:theObject parent:self] autorelease];
}

- (GRMustacheContext *)contextForKey:(NSString *)key scoped:(BOOL)scoped
{
    id value = [self valueForKey:key scoped:scoped];
    if (!value) {
        return nil;
    }
    if (scoped) {
        return [GRMustacheContext contextWithObject:value];
    }
    return [self contextByAddingObject:value];
}

- (void)dealloc {
    [_object release];
    [_parent release];
    [super dealloc];
}

- (id)valueForKey:(NSString *)key {
    return [self valueForKey:key scoped:NO];
}

- (id)valueForKey:(NSString *)key scoped:(BOOL)scoped {
    id value = nil;
    
    if (_object) {
        // value by KVC
        
        @try {
            if (preventingNSUndefinedKeyExceptionAttack) {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:_object];
            } else {
                value = [_object valueForKey:key];
            }
        }
        @catch (NSException *exception) {
            if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
                [[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != _object ||
                ![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
            {
                // that's some exception we are not related to
                [exception raise];
            }
        }
        
        if (value == nil) {
            // value by selector
            
            SEL renderingSelector = NSSelectorFromString([key stringByAppendingString:@"Section:withContext:"]);
            if ([_object respondsToSelector:renderingSelector]) {
                // Avoid the "render" key to be triggered by GRMustacheHelper instances,
                // who implement the renderSection:withContext: selector.
                if (![_object conformsToProtocol:@protocol(GRMustacheHelper)] || ![@"render" isEqualToString:key]) {
                    return [GRMustacheSelectorHelper helperWithObject:_object selector:renderingSelector];
                }
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
    
    if (scoped || _parent == nil) { return nil; }
    return [_parent valueForKey:key scoped:NO];
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
        [GRMustacheProperty class:[_object class] hasBOOLPropertyNamed:key])
    {
        if (outBooleanRef) {
            *outBooleanRef = [(NSNumber *)value boolValue] ? kCFBooleanTrue : kCFBooleanFalse;
        }
        return YES;
    }
    
    return NO;
}

@end

