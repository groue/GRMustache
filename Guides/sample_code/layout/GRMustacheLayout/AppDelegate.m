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
     * - article.mustache: the content of a specific "article" page.
     *
     * All of those want to access the rendered data. Precisely speaking,
     * layout.mustache needs to fill its <title> HTML tag; header.mustache needs
     * to fill its <h1> HTML tag; and article.mustache needs some text to be
     * displayed.
     *
     * header.mustache is embedded as a partial into layout.mustache, with the
     * {{> header }} tag, because all pages have a header.
     *
     * However, article.mustache is not embedded as a partial, and we do not
     * want it to be.
     *
     * This is because Mustache partials are always harcoded. Since we would
     * like to use layout.mustache with some other templates like, say,
     * author.mustache, video.mustache, or whatever, Mustache partials are not
     * the solution.
     *
     * No problem: we'll render our document in two passes:
     *
     * - the first pass will render the embedded content with article.mustache.
     * - the second pass will fill the {{{ embeddedContent }}} tag of
     *   layout.mustache with this embedded content.
     *
     * Is the plan clear? Let's start by defining the rendered data:
     */
    
    Article *article = [Article new];
    article.title = @"Layouts are awesome";
    article.author = @"John Doe";
    article.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse quam risus, scelerisque et malesuada a, facilisis et lorem.";
    
    
    /**
     * Now let's render the embedded content, by providing the article to
     * article.mustache:
     */
    
    GRMustacheTemplate *articleTemplate = [GRMustacheTemplate templateFromResource:@"article" bundle:nil error:NULL];
    NSString *embeddedContent = [articleTemplate renderObject:article];
    
    
    /**
     * Finally, render layout.mustache with two objects:
     *
     * - layoutContext: this object associates the embeddedContent to the
     *                  "embeddedContent" key, so that the layout template can
     *                  find it and perform its layout job.
     * 
     * - article:       so that the layout can render the article's properties.
     *
     * There are so few occasions to use the little know
     * -[GRMustacheTemplate renderObjects:] method, the one with a final s.
     * This brings tears to my eyes.
     */
    
    GRMustacheTemplate *layoutTemplate = [GRMustacheTemplate templateFromResource:@"layout" bundle:nil error:NULL];
    NSDictionary *layoutContext = [NSDictionary dictionaryWithObject:embeddedContent forKey:@"embeddedContent"];
    NSString *rendering = [layoutTemplate renderObjects:layoutContext, article, nil];
    
    
    // 4. Success!
    
    NSLog(@"%@", rendering);
}

@end
