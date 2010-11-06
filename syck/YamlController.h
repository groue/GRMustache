/* YamlController */

#import <Cocoa/Cocoa.h>

@interface YamlController : NSObject
{
    IBOutlet id input;
    IBOutlet id output;
}
- (IBAction)parse:(id)sender;
@end
