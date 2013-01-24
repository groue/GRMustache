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

@implementation GRMustacheTag
@synthesize expression=_expression;
@synthesize templateRepository=_templateRepository;
@synthesize rendersHTML=_rendersHTML;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression rendersHTML:(BOOL)rendersHTML
{
    self = [super init];
    if (self) {
        _templateRepository = templateRepository;   // do not retain, since templateRepository retains the template that retains self.
        _expression = [expression retain];
        _rendersHTML = rendersHTML;
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
        *HTMLSafe = self.rendersHTML;
    }
    return @"";
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderHTML:(BOOL)HTMLRequired inBuffer:(NSMutableString *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    NSAssert(HTMLRequired == self.rendersHTML, @"WTF");
    
    BOOL success = YES;
    
    @autoreleasepool {
        
        // Evaluate expression
        
        BOOL protected;
        __block id object = [_expression valueWithContext:context protected:&protected];
        
        
        // Hide object if it is protected
        
        if (protected) {
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
        
        [context enumerateTagDelegatesUsingBlock:^(id<GRMustacheTagDelegate> tagDelegate) {
            if ([tagDelegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                object = [tagDelegate mustacheTag:self willRenderObject:object];
            }
        }];
        
        
        // 4. Render
    
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:object];
        BOOL objectHTMLSafe = NO;
        NSError *renderingError = nil;
        NSString *rendering = [renderingObject renderForMustacheTag:self context:context HTMLSafe:&objectHTMLSafe error:&renderingError];
        
        // If rendering is nil, but rendering error is not set,
        // assume lazy coder, and the intention to render nothing:
        // fail if and only if rendering is nil and renderingError is
        // explicitely set.
        
        if (!rendering && renderingError) {
            
            // Error
            
            if (error != NULL) {
                *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
            } else {
                NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
            }
            success = NO;
            
            // Tag delegates post-rendering callbacks

            [context enumerateTagDelegatesUsingBlock:^(id<GRMustacheTagDelegate> tagDelegate) {
                if ([tagDelegate respondsToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) {
                    [tagDelegate mustacheTag:self didFailRenderingObject:object withError:renderingError];
                }
            }];
            
        } else {
            
            // Success
            
            if (rendering.length > 0) {
                if (HTMLRequired && !objectHTMLSafe && self.escapesHTML) {
                    rendering = [GRMustache escapeHTML:rendering];
                }
                [buffer appendString:rendering];
            }
            
            // Tag delegates post-rendering callbacks
            
            if (rendering == nil) { rendering = @""; }  // Don't expose nil as a success
            [context enumerateTagDelegatesUsingBlock:^(id<GRMustacheTagDelegate> tagDelegate) {
                if ([tagDelegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                    [tagDelegate mustacheTag:self didRenderObject:object as:rendering];
                }
            }];
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
    
    // Tag can only override other tag
    if (![component isKindOfClass:[GRMustacheTag class]]) {
        return component;
    }
    GRMustacheTag *otherTag = (GRMustacheTag *)component;
    
    // Tag can only override other overridable tag
    if (otherTag.type != GRMustacheTagTypeOverridableSection) {
        return otherTag;
    }
    
    // Tag can only override other tag with the same expression
    if (![otherTag.expression isEqual:_expression]) {
        return otherTag;
    }
    
    // OK, override tag with self
    return [otherTag tagWithOverridingTag:self];
}

- (GRMustacheTag *)tagWithOverridingTag:(GRMustacheTag *)overridingTag
{
    // default: overridingTag replaces self
    return overridingTag;
}

@end
