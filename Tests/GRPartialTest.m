//
//  PPartialTest.m
//

#import "GRPartialTest.h"


@implementation PPartialTest

- (void)testViewPartial {
	// TODO, but ruby test is unclear about its intent
}

- (void)testPartialWithSlashes {
	// TODO
}

- (void)testViewPartialInheritsContext {
	// TODO
}

- (void)testTemplatePartial {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"Welcome" forKey:@"title"];
	NSString *result = [self renderObject:context fromResource:@"template_partial"];
	STAssertEqualObjects(result, @"<h1>Welcome</h1>\nAgain, Welcome!", nil);
}

- (void)testPartialWithCustomExtension {
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Welcome", @"title",
							 @"-------", @"title_bars",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"template_partial" withExtension:@"txt"];
	STAssertEqualObjects(result, @"Welcome\n-------\n\n## Again, Welcome! ##\n\n", nil);
}

- (void)testRecursivePartial {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"show"];
	NSString *result = [self renderObject:context fromResource:@"recursive"];
	STAssertEqualObjects(result, @"It works!\n", @"");
}

- (void)testCrazyRecursivePartial {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																[NSDictionary dictionaryWithObjectsAndKeys:
																 @"1", @"contents",
																 [NSArray arrayWithObjects:
																  [NSDictionary dictionaryWithObjectsAndKeys:
																   @"2", @"contents",
																   [NSArray arrayWithObjects:
																	[NSDictionary dictionaryWithObjectsAndKeys:
																	 @"3", @"contents",
																	 [NSArray array], @"children",
																	 nil],
																	nil], @"children",
																   nil],
																  [NSDictionary dictionaryWithObjectsAndKeys:
																   @"4", @"contents",
																   [NSArray arrayWithObjects:
																	[NSDictionary dictionaryWithObjectsAndKeys:
																	 @"5", @"contents",
																	 [NSArray arrayWithObjects:
																	  [NSDictionary dictionaryWithObjectsAndKeys:
																	   @"6", @"contents",
																	   [NSArray array], @"children",
																	   nil],
																	  nil], @"children",
																	 nil],
																	nil], @"children",
																   nil],
																  nil], @"children",
																 nil],
																nil]
														forKey:@"top_nodes"];
	NSString *result = [self renderObject:context fromResource:@"crazy_recursive"];
	STAssertEqualObjects(result, @"<html>\n  <body>\n    <ul>\n      <li>\n  1\n  <ul>\n    <li>\n  2\n  <ul>\n    <li>\n  3\n  <ul>\n    </ul>\n</li>\n    </ul>\n</li>\n    <li>\n  4\n  <ul>\n    <li>\n  5\n  <ul>\n    <li>\n  6\n  <ul>\n    </ul>\n</li>\n    </ul>\n</li>\n    </ul>\n</li>\n    </ul>\n</li>\n      </ul>\n  </body>\n</html>", @"");
}



@end
