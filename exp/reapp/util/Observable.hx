package reapp.util;

typedef Sender = Dynamic;
typedef Observer = Sender->Dynamic->Void;

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
			var n = _observers.length - 1;
			for (i in 0..._observers.length) {
				_observers[n - i](sender, arg);
			}
		}
	}

}
