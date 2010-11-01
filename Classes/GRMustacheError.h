//
//  GRMustacheError.h
//

#import <Foundation/Foundation.h>


// The domain of returned errors
extern NSString* const GRMustacheErrorDomain;

// The key containing the url where the error occurred
extern NSString* const GRMustacheErrorURL;

// The key containing the error line
extern NSString* const GRMustacheErrorLine;

// The codes of returned errors
typedef enum {
	GRMustacheErrorCodeParseError,
	GRMustacheErrorCodePartialNotFound,
} GRMustacheErrorCode;


