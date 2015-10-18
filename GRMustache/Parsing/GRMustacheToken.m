// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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


@implementation GRMustacheToken

- (void)dealloc
{
    [_templateString release];
    [_templateID release];
    [_tagStartDelimiter release];
    [_tagEndDelimiter release];
    [super dealloc];
}

+ (instancetype)tokenWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range tagStartDelimiter:(NSString *)tagStartDelimiter tagEndDelimiter:(NSString *)tagEndDelimiter
{
    GRMustacheToken *token = [[[self alloc] init] autorelease];
    token.type = type;
    token.templateString = templateString;
    token.templateID = templateID;
    token.line = line;
    token.range = range;
    token.tagStartDelimiter = tagStartDelimiter;
    token.tagEndDelimiter = tagEndDelimiter;
    return token;
}

- (NSString *)templateSubstring
{
    return [_templateString substringWithRange:_range];
}

- (NSString *)tagInnerContent
{
    return [_templateString substringWithRange:_tagInnerRange];
}

@end

