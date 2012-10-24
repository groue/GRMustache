//
//  GRMustacheRenderer.h
//  GRMustache
//
//  Created by Gwendal Roué on 24/10/12.
//
//

#import <Foundation/Foundation.h>
#import "GRMustacheRenderingObject.h"

@interface GRMustacheRenderer : NSObject
+ (id<GRMustacheRenderingObject>)renderingObjectForValue:(id)value;
+ (void)registerNilWithRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder;
+ (void)registerObjectWithRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder;
+ (void)registerProtocol:(Protocol *)aProtocol withRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder;
+ (void)registerClass:(Class)aClass withRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder;
@end

