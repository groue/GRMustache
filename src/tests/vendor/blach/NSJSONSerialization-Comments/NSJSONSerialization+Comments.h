//
//  NSJSONSerialization+Comments.h
//  ABCodeEditor
//
//  Created by Alexander Blach on 22.07.14.
//  Copyright (c) 2014 Alexander Blach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Comments)

+ (NSData *)dataByStrippingJSONCommentsAndWhiteSpaceOfUTF8Data:(NSData *)data
                                                     skipBytes:(NSUInteger)bytesToSkip;

// preferred method, since it doesn't need to convert an NSString if the data is  encoded with UTF-8
+ (id)JSONObjectWithCommentedData:(NSData *)data
                          options:(NSJSONReadingOptions)opt
                            error:(NSError **)error;

+ (id)JSONObjectWithCommentedContentsOfURL:(NSURL *)url
                                   options:(NSJSONReadingOptions)opt
                                     error:(NSError **)error;

+ (id)JSONObjectWithCommentedContentsOfFile:(NSString *)path
                                    options:(NSJSONReadingOptions)opt
                                      error:(NSError **)error;

+ (id)JSONObjectWithCommentedString:(NSString *)string
                            options:(NSJSONReadingOptions)opt
                              error:(NSError **)error;


// convenience method if you need an NSString instead of NSData
+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

@end
