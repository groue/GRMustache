//
//  MGSAppDelegate.m
//  GRMustachio
//
//  Created by Jonathan on 22/01/2013.
//  Copyright (c) 2013 Mugginsoft LLP. All rights reserved.
//

#import "MGSAppDelegate.h"
#import "GRMustache.h"

@implementation MGSAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.JSONstring = @"{ \"value\" : \"proposition\" \n, \"valid?\" : \" \\\"Yes\\\" \" }";
    self.templateString = @"Thus my {{ value }} is valid, I declared? {{#valid?}}{{{.}}}{{^}}\"No\"{{/}}, she replied, {{#valid?}}raising{{^}}lowering{{/}} her Luger.";
    [self renderAction:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)renderAction:(id)sender
{
    [self.objectController commitEditing];
    
    NSString *output = nil;
    NSError *error = nil;
    NSData* data = [self.JSONstring dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!error) {
       output = [GRMustacheTemplate renderObject:object fromString:self.templateString error:&error];
    }
    
    if (error) {
        self.renderString = [error description];
    } else {
        self.renderString = output;
    }
}

@end
