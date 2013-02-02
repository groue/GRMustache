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

static GRMustacheConfiguration *defaultConfiguration;

@interface GRMustacheConfiguration()
- (void)assertNotLocked;
@end

@implementation GRMustacheConfiguration
@synthesize contentType=_contentType;
@synthesize tagStartDelimiter=_tagStartDelimiter;
@synthesize tagEndDelimiter=_tagEndDelimiter;
@synthesize locked=_locked;

+ (void)load
{
    defaultConfiguration = [[GRMustacheConfiguration alloc] init];
}

+ (GRMustacheConfiguration *)defaultConfiguration
{
    return defaultConfiguration;
}

+ (GRMustacheConfiguration *)configuration
{
    return [[[GRMustacheConfiguration alloc] init] autorelease];
}

- (void)dealloc
{
    [_tagStartDelimiter release];
    [_tagEndDelimiter release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _contentType = GRMustacheContentTypeHTML;
        _tagStartDelimiter = @"{{";
        _tagEndDelimiter = @"}}";
    }
    return self;
}

- (void)lock
{
    _locked = YES;
}

- (void)setContentType:(GRMustacheContentType)contentType
{
    [self assertNotLocked];
    
    _contentType = contentType;
}

- (void)setTagStartDelimiter:(NSString *)tagStartDelimiter
{
    [self assertNotLocked];
    
    if (_tagStartDelimiter != tagStartDelimiter) {
        [_tagStartDelimiter release];
        _tagStartDelimiter = [tagStartDelimiter copy];
    }
}

- (void)setTagEndDelimiter:(NSString *)tagEndDelimiter
{
    [self assertNotLocked];
    
    if (_tagEndDelimiter != tagEndDelimiter) {
        [_tagEndDelimiter release];
        _tagEndDelimiter = [tagEndDelimiter copy];
    }
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    GRMustacheConfiguration *configuration = [[GRMustacheConfiguration alloc] init];
    configuration.contentType = self.contentType;
    configuration.tagStartDelimiter = self.tagStartDelimiter;   // property setter does the copy
    configuration.tagEndDelimiter = self.tagEndDelimiter;       // property setter does the copy
    return configuration;
}


#pragma mark - Private

- (void)assertNotLocked
{
    if (_locked) {
        [NSException raise:NSGenericException format:@"%@ was mutated after template compilation", self];
    }
}
@end
