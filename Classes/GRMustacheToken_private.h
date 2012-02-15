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

#import <Foundation/Foundation.h>


typedef enum {
    GRMustacheTokenTypeUndefined = 0,
	GRMustacheTokenTypeText,
	GRMustacheTokenTypeComment,
	GRMustacheTokenTypeEscapedVariable,
	GRMustacheTokenTypeUnescapedVariable,
	GRMustacheTokenTypeSectionOpening,
	GRMustacheTokenTypeInvertedSectionOpening,
	GRMustacheTokenTypeSectionClosing,
	GRMustacheTokenTypePartial,
	GRMustacheTokenTypeSetDelimiter,
} GRMustacheTokenType;

@interface GRMustacheToken : NSObject {
	GRMustacheTokenType type;
	NSString *content;
	NSString *templateString;
	NSUInteger line;
	NSRange range;
}
@property (nonatomic, readonly) GRMustacheTokenType type;
@property (nonatomic, readonly, retain) NSString *content;
@property (nonatomic, readonly, retain) NSString *templateString;
@property (nonatomic, readonly) NSUInteger line;
@property (nonatomic, readonly) NSRange range;
+ (id)tokenWithType:(GRMustacheTokenType)type content:(NSString *)content templateString:(NSString *)templateString line:(NSUInteger)line range:(NSRange)range;
@end
