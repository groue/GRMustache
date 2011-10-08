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

#import "GRMustacheContextStrategy_private.h"
#import "GRMustacheContext_private.h"

@interface GRMustacheContextStrategy()
@property (nonatomic, copy) NSString *keyComponentsSeparator;
@property (nonatomic, copy) NSString *upContextKey;
@property (nonatomic, copy) NSString *selfContextKey;
@end

@implementation GRMustacheContextStrategy
@synthesize keyComponentsSeparator;
@synthesize upContextKey;
@synthesize selfContextKey;

+ (GRMustacheContextStrategy *)handlebarsStrategy
{
    GRMustacheContextStrategy *strategy = [[[GRMustacheContextStrategy alloc] init] autorelease];
    strategy.keyComponentsSeparator = @"/";
    strategy.upContextKey = @"..";
    strategy.selfContextKey = @".";
    return strategy;
}

+ (GRMustacheContextStrategy *)mustacheSpecStrategy
{
    GRMustacheContextStrategy *strategy = [[[GRMustacheContextStrategy alloc] init] autorelease];
    strategy.keyComponentsSeparator = @".";
    strategy.upContextKey = nil;
    strategy.selfContextKey = @".";
    return strategy;
}

- (id)valueForKey:(NSString *)key inContext:(GRMustacheContext *)context
{
	// fast path for selfContextKey
    if ([selfContextKey isEqualToString:key]) { // selfContextKey may be nil
        return context.object;
    }
    
	// fast path for upContextKey
    if ([upContextKey isEqualToString:key]) {   // upContextKey may be nil
        if (context.parent == nil) {
            // went too far
            return nil;
        }
        return context.parent.object;
    }
    
    NSArray *components = nil;
    if (keyComponentsSeparator != nil) {
        components = [key componentsSeparatedByString:keyComponentsSeparator];
    }
	
	// fast path for single component
	if (components == nil || components.count == 1) {
		return [context valueForKeyComponent:key];
	}
	
	// slow path for multiple components
	for (NSString *component in components) {
		if (component.length == 0) {
			continue;
		}
		if ([selfContextKey isEqualToString:component]) { // selfContextKey may be nil
			continue;
		}
		if ([upContextKey isEqualToString:component]) {   // upContextKey may be nil
			context = context.parent;
			if (context == nil) {
				// went too far
				return nil;
			}
			continue;
		}
		id value = [context valueForKeyComponent:component];
		if (value == nil) {
			return nil;
		}
		// further contexts are not in the context stack
		context = [GRMustacheContext contextWithObject:value];
	}
	
	return context.object;
}

@end
