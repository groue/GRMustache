@import GRMustache;
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"template" bundle:nil error:NULL];
    NSString *HTML = [template renderObject:@{ @"title": @"Welcome", @"paragraph": @"GRMustache is a flexible and production-ready Mustache templates for MacOS Cocoa and iOS." } error:NULL];
    [self.webView loadHTMLString:HTML baseURL:nil];
}

@end
