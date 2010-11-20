// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustache.h"
#import "YAML.h"

BOOL render(NSString *yamlPath, NSString *templatePath, NSError **outError) {
	// load YAML data
	NSString *yamlString = [NSString stringWithContentsOfFile:yamlPath encoding:NSUTF8StringEncoding error:outError];
	if (!yamlString) {
		return NO;
	}
	
	// parse YAML data
	id data = yaml_parse(yamlString);
	if (!data) {
		if (outError != NULL) {
			*outError = [[[NSError alloc] initWithDomain:GRMustacheErrorDomain
													code:NSNotFound // don't fuck up with GRMustacheErrorCode enum
												userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@: invalid YAML data", yamlPath]
																					 forKey:NSLocalizedDescriptionKey]] autorelease];
		}
		return NO;
	}
	
	// render template
	NSString *result = [GRMustacheTemplate renderObject:data
									  fromContentsOfURL:[NSURL fileURLWithPath:templatePath]
												  error:outError];
	if (!result) {
		return NO;
	}
	
	// output
	[result writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
	return YES;
}

BOOL displayUsage()
{
	fprintf(stderr, "Usage: grmustache YAML FILE   render the mustache template FILE with YAML data\n");
	fprintf(stderr, "       grmustache -v          print version number\n");
	return YES;
}

BOOL displayVersion()
{
	fprintf(stderr, "GRMustache %d.%d.%d\n", GRMUSTACHE_MAJOR_VERSION, GRMUSTACHE_MINOR_VERSION, GRMUSTACHE_PATCH_VERSION);
	return YES;
}

int main(int argc, char *argv[])
{
	int returnCode = 0;
	int optionChar;
	int helpFlag = NO;
	int versionFlag = NO;
	char *yamlCPath = NULL;
	char *templateCPath = NULL;
	
	NSAutoreleasePool * pool = [NSAutoreleasePool new];
	
	
	// enumerate options arguments
	
	while((optionChar = getopt(argc, argv, "hv")) != -1) {
		switch(optionChar) {
			case 'h':
				helpFlag = YES;		// display help
				break;
			case 'v':
				versionFlag = YES;	// display version
				break;
			case '?':
				// unknown option. getopt will display an error message
				returnCode = 1;
				break;
			default:
				abort();
		}
	}
	
	
	// are there some non-options arguments ?
	
	for(int i = optind; i < argc; i++) {
		if (yamlCPath == NULL) {
			yamlCPath = argv[i];
		} else if (templateCPath == NULL) {
			templateCPath = argv[i];
		} else {
			helpFlag = YES;
			returnCode = 1;
			break;
		}
	}
	
	
	// make sure all required input is there
	
	if (!helpFlag && !versionFlag && (!yamlCPath || !templateCPath)) {
		helpFlag = YES;
		returnCode = 1;
	}
	
	
	// Perform action
	
	if (helpFlag) {
		if (!displayUsage()) {
			returnCode = 1;
		}
	}
	else if (versionFlag) {
		if (!displayVersion()) {
			returnCode = 1;
		}
	} else {
		NSError *error;
		NSString *yamlPath = [NSString stringWithCString:yamlCPath encoding:NSUTF8StringEncoding];
		NSString *templatePath = [NSString stringWithCString:templateCPath encoding:NSUTF8StringEncoding];
		if (!render(yamlPath, templatePath, &error)) {
			const char *errorCString = [[error localizedDescription] UTF8String];
			fprintf(stderr, "%s: ", argv[0]);
			fwrite(errorCString, strlen(errorCString), 1, stderr);
			fprintf(stderr, "\n");
			returnCode = 1;
		}
	}
	
	
	[pool drain];
	return returnCode;
}
