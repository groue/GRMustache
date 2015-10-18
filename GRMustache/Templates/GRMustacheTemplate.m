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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheRenderingEngine_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheInheritedPartialNode_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheSectionTag_private.h"

@implementation GRMustacheTemplate
@synthesize templateRepository=_templateRepository;
@synthesize templateAST=_templateAST;
@synthesize baseContext=_baseContext;

+ (instancetype)templateFromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepository];
    return [templateRepository templateFromString:templateString error:error];
}

+ (instancetype)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:error];
}

+ (instancetype)templateFromContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (instancetype)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:error];
    return [template renderObject:object error:error];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:name bundle:bundle error:error];
    return [template renderObject:object error:error];
}

- (void)dealloc
{
    [_templateAST release];
    [_baseContext release];
    [_templateRepository release];
    [super dealloc];
}

- (void)extendBaseContextWithObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingObject:object];
}

- (void)extendBaseContextWithProtectedObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingProtectedObject:object];
}

- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    self.baseContext = [self.baseContext contextByAddingTagDelegate:tagDelegate];
}

- (NSString *)renderObject:(id)object error:(NSError **)error
{
    GRMustacheContext *context = [self.baseContext contextByAddingObject:object];
    return [self renderContentWithContext:context HTMLSafe:NULL error:error];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects error:(NSError **)error
{
    GRMustacheContext *context = self.baseContext;
    for (id object in objects) {
        context = [context contextByAddingObject:object];
    }
    return [self renderContentWithContext:context HTMLSafe:NULL error:error];
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    GRMustacheRenderingEngine *renderingEngine = [GRMustacheRenderingEngine renderingEngineWithTemplateAST:_templateAST context:context];
    return [renderingEngine renderHTMLSafe:HTMLSafe error:error];
}

- (void)setBaseContext:(GRMustacheContext *)baseContext
{
    if (!baseContext) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid baseContext:nil"];
        return;
    }
    
    if (_baseContext != baseContext) {
        [_baseContext release];
        _baseContext = [baseContext retain];
    }
}


#pragma mark - <GRMustacheRendering>

// Allows template to render as "dynamic partials"
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ template }} behaves just like {{> partial }}
            //
            // Let's simply render the template:
            return [self renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        case GRMustacheTagTypeSection: {
            // {{# template }}...{{/ template }} behaves just like {{< partial }}...{{/ partial }}
            //
            // Let's render the template, overriding blocks with the content
            // of the section.
            //
            // Overriding requires an GRMustacheInheritedPartialNode:
            
            GRMustachePartialNode *partialNode = [GRMustachePartialNode partialNodeWithTemplateAST:self.templateAST name:nil];
            GRMustacheInheritedPartialNode *partialOverrideNode = [GRMustacheInheritedPartialNode inheritedPartialNodeWithParentPartialNode:partialNode overridingTemplateAST:((GRMustacheSectionTag *)tag).innerTemplateAST];
            
            // Only GRMustacheRenderingEngine knows how to render GRMustacheInheritedPartialNode.
            // So wrap the node into a TemplateAST, and render.
            GRMustacheTemplateAST *templateAST = [GRMustacheTemplateAST templateASTWithASTNodes:@[partialOverrideNode] contentType:self.templateAST.contentType];
            GRMustacheRenderingEngine *renderingEngine = [GRMustacheRenderingEngine renderingEngineWithTemplateAST:templateAST context:context];
            return [renderingEngine renderHTMLSafe:HTMLSafe error:error];
        }
    }
}

@end
