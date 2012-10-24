//
//  GRMustacheRenderer.m
//  GRMustache
//
//  Created by Gwendal Roué on 24/10/12.
//
//

#import <objc/runtime.h>
#import "GRMustacheRenderer_private.h"
#import "GRMustacheRenderingObject.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplateDelegate.h"

static NSMutableDictionary *builderForProtocol = nil;
static NSMutableDictionary *builderForClass = nil;
static id<GRMustacheRenderingObject>(^builderForNil)(id value);
static id<GRMustacheRenderingObject>(^builderForObject)(id value);

@implementation GRMustacheRenderer

+ (id<GRMustacheRenderingObject>)renderingObjectForValue:(id)value
{
    if (value == nil) {
        return builderForNil(nil);
    }
    
    if ([value respondsToSelector:@selector(renderInRuntime:templateRepository:forRenderingObject:HTMLEscaped:)]) {
        return value;
    }
    
    id<GRMustacheRenderingObject>(^builder)(id value) = nil;
    
    // look by class
    
    {
        Class lastMatchedClass = nil;
        for (NSString *candidateClassName in builderForClass) {
            Class candidateClass = NSClassFromString(candidateClassName);
            
            if (!candidateClass) {
                continue;
            }
            
            if (![value isKindOfClass:candidateClass]) {
                continue;
            }
            
            if (lastMatchedClass == nil) {
                builder = [builderForClass objectForKey:candidateClassName];
                lastMatchedClass = candidateClass;
                continue;
            }
            
            // if lastMatchedClass is a super class of candidateClass, use candidateClass
            for (Class superClass = class_getSuperclass(candidateClass); superClass; superClass = class_getSuperclass(superClass)) {
                if (superClass == lastMatchedClass) {
                    builder = [builderForClass objectForKey:candidateClassName];
                    lastMatchedClass = candidateClass;
                    break;
                }
            }
        }
    }
    
    if (builder) {
        return builder(value);
    }

    // look by protocol
    
    {
        for (NSString *candidateProtocolName in builderForProtocol) {
            Protocol *candidateProtocol = NSProtocolFromString(candidateProtocolName);
            
            if (!candidateProtocol) {
                continue;
            }
            
            if (![value conformsToProtocol:candidateProtocol]) {
                continue;
            }
            
            builder = [builderForProtocol objectForKey:candidateProtocolName];
            break;  // TODO: look for a more precise protocol
        }
    }
    
    if (builder) {
        return builder(value);
    }
    
    // default rendering object
    
    NSLog(@"did not find a builder for class %@", [value class]);
    [self registerClass:[value class] withRenderingObjectBuilder:builderForObject];
    return builderForObject(value);
}

+ (void)registerProtocol:(Protocol *)aProtocol withRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder
{
    if (builderForProtocol == nil) {
        builderForProtocol = [[NSMutableDictionary alloc] init];
    }
    
    [builderForProtocol setObject:[builder copy] forKey:NSStringFromProtocol(aProtocol)];
}

+ (void)registerClass:(Class)aClass withRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder
{
    if (builderForClass == nil) {
        builderForClass = [[NSMutableDictionary alloc] init];
    }

    [builderForClass setObject:[builder copy] forKey:NSStringFromClass(aClass)];
}

+ (void)registerNilWithRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder
{
    builderForNil = [builder retain];
}

+ (void)registerObjectWithRenderingObjectBuilder:(id<GRMustacheRenderingObject>(^)(id value))builder
{
    builderForObject = builder;
}

@end
