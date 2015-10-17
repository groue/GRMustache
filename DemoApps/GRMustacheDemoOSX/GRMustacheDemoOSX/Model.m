//
//  Model.m
//  GRMustacheDemoOSX
//
//  Created by Gwendal Roué on 17/10/2015.
//  Copyright © 2015 Gwendal Roué. All rights reserved.
//

#import "Model.h"

@implementation Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.templateString = @"Hello {{ name }}!";
        self.JSONString = @"{\n  \"name\": \"Arthur\"\n}";
    }
    return self;
}

@end
