// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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

#import "ArrayElementProxy.h"

@interface ArrayElementProxy()
@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) NSArray *array;
@end

@implementation ArrayElementProxy
@synthesize index=_index;
@synthesize array=_array;

- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.index = index;
        self.array = array;
    }
    return self;
}

// Support for `{{.}}`, not used in our sample template, but a honest proxy
// should implement it.
- (NSString *)description
{
    id originalObject = [self.array objectAtIndex:self.index];
    return [originalObject description];
}

- (id)valueForKey:(NSString *)key
{
    // support for `{{index}}`
    if ([key isEqualToString:@"index"]) {
        return [NSNumber numberWithUnsignedInteger:self.index];
    }
    
    // support for `{{#first}}` and `{{^first}}`
    if ([key isEqualToString:@"first"]) {
        return [NSNumber numberWithBool:(self.index == 0)];
    }
    
    // support for `{{#even}}` and `{{^even}}`
    if ([key isEqualToString:@"even"]) {
        return [NSNumber numberWithBool:((self.index % 2) == 0)];
    }
    
    // for all other keys, forward to original array element
    id originalObject = [self.array objectAtIndex:self.index];
    return [originalObject valueForKey:key];
}

@end
