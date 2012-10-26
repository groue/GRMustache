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

#import "GRAppDelegate.h"
#import "GRMustache.h"
#import "LocalizingHelper.h"

@implementation GRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    {
        /**
         * Localizing a template section
         */
        
        id data = @{
            @"localize": [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
                return NSLocalizedString(context.innerTemplateString, nil);
            }]
        };
        
        NSString *templateString = @"{{#localize}}Hello{{/localize}}";
        NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:data];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
        /**
         * Localizing a value
         */
        
        id data = @{
            @"greeting": @"Hello",
            @"localize": [GRMustacheSectionTagHelper helperWithBlock:^NSString *(GRMustacheSectionTagRenderingContext *context) {
                return NSLocalizedString([context render], nil);
            }]
        };
        
        NSString *templateString = @"{{#localize}}{{greeting}}{{/localize}}";
        NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:data];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
        /**
         * Localizing a template section with arguments
         */
        
        id data = @{
        @"name1": @"Arthur",
        @"name2": @"Barbara",
        @"localize": [[LocalizingHelper alloc] init]
        };
        
        NSString *templateString = @"{{#localize}}Hello {{name1}}! Do you know {{name2}}?{{/localize}}";
        NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:data];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
        /**
         * Localizing a template section with arguments and conditions
         */
        
        id filters = @{ @"isPlural" : [GRMustacheFilter filterWithBlock:^id(NSNumber *count) {
            if ([count intValue] > 1) {
                return @YES;
            }
            return @NO;
        }]};
        
        NSString *templateString = @"{{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        
        {
            id data = @{
            @"name1": @"Arthur",
            @"name2": @"Barbara",
            @"count": @(0),
            @"localize": [[LocalizingHelper alloc] init]
            };
            
            NSString *rendering = [template renderObject:data withFilters:filters];
            
            NSLog(@"rendering = %@", rendering);
        }
        
        {
            id data = @{
            @"name1": @"Craig",
            @"name2": @"Dennis",
            @"count": @(1),
            @"localize": [[LocalizingHelper alloc] init]
            };
            
            NSString *rendering = [template renderObject:data withFilters:filters];
            
            NSLog(@"rendering = %@", rendering);
        }
        
        {
            id data = @{
            @"name1": @"Eugene",
            @"name2": @"Fiona",
            @"count": @(5),
            @"localize": [[LocalizingHelper alloc] init]
            };
            
            NSString *rendering = [template renderObject:data withFilters:filters];
            
            NSLog(@"rendering = %@", rendering);
        }
    }
    
    {
        /**
         * Encapsulation of the sentence
         */
        
        // In order to render `{{ localizedMutualFriendsSentence(x, y) }}`,
        // let's write a variadic filter.
        
        id localizedMutualFriendsSentence = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
            
            // The filter can not access Mustache engine itself. However, it can
            // return a variable tag helper that can, and will render our
            // sentence:
            
            return [GRMustacheVariableTagHelper helperWithBlock:^NSString *(GRMustacheVariableTagRenderingContext *context) {
                
                // Build local context from filter arguments:
                
                id data = @{
                    @"name1": [arguments objectAtIndex:0],
                    @"name2": [arguments objectAtIndex:1],
                    @"count": [arguments objectAtIndex:2],
                    @"localize": [[LocalizingHelper alloc] init],
                };
                
                
                // Build local filters
                
                id filters = @{ @"isPlural" : [GRMustacheFilter filterWithBlock:^id(NSNumber *count) {
                    if ([count intValue] > 1) {
                        return @YES;
                    }
                    return @NO;
                }]};
                
                // Render
                
                NSString *templateString = @"{{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}";
                return [context renderObject:data
                                 withFilters:filters
                                  fromString:templateString
                                       error:NULL];
            }];
        }];
        
        {
            id data = @{
                @"name1": @"Gwendal",
                @"name2": @"Henry",
                @"count12": @(20),
                @"name3": @"Kyle",
                @"name4": @"Louis",
                @"count34": @(50),
            };
            
            id filters = @{ @"localizedMutualFriendsSentence": localizedMutualFriendsSentence };
            
            NSString *rendering = [GRMustacheTemplate renderObject:data
                                                       withFilters:filters
                                                        fromString:@"{{localizedMutualFriendsSentence(name1, name2, count12)}}\n"
                                                                   @"{{localizedMutualFriendsSentence(name3, name4, count34)}}"
                                                             error:NULL];
            
            NSLog(@"rendering = %@", rendering);
        }
    }
    
    {
        id pairFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
            return [GRMustacheVariableTagHelper helperWithBlock:^NSString *(GRMustacheVariableTagRenderingContext *context) {
                id data = @{
                @"first": [arguments objectAtIndex:0],
                @"last": [arguments objectAtIndex:1],
                };
                return [context renderObject:data fromString:@"({{first}},{{last}})" error:NULL];
            }];
        }];
        
        id data = @{
        @"a":@"a",
        @"b":@"b",
        @"c":@"c",
        @"d":@"d",
        };
        
        NSString *rendering = [GRMustacheTemplate renderObject:data
                                                   withFilters:@{ @"pair": pairFilter }
                                                    fromString:@"{{pair(a,b)}} {{pair(c,d)}}"
                                                         error:NULL];
        
        NSLog(@"rendering = %@", rendering);
    }
}

@end

