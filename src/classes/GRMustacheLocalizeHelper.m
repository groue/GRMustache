// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#import "GRMustacheLocalizeHelper.h"

@interface GRMustacheLocalizeHelper()<GRMustacheTagDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
- (NSString *)localizedStringForKey:(NSString *)key;
@end

@implementation GRMustacheLocalizeHelper
@synthesize bundle=_bundle;
@synthesize tableName=_tableName;

- (void)dealloc
{
    [_bundle release];
    [_tableName release];
    [super dealloc];
}

- (id)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName
{
    self = [super init];
    if (self) {
        _bundle = [(bundle ?: [NSBundle mainBundle]) retain];
        _tableName = [_tableName retain];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key
{
    return [_bundle localizedStringForKey:key value:@"" table:_tableName];
}


#pragma mark - GRMustacheFilter

- (id)transformedValue:(id)object
{
    return [self localizedStringForKey:[object description]];
}


#pragma mark - GRMustacheRendering

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
    
    NSString *localizedFormat = [self localizedStringForKey:localizableFormat];
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

#pragma mark GRMustacheTagDelegate

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
