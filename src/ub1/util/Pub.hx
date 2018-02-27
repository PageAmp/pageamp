/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.util;

typedef Sub<T> = T->Void;

/**
* A parametrized version of Observable.
**/
class Pub<T> {

	public function new() {}

	public function subscribe(s:Sub<T>) {
		subscribers == null ? subscribers = [] : null;
		subscribers.push(s);
	}

	public function unsubscribe(s:Sub<T>) {
		subscribers != null ? subscribers.remove(s) : null;
	}

	public function isSubscribed(s:Sub<T>) {
		return (subscribers != null ? subscribers.indexOf(s) >= 0 : false);
	}

	public function notify(v:T) {
		if (subscribers != null) {
			for (s in subscribers) {
				s(v);
			}
		}
	}

	// =========================================================================
	// private
	// =========================================================================
	var subscribers: Array<Sub<T>>;

}
