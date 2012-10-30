//
//  LocalizingHelper.m
//  GRMustacheLocalization
//
//  Created by Gwendal Roué on 22/10/12.
//  Copyright (c) 2012 Gwendal Roué. All rights reserved.
//

#import "LocalizingHelper.h"

@interface LocalizingHelper()<GRMustacheRendering, GRMustacheTagDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
@end

@implementation LocalizingHelper

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError *__autoreleasing *)error
{
    /**
     * Add self as a tag delegate, so that we know when tag will and did render.
     */
    context = [context contextByAddingTagDelegate:self];
    
    
    /**
     * Perform a first rendering of the section tag, that will set
     * localizableFormat to "Hello %@! Do you know %@?".
     *
     * Our mustacheTag:willRenderObject: implementation will tell the tags to
     * render "%@" instead of the regular values, "Arthur" or "Barbara". This
     * behavior is trigerred by the nil value of self.formatArguments.
     */
    
    self.formatArguments = nil;
    NSString *localizableFormat = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Perform a second rendering that will fill our formatArguments array with
     * HTML-escaped tag renderings.
     *
     * Our mustacheTag:willRenderObject: implementation will now let the regular
     * values through ("Arthur" or "Barbara"), so that our
     * mustacheTag:didRenderObject:as: method can fill self.formatArguments.
     * This behavior is not the same as the previous one, and is trigerred by
     * the non-nil value of self.formatArguments.
     */
    
    self.formatArguments = [NSMutableArray array];
    [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    
    
    /**
     * Localize the format, and render.
     *
     * Unfortunately, [NSString stringWithFormat:] does not accept an array of
     * formatArguments to fill the format. Let's support up to 3 arguments:
     */
    
    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);
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
     * Cleanup and return
     */
    
    self.formatArguments = nil;
    return rendering;
}

- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    /**
     * We are only interested in the rendering of variable tags such as
     * {{name}}. We do not want to mess with Mustache handling of boolean
     * sections such as {{#count}}...{{/}}.
     */
    
    if (tag.type != GRMustacheTagTypeVariable) {
        return object;
    }
    
    /**
     * We behave as stated in renderForMustacheTag:context:HTMLSafe:error:
     */
    
    if (self.formatArguments) {
        return object;
    }

    return @"%@";
}

- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering
{
    /**
     * Without messing with section tags...
     */
    
    if (tag.type == GRMustacheTagTypeVariable) {
        
        /**
         * ... we behave as stated in renderForMustacheTag:context:HTMLSafe:error:
         */
        
        [self.formatArguments addObject:rendering];
    }
}

@end
