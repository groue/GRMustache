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


/**
 The kinds of tokens
 */
typedef enum {
    /**
     The kind of tokens representing escaped variable tags such as `{{name}}`.
     
     The implementation of GRMustacheTokenizer depends on the fact that GRMustacheTokenTypeEscapedVariable is 0.
     */
    GRMustacheTokenTypeEscapedVariable = 0,

    /**
     The kind of tokens representing raw text.
     */
    GRMustacheTokenTypeText,
    
    /**
     The kind of tokens representing a comment tag such as `{{! comment }}`.
     */
    GRMustacheTokenTypeComment,
    
    /**
     The kind of tokens representing unescaped variable tag such as `{{{name}}}` and `{{&name}}`.
     */
    GRMustacheTokenTypeUnescapedVariable,
    
    /**
     The kind of tokens representing section opening tags such as `{{#name}}`.
     */
    GRMustacheTokenTypeSectionOpening,
    
    /**
     The kind of tokens representing inverted section opening tags such as `{{^name}}`.
     */
    GRMustacheTokenTypeInvertedSectionOpening,
    
    /**
     The kind of tokens representing section closing tags such as `{{/name}}`.
     */
    GRMustacheTokenTypeSectionClosing,
    
    /**
     The kind of tokens representing partial tags such as `{{>name}}`.
     */
    GRMustacheTokenTypePartial,
    
    /**
     The kind of tokens representing delimiters tags such as `{{=< >=}}`.
     */
    GRMustacheTokenTypeSetDelimiter,
} GRMustacheTokenType;

/**
 A GRMustacheToken is the product of GRMustacheTokenizer. It represents a {{Mustache}} tag, or raw text between tags.
 
 For instance, the template string "hello {{name}}!" would be represented by three tokens:
 - a token of type GRMustacheTokenTypeText holding "hello "
 - a token of type GRMustacheTokenTypeEscapedVariable holding "{{name}}"
 - a token of type GRMustacheTokenTypeText holding "!"
 */
@interface GRMustacheToken : NSObject {
@private
    GRMustacheTokenType _type;
    NSString *_content;
    NSString *_templateString;
    id _templateID;
    NSUInteger _line;
    NSRange _range;
}

/**
 The type of the token.
 */
@property (nonatomic, readonly) GRMustacheTokenType type GRMUSTACHE_API_INTERNAL;

/**
 The content of the token depends on its type.
 
 For tokens of type GRMustacheTokenTypeText, the content is the represented text.
 
 For tokens of a tag type, the content is the identifier inside the tag.
 For instance, it would be "name" for a token representing `{{ name }}`.
 */
@property (nonatomic, readonly, retain) NSString *content GRMUSTACHE_API_INTERNAL;

/**
 The Mustache template string this token comes from.
 */
@property (nonatomic, readonly, retain) NSString *templateString GRMUSTACHE_API_INTERNAL;

/**
 The template ID of the template this token comes from (see GRMustacheTemplateRepository).
 */
@property (nonatomic, readonly, retain) id templateID GRMUSTACHE_API_INTERNAL;

/**
 The line in templateString where this token lies.
 */
@property (nonatomic, readonly) NSUInteger line GRMUSTACHE_API_INTERNAL;

/**
 The range in templateString where this token lies.
 
 For tokens of type GRMustacheTokenTypeText, the range is the full range of the represented text.
 
 For tokens of a tag type, the range is the full range of the tag, from `{{` to `}}` included.
 */
@property (nonatomic, readonly) NSRange range GRMUSTACHE_API_INTERNAL;

/**
 Builds and return a token.
 
 The caller is responsible for honoring the template properties semantics and relationships.
 
 @see type
 @see content
 @see templateString
 @see templateID
 @see line
 @see range
 */
+ (id)tokenWithType:(GRMustacheTokenType)type content:(NSString *)content templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range GRMUSTACHE_API_INTERNAL;
@end
