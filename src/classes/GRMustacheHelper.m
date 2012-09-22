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

#import "GRMustacheHelper.h"
#import "GRMustacheSection.h"
#import "GRMustacheVariable.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockSectionHelper

/**
 * Private subclass of GRMustacheSectionHelper that render sections by calling
 * a block.
 */
@interface GRMustacheBlockSectionHelper: GRMustacheSectionHelper {
@private
    NSString *(^_block)(GRMustacheSection* section);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section))block;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariableHelper

/**
 * Private subclass of GRMustacheVariableHelper that render variables by calling
 * a block.
 */
@interface GRMustacheBlockVariableHelper: GRMustacheVariableHelper {
@private
    NSString *(^_block)(GRMustacheVariable* variable);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheVariable* variable))block;
@end


// =============================================================================
#pragma mark - GRMustacheSectionHelper

@implementation GRMustacheSectionHelper

+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block
{
    return [[[GRMustacheBlockSectionHelper alloc] initWithBlock:block] autorelease];
}

#pragma mark <GRMustacheSectionHelper>

- (NSString *)renderSection:(GRMustacheSection *)section
{
    return [section render];
}

@end


// =============================================================================
#pragma mark - GRMustacheVariableHelper

@implementation GRMustacheVariableHelper

+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block
{
    return [[[GRMustacheBlockVariableHelper alloc] initWithBlock:block] autorelease];
}

#pragma mark <GRMustacheVariableHelper>

- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
    return [self description];
}

@end


// =============================================================================
#pragma mark - GRMustacheDynamicPartial

@interface GRMustacheDynamicPartial()
- (id)initWithName:(NSString *)name;
@end

@implementation GRMustacheDynamicPartial

+ (id)dynamicPartialWithName:(NSString *)name
{
    return [[[GRMustacheDynamicPartial alloc] initWithName:name] autorelease];
}

- (void)dealloc
{
    [_name release];
    [super dealloc];
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name retain];
    }
    return self;
}

#pragma mark <GRMustacheVariableHelper>

- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
    NSString *templateString = [NSString stringWithFormat:@"{{>%@}}", _name];
    // TODO: what should we do about the error? (empty name, missing template...)
    return [variable renderTemplateString:templateString error:NULL];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockSectionHelper

@implementation GRMustacheBlockSectionHelper

- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section))block
{
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}


- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheSectionHelper>

- (NSString *)renderSection:(GRMustacheSection *)section
{
    NSString *rendering = nil;
    
    if (_block) {
        rendering = _block(section);
    }
    
    return rendering;
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlockVariableHelper

@implementation GRMustacheBlockVariableHelper

- (id)initWithBlock:(NSString *(^)(GRMustacheVariable* variable))block
{
    self = [self init];
    if (self) {
        _block = [block copy];
    }
    return self;
}


- (void)dealloc
{
    [_block release];
    [super dealloc];
}

#pragma mark <GRMustacheVariableHelper>

- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
    NSString *rendering = nil;
    
    if (_block) {
        rendering = _block(variable);
    }
    
    return rendering;
}

@end


