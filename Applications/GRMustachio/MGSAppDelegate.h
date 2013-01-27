//
//  MGSAppDelegate.h
//  GRMustachio
//
//  Created by Jonathan on 22/01/2013.
//  Copyright (c) 2013 Mugginsoft LLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MGSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *JSONTextView;
@property (assign) IBOutlet NSTextView *templateTextView;
@property (assign) IBOutlet NSTextView *renderTextView;
@property (assign) IBOutlet NSObjectController *objectController;

@property (retain) NSString *JSONstring;
@property (retain) NSString *templateString;
@property (retain) NSString *renderString;
@property (nonatomic) NSUInteger contentType;

- (IBAction)renderAction:(id)sender;

@end
