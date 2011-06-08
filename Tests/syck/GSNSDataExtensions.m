//
//  GSNSDataExtensions.m
//
//  Created by khammond on Mon Oct 29 2001.
//  Copyright (c) 2001, 2005 Kyle Hammond. All rights reserved.
//
// Original development comments by Dave Winer.
// Jan 12, 2005 - added AltiVec implementation, and greatly improved encoding speed.

/*	C source code for Base 64 

       Here's the C source code for the Base 64 encoder/decoder.

        File:
                     base64.c
        Created:
                     Saturday, April 5, 1997; 1:30:13 PM
        Modified: 
                     Tuesday, April 8, 1997; 7:52:28 AM

       Dave Winer, dwiner@well.com, UserLand Software, 4/7/97
        
       I built this project using Symantec C++ 7.0.4 on a Mac 9500.
        
       We needed a handle-based Base 64 encoder/decoder. Looked around the
       net, found a bunch of code that couldn't easily be adapted to 
       in-memory stuff. Most of them work on files to conserve memory. This
       is inelegant in scripting environments such as Frontier.
        
       Anyway, so I wrote an encoder/decoder. Docs are being maintained 
       on the web, and updates at:
        
       http://www.scripting.com/midas/base64/
        
       If you port this code to another platform please put the result up
       on a website, and send me a pointer. Also send email if you think this
       isn't a compatible implementation of Base 64 encoding.
        
       BTW, I made it easy to port -- layering out the handle access routines.
       Of course there's a small performance penalty for this, and if you don't
       like it, change it. Thanks!
       */

#import "GSNSDataExtensions.h"

// Comment this out (or change it to a zero) to disable AltiVec processing.
#define COMPILE_FOR_ALTIVEC		0

static unsigned long local_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData );

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )

static BOOL local_AltiVec_IsPresent( void );
static unsigned long local_altiVec_encode( unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData, unsigned long *outEncodedLength );
static unsigned long local_altiVec_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData );
static unsigned long local_altiVec_decode( unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData, unsigned long *outDecodedLength );

#endif

@implementation NSData (Base64Encoding)

static char gEncodingTable[ 64 ] = {
           'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
           'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
           'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
           'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
            };

+ (BOOL)isCharacterPartOfBase64Encoding:(char)inChar
{
    int		i;

    for ( i = 0; i < 64; i++ )
    {
        if ( gEncodingTable[ i ] == inChar )
            return YES;
    }

    return NO;
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)inBase64String
{
    NSData	*result = nil;

    result = [ [ NSData alloc ] initWithBase64EncodedString:inBase64String ];

    return [ result autorelease ];
}

- (id)initWithBase64EncodedString:(NSString *)inBase64String
{
    NSMutableData	*mutableData = nil;

    if ( inBase64String && [ inBase64String length ] > 0 )
    {
        unsigned long		ixtext;
        unsigned long		lentext;
        unsigned char		ch;
        unsigned char		inbuf [4], outbuf [3];
        short				ixinbuf;
        NSData				*base64Data;
		unsigned char		*preprocessed, *decodedBytes;
		unsigned long		preprocessedLength, decodedLength;
		short				ctcharsinbuf = 3;
		BOOL				notDone = YES;

        // Convert the string to ASCII data.
        base64Data = [ inBase64String dataUsingEncoding:NSASCIIStringEncoding ];
        lentext = [ base64Data length ];

		preprocessed = malloc( lentext );	// We may have all valid data!

		// Allocate our outbound data, and set it's length.
		// Do this so we can fill it in without allocating memory in small chunks later.
		mutableData = [ NSMutableData dataWithCapacity:( lentext * 3 ) / 4 + 3 ];
		[ mutableData setLength:( lentext * 3 ) / 4 + 3 ];
		decodedBytes = [ mutableData mutableBytes ];

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )
		if ( lentext > 15 && local_AltiVec_IsPresent( ) )
		{
			preprocessedLength = local_altiVec_preprocessForDecode( [ base64Data bytes ], lentext, preprocessed );
			ixtext = local_altiVec_decode( preprocessed, preprocessedLength, decodedBytes,
						&decodedLength );
		}
		else
#endif // end COMPILE_FOR_ALTIVEC
		{
			preprocessedLength = local_preprocessForDecode( [ base64Data bytes ], lentext, preprocessed );
			decodedLength = 0;
			ixtext = 0;
		}

        ixinbuf = 0;

        while ( notDone && ixtext < preprocessedLength )
        {
            ch = preprocessed[ ixtext++ ];

			if ( 255 == ch )	// Hit our stop signal.
			{
				if (ixinbuf == 0)
					break;		// We're done now!

				else if ((ixinbuf == 1) || (ixinbuf == 2))
				{
					ctcharsinbuf = 1;
					ixinbuf = 3;
				}
				else
					ctcharsinbuf = 2;

				notDone = NO;	// We're finished after the outbuf gets copied this time.
			}

			inbuf [ixinbuf++] = ch;

			if ( 4 == ixinbuf )
			{
				ixinbuf = 0;

				outbuf [0] = (inbuf [0] << 2) | ((inbuf [1] & 0x30) >> 4);

				outbuf [1] = ((inbuf [1] & 0x0F) << 4) | ((inbuf [2] & 0x3C) >> 2);

				outbuf [2] = ((inbuf [2] & 0x03) << 6) | inbuf [3];

				memcpy( &decodedBytes[ decodedLength  ], outbuf, ctcharsinbuf );
				decodedLength += ctcharsinbuf;
			}
        } // end while loop on remaining characters

		free( preprocessed );

		// Adjust length down to however many bytes we actually decoded.
		[ mutableData setLength:decodedLength ];
    }

    self = [ self initWithData:mutableData ];

    return self;
}

- (NSString *)base64EncodingWithLineLength:(unsigned int)inLineLength
{   /*
        Encode the NSData. Some funny stuff about linelength -- it only makes
        sense to make it a multiple of 4. If it's not a multiple of 4, we make it
        so (by only checking it every 4 characters). 

        Further, if it's 0, we don't add any line breaks at all.
    */
        
    const unsigned char	*bytes = [ self bytes ];
	unsigned char		*encodedData;
	unsigned long		encodedLength;
    unsigned long		ixtext;
    unsigned long		lengthData;
    long				ctremaining;
    unsigned char		inbuf [4], outbuf [4];
    short				i;
    short				charsonline = 0, ctcopy;
    unsigned long		ix;
    NSString			*result = nil;

    lengthData = [ self length ];

	if ( inLineLength > 0 )
		// Allocate a buffer large enough to hold everything + line endings.
		encodedData = malloc( ( ( ( lengthData + 1 ) * 4 ) / 3 ) + ( ( ( ( lengthData + 1 ) * 4 ) / 3 ) / inLineLength ) + 1 );
	else
		// Allocate a buffer large enough to hold everything.
		encodedData = malloc( ( ( lengthData + 1 ) * 4 ) / 3 );

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )
	if ( lengthData > 12 && local_AltiVec_IsPresent( ) )
	{
		ixtext = local_altiVec_encode( (unsigned char *)bytes, lengthData, encodedData, &encodedLength );

		// Add line endings because the AltiVec algorithm doesn't do that.
        if ( inLineLength > 0 )
		{
			for ( ctremaining = inLineLength; ctremaining < encodedLength; ctremaining += inLineLength )
			{
				// Since dst and src overlap here, use memmove instead of memcpy.
				memmove( &encodedData[ ctremaining + 1 ], &encodedData[ ctremaining ],
							encodedLength - ctremaining );
				encodedData[ ctremaining ] = '\n';
				ctremaining++;
				encodedLength++;
			}

			// Do we need one more line ending at the very end of the string?
			if ( ctremaining == encodedLength )
			{
				encodedData[ ctremaining ] = '\n';
				encodedLength++;
			}
			else
				// If not, we have some characters on the line.
				charsonline = encodedLength - ( ctremaining - inLineLength );
		}
	}
	else
#endif // end COMPILE_FOR_ALTIVEC
	{
		// We can't do anything with AltiVec.  Do it all by standard algorithm.
		ixtext = 0;
		encodedLength = 0;
	}

	ctcopy = 4;

    while ( YES )
    {
        ctremaining = lengthData - ixtext;

		if ( ctremaining >= 4 )
			// Copy next four bytes into inbuf.
			(*(unsigned long *)inbuf) = *(unsigned long *)&bytes[ ixtext ];

        else if ( ctremaining <= 0 )
            break;

		else
		{
			// Have less than four bytes to copy.  Fill extras with zero.
			for ( i = 0; i < 3; i++ )
			{
				ix = ixtext + i;

				if (ix < lengthData)
					inbuf [i] = bytes[ix];
				else
					inbuf [i] = 0;
			} // for loop

			switch ( ctremaining )
			{
				case 1:
					ctcopy = 2; 
					break;

				case 2:
					ctcopy = 3; 
					break;
			} // switch
		}

        outbuf [0] = (inbuf [0] & 0xFC) >> 2;

        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);

        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);

        outbuf [3] = inbuf [2] & 0x3F;

		// Depending on how many characters we're supposed to copy, fill in with '=' characters.
		if ( 4 == ctcopy )
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[2] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[3] ];
		}
		else if ( 3 == ctcopy )
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[2] ];
			encodedData[ encodedLength++ ] = '=';
		}
		else
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = '=';
			encodedData[ encodedLength++ ] = '=';
		}

        ixtext += 3;

        if ( inLineLength > 0 )
        {	// DW 4/8/97 -- 0 means no line breaks

			charsonline += 4;
            if (charsonline >= inLineLength)
            {
				charsonline = 0;

				encodedData[ encodedLength++ ] = '\n';
            }
        }
    } // end while loop

	// Make a string object out of the encoded data buffer.
    result = (NSString *)CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, encodedData, encodedLength, kCFStringEncodingASCII, NO, kCFAllocatorMalloc);
	
    return [result autorelease];
}

@end

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )

static BOOL local_AltiVec_IsPresent( void )
{
    long	cpuAttributes;
    BOOL	result = NO;
    OSErr	err;

	err = Gestalt( gestaltNativeCPUtype, &cpuAttributes );
	if ( noErr == err && cpuAttributes > gestaltCPU750 )
	{
		// Only get in here if we're greater than a G3 processor.
		err = Gestalt( gestaltPowerPCProcessorFeatures, &cpuAttributes );
		if ( noErr == err )
			result = ( 0 != ( ( 1 << gestaltPowerPCHasVectorInstructions ) & cpuAttributes ) );
	}

    return result;
}

static unsigned long local_altiVec_encode( unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData, unsigned long *outEncodedLength )
{
	unsigned char			*finishedPtr;
	unsigned long			result = ( inBytesLength / 12 ) * 12;	// round down to nearest multiple of 12
	vector unsigned char	*outboundData = (vector unsigned char *)outData;
	vector unsigned char	workingVec, shiftedLeft_lowerHalf;
	vector bool char		comparison;
	const vector unsigned char	kZero = { 0 };
	const vector unsigned char	kPermuteInbound = (vector unsigned char)( 0, 1, 2, 2, 3, 4, 5, 5, 6, 7, 8, 8, 9, 10, 11, 11 );
	const vector unsigned char	kShiftRight = (vector unsigned char)( 2, 4, 6, 0, 2, 4, 6, 0, 2, 4, 6, 0, 2, 4, 6, 0 );
	const vector unsigned char	kShiftLeft = (vector unsigned char)( 4, 2, 0, 0, 4, 2, 0, 0, 4, 2, 0, 0, 4, 2, 0, 0 );
	const vector unsigned char	kPermuteShiftedLeft = (vector unsigned char)( 16, 0, 1, 16, 16, 4, 5, 16, 16, 8, 9, 16, 16, 12, 13, 16 );
	const vector unsigned char	kSelectShiftedRight = (vector unsigned char)( 255, 255, 255, 63, 255, 255, 255, 63, 255, 255, 255, 63, 255, 255, 255, 63 );
	const vector unsigned char	kSelectShiftedLeft = (vector unsigned char)( 0, 48, 60, 0, 0, 48, 60, 0, 0, 48, 60, 0, 0, 48, 60, 0 );
	const vector unsigned char kBase64LookupTable0 =(vector unsigned char)( 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P' );
	const vector unsigned char kBase64LookupTable1 = (vector unsigned char)( 'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f' );
	const vector unsigned char kBase64LookupTable2 = (vector unsigned char)( 'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v' );
	const vector unsigned char kBase64LookupTable3 = (vector unsigned char)( 'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' );
	const vector unsigned char kThirtyTwo = (vector unsigned char)( 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32 );

	// Determine when we will stop looping.
	// We only do multiples of twelve inbound bytes at a time.
	// Any extra data will need to be put into Base64 using the non-AltiVec algorithm.
	finishedPtr = inBytes + result;

	while ( inBytes < finishedPtr )
	{
		// Copy the twelve bytes into a vector, then
		// permute the inbound data into the correct bytes for output.
		// Note that to save some CPU cycles we copy three longs (at four bytes each).
		((unsigned long *)&workingVec)[ 0 ] = ((unsigned long *)inBytes)[ 0 ];
		((unsigned long *)&workingVec)[ 1 ] = ((unsigned long *)inBytes)[ 1 ];
		((unsigned long *)&workingVec)[ 2 ] = ((unsigned long *)inBytes)[ 2 ];

		// Shift the pointer to work on the next twelve inbound data bytes.
		inBytes += 12;

		workingVec = vec_perm( workingVec, kZero, kPermuteInbound );

		// Shift some bits left and permute them into the correct byte positions.
		// Do this first, because the vec_perm instruction can work at the same time as the next vec_sr.
		shiftedLeft_lowerHalf = vec_perm( vec_sl( workingVec, kShiftLeft ), kZero, kPermuteShiftedLeft );

		// Shift some bits right.
		// Select the parts of the right shifted and left shifted vectors we want.
		workingVec = vec_sel( vec_sel( kZero, vec_sr( workingVec, kShiftRight ), kSelectShiftedRight ), shiftedLeft_lowerHalf, kSelectShiftedLeft );

		// As of now, we have 16 indices ranging from 0 to 63 in workingVec.

		// Determine which indices will use the lower half of the lookup table and which the upper half.
		comparison = vec_cmplt( workingVec, kThirtyTwo );

		// Do the table lookup.
		// Recombine the characters from the upper and lower half lookups into the outbound data.
		(*outboundData) = vec_sel(
					vec_perm( kBase64LookupTable2, kBase64LookupTable3, workingVec ),
					vec_perm( kBase64LookupTable0, kBase64LookupTable1, workingVec ),
					comparison );

		// Shift the pointer to work on the next set of sixteen outbound data bytes.
		outboundData++;
	}

	// Specify how much data we created.
	*outEncodedLength = ((unsigned char *)outboundData - outData);

	// Return how much of the inbound data we encoded.
	return result;
}

static unsigned long local_altiVec_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData )
{
	unsigned long			i;
	BOOL					foundAnEqual = NO;
	unsigned char			*outboundData = outData;
	unsigned char			*inboundData = (unsigned char *)inBytes;
	unsigned char			*finishedPtr = (unsigned char *)inBytes + inBytesLength;
	vector unsigned char	workingVec, finishedVec;
	vector bool char		foundCaps, foundLower, foundNum, foundPlus, foundSlash, foundEqual;
	vector unsigned char		kOne;
	const vector unsigned char	kCharAlpha_Cap = (vector unsigned char)( 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1, 'A' - 1 );
	const vector unsigned char	kCharZed_Cap = (vector unsigned char)( 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1, 'Z' + 1 );
	const vector unsigned char	kCharAlpha_Lower = (vector unsigned char)( 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1, 'a' - 1 );
	const vector unsigned char	kCharZed_Lower = (vector unsigned char)( 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1, 'z' + 1 );
	const vector unsigned char	kCharZero = (vector unsigned char)( '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1, '0' - 1 );
	const vector unsigned char	kCharNine = (vector unsigned char)( '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1, '9' + 1 );
	const vector unsigned char	kCharPlus = (vector unsigned char)( '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+', '+' );
	const vector unsigned char	kCharSlash = (vector unsigned char)( '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/', '/' );
	const vector unsigned char	kCharEqual = (vector unsigned char)( '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=' );
	const vector unsigned char	kTwentySix = (vector unsigned char)( 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26 );
	const vector unsigned char	kFiftyTwo = (vector unsigned char)( 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52, 52 );
	const vector unsigned char	kSixtyTwo = (vector unsigned char)( 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62 );
	const vector unsigned char	kSixtyThree = (vector unsigned char)( 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63 );
	vector unsigned char		kTwoFiftyFive;

	// Create a couple of vectors we want to use.
	kOne = vec_splat_u8( 1 );
	kTwoFiftyFive = vec_add( vec_nor( kOne, kOne ), kOne );
	while ( inboundData < finishedPtr )
	{
		if ( finishedPtr - inboundData >= 16 )
		{
			// Copy the next sixteen characters into the working vector.
			((unsigned long *)&workingVec)[ 0 ] = *(unsigned long *)inboundData;
			((unsigned long *)&workingVec)[ 1 ] = *(unsigned long *)&inboundData[ 4 ];
			((unsigned long *)&workingVec)[ 2 ] = *(unsigned long *)&inboundData[ 8 ];
			((unsigned long *)&workingVec)[ 3 ] = *(unsigned long *)&inboundData[ 12 ];
			inboundData += 16;
		}
		else
		{
			// Copy valid characters in and fill the rest with zero.
			for ( i = 0; i < 16; i++ )
			{
				if ( inboundData < finishedPtr )
					((unsigned char *)&workingVec)[ i ] = *(inboundData++);
				else
					((unsigned char *)&workingVec)[ i ] = 0;
			} // end for loop
		}

		// Look for capital letters, lower case letters, numbers, plus signs, slashes, and equal signs.
		foundCaps = vec_and( vec_cmpgt( workingVec, kCharAlpha_Cap ), vec_cmplt( workingVec, kCharZed_Cap ) );
		foundLower = vec_and( vec_cmpgt( workingVec, kCharAlpha_Lower ), vec_cmplt( workingVec, kCharZed_Lower ) );
		foundNum = vec_and( vec_cmpgt( workingVec, kCharZero ), vec_cmplt( workingVec, kCharNine ) );
		foundPlus = vec_cmpeq( workingVec, kCharPlus );
		foundSlash = vec_cmpeq( workingVec, kCharSlash );
		foundEqual = vec_cmpeq( workingVec, kCharEqual );

		// Adjust Base64 symbols into indices 0 to 63.
		// Select the parts of the data we want.
		// Note that in this first one, we're getting garbage where we didn't have caps.
		finishedVec = vec_sub( workingVec, vec_add( kCharAlpha_Cap, kOne ) );
		finishedVec = vec_sel( finishedVec, vec_add( vec_sub( workingVec, vec_add( kCharAlpha_Lower, kOne ) ), kTwentySix ), foundLower );
		finishedVec = vec_sel( finishedVec, vec_add( vec_sub( workingVec, vec_add( kCharZero, kOne ) ), kFiftyTwo ), foundNum );
		finishedVec = vec_sel( finishedVec, kSixtyTwo, foundPlus );
		finishedVec = vec_sel( finishedVec, kSixtyThree, foundSlash );

		// Stick in a 255 for any equal signs (255 is our stop signal).
		finishedVec = vec_sel( finishedVec, kTwoFiftyFive, foundEqual );

		// Combine all foundBlah comparisons so we can grab only real Base64 data.
		foundCaps = vec_or( vec_or( vec_or( foundCaps, foundLower ), vec_or( foundNum, foundPlus ) ),
					vec_or( foundSlash, foundEqual ) );

		for ( i = 0; i < 16; i++ )
		{
			if ( ((unsigned char *)&foundCaps)[ i ] != 0 )
				// Do not ignore this byte.
				*outboundData++ = ((unsigned char *)&finishedVec)[ i ];
		} // end for loop copying valid data to outBoundData

		// If we found any equal signs on this block, we're done.
		if ( vec_any_eq( workingVec, kCharEqual ) )
		{
			foundAnEqual = YES;
			break;
		}
	} // end for loop over all incoming data.

	if ( foundAnEqual && 255 == *( outboundData - 2 ) )
	{
		// Check to see if we hit two equal signs at the end of the data.
		// If so, back up the outboundData pointer by one so we only include the first stop signal.
		outboundData--;
	}

	// How much valid data did we end up with?
	return outboundData - outData;
}

static unsigned long local_altiVec_decode( unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData, unsigned long *outDecodedLength )
{
	unsigned char			*finishedPtr;
	unsigned long			result = ( inBytesLength / 16 ) * 16;	// round down to nearest multiple of 16
	unsigned long			*outboundData = (unsigned long *)outData;
	vector unsigned char	shiftedRight, outputVec;
	vector unsigned char	kZero = { 0 };
	const vector unsigned char kShiftLeft = (vector unsigned char)( 2, 4, 6, 0, 2, 4, 6, 0, 2, 4, 6, 0, 2, 4, 6, 0 );
	const vector unsigned char kShiftRight = (vector unsigned char)( 0, 4, 2, 0, 0, 4, 2, 0, 0, 4, 2, 0, 0, 4, 2, 0 );
	const vector unsigned char kPermuteShiftedRight = (vector unsigned char)( 1, 2, 3, 16, 5, 6, 7, 16, 9, 10, 11, 16, 13, 14, 15, 16 );
	const vector unsigned char kPermuteRelevantData = (vector unsigned char)( 0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 16, 16, 16 );

	// Determine when we will stop looping.
	// We only do multiples of sixteen inbound bytes at a time.
	// Any extra data will need to be decoded from Base64 using the non-AltiVec algorithm.
	finishedPtr = inBytes + result;

	while ( inBytes < finishedPtr )
	{
		outputVec = *(vector unsigned char *)inBytes;
		inBytes += 16;

		// Do the shift right first, so the vec_perm can be working at the same time as the next vec_sl.
		shiftedRight = vec_perm( vec_sr( outputVec, kShiftRight ), kZero, kPermuteShiftedRight );

		// Some bits need shifting to the left.
		// Combine the shifted left and shifted right bits.
		outputVec = vec_or( shiftedRight, vec_sl( outputVec, kShiftLeft ) );

		// Mash the relevant bytes together.
		outputVec = vec_perm( outputVec, kZero, kPermuteRelevantData );

		// Grab the relevant twelve bytes from the vector.
		// Note that to save some CPU cycles we copy three longs (at four bytes each).
		*(outboundData++) = ((unsigned long *)&outputVec)[ 0 ];
		*(outboundData++) = ((unsigned long *)&outputVec)[ 1 ];
		*(outboundData++) = ((unsigned long *)&outputVec)[ 2 ];
	} // end while loop

	// Specify how much data we created.
	*outDecodedLength = (unsigned char *)outboundData - outData;

	// Return how much of the incoming data we finished off.
	return result;
}

#endif // end compiling for AltiVec

static unsigned long local_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData )
{
	unsigned long		i;
	unsigned char		*outboundData = outData;
	unsigned char		ch;

	for ( i = 0; i < inBytesLength; i++ )
	{
		ch = inBytes[ i ];

		if ((ch >= 'A') && (ch <= 'Z'))
			*outboundData++ = ch - 'A';

		else if ((ch >= 'a') && (ch <= 'z'))
			*outboundData++ = ch - 'a' + 26;

		else if ((ch >= '0') && (ch <= '9'))
			*outboundData++ = ch - '0' + 52;

		else if (ch == '+')
			*outboundData++ = 62;

		else if (ch == '/')
			*outboundData++ = 63;

		else if (ch == '=')
		{	// no op -- put in our stop signal
			*outboundData++ = 255;
			break;
		}
	}

	// How much valid data did we end up with?
	return outboundData - outData;
}
