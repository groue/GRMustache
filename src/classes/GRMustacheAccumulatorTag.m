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

#import "GRMustacheAccumulatorTag_private.h"

@interface GRMustacheAccumulatorTag()
- (id)initWithTags:(NSArray *)tags;
@end

@implementation GRMustacheAccumulatorTag

+ (instancetype)accumulatorTagWithTag:(GRMustacheTag *)tag
{
    return [[[self alloc] initWithTags:[NSArray arrayWithObject:tag]] autorelease];
}

- (void)dealloc
{
    [_tags release];
    [super dealloc];
}


#pragma mark - GRMustacheTag

- (NSString *)innerTemplateString
{
    return [[_tags valueForKey:@"innerTemplateString"] componentsJoinedByString:@""];
}

- (BOOL)escapesHTML
{
    return ((GRMustacheTag *)[_tags objectAtIndex:0]).escapesHTML;
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    NSMutableString *buffer = [NSMutableString string];
    for (GRMustacheTag *tag in _tags) {
        @autoreleasepool {
            // Consistency of HTML safety is asserted in tagWithOverridingTag:
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            if (!rendering) {
                // make sure error is not released by autoreleasepool
                if (error != NULL) [*error retain];
                buffer = nil;
                break;
            }
            [buffer appendString:rendering];
        }
    }
    if (!buffer && error != NULL) [*error autorelease];
    return buffer;
}

- (GRMustacheTag *)tagWithOverridingTag:(GRMustacheTag *)overridingTag
{
    // In the following situation, the overriden tag (self) is extended by
    // the overriding tag:
    //
    // layout.mustache:
    //
    //   {{$head}}overriden{{/head}}
    //
    // base.mustache:
    //
    //   {{<layout}}
    //     {{>partial1}}
    //     {{>partial2}}
    //   {{/}}
    //
    // partial1.mustache:
    //
    //   {{$head}}head for partial 1{{/head}}
    //
    // partial2.mustache:
    //
    //   {{$head}}head for partial 2{{/head}}   <- overriding tag
    //
    // Rendering:
    //
    //   head for partial 1
    //   head for partial 2
    //
    // See also [GRMustacheSectionTag tagWithOverridingTag:]
    
    if (overridingTag.escapesHTML != self.escapesHTML) {
        [NSException raise:NSInternalInconsistencyException format:@"Tag escapesHTML mismatch"];
    }
    return [[[GRMustacheAccumulatorTag alloc] initWithTags:[_tags arrayByAddingObject:overridingTag]] autorelease];
}


#pragma mark - Private

- (id)initWithTags:(NSArray *)tags
{
    GRMustacheTag *initialTag = [tags objectAtIndex:0];
    self = [super initWithType:initialTag.type templateRepository:initialTag.templateRepository expression:initialTag.expression contentType:initialTag.contentType];
    if (self) {
        _tags = [tags retain];
    }
    return self;
}

@end
