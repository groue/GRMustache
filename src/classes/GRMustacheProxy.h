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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"

/**
 * When thrown in the Mustache rendering engine, GRMustacheProxy instances have
 * the same behavior as another object, named their "delegate":
 *
 * Mustache variable tags and section tags, `{{name}}`, `{{#name}}`, and
 * `{{^name}}` render *exactly* the same whenever the `name` key resolves to an
 * object or to a proxy whose delegate is that object.
 *
 * You will generally subclass the GRMustacheProxy class in order to extend the
 * abilities of the delegate.
 *
 * For instance, you may define some extra keys: the `valueForKey:`
 * implementation of GRMustacheProxy looks for custom keys in the proxy before
 * forwarding the lookup in the delegate object. This is the technique used
 * by the PositionFilter filter in the "indexes" sample code (see
 * https://github.com/groue/GRMustache/blob/master/Guides/sample_code/indexes.md).
 *
 * GRMustacheProxies provides two initialization methods: `initWithDelegate:`,
 * and `init`. The `initWithDelegate:` sets the delegate of the proxy, which is
 * from now on ready to use. The `init` method does not set the delegate: you
 * must then provide your own implementation of the `loadDelegate` method, whose
 * responsability is to set the delegate of the proxy.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/proxies.md
 *
 * @see https://github.com/groue/GRMustache/blob/master/Guides/sample_code/indexes.md
 *
 * @since v5.5
 */
@interface GRMustacheProxy : NSObject {
@private
    id _delegate;
}

/**
 * The delegate object of the proxy.
 *
 * Proxies initialized with the `initWithDelegate:` method have a delegate
 * property whose value is the provided delegate object.
 *
 * Proxies initialized with the `init` method have no default value for their
 * delegate property. If this property is accessed, the proxy automatically
 * calls the `loadDelegate` method, and returns the resulting delegate.
 *
 * Delegate objects can not be nil: use [NSNull null] instead.
 *
 * @see init
 * @see initWithDelegate
 * @see loadDelegate
 *
 * @since v5.5
 */
@property (nonatomic, retain) id delegate AVAILABLE_GRMUSTACHE_VERSION_5_5_AND_LATER;

/**
 * Returns a newly initialized proxy without any delegate.
 *
 * In order to use this method, you must subclass GRMustacheProxy, and provide
 * your own implementation of the `loadDelegate` method.
 *
 * @return A newly initialized GRMustacheProxy object.
 *
 * @see initWithDelegate:
 * @see loadDelegate:
 * @see delegate
 *
 * @since v5.5
 */
- (id)init AVAILABLE_GRMUSTACHE_VERSION_5_5_AND_LATER;

/**
 * Returns a newly initialized proxy with the provided delegate.
 *
 * Delegate objects can not be nil: use [NSNull null] instead.
 *
 * @param delegate  The value for the delegate property.
 *
 * @return A newly initialized GRMustacheProxy object.
 *
 * @see delegate
 *
 * @since v5.5
 */
- (id)initWithDelegate:(id)delegate AVAILABLE_GRMUSTACHE_VERSION_5_5_AND_LATER;

/**
 * You should never call this method directly. The proxy calls this method when
 * its delegate property is requested but has not been set yet.
 *
 * Unless the proxy object has been initialized with the `initWithDelegate:`
 * method, you must override this method and assign any object to the delegate
 * property.
 *
 * Delegate objects can not be nil: use [NSNull null] instead.
 *
 * @see init
 * @see initWithDelegate
 * @see delegate
 *
 * @since v5.5
 */
- (void)loadDelegate AVAILABLE_GRMUSTACHE_VERSION_5_5_AND_LATER;

@end

