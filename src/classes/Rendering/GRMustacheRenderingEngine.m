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

#import "GRMustacheRenderingEngine_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheVariableTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheRendering_private.h"
#import "GRMustacheTranslateCharacters_private.h"
#import "GRMustacheInheritablePartialNode_private.h"
#import "GRMustacheInheritableSectionNode_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheTextNode_private.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheExpressionInvocation_private.h"

@implementation GRMustacheRenderingEngine

- (void)dealloc
{
    GRMustacheBufferRelease(&_buffer);
    [_context release];
    [_expressionInvocation release];
    [super dealloc];
}

+ (instancetype)renderingEngineWithContentType:(GRMustacheContentType)contentType context:(GRMustacheContext *)context
{
    return [[[self alloc] initWithContentType:contentType context:context] autorelease];
}

- (NSString *)renderHTMLSafe:(BOOL *)HTMLSafe
{
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
    }
    return (NSString *)GRMustacheBufferGetString(&_buffer);
}


#pragma mark - AST Nodes

- (BOOL)visitTemplateAST:(GRMustacheTemplateAST *)templateAST error:(NSError **)error
{
    GRMustacheContentType ASTContentType = templateAST.contentType;
    
    if (_contentType != ASTContentType)
    {
        // Render separately...
        
        GRMustacheRenderingEngine *renderingEngine = [[[GRMustacheRenderingEngine alloc] initWithContentType:ASTContentType context:_context] autorelease];
        if (![templateAST acceptTemplateASTVisitor:renderingEngine error:error]) {
            return NO;
        }
        BOOL HTMLSafe;
        NSString *rendering = [renderingEngine renderHTMLSafe:&HTMLSafe];
        
        // ... and escape if needed
        
        if (_contentType == GRMustacheContentTypeHTML && !HTMLSafe) {
            rendering = GRMustacheTranslateHTMLCharacters(rendering);
        }
        GRMustacheBufferAppendString(&_buffer, rendering);
        return YES;
    }
    else
    {
        [GRMustacheRendering pushCurrentContentType:ASTContentType];
        BOOL success = [self visitTemplateASTNodes:templateAST.templateASTNodes error:error];
        [GRMustacheRendering popCurrentContentType];
        return success;
    }
}

- (BOOL)visitInheritablePartialNode:(GRMustacheInheritablePartialNode *)inheritablePartialNode error:(NSError **)error
{
    GRMustacheContext *context = _context;
    _context = [_context contextByAddingInheritablePartialNode:inheritablePartialNode];
    BOOL success = [inheritablePartialNode.partialNode acceptTemplateASTVisitor:self error:error];
    _context = context;
    return success;
}

- (BOOL)visitInheritableSectionTag:(GRMustacheInheritableSectionNode *)inheritableSectionNode error:(NSError **)error
{
    return [inheritableSectionNode.templateAST acceptTemplateASTVisitor:self error:error];
}

- (BOOL)visitPartialNode:(GRMustachePartialNode *)partialNode error:(NSError **)error
{
    return [partialNode.templateAST acceptTemplateASTVisitor:self error:error];
}

- (BOOL)visitVariableTag:(GRMustacheVariableTag *)variableTag error:(NSError **)error
{
    return [self visitTag:variableTag expression:variableTag.expression escapesHTML:variableTag.escapesHTML error:error];
}

- (BOOL)visitSectionTag:(GRMustacheSectionTag *)sectionTag error:(NSError **)error
{
    return [self visitTag:sectionTag expression:sectionTag.expression escapesHTML:YES error:error];
}

- (BOOL)visitTextNode:(GRMustacheTextNode *)textNode error:(NSError **)error
{
    GRMustacheBufferAppendString(&_buffer, textNode.text);
    return YES;
}


#pragma mark - Private

- (instancetype)initWithContentType:(GRMustacheContentType)contentType context:(GRMustacheContext *)context
{
    if (!context) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    self = [super init];
    if (self) {
        _contentType = contentType;
        _context = [context retain];
        _buffer = GRMustacheBufferCreate(1024);
        _expressionInvocation = [[GRMustacheExpressionInvocation alloc] init];
    }
    return self;
}

- (BOOL)visitTag:(GRMustacheTag *)tag expression:(GRMustacheExpression *)expression escapesHTML:(BOOL)escapesHTML error:(NSError **)error
{
    BOOL success = YES;
    
    @autoreleasepool {
        
        GRMustacheContext *context = _context;
        
        // Evaluate expression
        
        _expressionInvocation.expression = expression;
        _expressionInvocation.context = context;
        if (![_expressionInvocation invokeReturningError:error]) {
            
            // Error
            
            if (error != NULL) {
                [*error retain];   // retain error so that it survives the @autoreleasepool block
            }
            
            success = NO;
            
        } else {
            
            id value = _expressionInvocation.value;
            BOOL valueIsProtected = _expressionInvocation.valueIsProtected;
            
            // Hide value if it is protected
            if (valueIsProtected) {
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
                context = [context contextByAddingHiddenObject:value];
            }
            
            
            // Rendered value hooks
            
            NSArray *tagDelegateStack = [context tagDelegateStack];
            for (id<GRMustacheTagDelegate> tagDelegate in [tagDelegateStack reverseObjectEnumerator]) { // willRenderObject: from top to bottom
                if ([tagDelegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                    value = [tagDelegate mustacheTag:tag willRenderObject:value];
                }
            }
            
            
            // Render value
            
            id<GRMustacheRendering> renderingObject = [GRMustacheRendering renderingObjectForObject:value];
            NSString *rendering = nil;
            NSError *renderingError = nil;  // Default nil, so that we can help lazy coders who return nil as a valid rendering.
            BOOL HTMLSafe = NO;             // Default NO, so that we assume unsafe rendering from lazy coders who do not explicitly set it.
            switch (tag.type) {
                case GRMustacheTagTypeVariable:
                    rendering = [renderingObject renderForMustacheTag:tag context:context HTMLSafe:&HTMLSafe error:&renderingError];
                    break;
                    
                case GRMustacheTagTypeSection: {
                    // Section rendering depends on the boolean value of the
                    // rendering object.
                    //
                    // Despite the mustacheBoolValue method being declared
                    // optional by the GRMustacheRendering protocol (for API
                    // compatibility with GRMustache <= 7.1), the method is
                    // always implemented, with YES as a default value.
                    //
                    // See +[GRMustacheRendering initialize]
                    BOOL boolValue = [renderingObject mustacheBoolValue];
                    if (!tag.isInverted != !boolValue) {
                        rendering = [renderingObject renderForMustacheTag:tag context:context HTMLSafe:&HTMLSafe error:&renderingError];
                    } else {
                        rendering = @"";
                    }
                } break;
            }
            
            if (!rendering && !renderingError)
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
                // Render
                
                if ((_contentType == GRMustacheContentTypeHTML) && !HTMLSafe && escapesHTML) {
                    rendering = GRMustacheTranslateHTMLCharacters(rendering);
                }
                GRMustacheBufferAppendString(&_buffer, rendering);
                
                
                // Post-rendering hooks
                
                for (id<GRMustacheTagDelegate> tagDelegate in tagDelegateStack) { // didRenderObject: from bottom to top
                    if ([tagDelegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                        [tagDelegate mustacheTag:tag didRenderObject:value as:rendering];
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
                        [tagDelegate mustacheTag:tag didFailRenderingObject:value withError:renderingError];
                    }
                }
            }
        }
    }
    
    if (!success && error) [*error autorelease];    // the error has been retained inside the @autoreleasepool block
    return success;
}

- (BOOL)visitTemplateASTNodes:(NSArray *)templateASTNodes error:(NSError **)error
{
    for (id<GRMustacheTemplateASTNode> ASTNode in templateASTNodes) {
        ASTNode = [_context resolveTemplateASTNode:ASTNode];
        if (![ASTNode acceptTemplateASTVisitor:self error:error]) {
            return NO;
        }
    }
    
    return YES;
}

@end
