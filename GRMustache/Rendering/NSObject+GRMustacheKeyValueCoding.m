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


#import "NSObject+GRMustacheKeyValueCoding_private.h"
#import "GRMustacheKeyAccess_private.h"

@implementation NSObject(GRMustacheKeyValueCoding)

- (BOOL)exceptionSafeHasValue:(id *)value forMustacheKey:(NSString *)key
{
    @try {
        return [self hasValue:value forMustacheKey:key];
    }
    @catch (NSException *exception) {
        // Swallow NSUndefinedKeyException only
        if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
            [exception raise];
        }
        // Missing key
        return NO;
    }
}

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    // Try valueForKey: for safe keys onlys
    if (![GRMustacheKeyAccess isSafeMustacheKey:key forObject:self]) {
        return NO;
    }
    
    // If property is nil, behave as if the key was missing.
    *value = [self valueForKey:key];
    return (*value != nil);
}

@end

@implementation NSDictionary(GRMustacheKeyValueCoding)

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    *value = [self objectForKey:key];
    return (*value != nil);
}

@end

@implementation NSArray(GRMustacheKeyValueCoding)

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        *value = @(self.count);
        return YES;
    } else if ([key isEqualToString:@"first"]) {
        *value = self.firstObject;
        return YES;
    } else if ([key isEqualToString:@"last"]) {
        *value = self.lastObject;
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation NSOrderedSet(GRMustacheKeyValueCoding)

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        *value = @(self.count);
        return YES;
    } else if ([key isEqualToString:@"first"]) {
        *value = self.firstObject;
        return YES;
    } else if ([key isEqualToString:@"last"]) {
        *value = self.lastObject;
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation NSSet(GRMustacheKeyValueCoding)

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        *value = @(self.count);
        return YES;
    } else if ([key isEqualToString:@"first"]) {
        *value = self.anyObject;
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation NSString(GRMustacheKeyValueCoding)

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"length"]) {
        *value = @(self.length);
        return YES;
    } else {
        return NO;
    }
}

@end
