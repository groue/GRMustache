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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"

// Inspired by https://github.com/fotonauts/handlebars-objc/blob/master/src/handlebars-objc/astVisitors/HBAstEvaluationVisitor.m

typedef struct {
    CFIndex capacity;
    CFMutableStringRef string;
} GRMustacheBuffer;

static inline GRMustacheBuffer GRMustacheBufferCreate(CFIndex capacity)
{
    return (GRMustacheBuffer){
        .capacity = capacity,
        .string = CFStringCreateMutable(0, capacity),
    };
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAdjustCapacityForLength(GRMustacheBuffer *buffer, CFIndex length)
{
// Maximum CFIndex value based on http://www.fefe.de/intof.html
#define CFINDEX_HALF_MAX ((CFIndex)1 << (sizeof(CFIndex)*8-2))
#define CFINDEX_MAX (CFINDEX_HALF_MAX - 1 + CFINDEX_HALF_MAX)
    if (length > buffer->capacity) {
        CFIndex newCapacity = (buffer->capacity >= CFINDEX_MAX / 2) ? CFINDEX_MAX : MAX(length, buffer->capacity * 2); // Avoid CFIndex overflow
        CFMutableStringRef newBuffer = CFStringCreateMutableCopy(NULL, newCapacity, buffer->string);
        CFRelease(buffer->string);
        buffer->capacity = newCapacity;
        buffer->string = newBuffer;
    }
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAppendString(GRMustacheBuffer *buffer, CFStringRef string)
{
    CFIndex newLength = CFStringGetLength(buffer->string) + CFStringGetLength(string);
    GRMustacheBufferAdjustCapacityForLength(buffer, newLength);
    CFStringAppend(buffer->string, string);
} GRMUSTACHE_API_INTERNAL

static inline void GRMustacheBufferAppendCharacters(GRMustacheBuffer *buffer, const UniChar *chars, CFIndex numChars)
{
    CFIndex newLength = CFStringGetLength(buffer->string) + numChars;
    GRMustacheBufferAdjustCapacityForLength(buffer, newLength);
    CFStringAppendCharacters(buffer->string, chars, numChars);
} GRMUSTACHE_API_INTERNAL

static inline CFStringRef GRMustacheBufferGetStringAndRelease(GRMustacheBuffer *buffer)
{
    CFAutorelease(buffer->string);
    return buffer->string;
} GRMUSTACHE_API_INTERNAL

