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

#import "AppDelegate.h"
#import "Article.h"
#import "GRMustache.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /**
     * The application ships with three templates:
     *
     * - layout.mustache: the base structure for a HTML page.
     * - header.mustache: a partial template that renders a HTML header.
     * - article.mustache: a template that overrides layout and header elements,
     *   in order to build a specific "article" page.
     */
    
    Article *article = [Article new];
    article.title = @"Layouts are awesome";
    article.author = @"John Doe";
    article.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse quam risus, scelerisque et malesuada a, facilisis et lorem.";
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"article" bundle:nil error:NULL];
    NSString *rendering = [template renderObject:article error:NULL];
    NSLog(@"%@", rendering);
}

@end
