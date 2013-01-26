// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#import "GRMustacheConfiguration_private.h"

@implementation GRMustacheConfiguration
@synthesize contentType=_contentType;
@synthesize locked=_locked;

+ (GRMustacheConfiguration *)defaultConfiguration
{
    static GRMustacheConfiguration *defaultConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfiguration = [[GRMustacheConfiguration configuration] retain];
    });
    return defaultConfiguration;
}

+ (GRMustacheConfiguration *)configuration
{
    return [[[GRMustacheConfiguration alloc] init] autorelease];
}

- (void)lock
{
    _locked = YES;
}

- (void)setContentType:(GRMustacheContentType)contentType
{
    if (_locked) {
        [NSException raise:NSGenericException format:@"%@ was mutated after template compilation", self];
        return;
    }
    _contentType = contentType;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    GRMustacheConfiguration *configuration = [[GRMustacheConfiguration alloc] init];
    configuration.contentType = self.contentType;
    return configuration;
}

@end
