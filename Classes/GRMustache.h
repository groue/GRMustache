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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"

enum {
    GRMustacheTemplateOptionNone = 0,
    GRMustacheTemplateOptionMustacheSpecCompatibility = 0x01,
};

typedef NSUInteger GRMustacheTemplateOptions;


/**
 A C struct that hold GRMustache version information
 
 @since v1.0
 */
typedef struct {
    int major;    /**< The major component of the version. */
    int minor;    /**< The minor component of the version. */
    int patch;    /**< The patch-level component of the version. */
} GRMustacheVersion;


/**
 The GRMustache class provides with global-level information and configuration
 of the GRMustache library.
 @since v1.0
 */
@interface GRMustache: NSObject

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Getting the GRMustache version
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the version of GRMustache as a GRMustacheVersion struct.
 
 @return The version of GRMustache as a GRMustacheVersion struct.
 @since v1.0
 */
+ (GRMustacheVersion)version AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Handling of BOOL properties
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns a Boolean value that determines whether GRMustache renders templates in strict
 boolean mode.
 
 In strict boolean mode, properties of context objects that are declared as BOOL
 are interpreted as numbers, and can not be used for controlling Mustache
 boolean sections.
 
 In non-strict boolean mode, all properties declared as signed char (including
 those declared as BOOL), are interpreted as booleans, and can be used for
 controlling Mustache boolean sections.
 
 @return YES if GRMustache renders templates in strict boolean mode,
 NO otherwise. The default value is NO.
 
 @see setStrictBooleanMode:
 @see [GRMustacheContext valueForKey:]
 @since v1.0
 */
+ (BOOL)strictBooleanMode AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;

/**
 Sets the strict boolean mode of GMustache.
 
 See the documentation for strictBooleanMode for more information.
 
 @param strictBooleanMode YES if GRMustache should render templates in strict boolean mode,
 NO otherwise.
 
 @see strictBooleanMode
 @see [GRMustacheContext valueForKey:]
 @since v1.0
 */
+ (void)setStrictBooleanMode:(BOOL)strictBooleanMode AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Preventing NSUndefinedKeyException when using GRMustache in Development configuration
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Have GRMustache raise much less `NSUndefinedKeyExceptions` when rendering templates.
 
 The rendering of a GRMustache template can lead to many `NSUndefinedKeyExceptions` to be raised, because of the heavy usage of Key-Value Coding. Those exceptions are nicely handled by GRMustache, and are part of the regular rendering of a template.
 
 Unfortunately, when debugging a project, developers usually set their debugger to stop on every Objective-C exceptions. GRMustache rendering can thus become a huge annoyance. This method prevents it.
 
 You'll get a slight performance hit, so you'd probably make sure this call does not enter your Release configuration.
 
 One way to achieve this is to add `-DDEBUG` to the "Other C Flags" setting of your development configuration, and to wrap the `preventNSUndefinedKeyExceptionAttack` method call in a #if block, like:
 
    #ifdef DEBUG
    [GRMustache preventNSUndefinedKeyExceptionAttack];
    #endif
 
 @since v1.7
 */
+ (void)preventNSUndefinedKeyExceptionAttack AVAILABLE_GRMUSTACHE_VERSION_1_7_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Global template options
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the default template options. The default value is GRMustacheTemplateOptionNone.
 
 @return The default template options. The default value is GRMustacheTemplateOptionNone.
 @see setDefaultTemplateOptions:
 @since v1.8
 */
+ (GRMustacheTemplateOptions)defaultTemplateOptions AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;

/**
 Sets the default template options.
 
 Those options will be used by all GRMustacheTemplate rendering and parsing methods, such as [GRMustacheTemplate templateFromString:error:] and [GRMustacheTemplate renderObject:fromString:error:].
 
 For instance, you'll trigger support for the [Mustache Specification 1.1.2](https://github.com/mustache/spec) with:
 
    [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionMustacheSpecCompatibility];
 
 @param templateOptions A mask of options indicating the default behavior of templates.
 @see defaultTemplateOptions
 @since v1.8
 */
+ (void)setDefaultTemplateOptions:(GRMustacheTemplateOptions)templateOptions AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;

@end

#import "GRMustacheSection.h"
#import "GRMustacheInvocation.h"
#import "GRMustacheTemplate.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheTemplateLoader.h"
#import "GRMustacheTemplateRepository.h"
#import "GRMustacheContext.h"
#import "GRMustacheLambda.h"
#import "GRBoolean.h"
#import "GRMustacheEnvironment.h"
#import "GRMustacheError.h"
#import "GRMustacheVersion.h"
