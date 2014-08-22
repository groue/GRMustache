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

#import "GRMustacheEachFilter_private.h"

// Only use public APIs
#import "GRMustacheRendering.h"
#import "GRMustacheContext.h"
#import "GRMustacheError.h"

@implementation GRMustacheEachFilter

/**
 * The transformedValue: method is required by the GRMustacheFilter protocol.
 *
 * Don't provide any type checking, and assume the filter argument is
 * enumerable.
 */

- (id)transformedValue:(id)object
{
    /**
     * Check that parameter can be iterated.
     */
    
    if (![object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        return [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            if (error) {
                *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"each filter in tag %@ expects its arguments to conform to the NSFastEnumeration protocol. %@ is not.", tag, object] }];
            }
            return nil;
        }];
    }
    
    
    /**
     * When iterating dictionaries, set the `@key` and `@first` keys.
     * When iterating arrays, set the `@index` and `@first` keys.
     */
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self transformedDictionary:object];
    } else {
        return [self transformedArray:object];
    }
}

- (id)transformedArray:(id<NSFastEnumeration>)array
{
    /**
     * We'll return an array containing as many objects as in the original
     * collection.
     *
     * The replacement objects will perform custom rendering by enqueuing in the
     * context stack the positional keys before rendering just like the original
     * objects.
     *
     * Objects that perform custom rendering conform to the GRMustacheRendering
     * protocol, hence the name of our array of replacement objects:
     */
    NSMutableArray *replacementRenderingObjects = [NSMutableArray array];
    
    __block NSUInteger indexOfLastObject = 0;
    NSUInteger index = 0;
    for (id object in array) {
        
        /**
         * Build the replacement rendering object.
         *
         * It has the same boolean value as the original one, so that it
         * triggers the rendering {{#regular}} or {{^inverted}} sections just
         * the same as the original object.
         *
         * It enqueues the positional keys, and then renders the same as the
         * original object.
         *
         * To known the boolean value of the original object, and know how it
         * would render, turn it into a rendering object.
         */
        
        // The original rendering object:
        id<GRMustacheRendering> originalRenderingObject = [GRMustacheRendering renderingObjectForObject:object];
        
        // Its boolean value:
        BOOL originalBoolValue = originalRenderingObject.mustacheBoolValue;
        
        // The replacement rendering object:
        indexOfLastObject = index;
        id<GRMustacheRendering> replacementRenderingObject = [GRMustacheRendering renderingObjectWithBoolValue:originalBoolValue block:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            
            /**
             * Add our positional keys in the rendering context
             */
            
            context = [context contextByAddingObject:@{@"@index": @(index),
                                                       @"@first" : @(index == 0),
                                                       @"@last" : @(index == indexOfLastObject),    // When this is evaluated, on rendering, the filter will have been long executed. The __block variable indexOfLastObject will have the value of the last index.
                                                       }];
            
            /**
             * And return the rendering of the original object given the
             * extended context.
             */
            
            return [originalRenderingObject renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
        }];
        
        [replacementRenderingObjects addObject:replacementRenderingObject];
        ++index;
    }
    
    return replacementRenderingObjects;
}

- (id)transformedDictionary:(NSDictionary *)dictionary
{
    /**
     * We'll return an array containing as many objects as in the original
     * dictionary.
     *
     * The replacement objects will perform custom rendering by enqueuing in the
     * context stack the positional keys before rendering just like the original
     * values.
     *
     * Objects that perform custom rendering conform to the GRMustacheRendering
     * protocol, hence the name of our array of replacement objects:
     */
    NSMutableArray *replacementRenderingObjects = [NSMutableArray array];
    
    NSUInteger indexOfLastObject = dictionary.count - 1;
    NSUInteger index = 0;
    for (id key in dictionary) {
        
        /**
         * Build the replacement rendering object.
         *
         * It has the same boolean value as the original one, so that it
         * triggers the rendering {{#regular}} or {{^inverted}} sections just
         * the same as the original object.
         *
         * It enqueues the positional keys, and then renders the same as the
         * original object.
         *
         * To known the boolean value of the original object, and know how it
         * would render, turn it into a rendering object.
         */
        
        // The original rendering object:
        id object = dictionary[key];
        id<GRMustacheRendering> originalRenderingObject = [GRMustacheRendering renderingObjectForObject:object];
        
        // Its boolean value:
        BOOL originalBoolValue = originalRenderingObject.mustacheBoolValue;
        
        // The replacement rendering object:
        id<GRMustacheRendering> replacementRenderingObject = [GRMustacheRendering renderingObjectWithBoolValue:originalBoolValue block:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
            
            /**
             * Add our positional keys in the rendering context
             */
            
            context = [context contextByAddingObject:@{@"@key": key,
                                                       @"@first" : @(index == 0),
                                                       @"@last" : @(index == indexOfLastObject),
                                                       }];
            
            /**
             * And return the rendering of the original object given the
             * extended context.
             */
            
            return [originalRenderingObject renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
        }];
        
        [replacementRenderingObjects addObject:replacementRenderingObject];
        ++index;
    }
    
    return replacementRenderingObjects;
}

@end
