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

#import "GRMustacheRenderingASTVisitor_private.h"
#import "GRMustacheAST_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheSectionNode_private.h"
#import "GRMustacheVariableNode_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheTranslateCharacters_private.h"
#import "GRMustacheInheritablePartial_private.h"
#import "GRMustacheInheritableSection_private.h"
#import "GRMustachePartial_private.h"
#import "GRMustacheTextNode_private.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheFilter_private.h"
#import "GRMustacheError.h"

@implementation GRMustacheRenderingASTVisitor

- (void)dealloc
{
    GRMustacheBufferRelease(&_buffer);
    [super dealloc];
}

- (instancetype)initWithContentType:(GRMustacheContentType)contentType context:(GRMustacheContext *)context
{
    if (!context) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    self = [super init];
    if (self) {
        _contentType = contentType;
        _context = context;
        _buffer = GRMustacheBufferCreate(1024);
    }
    return self;
}

- (NSString *)renderingWithHTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
    }
    return (NSString *)GRMustacheBufferGetString(&_buffer);
}

- (BOOL)visitContentOfSectionNode:(GRMustacheSectionNode *)sectionNode error:(NSError **)error
{
    return [self visitASTNodes:sectionNode.ASTNodes error:error];
}


#pragma mark - AST Nodes

- (BOOL)visitInheritablePartial:(GRMustacheInheritablePartial *)inheritablePartial error:(NSError **)error
{
    GRMustacheContext *context = _context;
    _context = [_context contextByAddingInheritablePartial:inheritablePartial];
    BOOL success = [inheritablePartial.partial acceptVisitor:self error:error];
    _context = context;
    return success;
}

- (BOOL)visitInheritableSection:(GRMustacheInheritableSection *)inheritableSection error:(NSError **)error
{
    return [self visitASTNodes:inheritableSection.ASTNodes error:error];
}

- (BOOL)visitPartial:(GRMustachePartial *)partial error:(NSError **)error
{
    GRMustacheAST *AST = partial.AST;
    GRMustacheContentType partialContentType = AST.contentType;
    
    if (_contentType != partialContentType)
    {
        GRMustacheRenderingASTVisitor *visitor = [[[GRMustacheRenderingASTVisitor alloc] initWithContentType:partialContentType context:_context] autorelease];
        if (![partial acceptVisitor:visitor error:error]) {
            return NO;
        }
        BOOL HTMLSafe;
        NSString *rendering = [visitor renderingWithHTMLSafe:&HTMLSafe error:error];
        if (!rendering) {
            return NO;
        }
        if (_contentType == GRMustacheContentTypeHTML && !HTMLSafe) {
            rendering = GRMustacheTranslateHTMLCharacters(rendering);
        }
        GRMustacheBufferAppendString(&_buffer, rendering);
        return YES;
    }
    else
    {
        [GRMustacheRendering pushCurrentContentType:partialContentType];
        BOOL success = [self visitASTNodes:AST.ASTNodes error:error];
        [GRMustacheRendering popCurrentContentType];
        return success;
    }
}

- (BOOL)visitVariableNode:(GRMustacheVariableNode *)variableNode error:(NSError **)error
{
    GRMustacheTag *tag = [GRMustacheTag tagWithVariableNode:variableNode];
    return [self visitTag:tag expression:variableNode.expression escapesHTML:variableNode.escapesHTML error:error];
}

- (BOOL)visitSectionNode:(GRMustacheSectionNode *)sectionNode error:(NSError **)error
{
    GRMustacheTag *tag = [GRMustacheTag tagWithSectionNode:sectionNode];
    return [self visitTag:tag expression:sectionNode.expression escapesHTML:YES error:error];
}

- (BOOL)visitTextNode:(GRMustacheTextNode *)textNode error:(NSError **)error
{
    GRMustacheBufferAppendString(&_buffer, textNode.text);
    return YES;
}


#pragma mark - Expressions

- (BOOL)visitFilteredExpression:(GRMustacheFilteredExpression *)expression value:(id *)value error:(NSError **)error
{
    id filter;
    if (![expression.filterExpression acceptVisitor:self value:&filter error:error]) {
        return NO;
    }
    
    id argument;
    if (![expression.argumentExpression acceptVisitor:self value:&argument error:error]) {
        return NO;
    }
    
    if (filter == nil) {
        GRMustacheToken *token = expression.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu of template %@", token.templateSubstring, (unsigned long)token.line, token.templateID];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu", token.templateSubstring, (unsigned long)token.line];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Missing filter"];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        } else {
            NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
        }
        return NO;
    }
    
    if (![filter respondsToSelector:@selector(transformedValue:)]) {
        GRMustacheToken *token = expression.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu of template %@: %@", token.templateSubstring, (unsigned long)token.line, token.templateID, filter];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu: %@", token.templateSubstring, (unsigned long)token.line, filter];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol: %@", filter];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        } else {
            NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
        }
        return NO;
    }
    
    if (expression.isCurried && [filter respondsToSelector:@selector(filterByCurryingArgument:)]) {
        *value = [(id<GRMustacheFilter>)filter filterByCurryingArgument:argument];
    } else {
        *value = [(id<GRMustacheFilter>)filter transformedValue:argument];
    }
    
    _protected = NO;
    return YES;
}

- (BOOL)visitIdentifierExpression:(GRMustacheIdentifierExpression *)expression value:(id *)value error:(NSError **)error
{
    *value = [_context valueForMustacheKey:expression.identifier protected:&_protected];
    return YES;
}

- (BOOL)visitScopedExpression:(GRMustacheScopedExpression *)expression value:(id *)value error:(NSError **)error
{
    id scopedValue;
    if (![expression.baseExpression acceptVisitor:self value:&scopedValue error:error]) {
        return NO;
    }
    
    *value = [GRMustacheKeyAccess valueForMustacheKey:expression.identifier inObject:scopedValue unsafeKeyAccess:_context.unsafeKeyAccess];
    _protected = NO;
    return YES;
}

- (BOOL)visitImplicitIteratorExpression:(GRMustacheImplicitIteratorExpression *)expression value:(id *)value error:(NSError **)error
{
    *value = [_context topMustacheObject];
    _protected = NO;
    return YES;
}


#pragma mark - Private

- (BOOL)visitTag:(GRMustacheTag *)tag expression:(GRMustacheExpression *)expression escapesHTML:(BOOL)escapesHTML error:(NSError **)error
{
    BOOL success = YES;
    
    @autoreleasepool {
        
        GRMustacheContext *context = _context;
        
        // Evaluate expression
        
        __block id object;
        if (![expression acceptVisitor:self value:&object error:error]) {  // this sets _protected
            
            // Error
            
            if (error != NULL) {
                [*error retain];   // retain error so that it survives the @autoreleasepool block
            }
            
            success = NO;
            
        } else {
            
            // Hide object if it is protected
            
            if (_protected) {
                // Object is protected: it may enter the context stack, and provide
                // value for `.` and `.name`. However, it must not expose its keys.
                //
                // The goal is to have `{{ safe.name }}` and `{{#safe}}{{.name}}{{/safe}}`
                // work, but not `{{#safe}}{{name}}{{/safe}}`.
                //
                // Rationale:
                //
                // Let's look at `{{#safe}}{{#hacker}}{{name}}{{/hacker}}{{/safe}}`:
                //
                // The protected context stack contains the "protected root":
                // { safe : { name: "important } }.
                //
                // Since the user has used the key `safe`, he expects `name` to be
                // safe as well, even if `hacker` has defined its own `name`.
                //
                // So we need to have `name` come from `safe`, not from `hacker`.
                // We should thus start looking in `safe` first. But `safe` was
                // not initially in the protected context stack. Only the protected
                // root was. Hence somebody had `safe` in the protected context
                // stack.
                //
                // Who has objects enter the context stack? Rendering objects do. So
                // rendering objects have to know that values are protected or not,
                // and choose the correct bucket accordingly.
                //
                // Who can write his own rendering objects? The end user does. So
                // the end user must carefully read a documentation about safety,
                // and then carefully code his rendering objects so that they
                // conform to this safety notice.
                //
                // Of course this is not what we want. So `name` can not be
                // protected. Since we don't want to let the user think he is data
                // is given protected when it is not, we prevent this whole pattern, and
                // forbid `{{#safe}}{{name}}{{/safe}}`.
                context = [context contextByAddingHiddenObject:object];
            }
            
            
            // Rendered value hooks
            
            NSArray *tagDelegateStack = [context tagDelegateStack];
            for (id<GRMustacheTagDelegate> tagDelegate in [tagDelegateStack reverseObjectEnumerator]) { // willRenderObject: from top to bottom
                if ([tagDelegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                    object = [tagDelegate mustacheTag:tag willRenderObject:object];
                }
            }
            
            
            // Render value
            
            BOOL objectHTMLSafe = NO;
            NSError *renderingError = nil;  // set it to nil, so that we can help lazy coders who return nil as a valid rendering.
            NSString *rendering = [[GRMustacheRendering renderingObjectForObject:object] renderForMustacheTag:tag context:context HTMLSafe:&objectHTMLSafe error:&renderingError];
            
            if (rendering == nil && renderingError == nil)
            {
                // Rendering is nil, but rendering error is not set.
                //
                // Assume a rendering object coded by a lazy programmer, whose
                // intention is to render nothing.
                
                rendering = @"";
            }
            
            
            // Finish
            
            if (rendering)
            {
                // render
                
                if (rendering.length > 0) {
                    if ((_contentType == GRMustacheContentTypeHTML) && !objectHTMLSafe && escapesHTML) {
                        rendering = GRMustacheTranslateHTMLCharacters(rendering);
                    }
                    GRMustacheBufferAppendString(&_buffer, rendering);
                }
                
                
                // Post-rendering hooks
                
                for (id<GRMustacheTagDelegate> tagDelegate in tagDelegateStack) { // didRenderObject: from bottom to top
                    if ([tagDelegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                        [tagDelegate mustacheTag:tag didRenderObject:object as:rendering];
                    }
                }
            }
            else
            {
                // Error
                
                if (error != NULL) {
                    *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
                } else {
                    NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
                }
                success = NO;
                
                
                // Post-error hooks
                
                for (id<GRMustacheTagDelegate> tagDelegate in tagDelegateStack) { // didFailRenderingObject: from bottom to top
                    if ([tagDelegate respondsToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) {
                        [tagDelegate mustacheTag:tag didFailRenderingObject:object withError:renderingError];
                    }
                }
            }
        }
    }
    
    if (!success && error) [*error autorelease];    // the error has been retained inside the @autoreleasepool block
    return success;
}

- (BOOL)visitASTNodes:(NSArray *)ASTNodes error:(NSError **)error
{
    for (id<GRMustacheASTNode> ASTNode in ASTNodes) {
        
        ASTNode = [_context resolveASTNode:ASTNode];
        
        if (![ASTNode acceptVisitor:self error:error]) {
            return NO;
        }
    }
    
    return YES;
}

@end
