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

/**
 @warning *Deprecated*: You should no longer use the GRMustacheContext class in your mustache lambda definitions.
 
 Instead, check the GRMustacheSection overview, which tells about modern ways to define mustache lambdas.
 
 @since v1.3
 @deprecated v1.5
 */
@interface GRMustacheContext: NSObject {
@private
    id _object;
    GRMustacheContext *_parent;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creating a context
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns a context objet containing a single object.
 
 @warning *Deprecated*: See the class overview above.
 
 @return A context objet containing a single object.
 
 @since v1.3
 
 @deprecated v1.5
 */
+ (id)contextWithObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_5;

/**
 Returns a context objet containing several objects.
 
 @warning *Deprecated*: See the class overview above.
 
 @return A context objet containing several objects.
 
 @since v1.3
 
 @deprecated v1.5
 */
+ (id)contextWithObjects:(id)object, ... AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_5;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Deriving new contexts
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns a new context that is a copy of the receiving context with a given object added to the end.
 
 @warning *Deprecated*: See the class overview above.
 
 @return A new context that is a copy of the receiving context with a given object added to the end.
 
 @since v1.3
 
 @deprecated v1.5
 */
- (GRMustacheContext *)contextByAddingObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_5;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Key value coding
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the first non nil value found in the objects contained in the context, if possible, and nil otherwise.
 
 GRMustacheContext sends the `valueForKey:` message to all its objects, starting from the last one, until one returns a value that is not nil.
 
 If no object can return a value, this method returns nil.
 
 If GRMustache does not run in strict boolean mode, this method will return objects created with `[NSNumber numberWithBOOL:]` instead of `[NSNumber numberWithChar:]` when dealing with BOOL properties of objects.
 
 @return The first non nil value found in the objects contained in the context, if possible, and nil otherwise.
 
 @param key The name of one of the receiver's properties.
 
 @see [GRMustache strictBooleanMode]
 @see [GRMustache setStrictBooleanMode:]
 
 @since v1.3
 */
- (id)valueForKey:(NSString *)key;
@end
