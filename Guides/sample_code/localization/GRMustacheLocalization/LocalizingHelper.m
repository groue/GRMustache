//
//  LocalizingHelper.m
//  GRMustacheLocalization
//
//  Created by Gwendal Roué on 22/10/12.
//  Copyright (c) 2012 Gwendal Roué. All rights reserved.
//

#import "LocalizingHelper.h"

@interface LocalizingHelper()<GRMustacheTemplateDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
@end

@implementation LocalizingHelper

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
    NSString *localizableFormat = [context render];
    
    
    /**
     * [context render] has rendered the localizable format, and has triggered
     * delegate callbacks: now self.formatArguments is ready.
     *
     * Let's localize the format.
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
            
        default:
            NSAssert(NO, @"Not implemented");
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
     * We are only interested in the rendering of variable tags such as
     * {{name}}. We do not want to mess with Mustache handling of boolean
     * sections such as {{#count}}...{{/}}.
     *
     * We target variable tags with the interpretation argument:
     */
    
    if (interpretation == GRMustacheVariableTagInterpretation) {
        
        /**
         * invocation.returnValue is "Arthur" or "Barbara".
         *
         * Fill self.formatArguments so that we have arguments for
         * [NSString stringWithFormat:].
         */
        
        [self.formatArguments addObject:invocation.returnValue ?: [NSNull null]];
        
        
        /**
         * Render "%@" instead of the value.
         */
        
        invocation.returnValue = @"%@";
    }
}

@end
