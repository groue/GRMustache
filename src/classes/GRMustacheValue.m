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

#import "GRMustacheValue_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheFilter.h"


// =============================================================================
#pragma mark - GRMustacheKeyPathValue

@interface GRMustacheKeyPathValue()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic, retain) GRMustacheToken *token;
- (id)initWithToken:(GRMustacheToken *)token keys:(NSArray *)keys;
@end

@implementation GRMustacheKeyPathValue
@synthesize invocation = _invocation;
@synthesize token = _token;

+ (id)valueWithToken:(GRMustacheToken *)token keys:(NSArray *)keys
{
    return [[[self alloc] initWithToken:token keys:keys] autorelease];
}

- (void)dealloc
{
    [_token release];
    [_invocation release];
    [super dealloc];
}

- (id)initWithToken:(GRMustacheToken *)token keys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        self.token = token;
        self.invocation = [GRMustacheInvocation invocationWithKeys:keys token:token];
    }
    return self;
}


#pragma mark GRMustacheValue

- (id)objectForContext:(GRMustacheContext *)context template:(GRMustacheTemplate *)rootTemplate;
{
    [_invocation invokeWithContext:context];
    return [[_invocation.returnValue retain] autorelease];
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterChainValue

@interface GRMustacheFilterChainValue()
@property (nonatomic, retain) id<GRMustacheValue> filteredValue;
@property (nonatomic, retain) NSArray *filterValues;
@property (nonatomic, retain) GRMustacheToken *token;
- (id)initWithToken:(GRMustacheToken *)token filteredValue:(id<GRMustacheValue>)filteredValue filterValues:(NSArray *)filterValues;
@end

@implementation GRMustacheFilterChainValue
@synthesize filteredValue = _filteredValue;
@synthesize filterValues = _filterValues;
@synthesize token = _token;

+ (id)valueWithToken:(GRMustacheToken *)token filteredValue:(id<GRMustacheValue>)filteredValue filterValues:(NSArray *)filterValues
{
    return [[[self alloc] initWithToken:token filteredValue:filteredValue filterValues:filterValues] autorelease];
}

- (void)dealloc
{
    [_token release];
    [_filteredValue release];
    [_filterValues release];
    [super dealloc];
}

- (id)initWithToken:(GRMustacheToken *)token filteredValue:(id<GRMustacheValue>)filteredValue filterValues:(NSArray *)filterValues
{
    self = [super init];
    if (self) {
        self.token = token;
        self.filteredValue = filteredValue;
        self.filterValues = filterValues;
    }
    return self;
}


#pragma mark GRMustacheValue

- (id)objectForContext:(GRMustacheContext *)context template:(GRMustacheTemplate *)rootTemplate;
{
    id object = [_filteredValue objectForContext:context template:rootTemplate];
    
    for (id<GRMustacheValue> filterValue in _filterValues) {
        id<GRMustacheFilter> filter = [filterValue objectForContext:context template:rootTemplate];
        object = [filter transformedValue:object];
    }
    
    return [[object retain] autorelease];
}

@end
