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
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustache_private.h"
#import "GRMustacheRendering.h"

@interface GRMustacheTag()
- (NSString *)escapeHTML:(NSString *)string;
@end

@implementation GRMustacheTag
@synthesize expression=_expression;
@synthesize templateRepository=_templateRepository;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression
{
    self = [super init];
    if (self) {
        _templateRepository = templateRepository;   // do not retain, since templateRepository retains the template that retains self.
        _expression = [expression retain];
    }
    return self;
}

- (NSString *)description
{
    GRMustacheToken *token = _expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (GRMustacheTagType)type
{
    NSAssert(NO, @"Subclasses must override");
    return 0;
}

- (BOOL)escapesHTML
{
    // default
    return YES;
}

- (NSString *)innerTemplateString
{
    // default
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    // default
    if (HTMLSafe) {
        *HTMLSafe = YES;
    }
    return @"";
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderWithContext:(GRMustacheContext *)context inBuffer:(NSMutableString *)buffer error:(NSError **)error
{
    BOOL success = YES;
    
    @autoreleasepool {
        
        // Evaluate expression
        
        id object;
        BOOL isProtected;
        if (![_expression evaluateInContext:context value:&object isProtected:&isProtected error:error]) {
            return NO;
        }
        
        
        // Hide object if it is protected
        
        if (isProtected) {
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
            // is protected when it is not, we prevent this whole pattern, and
            // forbid `{{#safe}}{{name}}{{/safe}}`.
            context = [context contextByAddingHiddenObject:object];
        }
        
        
        // Tag delegates pre-rendering callbacks
        
        for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
            if ([delegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                object = [delegate mustacheTag:self willRenderObject:object];
            }
        }
        
        
        // 4. Render
    
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:object];
        BOOL HTMLSafe = NO;
        NSError *renderingError = nil;
        NSString *rendering = [renderingObject renderForMustacheTag:self context:context HTMLSafe:&HTMLSafe error:&renderingError];
        
        // If rendering is nil, but rendering error is not set,
        // assume lazy coder, and the intention to render nothing:
        // fail if and only if rendering is nil and renderingError is
        // explicitely set.
        
        if (!rendering && renderingError) {
            
            // Error
            
            if (error) {
                *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
            }
            success = NO;
            
            // Tag delegates post-rendering callbacks

            for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
                if ([delegate respondsToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) {
                    [delegate mustacheTag:self didFailRenderingObject:object withError:renderingError];
                }
            }
            
        } else {
            
            // Success
            
            if (rendering.length > 0) {
                if (self.escapesHTML && !HTMLSafe) {
                    rendering = [self escapeHTML:rendering];
                }
                [buffer appendString:rendering];
            }
            
            // Tag delegates post-rendering callbacks
            
            if (rendering == nil) { rendering = @""; }  // Don't expose nil as a success
            for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
                if ([delegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                    [delegate mustacheTag:self didRenderObject:object as:rendering];
                }
            }
        }
    }
    
    if (!success && error) [*error autorelease];    // the error has been retained inside the @autoreleasepool block
    return success;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Only overridable tags can override components
    if (self.type != GRMustacheTagTypeOverridableSection) {
        return component;
    }
    
    // Overridable tags can only override other tags
    if (![component isKindOfClass:[GRMustacheTag class]]) {
        return component;
    }
    GRMustacheTag *otherTag = (GRMustacheTag *)component;
    
    // Overridable tags can only override other overridable tags
    if (otherTag.type != GRMustacheTagTypeOverridableSection) {
        return otherTag;
    }
    
    // Overridable tags can only override other sections with the same expression
    if (![otherTag.expression isEqual:_expression]) {
        return otherTag;
    }
    
    // OK, override otherTag with self
    return [otherTag tagWithOverridingTag:self];
}

- (GRMustacheTag *)tagWithOverridingTag:(GRMustacheTag *)overridingTag
{
    // default: overridingTag replaces self
    return overridingTag;
}


#pragma mark - Private

- (NSString *)escapeHTML:(NSString *)string
{
    NSMutableString *result = [NSMutableString stringWithString:string];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

@end
