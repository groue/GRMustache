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

#warning Missing availibility macros

@protocol GRMustacheKeyValidation <NSObject>

/**
 * TODO
 *
 * List the name of the keys GRMustache can access on this class.
 *
 * Your object should implement this method to fine-tune the values GRMustache
 * can access using `valueForKey:` and `objectForKeyedSubscript:`.
 *
 * When objects do not respond to this method, all keys can be accessed through
 * `objectForKeyedSubscript:`, and only declared properties can be
 * accessed by `valueForKey:` (except for CoreData NSManagedObjects where all
 * CoreData properties are also accessible, even without property declaration).
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/security.md
 *
 * @return The set of accessible keys on the class.
 */
- (BOOL)isValidMustacheKey:(NSString *)key;

@end
