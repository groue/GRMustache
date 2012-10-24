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

#import "GRMustache_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheVersion.h"
#import "GRMustacheRenderer_private.h"
#import "GRMustacheRenderingObject.h"

@implementation GRMustache

+ (void)load
{
    [GRMustacheRenderer registerNilWithRenderingObjectBuilder:^id<GRMustacheRenderingObject>(id value) {
        return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
            
            if (renderingObject) {
                if (renderingObject.isInverted || renderingObject.isOverridable) {
                    return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                } else {
                    return nil;
                }
            } else {
                return nil;
            }
        }];
    }];
    
    [GRMustacheRenderer registerObjectWithRenderingObjectBuilder:^id<GRMustacheRenderingObject>(id value) {
        return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
            
            if (renderingObject) {
                if (renderingObject.isInverted) {
                    return nil;
                } else {
                    // value enters the runtime as a context object
                    runtime = [runtime runtimeByAddingContextObject:value];
                    
                    // value may enter the runtime as a delegate object
                    if ([value conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                        runtime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)value];
                    }
                    
                    return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                }
            } else {
                *HTMLEscaped = NO;
                return [value description];
            }
        }];
    }];
    
    [GRMustacheRenderer registerClass:[NSNull class] withRenderingObjectBuilder:^id<GRMustacheRenderingObject>(NSNull *null) {
        return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
            
            if (renderingObject) {
                if (renderingObject.isInverted) {
                    return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                } else {
                    return nil;
                }
            } else {
                return nil;
            }
        }];
    }];
    
    [GRMustacheRenderer registerClass:[NSNumber class] withRenderingObjectBuilder:^id<GRMustacheRenderingObject>(NSNumber *number) {
        return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
            
            if (renderingObject) {
                if ([number boolValue] ^ renderingObject.isInverted) {
                    if (!renderingObject.isInverted) {
                        // value enters the runtime as a context object
                        runtime = [runtime runtimeByAddingContextObject:number];
                        
                        // value may enter the runtime as a delegate object
                        if ([number conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                            runtime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)number];
                        }
                    }
                    
                    return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                } else {
                    return nil;
                }
            } else {
                *HTMLEscaped = NO;
                return [number description];
            }
        }];
    }];
    
    [GRMustacheRenderer registerClass:[NSString class] withRenderingObjectBuilder:^id<GRMustacheRenderingObject>(NSString *string) {
        return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
            
            if (renderingObject) {
                if ((string.length > 0) ^ renderingObject.isInverted) {
                    if (!renderingObject.isInverted) {
                        // value enters the runtime as a context object
                        runtime = [runtime runtimeByAddingContextObject:string];
                        
                        // value may enter the runtime as a delegate object
                        if ([string conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                            runtime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)string];
                        }
                    }
                    
                    return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                } else {
                    return nil;
                }
            } else {
                *HTMLEscaped = NO;
                return string;
            }
        }];
    }];
    
    [GRMustacheRenderer registerProtocol:@protocol(NSFastEnumeration) withRenderingObjectBuilder:^id<GRMustacheRenderingObject>(id value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
                
                if (renderingObject) {
                    if (renderingObject.isInverted) {
                        return nil;
                    } else {
                        // value enters the runtime as a context object
                        runtime = [runtime runtimeByAddingContextObject:value];
                        
                        // value may enter the runtime as a delegate object
                        if ([value conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                            runtime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)value];
                        }
                        
                        return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                    }
                } else {
                    *HTMLEscaped = NO;
                    return [value description];
                }
            }];
        } else {
            id<NSFastEnumeration>list = value;
            return [GRMustacheRenderingObject renderingObjectWithBlock:^NSString *(GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, id<GRMustacheRenderingObject> renderingObject, BOOL *HTMLEscaped) {
                
                if (renderingObject) {
                    if (renderingObject.isInverted) {
                        BOOL empty = YES;
                        for (id item in list) {
                            empty = NO;
                            break;
                        }
                        if (empty) {
                            return [renderingObject renderInRuntime:runtime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                        } else {
                            return nil;
                        }
                    } else {
                        NSMutableString *buffer = [NSMutableString string];
                        for (id item in list) {
                            // item enters the runtime as a context object
                            GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
                            
                            // item may enter the runtime as a delegate object
                            if ([item conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                                itemRuntime = [itemRuntime runtimeByAddingTemplateDelegate:item];
                            }
                            
                            NSString *rendering = [renderingObject renderInRuntime:itemRuntime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                            if (rendering) {
                                [buffer appendString:rendering];
                            }
                        }
                        return buffer;
                    }
                } else {
                    NSMutableString *buffer = [NSMutableString string];
                    for (id item in list) {
                        // item enters the runtime as a context object
                        GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
                        
                        // item may enter the runtime as a delegate object
                        if ([item conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
                            itemRuntime = [itemRuntime runtimeByAddingTemplateDelegate:item];
                        }
                        
                        id<GRMustacheRenderingObject> itemRenderingObject = [GRMustacheRenderer renderingObjectForValue:item];
                        NSString *rendering = [itemRenderingObject renderInRuntime:itemRuntime templateRepository:templateRepository forRenderingObject:nil HTMLEscaped:HTMLEscaped];
                        if (rendering) {
                            [buffer appendString:rendering];
                        }
                    }
                    return buffer;
                }
            }];
        }
    }];
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    [GRMustacheRuntime preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)version
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

@end
