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

#import "GRMustacheEnvironment.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

// =============================================================================
#pragma mark - GRMustacheDirectoryURLTemplateLoader

@implementation GRMustacheDirectoryURLTemplateLoader

- (id)initWithURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [super initWithExtension:ext encoding:encoding options:options];
    if (self) {
        _URL = [URL retain];
    }
    return self;
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId
{
    if (baseTemplateId) {
        NSAssert([baseTemplateId isKindOfClass:[NSURL class]], @"");
        if (self.extension.length == 0) {
            return [[NSURL URLWithString:name relativeToURL:(NSURL *)baseTemplateId] URLByStandardizingPath];
        }
        return [[NSURL URLWithString:[name stringByAppendingPathExtension:self.extension] relativeToURL:(NSURL *)baseTemplateId] URLByStandardizingPath];
    }
    if (self.extension.length == 0) {
        return [[_URL URLByAppendingPathComponent:name] URLByStandardizingPath];
    }
    return [[[_URL URLByAppendingPathComponent:name] URLByAppendingPathExtension:self.extension] URLByStandardizingPath];
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError
{
    NSAssert([templateId isKindOfClass:[NSURL class]], @"");
    return [NSString stringWithContentsOfURL:(NSURL*)templateId
                                    encoding:self.encoding
                                       error:outError];
}

#pragma mark <GRMustacheURLTemplateLoader>

- (GRMustacheTemplate *)templateFromContentsOfURL:(NSURL *)templateURL error:(NSError **)outError
{
    NSString *templateString = [NSString stringWithContentsOfURL:templateURL encoding:self.encoding error:outError];
    if (!templateString) {
        return nil;
    }
    GRMustacheTemplate *template = [self templateFromString:templateString error:outError];
    if (!template) {
        return nil;
    }
    // we can cache this template
    [self setTemplate:template forTemplateId:templateURL];
    return template;
}

- (void)dealloc
{
    [_URL release];
    [super dealloc];
}

@end

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */


// =============================================================================
#pragma mark - GRMustacheDirectoryPathTemplateLoader

@implementation GRMustacheDirectoryPathTemplateLoader

- (id)initWithPath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [super initWithExtension:ext encoding:encoding options:options];
    if (self) {
        _path = [path retain];
    }
    return self;
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId
{
    if (baseTemplateId) {
        NSAssert([baseTemplateId isKindOfClass:[NSString class]], @"");
        NSString *basePath = [(NSString *)baseTemplateId stringByDeletingLastPathComponent];
        if (self.extension.length == 0) {
            return [[basePath stringByAppendingPathComponent:name] stringByStandardizingPath];
        }
        return [[basePath stringByAppendingPathComponent:[name stringByAppendingPathExtension:self.extension]] stringByStandardizingPath];
    }
    if (self.extension.length == 0) {
        return [[_path stringByAppendingPathComponent:name] stringByStandardizingPath];
    }
    return [[[_path stringByAppendingPathComponent:name] stringByAppendingPathExtension:self.extension] stringByStandardizingPath];
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError
{
    NSAssert([templateId isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString*)templateId
                                     encoding:self.encoding
                                        error:outError];
}

#pragma mark <GRMustachePathTemplateLoader>

- (GRMustacheTemplate *)templateFromContentsOfFile:(NSString *)templatePath error:(NSError **)outError
{
    NSString *templateString = [NSString stringWithContentsOfFile:templatePath encoding:self.encoding error:outError];
    if (!templateString) {
        return nil;
    }
    GRMustacheTemplate *template = [self templateFromString:templateString error:outError];
    if (!template) {
        return nil;
    }
    // we can cache this template
    [self setTemplate:template forTemplateId:templatePath];
    return template;
}

- (void)dealloc
{
    [_path release];
    [super dealloc];
}

@end
