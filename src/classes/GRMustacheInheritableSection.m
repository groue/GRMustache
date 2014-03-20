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

#import "GRMustacheInheritableSection_private.h"
#import "GRMustacheASTVisitor_private.h"

@interface GRMustacheInheritableSection()
@property (nonatomic, readonly) NSString *identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier templateComponents:(NSArray *)templateComponents;
@end

@implementation GRMustacheInheritableSection
@synthesize identifier=_identifier;
@synthesize templateComponents=_templateComponents;

+ (instancetype)inheritableSectionWithIdentifier:(NSString *)identifier templateComponents:(NSArray *)templateComponents
{
    return [[[self alloc] initWithIdentifier:identifier templateComponents:templateComponents] autorelease];
}

- (void)dealloc
{
    [_identifier release];
    [_templateComponents release];
    [super dealloc];
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)accept:(id<GRMustacheASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitInheritableSection:self error:error];
}

//- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
//{
//    if (!context) {
//        // With a nil context, the method would return NO without setting the
//        // error argument.
//        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
//        return NO;
//    }
//    
//    for (id<GRMustacheTemplateComponent> component in _templateComponents) {
//        // component may be overriden by a GRMustacheInheritablePartial: resolve it.
//        component = [context resolveTemplateComponent:component];
//        
//        // render
//        if (![component renderContentType:requiredContentType inBuffer:buffer withContext:context error:error]) {
//            return NO;
//        }
//    }
//    
//    return YES;
//}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Inheritable section can only override inheritable section
    if (![component isKindOfClass:[GRMustacheInheritableSection class]]) {
        return component;
    }
    GRMustacheInheritableSection *otherSection = (GRMustacheInheritableSection *)component;
    
    // Identifiers must match
    if (![otherSection.identifier isEqual:_identifier]) {
        return otherSection;
    }
    
    // OK, override with self
    return self;
}


#pragma mark - Private

- (instancetype)initWithIdentifier:(NSString *)identifier templateComponents:(NSArray *)templateComponents
{
    self = [self init];
    if (self) {
        _identifier = [identifier retain];
        _templateComponents = [templateComponents retain];
    }
    return self;
}

@end
