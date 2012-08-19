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

@interface LocalizatingHelper : NSObject<GRMustacheHelper, GRMustacheTemplateDelegate>
@end

@implementation GRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    {
        id data = @{
            @"localize": [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                return NSLocalizedString(section.innerTemplateString, nil);
            }]
        };
        
        NSString *templateString = @"{{#localize}}Hello{{/localize}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
        id data = @{
            @"greeting": @"Hello",
            @"localize": [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section) {
                return NSLocalizedString([section render], nil);
            }]
        };
        
        NSString *templateString = @"{{#localize}}{{greeting}}{{/localize}}";
        NSString *rendering = [GRMustacheTemplate renderObject:data fromString:templateString error:NULL];
        
        NSLog(@"rendering = %@", rendering);
    }
    
    {
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


@interface LocalizatingHelper()
@property (nonatomic, strong) NSMutableArray *values;
@end

@implementation LocalizatingHelper

- (NSString *)renderSection:(GRMustacheSection *)section
{
    self.values = [NSMutableArray array];
    NSString *localizableFormat = [section render];
    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);
    NSString *result = nil;
    switch (self.values.count) {
        case 0:
            result = localizedFormat;
            break;
        
        case 1:
            result = [NSString stringWithFormat:localizedFormat, [self.values objectAtIndex:0]];
            break;
            
        case 2:
            result = [NSString stringWithFormat:localizedFormat, [self.values objectAtIndex:0], [self.values objectAtIndex:1]];
            break;
            
        case 3:
            result = [NSString stringWithFormat:localizedFormat, [self.values objectAtIndex:0], [self.values objectAtIndex:1], [self.values objectAtIndex:2]];
            break;
    }
    self.values = nil;
    return result;
}

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    [self.values addObject:invocation.returnValue];
    invocation.returnValue = @"%@";
}

@end
