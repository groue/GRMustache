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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheTestBase.h"

#ifdef GRMUSTACHE_USE_JSONKIT
#import "JSONKit.h"
#endif

@implementation GRMustacheTestBase
@dynamic testBundle;

- (NSBundle *)testBundle
{
    return [NSBundle bundleWithIdentifier:@"com.github.groue.GRMustache"];
}

- (id)JSONObjectWithData:(NSData *)data error:(NSError **)error
{
#ifdef GRMUSTACHE_USE_JSONKIT
    return [data objectFromJSONDataWithParseOptions:JKParseOptionComments error:error];
#else
    // Naive support for single line comments "// ..."
    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSMutableString *commentLessString = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:nil]; // Keep newlines
    while (![scanner isAtEnd]) {
        NSString *chunk;
        if ([scanner scanUpToString:@"//" intoString:&chunk]) {
            [commentLessString appendString:chunk];
        }
        [scanner scanUpToString:@"\n" intoString:NULL];
    }
    data = [commentLessString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
#endif
}

@end

@implementation GRMustacheTestingDelegate
@synthesize mustacheTagWillRenderBlock=_mustacheTagWillRenderBlock;
@synthesize mustacheTagDidRenderAsBlock=_mustacheTagDidRenderAsBlock;
@synthesize mustacheTagDidFailBlock=_mustacheTagDidFailBlock;

- (void)dealloc
{
    self.mustacheTagWillRenderBlock = nil;
    self.mustacheTagDidRenderAsBlock = nil;
    self.mustacheTagDidFailBlock = nil;
    [super dealloc];
}

- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    if (self.mustacheTagWillRenderBlock) {
        return self.mustacheTagWillRenderBlock(tag, object);
    } else {
        return object;
    }
}

- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering
{
    if (self.mustacheTagDidRenderAsBlock) {
        self.mustacheTagDidRenderAsBlock(tag, object, rendering);
    }
}

- (void)mustacheTag:(GRMustacheTag *)tag didFailRenderingObject:(id)object withError:(NSError *)error
{
    if (self.mustacheTagDidFailBlock) {
        self.mustacheTagDidFailBlock(tag, object, error);
    }
}

@end

