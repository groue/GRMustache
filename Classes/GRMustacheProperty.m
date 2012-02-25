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
@end

@implementation GRMustacheProperty
@dynamic BOOLProperty;

+ (BOOL)class:(Class)class hasBOOLPropertyGetterNamed:(NSString *)getterName
{
    // You can use the property_getAttributes function to discover the name,
    // the @encode type string of a property, and other attributes of the property.
    //    
    // The string starts with a T followed by the @encode type and a comma,
    // and finishes with a V followed by the name of the backing instance variable.
    // Between these, the attributes are specified by the following descriptors,
    // separated by commas:
    //
    // ...
    // G<name>  The property defines a custom getter selector name.
    //          The name follows the G (for example, GcustomGetter,).
    // ...
    
    static char BOOLEncodeTypePrefix = 0;
    if (BOOLEncodeTypePrefix == 0) {
        objc_property_t BOOLproperty = class_getProperty([GRMustacheProperty class], "BOOLProperty");
        const char *BOOLpropertyAttributes = property_getAttributes(BOOLproperty);
        BOOLEncodeTypePrefix = BOOLpropertyAttributes[1];
    }
    
    const char *getterNameCString = [getterName cStringUsingEncoding:NSUTF8StringEncoding];
    
    // first look for property with the same name
    objc_property_t property = class_getProperty(class, getterNameCString);
    if (property != NULL) {
        const char *propertyAttributes = property_getAttributes(property);
        if (propertyAttributes[1] == BOOLEncodeTypePrefix) {
            return YES;
        }
    }

    // now look for check for custom getter in all properties
    size_t getterNeedleSize = strlen(getterNameCString) + 3; // room for 'G', selector name, ',', and '\0'
    char *getterNeedleCString = malloc(getterNeedleSize);
    sprintf(getterNeedleCString, "G%s,", getterNameCString);
    BOOL found = NO;
    for (; class; class = class_getSuperclass(class)) {
        objc_property_t *properties = class_copyPropertyList(class, NULL);
        if (properties == NULL) continue;
        for (objc_property_t *p = properties; *p; ++p) {
            const char *propertyAttributes = property_getAttributes(*p);
            found = ((propertyAttributes[1] == BOOLEncodeTypePrefix) && strstr(propertyAttributes, getterNeedleCString));
            if (found) break;
        }
        free(properties);
        if (found) break;
    }
    free(getterNeedleCString);
    return found;
}


@end
