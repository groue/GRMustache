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

#import "GRMustacheInvocation_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheToken_private.h"

@implementation GRMustacheInvocation
@synthesize returnValue=_returnValue;
@synthesize key=_key;

- (void)dealloc
{
    [_returnValue release];
    [_key release];
    [super dealloc];
}

- (NSString *)description
{
//    NSAssert(_debuggingToken, @"debuggingToken not set");
//    if (_debuggingToken.templateID) {
//        return [NSString stringWithFormat:@"`%@` at line %lu of template %@", _debuggingToken.templateSubstring, (unsigned long)_debuggingToken.line, _debuggingToken.templateID];
//    } else {
//        return [NSString stringWithFormat:@"`%@` at line %lu", _debuggingToken.templateSubstring, (unsigned long)_debuggingToken.line];
//    }
    return nil;
}

- (BOOL)isScopable
{
    return !_nonScopable;
}

- (void)setScopable:(BOOL)scopable
{
    _nonScopable = !scopable;
}

@end
