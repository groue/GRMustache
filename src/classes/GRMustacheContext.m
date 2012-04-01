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
#import "GRMustacheHelper_private.h"
#import "GRMustacheProperty_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheTemplate_private.h"

#if !defined(NS_BLOCK_ASSERTIONS)
// For testing purpose
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;

@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef options:(GRMustacheTemplateOptions)options;
@end


@implementation GRMustacheContext
@synthesize object=_object;
@synthesize parent=_parent;

+ (void)preventNSUndefinedKeyExceptionAttack
{
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object
{
    if (object == nil) {
        return nil;
    }
    if ([object isKindOfClass:[GRMustacheContext class]]) {
        return object;
    }
    return [[[self alloc] initWithObject:object parent:nil] autorelease];
}

+ (id)contextWithObject:(id)object andObjectList:(va_list)objectList
{
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

- (GRMustacheContext *)contextByAddingObject:(id)object
{
    return [[[GRMustacheContext alloc] initWithObject:object parent:self] autorelease];
}

- (GRMustacheContext *)contextForKey:(NSString *)key scoped:(BOOL)scoped options:(GRMustacheTemplateOptions)options
{
    id value = [self valueForKey:key scoped:scoped options:options];
    if (!value) {
        return nil;
    }
    if (scoped) {
        return [GRMustacheContext contextWithObject:value];
    }
    return [self contextByAddingObject:value];
}

- (id)valueForKey:(NSString *)key scoped:(BOOL)scoped options:(GRMustacheTemplateOptions)options
{
    id value = nil;
    
    if (_object) {
        @try {
            if (preventingNSUndefinedKeyExceptionAttack) {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:_object];
            } else {
                value = [_object valueForKey:key];
            }
        }
        @catch (NSException *exception) {
#if !defined(NS_BLOCK_ASSERTIONS)
            // For testing purpose
            GRMustacheContextDidCatchNSUndefinedKeyException = YES;
#endif
            
            if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
                [[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != _object ||
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
        if ([self shouldConsiderObjectValue:value forKey:key asBoolean:&booleanRef options:options]) {
            return (id)booleanRef;
        }
        return value;
    }
    
    // parent value
    
    if (scoped || _parent == nil) { return nil; }
    return [_parent valueForKey:key scoped:NO options:options];
}

- (void)dealloc
{
    [_object release];
    [_parent release];
    [super dealloc];
}

#pragma mark Private

- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent
{
    self = [self init];
    if (self) {
        _object = [object retain];
        _parent = [parent retain];
    }
    return self;
}

- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef options:(GRMustacheTemplateOptions)options
{
    if ((CFBooleanRef)value == kCFBooleanTrue ||
        (CFBooleanRef)value == kCFBooleanFalse)
    {
        if (outBooleanRef) {
            *outBooleanRef = (CFBooleanRef)value;
        }
        return YES;
    }
    
    if ([value isKindOfClass:[NSNumber class]] &&
        !(options & GRMustacheTemplateOptionStrictBoolean) &&
        [GRMustacheProperty class:[_object class] hasBOOLPropertyGetterNamed:key])
    {
        if (outBooleanRef) {
            *outBooleanRef = [(NSNumber *)value boolValue] ? kCFBooleanTrue : kCFBooleanFalse;
        }
        return YES;
    }
    
    return NO;
}

@end

