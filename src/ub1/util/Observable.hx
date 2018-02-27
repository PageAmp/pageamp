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

typedef Sender = Dynamic;
typedef Observer = Sender->Dynamic->Void;

// =============================================================================
// Observable
// =============================================================================

class Observable {
	var _observers: Array<Observer>;
	var _cb: Int->Void;

	public function new(?cb:Int->Void) {
		this._cb = cb;
	}

	public inline function setCallback(cb:Int->Void) {
		this._cb = cb;
	}

	public function addObserver(o:Observer) {
		if (_observers == null) {
			_observers = [];
		}
		if (_observers.indexOf(o) < 0) {
			_observers.push(o);
			if (_cb != null) {
				_cb(_observers.length);
			}
		}
	}

	public function removeObserver(o:Observer): Bool {
		var ret = false;
		if (_observers != null &&_observers.remove(o)) {
			if (_observers.length < 1) {
				_observers = null;
			}
			ret = true;
		}
		if (_cb != null) {
			_cb(_observers != null ? _observers.length : 0);
		}
		return ret;
	}

	public function clearObservers() {
		if (_observers != null) {
			while (_observers.length > 0) {
				_observers.pop();
			}
		}
		if (_cb != null) {
			_cb(_observers != null ? _observers.length : 0);
		}
	}

	public function hasObservers(): Bool {
		return (_observers != null ? _observers.length > 0 : false);
	}

	public function notifyObservers(sender:Sender, arg:Dynamic) {
		sender = (sender != null ? sender : this);
		if (_observers != null) {
//			for (o in _observers) {
//				o(sender, arg);
//			}
			var n = _observers.length - 1;
			for (i in 0..._observers.length) {
				_observers[n - i](sender, arg);
			}
		}
	}

}
