// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheSection_private.h"


@interface GRMustacheSection()
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *baseTemplateString;
@property (nonatomic) NSRange range;
@property (nonatomic) BOOL inverted;
@property (nonatomic, retain) NSArray *elems;
- (id)initWithName:(NSString *)name baseTemplateString:(NSString *)baseTemplateString range:(NSRange)range inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSection
@synthesize baseTemplateString;
@synthesize range;
@synthesize name;
@synthesize inverted;
@synthesize elems;

+ (id)sectionElementWithName:(NSString *)name baseTemplateString:(NSString *)baseTemplateString range:(NSRange)range inverted:(BOOL)inverted elements:(NSArray *)elems {
	return [[[self alloc] initWithName:name baseTemplateString:baseTemplateString range:range inverted:inverted elements:elems] autorelease];
}

- (id)initWithName:(NSString *)theName baseTemplateString:(NSString *)theBaseTemplateString range:(NSRange)theRange inverted:(BOOL)theInverted elements:(NSArray *)theElems {
	if ((self = [self init])) {
		self.name = theName;
		self.baseTemplateString = theBaseTemplateString;
        self.range = theRange;
		self.inverted = theInverted;
		self.elems = theElems;
	}
	return self;
}

- (void)dealloc {
	[name release];
	[baseTemplateString release];
	[elems release];
	[super dealloc];
}

- (NSString *)templateString {
    return [baseTemplateString substringWithRange:range];
}


@end
