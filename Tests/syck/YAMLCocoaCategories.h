//
//  YAMLCocoaCategories.h
//  YAML
//
//  Created by Will on 29/09/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE

#import <Cocoa/Cocoa.h>

@interface NSColor (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

@interface NSAffineTransform (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

@interface NSPrinter (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

@interface NSValue (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

@interface NSDate (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

#endif

@interface NSNumber (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end

#if 0
@interface NSData (YAMLCocoaAdditions)
+ (id)objectWithYAML:(id)data;
- (id)toYAML;
@end
#endif