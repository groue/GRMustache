//
//  GRMustacheTest.h
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GRMustache.h"


@interface GRMustacheTestBase: SenTestCase
@property (nonatomic, readonly) NSBundle *testBundle;
- (NSString *)renderObject:(id)object fromResource:(NSString *)name;
- (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext;
@end
