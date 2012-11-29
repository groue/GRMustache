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
        
        NSLog(@"-----------------------------");
        NSLog(@"Localizing a template section");
        
        id data = @{
            @"localize": [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error) {
                return NSLocalizedString(tag.innerTemplateString, nil);
            }]
        };
        
        NSString *templateString = @"{{#localize}}Hello{{/localize}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"%@", rendering);
        
        // With LocalizingHelper class
        
        data = @{
            @"localize": [[LocalizingHelper alloc] init]
        };
        rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        NSLog(@"With LocalizingHelper: %@", rendering);
    }
    
    {
        /**
         * Localizing a value
         */
        
        NSLog(@"------------------");
        NSLog(@"Localizing a value");
        
        id data = @{
            @"greeting": @"Hello",
            @"localize": [GRMustacheFilter filterWithBlock:^id(id value) {
                return NSLocalizedString([value description], nil);
            }]
        };
        
        NSString *templateString = @"{{ localize(greeting) }}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"%@", rendering);
        
        // With LocalizingHelper class
        
        data = @{
            @"greeting": @"Hello",
            @"localize": [[LocalizingHelper alloc] init]
        };
        rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        NSLog(@"With LocalizingHelper: %@", rendering);
    }
    
    {
        /**
         * Localizing a template section with arguments
         */
        
        NSLog(@"--------------------------------------------");
        NSLog(@"Localizing a template section with arguments");
        
        id data = @{
        @"name1": @"Arthur",
        @"name2": @"Barbara",
        @"localize": [[LocalizingHelper alloc] init]
        };
        
        NSString *templateString = @"{{#localize}}Hello {{name1}}! Do you know {{name2}}?{{/localize}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"With LocalizingHelper: %@", rendering);
    }
    
    {
        /**
         * Localizing a template section with arguments and conditions
         */
        
        NSLog(@"-----------------------------------------------------------");
        NSLog(@"Localizing a template section with arguments and conditions");
        
        id localizingHelper = [[LocalizingHelper alloc] init];
        id isPluralFilter = [GRMustacheFilter filterWithBlock:^id(NSNumber *count) {
            if ([count intValue] > 1) {
                return @YES;
            }
            return @NO;
        }];
        
        NSString *templateString = @"{{#localize}}{{name1}} and {{name2}} {{#count}}have {{#isPlural(count)}}{{count}} mutual friends{{/}}{{^isPlural(count)}}one mutual friend{{/}}{{/count}}{{^count}}have no mutual friend{{/count}}.{{/localize}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        
        {
            id data = @{
            @"name1": @"Arthur",
            @"name2": @"Barbara",
            @"count": @(0),
            @"localize": localizingHelper,
            @"isPlural": isPluralFilter,
            };
            
            NSString *rendering = [template renderObject:data error:NULL];
            
            NSLog(@"With LocalizingHelper: %@", rendering);
        }
        
        {
            id data = @{
            @"name1": @"Craig",
            @"name2": @"Dennis",
            @"count": @(1),
            @"localize": localizingHelper,
            @"isPlural": isPluralFilter,
            };
            
            NSString *rendering = [template renderObject:data error:NULL];
            
            NSLog(@"With LocalizingHelper: %@", rendering);
        }
        
        {
            id data = @{
            @"name1": @"Eugene",
            @"name2": @"Fiona",
            @"count": @(5),
            @"localize": localizingHelper,
            @"isPlural": isPluralFilter,
            };
            
            NSString *rendering = [template renderObject:data error:NULL];
            
            NSLog(@"With LocalizingHelper: %@", rendering);
        }
    }
}

@end

