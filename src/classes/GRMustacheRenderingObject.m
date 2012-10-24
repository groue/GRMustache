//
//  GRMustacheRenderingObject.h
//  GRMustache
//
//  Created by Gwendal Roué on 24/10/12.
//
//

#import "GRMustacheRenderingObject.h"

@interface GRMustacheRenderingObjectWithBlock:GRMustacheRenderingObject {
    NSString *(^_block)(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped))block;
@end

@implementation GRMustacheRenderingObject

+ (id)renderingObjectWithBlock:(NSString *(^)(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped))block
{
    return [[[GRMustacheRenderingObjectWithBlock alloc] initWithBlock:block] autorelease];
}

- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository forRenderingObject:(id<GRMustacheRenderingObject>)renderingObject HTMLEscaped:(BOOL *)HTMLEscaped
{
    return nil;
}

- (BOOL)isInverted
{
    return NO;
}

- (BOOL)isOverridable
{
    return NO;
}

@end

@implementation GRMustacheRenderingObjectWithBlock

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

- (id)initWithBlock:(NSString *(^)(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository forRenderingObject:(id<GRMustacheRenderingObject>)renderingObject HTMLEscaped:(BOOL *)HTMLEscaped
{
    if (!_block) {
        return nil;
    }
    return _block(runtime, templateRepository, renderingObject, HTMLEscaped);
}

@end