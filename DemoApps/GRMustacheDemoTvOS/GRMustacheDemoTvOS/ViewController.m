#import "GRMustache/GRMustache.h"
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"Hello {{name}}" error:NULL];
    NSString *rendering = [template renderObject:@{ @"name": @"Arthur" } error:NULL];
    self.label.text = rendering;
}

@end
