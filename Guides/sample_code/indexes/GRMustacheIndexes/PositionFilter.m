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

#import "PositionFilter.h"

#pragma mark - PositionFilter implementation

// Documented in PositionFilter.h
@implementation PositionFilter

/**
 * The method required by the GRMustacheFilter protocol
 */
- (id)transformedValue:(id)object
{
    // Input validation: we can only filter arrays.
    
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    // Let's return a object that provides custom rendering:
    
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error)
    {
        // We only provide custom rendering for sections (and overridable
        // sections, since they are supposed to render in the same way.
        
        switch (tag.type)
        {
            case GRMustacheTagTypeSection:
            case GRMustacheTagTypeOverridableSection:
            {
                // {{# withPosition(items) }}...{{/}}
                // {{$ withPosition(items) }}...{{/}}
                //
                // Let's render the section tag as many times as we have items.
                
                NSMutableString *buffer = [NSMutableString string];
                NSUInteger position = 1;
                for (id item in array)
                {
                    
                    // For each item, extend the context stack twice:
                    //
                    // - once with our special keys, `position`, `isFirst` and `isOdd`,
                    // - once with the item itself, so that it can provide its own keys:
                    
                    NSDictionary *special = @{
                        @"position": @(position),
                        @"isFirst":  @(position == 1),
                        @"isOdd":    @(position % 2 == 1),
                    };
                    GRMustacheContext *itemContext = [context contextByAddingObject:special];
                    itemContext = [itemContext contextByAddingObject:item];
                    
                    // Append the rendering to our buffer. Don't forget to handle errors:
                    
                    NSString *rendering = [tag renderContext:itemContext HTMLSafe:HTMLSafe error:error];
                    if (!rendering) {
                        // Some error occurred.
                        return nil;
                    }
                    
                    [buffer appendString:rendering];
                    ++position;
                }
                return buffer;
            } break;
                
            default:
            {
                // {{ withPosition(items) }}
                // {{^ withPosition(items) }}...{{/}}
                
                // For other tags, use the default Mustache rendering:

                id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:array];
                return [renderingObject renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
            } break;
        }
    }];
}

@end

