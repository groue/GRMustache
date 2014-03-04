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
//
//
// The following macros are a trick to circumvent NSMutableString ignoring the
// capacity in initWithCapacity: initializer
//
// Instead, we use a CFMutableString with capped length. Those are optimized for real
// and will show much better performances. But they do not autogrow beyond the capped
// length.
//
// So we use a capped CF string until we reach its max size and then fallback to
// normal NSMutableString beyond.
//
// The key of course is to properly evaluate resulting string length.
//
// We use macros instead of a method call since benchmark gave much better results this
// way.
//
//

#define GR_CREATE_FASTER_MUTABLE_STRING(__buffer_name__, __estimated_length__) \
    BOOL __buffer_name__##usingCappedString = true; \
    NSInteger __buffer_name__##cappedLength = (__estimated_length__); \
    NSMutableString* __buffer_name__ = (NSMutableString*)CFStringCreateMutable(0, __buffer_name__##cappedLength)

#define GR_APPEND_STRING_TO_FASTER_MUTABLE_STRING(__buffer_name__, __string_to_append__) \
    if (__buffer_name__##usingCappedString && ([__buffer_name__ length] + [__string_to_append__ length] > __buffer_name__##cappedLength)) { \
        NSMutableString* __buffer_name__##newBuffer = [__buffer_name__ mutableCopy]; \
        [__buffer_name__ release]; \
        __buffer_name__ = __buffer_name__##newBuffer; \
        __buffer_name__##usingCappedString = false; \
    } \
    CFStringAppend((CFMutableStringRef)__buffer_name__, (CFStringRef)__string_to_append__)

#define GR_APPEND_CHARACTERS_TO_FASTER_MUTABLE_STRING(__buffer_name__, __chars_to_append__, __num_chars__) \
    if (__buffer_name__##usingCappedString && ([__buffer_name__ length] + __num_chars__ > __buffer_name__##cappedLength)) { \
        NSMutableString* __buffer_name__##newBuffer = [__buffer_name__ mutableCopy]; \
        [__buffer_name__ release]; \
        __buffer_name__ = __buffer_name__##newBuffer; \
        __buffer_name__##usingCappedString = false; \
    } \
    CFStringAppendCharacters((CFMutableStringRef)__buffer_name__, __chars_to_append__, __num_chars__)


extern NSString *GRMustacheTranslateCharacters(NSString *string, NSString **escapeForCharacter, size_t escapeForCharacterLength, NSUInteger capacity) GRMUSTACHE_API_INTERNAL;
extern NSString *GRMustacheTranslateHTMLCharacters(NSString *string) GRMUSTACHE_API_INTERNAL;
