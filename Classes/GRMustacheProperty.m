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

#import "GRMustacheProperty_private.h"

#if (TARGET_OS_IPHONE)
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-runtime.h>
#endif

@interface GRMustacheProperty()
@property BOOL BOOLProperty;
+ (NSInteger)typeForPropertyNamed:(NSString *)propertyName ofClass:(Class)class;
@end

@implementation GRMustacheProperty
@dynamic BOOLProperty;

+ (BOOL)class:(Class)class hasBOOLPropertyNamed:(NSString *)propertyName
{
    static NSMutableDictionary *classes = nil;
    if (classes == nil) {
        classes = [[NSMutableDictionary dictionary] retain];
    }
    
    NSMutableDictionary *propertyNames = [classes objectForKey:class];
    if (propertyNames == nil) {
        propertyNames = [NSMutableDictionary dictionary];
        [classes setObject:propertyNames forKey:class];
    }
    
    NSNumber *boolNumber = [propertyNames objectForKey:propertyName];
    if (boolNumber == nil) {
        static NSInteger BOOLPropertyType = NSNotFound;
        if (BOOLPropertyType == NSNotFound) {
            BOOLPropertyType = [self typeForPropertyNamed:@"BOOLProperty" ofClass:self];
        }
        BOOL booleanProperty = ([self typeForPropertyNamed:propertyName ofClass:class] == BOOLPropertyType);
        [propertyNames setObject:[NSNumber numberWithBool:booleanProperty] forKey:propertyName];
        return booleanProperty;
    }
    
    return [boolNumber boolValue];
}

#pragma mark - Private

+ (NSInteger)typeForPropertyNamed:(NSString *)propertyName ofClass:(Class)class
{
    objc_property_t property = class_getProperty(class, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (property != NULL) {
        const char *attributesCString = property_getAttributes(property);
        while (attributesCString) {
            if (attributesCString[0] == 'T') {
                return attributesCString[1];
            }
            attributesCString = strchr(attributesCString, ',');
            if (attributesCString) {
                attributesCString++;
            }
        }
    }
    return NSNotFound;
}

@end
