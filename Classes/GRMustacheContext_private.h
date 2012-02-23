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

@interface GRMustacheContext: NSObject { // deprecated
@private
    id _object;
    GRMustacheContext *_parent;
}
@property (nonatomic, retain, readonly) id object;
@property (nonatomic, retain, readonly) GRMustacheContext *parent;
+ (void)preventNSUndefinedKeyExceptionAttack;
+ (id)contextWithObject:(id)object; // deprecated
+ (id)contextWithObjects:(id)object, ... UNAVAILABLE_ATTRIBUTE; // privately unavailable deprecated public method
+ (id)contextWithObject:(id)object andObjectList:(va_list)objectList;
- (GRMustacheContext *)contextByAddingObject:(id)object; // deprecated
- (GRMustacheContext *)contextForKey:(NSString *)key scoped:(BOOL)scoped;
- (id)valueForKey:(NSString *)key;
@end
