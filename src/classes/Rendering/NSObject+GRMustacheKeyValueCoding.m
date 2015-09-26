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

@interface NSObject(KeyedSubscripting)
- (id)valueForMustacheKey:(id)key;
@end

@implementation NSObject(GRMustacheKeyValueCoding)

- (id)valueForMustacheKey:(NSString *)key unsafeKeyAccess:(BOOL)unsafeKeyAccess
{
    // Try valueForMustacheKey:
    
    if ([self respondsToSelector:@selector(valueForMustacheKey:)]) {
        @try {
            return [self valueForMustacheKey:key];
        }
        @catch (NSException *exception) {
            // Swallow NSUndefinedKeyException only
            if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
                [exception raise];
            }
            return nil;
        }
    }
    
    
    // Then try valueForKey: for safe keys
    
    if (!unsafeKeyAccess && ![GRMustacheKeyAccess isSafeMustacheKey:key forObject:self]) {
        return nil;
    }
    
    @try {
        return [self valueForKey:key];
    }
    @catch (NSException *exception) {
        // Swallow NSUndefinedKeyException only
        if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
            [exception raise];
        }
        return nil;
    }
}

@end

@implementation NSDictionary(GRMustacheKeyValueCoding)

- (id)valueForMustacheKey:(NSString *)key
{
    return [self objectForKey:key];
}

@end

@implementation NSArray(GRMustacheKeyValueCoding)

- (id)valueForMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        return @(self.count);
    } else if ([key isEqualToString:@"first"]) {
        return self.firstObject;
    } else if ([key isEqualToString:@"last"]) {
        return self.lastObject;
    } else {
        return nil;
    }
}

@end

@implementation NSOrderedSet(GRMustacheKeyValueCoding)

- (id)valueForMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        return @(self.count);
    } else if ([key isEqualToString:@"first"]) {
        return self.firstObject;
    } else if ([key isEqualToString:@"last"]) {
        return self.lastObject;
    } else {
        return nil;
    }
}

@end

@implementation NSSet(GRMustacheKeyValueCoding)

- (id)valueForMustacheKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) {
        return @(self.count);
    } else if ([key isEqualToString:@"first"]) {
        return self.anyObject;
    } else {
        return nil;
    }
}

@end
