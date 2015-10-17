//
//  ViewController.m
//  GRMustacheDemoOSX
//
//  Created by Gwendal Roué on 17/10/2015.
//  Copyright © 2015 Gwendal Roué. All rights reserved.
//

@import GRMustache;
#import "ViewController.h"
#import "Model.h"

@interface ViewController()
@property (nonatomic) IBOutlet NSTextView *templateTextView;
@property (nonatomic) IBOutlet NSTextView *JSONTextView;
@property (nonatomic) IBOutlet NSTextView *renderingTextView;
@property (nonatomic) IBOutlet Model *model;
@end

@implementation ViewController

+ (NSFont *)font
{
    static NSFont *font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        font = [NSFont fontWithName:@"Menlo" size:12];
    });
    return font;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for(NSTextView *textView in @[self.templateTextView, self.JSONTextView]) {
        textView.automaticQuoteSubstitutionEnabled = YES;
        textView.textStorage.font = [ViewController font];
    }
}

- (IBAction)render:(id)sender
{
    NSError *error;
    NSNumberFormatter *percentFormatter = nil;
    NSData *JSONData = nil;
    id JSONObject = nil;
    NSString *rendering = nil;
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.model.templateString error:&error];
    if (!template) { goto error; }
    
    percentFormatter = [[NSNumberFormatter alloc] init];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    [template extendBaseContextWithProtectedObject:
     @{ @"percent": percentFormatter,
        @"each": [GRMustache standardEach],
        @"zip": [GRMustache standardZip],
        @"localize": [[GRMustacheLocalizer alloc] init],
        @"HTMLEscape": [GRMustache standardHTMLEscape],
        @"URLEscape": [GRMustache standardURLEscape],
        @"javascriptEscape": [GRMustache standardJavascriptEscape],
        }];
    
    JSONData = [self.model.JSONString dataUsingEncoding:NSUTF8StringEncoding];
    JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    if (!JSONObject) { goto error; }
    
    rendering = [template renderObject:JSONObject error:&error];
    if (!rendering) { goto error; }
    [self presentRenderingString:rendering];
    return;
    
error:
    [self presentRenderingString:[NSString stringWithFormat:@"%@: %@", error.domain, error.localizedDescription]];
}

- (void)presentRenderingString:(NSString *)string
{
    self.renderingTextView.string = string;
    self.renderingTextView.textStorage.font = [ViewController font];
}

@end
