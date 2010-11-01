//
//  GRMustacheTest.m
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRMustacheTestBase.h"


@implementation GRMustacheTestBase
@dynamic testBundle;

- (NSBundle *)testBundle {
	return [NSBundle bundleWithIdentifier:@"com.pierlis.GRMustacheTest"];
}

- (NSString *)renderObject:(id)object fromResource:(NSString *)name {
	return [GRMustacheTemplate renderObject:object
							  fromResource:name
									bundle:self.testBundle
									 error:nil];
}

- (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext {
	return [GRMustacheTemplate renderObject:object
							  fromResource:name
							 withExtension:ext
									bundle:self.testBundle
									 error:nil];
}

@end
