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

#import "GRMustacheOverridableSection_private.h"

@interface GRMustacheOverridableSection()
@property (nonatomic, readonly) NSString *identifier;
/**
 * @see +[GRMustacheOverridableSection overridableSectionWithComponents:]
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier components:(NSArray *)components;

/**
 * TODO
 *
 * Returns a tag that represents the receiver overrided by
 * _overridingTag_.
 *
 * This method is used in the context of overridable partials, by the
 * GRMustacheTag implementation of
 * [GRMustacheTemplateComponent resolveTemplateComponent:].
 *
 * Default implementation raises an exception. GRMustacheSectionTag and
 * GRMustacheAccumulatorTag override it.
 *
 * @param overridingSection  The overriding section
 * @return A section that represents the receiver overrided by _overridingSection_.
 */
- (GRMustacheOverridableSection *)overridableSectionWithOverridingSection:(GRMustacheOverridableSection *)overridingSection;

@end

@interface GRMustacheAccumulatorOverridableSection : GRMustacheOverridableSection {
@private
    NSArray *_sections;
}

- (instancetype)initWithOverridableSection:(GRMustacheOverridableSection *)section;

@end


@implementation GRMustacheOverridableSection
@synthesize identifier=_identifier;

+ (instancetype)overridableSectionWithIdentifier:(NSString *)identifier components:(NSArray *)components
{
    return [[[self alloc] initWithIdentifier:identifier components:components] autorelease];
}

- (void)dealloc
{
    [_identifier release];
    [_components release];
    [super dealloc];
}

- (GRMustacheOverridableSection *)overridableSectionWithOverridingSection:(GRMustacheOverridableSection *)overridingSection
{
    // In the following situation, the overriden section (self) is replaced by
    // an accumulator section initialized with the overriding section:
    //
    // layout.mustache:
    //
    //   {{$head}}overriden{{/head}}            <- overriden section (self)
    //
    // base.mustache:
    //
    //   {{<layout}}
    //     {{>partial1}}
    //     {{>partial2}}
    //   {{/}}
    //
    // partial1.mustache:
    //
    //   {{$head}}head for partial 1{{/head}}   <- overriding section
    //
    // partial2.mustache:
    //
    //   {{$head}}head for partial 2{{/head}}
    //
    // Rendering:
    //
    //   head for partial 1
    //   head for partial 2
    //
    // Later, the accumulatorTag will itself be overriden by the section in
    // partial2. See [GRMustacheAccumulatorOverridableSection overridableSectionWithOverridingSection:]
    
    return [[[GRMustacheAccumulatorOverridableSection alloc] initWithOverridableSection:overridingSection] autorelease];
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    if (!context) {
        // With a nil context, the method would return NO without setting the
        // error argument.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustachePartialOverride: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:requiredContentType inBuffer:buffer withContext:context error:error]) {
            return NO;
        }
    }
    
    return YES;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Overridable section can only override overridable section
    if (![component isKindOfClass:[GRMustacheOverridableSection class]]) {
        return component;
    }
    GRMustacheOverridableSection *otherSection = (GRMustacheOverridableSection *)component;
    
    // Identifiers must match
    if (![otherSection.identifier isEqual:_identifier]) {
        return otherSection;
    }
    
    // OK, override tag with self
    return [otherSection overridableSectionWithOverridingSection:self];
}


#pragma mark - Private

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = [identifier retain];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier components:(NSArray *)components
{
    self = [self initWithIdentifier:identifier];
    if (self) {
        _components = [components retain];
    }
    return self;
}

@end


@implementation GRMustacheAccumulatorOverridableSection

- (instancetype)initWithOverridableSection:(GRMustacheOverridableSection *)section
{
    self = [self initWithIdentifier:section.identifier];
    if (self) {
        _sections = [[NSArray alloc] initWithObjects:section, nil];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier sections:(NSArray *)sections
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _sections = [sections retain];
    }
    return self;
}

- (void)dealloc
{
    [_sections release];
    [super dealloc];
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    NSAssert(NO, @"YES!");
    return nil;
}

- (GRMustacheOverridableSection *)overridableSectionWithOverridingSection:(GRMustacheOverridableSection *)overridingSection
{
    // In the following situation, the overriden tag (self) is extended by
    // the overriding tag:
    //
    // layout.mustache:
    //
    //   {{$head}}overriden{{/head}}
    //
    // base.mustache:
    //
    //   {{<layout}}
    //     {{>partial1}}
    //     {{>partial2}}
    //   {{/}}
    //
    // partial1.mustache:
    //
    //   {{$head}}head for partial 1{{/head}}
    //
    // partial2.mustache:
    //
    //   {{$head}}head for partial 2{{/head}}   <- overriding tag
    //
    // Rendering:
    //
    //   head for partial 1
    //   head for partial 2
    //
    // See also [GRMustacheOverridableSection overridableSectionWithOverridingSection:]
    
    return [[[GRMustacheAccumulatorOverridableSection alloc] initWithIdentifier:self.identifier sections:[_sections arrayByAddingObject:overridingSection]] autorelease];
}

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    BOOL result = YES;
    for (GRMustacheOverridableSection *section in _sections) {
        @autoreleasepool {
            result = [section renderContentType:requiredContentType inBuffer:buffer withContext:context error:error];
            if (!result) {
                // make sure error is not released by autoreleasepool
                if (error != NULL) [*error retain];
                break;
            }
        }
    }
    if (!result && error != NULL) [*error autorelease];
    return result;
}

@end