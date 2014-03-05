//
//  GRMustacheStringSet.m
//  GRMustache
//
//  Created by Gwendal Roué on 05/03/2014.
//
//

#import "GRMustacheStringSet.h"

typedef struct {
    NSUInteger retainCount;
    unichar character;
    BOOL endOfString;
} GRMustacheStringSetInfo;

const void *GRMustacheStringSetInfoRetain(const void *info) {
    ++(((GRMustacheStringSetInfo *)info)->retainCount);
    return info;
}

void GRMustacheStringSetInfoRelease(const void *info) {
    if (--(((GRMustacheStringSetInfo *)info)->retainCount) == 0) {
        free((void *)info);
    }
}

@implementation GRMustacheStringSet

- (void)dealloc
{
    if (_tree) {
        CFRelease(_tree);
    }
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        CFTreeContext treeContext = {
            .version = 0,
            .info = NULL,
            .retain = GRMustacheStringSetInfoRetain,
            .release = GRMustacheStringSetInfoRelease,
            .copyDescription = NULL,
        };
        _tree = CFTreeCreate(NULL, &treeContext);
    }
    return self;
}

- (BOOL)containsString:(NSString *)string
{
    return ([self treeForString:string index:0 inTree:_tree] != NULL);
}

- (CFTreeRef)treeForString:(NSString *)string index:(NSUInteger)index inTree:(CFTreeRef)tree
{
    unichar c = [string characterAtIndex:index];
    CFTreeContext context;
    for (CFTreeRef child = CFTreeGetFirstChild(tree); child; child = CFTreeGetNextSibling(child)) {
        CFTreeGetContext(child, &context);
        GRMustacheStringSetInfo *info = (GRMustacheStringSetInfo *)context.info;
        if (info->character == c) {
            if (index == [string length] - 1) {
                if (info->endOfString) {
                    return child;
                } else {
                    return NULL;
                }
            } else {
                return [self treeForString:string index:index + 1 inTree:child];
            }
        }
    }
    return NULL;
}

@end

@implementation GRMustacheMutableStringSet

- (void)addString:(NSString *)string
{
    CFTreeContext context;
    NSUInteger index = 0;
    CFTreeRef tree = [self blahString:string index:&index context:&context inTree:_tree];
    NSUInteger maxIndex = [string length] - 1;
    GRMustacheStringSetInfo *info;
    for (;index < maxIndex; ++index) {
        unichar c = [string characterAtIndex:index];
        info = malloc(sizeof(GRMustacheStringSetInfo));
        info->retainCount = 1;
        info->character = c;
        info->endOfString = NO;
        CFTreeContext treeContext = {
            .version = 0,
            .info = NULL,
            .retain = GRMustacheStringSetInfoRetain,
            .release = GRMustacheStringSetInfoRelease,
            .copyDescription = NULL,
        };
        CFTreeRef child = CFTreeCreate(NULL, &treeContext);
        CFTreeAppendChild(tree, child);
        tree = child;
    }
    info->endOfString = YES;
}

- (CFTreeRef)blahString:(NSString *)string index:(NSUInteger *)ioIndex context:(CFTreeContext *)outContext inTree:(CFTreeRef)tree
{
    unichar c = [string characterAtIndex:*ioIndex];
    for (CFTreeRef child = CFTreeGetFirstChild(tree); child; child = CFTreeGetNextSibling(child)) {
        CFTreeGetContext(child, outContext);
        GRMustacheStringSetInfo *info = (GRMustacheStringSetInfo *)outContext->info;
        if (info->character == c) {
            if (*ioIndex == [string length] - 1) {
                return child;
            } else {
                ++*ioIndex;
                return [self blahString:string index:ioIndex context:outContext inTree:child];
            }
        }
    }
    return _tree;
}

@end
