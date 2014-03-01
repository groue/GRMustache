// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

@protocol GRMustacheKeyValidation <NSObject>

/**
 * List the name of the property GRMustache can access on this class via the
 * `valueForKey:`method.
 *
 * This method is not used if your object respond to `objectForKeyedSubscript:`.
 *
 * Your object should implement this method to fine-tune the values GRMustache
 * can access using Key-Value Coding.
 *
 * When objects do not respond to this method, only declared properties can be
 * accessed by GRMustache (except for CoreData NSManagedObjects where all
 * CoreData properties are accessible).
 *
 * @return The list of accessible properties on the class
 */
+ (NSArray *)validMustacheKeys;

@end
