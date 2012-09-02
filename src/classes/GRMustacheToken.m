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

#import "GRMustacheToken_private.h"


@interface GRMustacheToken()

/**
 * @see +[GRMustacheToken tokenWithType:value:templateString:templateID:line:range:]
 */
- (id)initWithType:(GRMustacheTokenType)type value:(GRMustacheTokenValue)value templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range;

@end

@implementation GRMustacheToken
@synthesize type=_type;
@synthesize value=_value;
@synthesize templateString=_templateString;
@synthesize templateID=_templateID;
@synthesize line=_line;
@synthesize range=_range;

- (void)dealloc
{
    [_templateString release];
    [_templateID release];
    [super dealloc];
}

+ (id)tokenWithType:(GRMustacheTokenType)type value:(GRMustacheTokenValue)value templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range
{
    return [[[self alloc] initWithType:type value:value templateString:templateString templateID:templateID line:line range:range] autorelease];
}


#pragma mark Private

- (id)initWithType:(GRMustacheTokenType)type value:(GRMustacheTokenValue)value templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range
{
    self = [self init];
    if (self) {
        _type = type;
        _value = value;
        _templateString = [templateString retain];
        _templateID = [templateID retain];
        _line = line;
        _range = range;
    }
    return self;
}

- (NSString *)templateSubstring
{
    return [_templateString substringWithRange:_range];
}

- (GRMustacheTokenValue)value
{
    [[_value.object retain] autorelease];
    return _value;
}
@end

