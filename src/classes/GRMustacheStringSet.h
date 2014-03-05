//
//  GRMustacheStringSet.h
//  GRMustache
//
//  Created by Gwendal Roué on 05/03/2014.
//
//

#import <Foundation/Foundation.h>

@interface GRMustacheStringSet : NSObject {
    CFTreeRef _tree;
}
- (BOOL)containsString:(NSString *)string;
@end

@interface GRMustacheMutableStringSet : GRMustacheStringSet
- (void)addString:(NSString *)string;
@end
