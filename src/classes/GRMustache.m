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
#import "GRMustacheRenderingObject_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheError.h"

static CFMutableDictionaryRef renderingObjectImplementationForProtocol = nil;
static IMP defaultRenderingObjectImplementation;

static NSString *GRMustacheRenderingObjectNil(id self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
static NSString *GRMustacheRenderingObjectNSNull(NSNull *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
static NSString *GRMustacheRenderingObjectNSNumber(NSNumber *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
static NSString *GRMustacheRenderingObjectNSString(NSString *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
static NSString *GRMustacheRenderingObjectNSObject(NSObject *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);
static NSString *GRMustacheRenderingObjectNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped);

@interface GRMustacheNil : NSObject<GRMustacheRenderingObject>
+ (void)setRenderingObjectImplementation:(IMP)imp;
+ (id)instance;
@end

@interface GRMustache()
+ (void)registerDefaultRenderingObjectImplementation:(IMP)imp;
+ (void)registerNilRenderingObjectImplementation:(IMP)imp;
+ (void)registerClass:(Class)aClass renderingObjectImplementation:(IMP)imp;
+ (void)registerProtocol:(Protocol *)aProtocol renderingObjectImplementation:(IMP)imp;
@end

@implementation GRMustache

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

+ (id<GRMustacheRenderingObject>)renderingObjectForValue:(id)value
{
    if (value == nil) {
        return [GRMustacheNil instance];
    }
    
    SEL renderSelector = @selector(renderForSection:inRuntime:templateRepository:HTMLEscaped:);
    
    if ([value respondsToSelector:renderSelector]) {
        return value;
    }

    // look by protocol
    
    IMP implementation = nil;
    if (renderingObjectImplementationForProtocol) {
        
        CFIndex count = CFDictionaryGetCount(renderingObjectImplementationForProtocol);
        const void **protocols = malloc(count * sizeof(void *));
        const void **imps = malloc(count * sizeof(void *));
        
        CFDictionaryGetKeysAndValues(renderingObjectImplementationForProtocol, protocols, imps);
        for (CFIndex i=0; i<count; ++i) {
            Protocol *protocol = protocols[i];
            if ([value conformsToProtocol:protocol]) {
                implementation = (IMP)imps[i];
                break;  // TODO: look for a more precise protocol
            }
        }
        
        free(protocols);
        free(imps);
    }
    
    if (!implementation) {
        implementation = defaultRenderingObjectImplementation;
    }
    
    Class aClass = [value class];
    if (aClass != [NSObject class]) {
        [self registerClass:aClass renderingObjectImplementation:implementation];
    }
    
    return [GRMustacheRenderingObject renderingObjectWithObject:value implementation:implementation];
}

+ (NSString *)htmlEscape:(NSString *)string
{
    NSMutableString *result = [NSMutableString stringWithString:string];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}


#pragma mark Private

+ (void)load
{
    [self registerDefaultRenderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSObject];
    [self registerNilRenderingObjectImplementation:(IMP)GRMustacheRenderingObjectNil];
    [self registerClass:[NSNull class] renderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSNull];
    [self registerClass:[NSNumber class] renderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSNumber];
    [self registerClass:[NSString class] renderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSString];
    [self registerClass:[NSDictionary class] renderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSObject];
    [self registerProtocol:@protocol(NSFastEnumeration) renderingObjectImplementation:(IMP)GRMustacheRenderingObjectNSFastEnumeration];
}

+ (void)registerDefaultRenderingObjectImplementation:(IMP)imp
{
    defaultRenderingObjectImplementation = imp;
}

+ (void)registerNilRenderingObjectImplementation:(IMP)imp
{
    [GRMustacheNil setRenderingObjectImplementation:imp];
}

+ (void)registerClass:(Class)aClass renderingObjectImplementation:(IMP)imp
{
    SEL renderSelector = @selector(renderForSection:inRuntime:templateRepository:HTMLEscaped:);
    if (!class_addMethod(aClass, renderSelector, imp, "@@:@@@^c")) {
        Method method = class_getInstanceMethod(aClass, renderSelector);
        method_setImplementation(method, imp);
    }
}

+ (void)registerProtocol:(Protocol *)aProtocol renderingObjectImplementation:(IMP)imp
{
    if (renderingObjectImplementationForProtocol == nil) {
        renderingObjectImplementationForProtocol = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    
    CFDictionaryAddValue(renderingObjectImplementationForProtocol, aProtocol, imp);
}

@end


// =============================================================================
#pragma mark - GRMustacheNil

static IMP nilRenderingObjectImplementation;

@implementation GRMustacheNil

+ (void)setRenderingObjectImplementation:(IMP)imp
{
    nilRenderingObjectImplementation = imp;
}

+ (id)instance
{
    static GRMustacheNil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    return nilRenderingObjectImplementation(nil, @selector(renderForSection:inRuntime:templateRepository:HTMLEscaped:), section, runtime, templateRepository, HTMLEscaped);
}

@end


// =============================================================================
#pragma mark - nil(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNil(id self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# number }}...{{/}}
        
        // The section renders if and only if it is inverted or overridable
        if (section.isInverted || section.isOverridable)
        {
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
        else
        {
            return nil;
        }
        
    }
    else
    {
        // Variable tag {{ number }}
        
        // nil does not render
        return nil;
    }
}


// =============================================================================
#pragma mark - NSNull(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNSNull(NSNull *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# number }}...{{/}}
        
        // The section renders if and only if it is inverted
        if (section.isInverted)
        {
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
        else
        {
            return nil;
        }
        
    }
    else
    {
        // Variable tag {{ number }}
        
        // NSNull does not render
        return nil;
    }
}


// =============================================================================
#pragma mark - NSNumber(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNSNumber(NSNumber *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# number }}...{{/}}
        
        // The section renders if and only if self is true xor section is inverted
        if ([self boolValue] ^ section.isInverted)
        {
            runtime = [runtime runtimeByAddingContextObject:self];
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
        else
        {
            return nil;
        }
        
    }
    else
    {
        // Variable tag {{ number }}
        
        // Return description, unescaped;
        *HTMLEscaped = NO;
        return [self description];
    }
}


// =============================================================================
#pragma mark - NSString(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNSString(NSString *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# string }}...{{/}}
        
        // The section renders if and only if self is non empty xor section is inverted
        if ((self.length > 0) ^ section.isInverted)
        {
            runtime = [runtime runtimeByAddingContextObject:self];
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
        else
        {
            return nil;
        }
        
    }
    else
    {
        // Variable tag {{ string }}
        
        // Return self, unescaped;
        *HTMLEscaped = NO;
        return self;
    }
}


// =============================================================================
#pragma mark - NSObject(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNSObject(NSObject *self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# dictionary }}...{{/}}
        
        // The section renders if and only if it is not inverted
        if (section.isInverted)
        {
            return nil;
        }
        else
        {
            runtime = [runtime runtimeByAddingContextObject:self];
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
        
    }
    else
    {
        // Variable tag {{ dictionary }}
        
        // Return description, unescaped;
        *HTMLEscaped = NO;
        return [self description];
    }
}


// =============================================================================
#pragma mark - NSFastEnumeration(GRMustacheRenderingObject)

static NSString *GRMustacheRenderingObjectNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped)
{
    if (section)
    {
        // Section tag {{# list }}...{{/}}
        
        if (section.isInverted)
        {
            // Inverted section render if and only if self is empty.
            
            BOOL empty = YES;
            for (id item in self) {
                empty = NO;
                break;
            }
            
            if (empty) {
                return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
            } else {
                return nil;
            }
        }
        else
        {
            // Non inverted sections render for each item in the list
            
            NSMutableString *buffer = [NSMutableString string];
            for (id item in self) {
                // item enters the runtime as a context object
                GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
                
                NSString *rendering = [section renderForSection:section inRuntime:itemRuntime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
                if (rendering) {
                    [buffer appendString:rendering];
                }
            }
            return buffer;
        }
    }
    else
    {
        // Variable tag {{# list }}
        
        // Render the concatenation of the rendering of each item
        
        NSMutableString *buffer = [NSMutableString string];
        BOOL oneItemHasRenderedHTMLEscaped = NO;
        BOOL oneItemHasRenderedHTMLUnescaped = NO;
        
        for (id item in self) {
            // item enters the runtime as a context object
            GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
            
            // render item
            id<GRMustacheRenderingObject> itemRenderingObject = [GRMustache renderingObjectForValue:item];
            BOOL itemHasRenderedHTMLEscaped = NO;
            NSString *rendering = [itemRenderingObject renderForSection:nil inRuntime:itemRuntime templateRepository:templateRepository HTMLEscaped:&itemHasRenderedHTMLEscaped];
            
            if (rendering)
            {
                // check consistency of HTML escaping before appending the rendering to the buffer
                
                if (itemHasRenderedHTMLEscaped) {
                    oneItemHasRenderedHTMLEscaped = YES;
                    if (oneItemHasRenderedHTMLUnescaped) {
                        [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                    }
                } else {
                    oneItemHasRenderedHTMLUnescaped = YES;
                    if (oneItemHasRenderedHTMLEscaped) {
                        [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                    }
                }
                
                [buffer appendString:rendering];
            }
        }
        
        *HTMLEscaped = oneItemHasRenderedHTMLEscaped;
        return buffer;
    }
}
