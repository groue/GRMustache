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

#import "PositionFilter.h"

@implementation PositionFilter

/**
 * The transformedValue: method is required by the GRMustacheFilter protocol.
 * 
 * Don't provide any type checking, and assume the filter argument is an array:
 */

- (id)transformedValue:(NSArray *)array
{
    /**
     * We want to provide custom rendering of the array.
     *
     * So let's provide an object that does custom rendering.
     */
    
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
       
        /**
         * We are going to render the tag once for each item. We need a buffer
         * to store all those renderings:
         */
        
        NSMutableString *buffer = [NSMutableString string];
        
        
        /**
         * For each item...
         */
        
        [array enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
            
            /**
             * Have our "specials" keys enter the context stack:
             */
            
            id specials = @{
                @"position": @(index + 1),
                @"isFirst" : @(index == 0),
                @"isOdd" : @(index % 2 == 0),
            };
            GRMustacheContext *itemContext = [context contextByAddingObject:specials];
            
            
            /**
             * Have the item itself enter the context stack (so that the `name`
             * key can render):
             */
            
            itemContext = [itemContext contextByAddingObject:item];
            
            
            /**
             * Append the item rendering to our buffer:
             */
            
            NSString *itemRendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
            [buffer appendString:itemRendering];
        }];
        
        
        /**
         * Done
         */
        
        return buffer;
    }];
}

@end
