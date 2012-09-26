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

@interface LocalizatingHelper : NSObject<GRMustacheSectionTagHelper, GRMustacheTemplateDelegate>
@end

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
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
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
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
        /**
         * Localizing a template section with arguments
         */
        
        id data = @{
            @"name1": @"Arthur",
            @"name2": @"Barbara",
            @"localize": [[LocalizatingHelper alloc] init]
        };
        
        NSString *templateString = @"{{#localize}}Hello {{name1}}! Do you know {{name2}}?{{/localize}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"rendering = %@", rendering);
    }
}

@end


/**
 * LocalizatingHelper
 */

@interface LocalizatingHelper()
@property (nonatomic, strong) NSMutableArray *formatArguments;
@end

@implementation LocalizatingHelper

- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    /**
     * Let's perform a first rendering of the section, invoking
     * [context render].
     *
     * This method returns the rendering of the section:
     * "Hello {{name1}}! Do you know {{name2}}?" in our specific example.
     *
     * Normally, it would return "Hello Arthur! Do you know Barbara?", which
     * we could not localize.
     *
     * But we are also a GRMustacheTemplateDelegate, and as such, GRMustache
     * will tell us when it is about to render a value.
     *
     * In the template:willInterpretReturnValueOfInvocation:as: delegate method,
     * we'll tell GRMustache to render "%@" instead of the actual values
     * "Arthur" and "Barbara".
     *
     * The rendering of the section will thus be "Hello %@! Do you know %@?",
     * which is a string that is suitable for localization.
     *
     * We still need the format arguments to fill the format: "Arthur", and
     * "Barbara".
     *
     * They also be gathered in the delegate method, that will fill the
     * self.formatArguments array, here initialized as an empty array.
     */
    
    self.formatArguments = [NSMutableArray array];
    NSString *localizableFormat = [context render]; // triggers delegate callbacks
    
    
    /**
     * Now localize the format.
     */
    
    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);
    
    
    /**
     * Render!
     *
     * [NSString stringWithFormat:] unfortunately does not accept an array of
     * formatArguments to fill the format. Let's support up to 3 arguments:
     */
    
    NSString *rendering = nil;
    switch (self.formatArguments.count) {
        case 0:
            rendering = localizedFormat;
            break;
        
        case 1:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0]];
            break;
            
        case 2:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1]];
            break;
            
        case 3:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1],
                         [self.formatArguments objectAtIndex:2]];
            break;
    }
    
    
    /**
     * Cleanup and return the rendering
     */
    
    self.formatArguments = nil;
    return rendering;
}

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * invocation.returnValue is "Arthur" or "Barbara".
     *
     * Fill self.formatArguments so that we have arguments for
     * [NSString stringWithFormat:].
     */
    
    [self.formatArguments addObject:invocation.returnValue];
    
    
    /**
     * Render "%@" instead of the value.
     */
    
    invocation.returnValue = @"%@";
}

@end
