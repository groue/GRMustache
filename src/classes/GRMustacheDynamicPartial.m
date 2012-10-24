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

#import "GRMustacheDynamicPartial.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateRepository.h"
#import "GRMustacheRenderingObject.h"

@interface GRMustacheDynamicPartial()
- (id)initWithName:(NSString *)name;
@end

@implementation GRMustacheDynamicPartial

+ (id)dynamicPartialWithName:(NSString *)name
{
    return [[[GRMustacheDynamicPartial alloc] initWithName:name] autorelease];
}

- (void)dealloc
{
    [_name release];
    [super dealloc];
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name retain];
    }
    return self;
}

// =============================================================================
#pragma mark - <GRMustacheRenderingObject> informal protocol

- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository forRenderingObject:(id<GRMustacheRenderingObject>)renderingObject HTMLEscaped:(BOOL *)HTMLEscaped
{
    NSError *error;
    GRMustacheTemplate *template = [templateRepository templateNamed:_name error:&error];
    if (!template) {
        [NSException raise:GRMustacheRenderingException format:@"%@", [error localizedDescription]];
    }
    return [template renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
}

@end


