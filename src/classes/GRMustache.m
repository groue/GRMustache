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

#import "GRMustache_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheJavascriptEscapeFilter_private.h"
#import "GRMustacheHTMLEscapeFilter_private.h"
#import "GRMustacheURLEscapeFilter_private.h"
#import "GRMustacheEachFilter_private.h"
#import "GRMustacheLocalizer.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTag_private.h"

// =============================================================================
#pragma mark - GRMustache

@implementation GRMustache


// =============================================================================
#pragma mark - Standard library

// Documented in GRMustache.h
+ (NSObject *)standardEach
{
    return [[[GRMustacheEachFilter alloc] init] autorelease];
}

// Documented in GRMustache.h
+ (NSObject *)standardHTMLEscape
{
    return [[[GRMustacheHTMLEscapeFilter alloc] init] autorelease];
}

// Documented in GRMustache.h
+ (NSObject *)standardURLEscape
{
    return [[[GRMustacheURLEscapeFilter alloc] init] autorelease];
}

// Documented in GRMustache.h
+ (NSObject *)standardJavascriptEscape
{
    return [[[GRMustacheJavascriptEscapeFilter alloc] init] autorelease];
}

// Documented in GRMustache.h
+ (NSObject *)standardZip
{
    return [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        
        // GRMustache generally identifies collections as objects conforming
        // to NSFastEnumeration, excluding NSDictionary.
        //
        // Let's validate our arguments first.
        
        for (id argument in arguments) {
            if (![argument respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] || [argument isKindOfClass:[NSDictionary class]]) {
                return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                    if (error) {
                        *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Tag %@: Non-enumerable argument in zip filter: %@", tag, argument] }];
                    }
                    return nil;
                }];
            }
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
        
        
        // Build an array of objects which will perform custom rendering.
        
        NSMutableArray *renderingObjects = [NSMutableArray array];
        while (YES) {
            
            // Extract from all iterators the objects that should enter the
            // rendering context at each iteration.
            //
            // Given the [1,2,3], [a,b,c] input collections, those objects
            // would be [1,a] then [2,b] and finally [3,c].
            
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
            
            
            // Build a rendering object which extends the rendering context
            // before rendering the tag.
            
            id<GRMustacheRendering> renderingObject = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
                for (id object in objects) {
                    context = [context contextByAddingObject:object];
                }
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }];
            [renderingObjects addObject:renderingObject];
        }
        
        return renderingObjects;
    }];
}

@end
