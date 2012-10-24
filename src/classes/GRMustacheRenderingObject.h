//
//  GRMustacheRenderingObject.h
//  GRMustache
//
//  Created by Gwendal Roué on 24/10/12.
//
//

#import <Foundation/Foundation.h>

@protocol GRMustacheRenderingObject;
@class GRMustacheRuntime;
@class GRMustacheTemplateRepository;

@interface NSObject(GRMustacheRenderingObject)
- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository forRenderingObject:(id<GRMustacheRenderingObject>)renderingObject HTMLEscaped:(BOOL *)HTMLEscaped;
@end

@protocol GRMustacheRenderingObject <NSObject>
- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository forRenderingObject:(id<GRMustacheRenderingObject>)renderingObject HTMLEscaped:(BOOL *)HTMLEscaped;
@property (nonatomic, readonly, getter = isInverted) BOOL inverted;
@property (nonatomic, readonly, getter = isOverridable) BOOL overridable;
@end

@interface GRMustacheRenderingObject : NSObject<GRMustacheRenderingObject>
+ (id)renderingObjectWithBlock:(NSString *(^)(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped))block;
@end
