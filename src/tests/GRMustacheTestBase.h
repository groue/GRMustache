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

#import <SenTestingKit/SenTestingKit.h>
#import "GRMustacheTagDelegate.h"

@interface GRMustacheTestBase: SenTestCase
@property (nonatomic, readonly) NSBundle *testBundle;
- (id)JSONObjectWithData:(NSData *)data error:(NSError **)error;
@end

@interface GRMustacheTestingDelegate : NSObject<GRMustacheTagDelegate> {
    id(^_mustacheTagWillRenderBlock)(GRMustacheTag *tag, id object);
    void(^_mustacheTagDidRenderAsBlock)(GRMustacheTag *tag, id object, NSString *rendering);
    void(^_mustacheTagDidFailBlock)(GRMustacheTag *tag, id object, NSError *error);
}
@property (nonatomic, copy) id(^mustacheTagWillRenderBlock)(GRMustacheTag *tag, id object);
@property (nonatomic, copy) void(^mustacheTagDidRenderAsBlock)(GRMustacheTag *tag, id object, NSString *rendering);
@property (nonatomic, copy) void(^mustacheTagDidFailBlock)(GRMustacheTag *tag, id object, NSError *error);
@end

