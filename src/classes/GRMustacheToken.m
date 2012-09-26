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
- (id)initWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range text:(NSString *)text expression:(GRMustacheExpression *)expression invalidExpression:(BOOL)invalidExpression partialName:(NSString *)partialName pragma:(NSString *)pragma;

@end

@implementation GRMustacheToken
@synthesize type=_type;
@synthesize templateString=_templateString;
@synthesize templateID=_templateID;
@synthesize line=_line;
@synthesize range=_range;
@synthesize text=_text;
@synthesize expression=_expression;
@synthesize invalidExpression=_invalidExpression;
@synthesize partialName=_partialName;
@synthesize pragma=_pragma;

- (void)dealloc
{
    [_templateString release];
    [_templateID release];
    [super dealloc];
}

+ (id)tokenWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range text:(NSString *)text expression:(GRMustacheExpression *)expression invalidExpression:(BOOL)invalidExpression partialName:(NSString *)partialName pragma:(NSString *)pragma
{
    return [[[self alloc] initWithType:type templateString:templateString templateID:templateID line:line range:range text:text expression:expression invalidExpression:invalidExpression partialName:partialName pragma:pragma] autorelease];
}


#pragma mark Private

- (id)initWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range text:(NSString *)text expression:(GRMustacheExpression *)expression invalidExpression:(BOOL)invalidExpression partialName:(NSString *)partialName pragma:(NSString *)pragma;
{
    self = [self init];
    if (self) {
        _type = type;
        _templateString = [templateString retain];
        _templateID = [templateID retain];
        _line = line;
        _range = range;
        _text = text;
        _expression = expression;
        _invalidExpression = invalidExpression;
        _partialName = partialName;
        _pragma = pragma;
    }
    return self;
}

- (NSString *)templateSubstring
{
    return [_templateString substringWithRange:_range];
}

@end

