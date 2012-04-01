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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"


typedef enum {
    GRMustacheTokenTypeEscapedVariable = 0, // 0 is used by GRMustacheTokenizer
    GRMustacheTokenTypeText,
    GRMustacheTokenTypeComment,
    GRMustacheTokenTypeUnescapedVariable,
    GRMustacheTokenTypeSectionOpening,
    GRMustacheTokenTypeInvertedSectionOpening,
    GRMustacheTokenTypeSectionClosing,
    GRMustacheTokenTypePartial,
    GRMustacheTokenTypeSetDelimiter,
} GRMustacheTokenType;

@interface GRMustacheToken : NSObject {
    GRMustacheTokenType _type;
    NSString *_content;
    NSString *_templateString;
    id _templateID;
    NSUInteger _line;
    NSRange _range;
}
@property (nonatomic, readonly) GRMustacheTokenType type GRMUSTACHE_API_INTERNAL;
@property (nonatomic, readonly, retain) NSString *content GRMUSTACHE_API_INTERNAL;
@property (nonatomic, readonly, retain) NSString *templateString GRMUSTACHE_API_INTERNAL;
@property (nonatomic, readonly, retain) id templateID GRMUSTACHE_API_INTERNAL;
@property (nonatomic, readonly) NSUInteger line GRMUSTACHE_API_INTERNAL;
@property (nonatomic, readonly) NSRange range GRMUSTACHE_API_INTERNAL;
+ (id)tokenWithType:(GRMustacheTokenType)type content:(NSString *)content templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range GRMUSTACHE_API_INTERNAL;
@end
