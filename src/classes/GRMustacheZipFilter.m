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

#import "GRMustacheZipFilter_private.h"

// Only use public APIs
#import "GRMustacheRendering.h"
#import "GRMustacheContext.h"
#import "GRMustacheTag.h"
#import "GRMustacheError.h"

// =============================================================================
#pragma mark - Private class GRMustacheZippedObjects

@interface GRMustacheZippedObjects : NSObject<GRMustacheRendering> {
@private
    NSArray *_objects;
}
@end

@implementation GRMustacheZippedObjects

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (id)initWithObjects:(NSArray *)objects
{
    self = [super init];
    if (self) {
        _objects = [objects retain];
    }
    return self;
}


#pragma mark - <GRMustacheRendering>

- (BOOL)boolValue
{
    return [_objects count] > 0;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    for (id object in _objects) {
        context = [context contextByAddingObject:object];
    }
    return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}

@end

// =============================================================================
#pragma mark - GRMustacheZipFilter

@implementation GRMustacheZipFilter

- (instancetype)init
{
    return [self initWithArguments:@[]];
}

- (instancetype)initWithArguments:(NSArray *)arguments
{
    self = [super init];
    if (self) {
        _arguments = [arguments retain];
    }
    return self;
}

- (void)dealloc
{
    [_arguments release];
    [super dealloc];
}

#pragma mark <GRMustacheFilter>

- (id)transformedValue:(id)object
{
    NSArray *arguments = [_arguments arrayByAddingObject:(object ?: [NSNull null])];
    
    // GRMustache generally identifies collections as objects conforming
    // to NSFastEnumeration, excluding NSDictionary.
    //
    // Let's validate our arguments first.
    
    for (id argument in arguments) {
        if (![argument respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] || [argument isKindOfClass:[NSDictionary class]]) {
            return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                if (error) {
                    *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"zip filter in tag %@ requires all its arguments to be enumerable. %@ is not.", tag, argument] }];
                }
                return nil;
            }];
        }
    }
    
    
    // Fast path: leave single argument untouched.
    
    if (arguments.count == 1) {
        return arguments;
    }
    
    // Turn NSFastEnumeration arguments into enumerators. This is
    // because enumerators can be iterated all together, when
    // NSFastEnumeration objects can not.
    
    NSMutableArray *enumerators = [NSMutableArray array];
    for (id argument in arguments) {
        if ([argument respondsToSelector:@selector(objectEnumerator)]) {
            // Assume objectEnumerator method returns what we need.
            [enumerators addObject:[argument objectEnumerator]];
        } else {
            // Turn NSFastEnumeration argument into an array,
            // and extract enumerator from the array.
            NSMutableArray *array = [NSMutableArray array];
            for (id object in argument) {
                [array addObject:object];
            }
            [enumerators addObject:[array objectEnumerator]];
        }
    }
    
    
    // Iterate all enumerators
    
    NSMutableArray *renderingObjects = [NSMutableArray array];
    while (YES) {
        
        // TODO
        
        NSMutableArray *objects = [NSMutableArray array];
        for (NSEnumerator *enumerator in enumerators) {
            id object = [enumerator nextObject];
            if (object) {
                [objects addObject:object];
            }
        }
        
        
        // All iterators have been enumerated: stop
        
        if (objects.count == 0) {
            break;
        }
        
        
        // TODO
        
        [renderingObjects addObject:[[[GRMustacheZippedObjects alloc] initWithObjects:objects] autorelease]];
    }
    
    return renderingObjects;
}

// Support for variadic argument list
- (id<GRMustacheFilter>)filterByCurryingArgument:(id)object
{
    NSArray *arguments = [_arguments arrayByAddingObject:(object ?: [NSNull null])];
    return [[[GRMustacheZipFilter alloc] initWithArguments:arguments] autorelease];
}

@end
