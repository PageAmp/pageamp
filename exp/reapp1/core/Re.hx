package reapp1.core;

#if feffects
	import ubl.reapp.core.ReApp.Appliable;
	import haxe.Timer;
	import feffects.Tween;
	import feffects.easing.Cubic;
#end
import ub1.Ub1Log;
import ub1.util.Observable;
using ub1.util.ArrayTool;

/**
* Reactive parametrized value.
**/
class Re<T> implements Applicable {
	public var value: T;

	public function new(node:ReNode,
	                    v:Dynamic,
	                    ?cb:T->Void,
	                    ?observersCb:Int->Void) {
		this.node = node;
		if (v != null) {
			if (Reflect.isFunction(v)) {
				// value-function
				fun = cast v;
				node != null ? node.addRefreshable(this) : null;
			} else {
				// value
				value = cast v;
				node.app.addApplyItem(this);
			}
		} else {
			value = null;
		}
		this.cb = cb;
		this.observersCb = observersCb;
	}

	public function get(): T {
		refresh();
		if (node.app.isRefreshing) {
			// while refreshing, get() performs a "dependencies pull"
			var v:Re<Dynamic> = node.app.stack.peek();
			if (v != null) {
				// we're being pulled by a dynamic value: make it observe us
				addObserver(v.observer);
			}
		}
		return value;
	}

	public function set(v:T, force=false) {
		var oldValue = value;
		if (_set(v) && !node.app.isRefreshing) {
			// while not refreshing, set() performs a "dependencies push"
			var depth = node.app.enterValuePush();
			if (depth == 1 || force) {
				node.app.nextCycle();
				cycle = node.app.ctxCycle;
			}
			if (depth <= MAX_DEPENDENCY_DEPTH && observable != null) {
				observable.notifyObservers(this, oldValue);
			}
			node.app.exitValuePush();
		}
	}

#if feffects
	public function animate(v:T,
	                        secs:Float,
	                        ?delay:Float,
	                        ?easing:Float->Float->Float->Float->Float,
	                        ?cb:Void->Void) {
		function start() {
			var v1 = toFloat(value);
			var v2 = toFloat(v);
			var s = (suffixRE.match(v + '') ? suffixRE.matched(1) : null);
			var e = (easing != null ? easing : Cubic.easeInOut);
			var t = new Tween(v1, v2, Std.int(secs * 1000), e);
			t.onUpdate(s != null ? function(v) {
				set(untyped (Math.round(v * 100) / 100) + s);
			} : function(v) {
				set(untyped Math.round(v * 100) / 100);
			});
			t.onFinish(function() {
				tween = null;
				cb != null ? cb() : null;
			});
			tween != null ? tween.stop() : null;
			tween = t;
			t.start();
		}
		if (delay != null) {
			Timer.delay(start, Std.int(delay * 1000));
		} else {
			start();
		}
	}
	#if !java static #end var suffixRE = ~/([^\d^-^\.]+)\s*$/;
	var tween: Tween;

	public static inline function toFloat(s:Dynamic, defval=0): Float {
		var ret = Std.parseFloat(Std.string(s != null ? s : 0));
		return (ret != Math.NaN ? ret : defval);
	}
#else
	public function animate(v:T,
	                        secs:Float,
	                        ?delay:Float,
	                        ?easing:Float->Float->Float->Float->Float,
	                        ?cb:Void->Void) {
		function f() {
			set(v);
			cb != null ? cb() : null;
		}
		if (delay != null) {
			haxe.Timer.delay(f, Std.int(delay * 1000));
		} else {
			f();
		}
	}
#end

	public inline function clearObservers() {
		if (observable != null) {
			observable.clearObservers();
		}
	}

	public function apply() {
		cb != null ? cb(value) : null;
	}

	// =========================================================================
	// private
	// =========================================================================
	static inline var MAX_DEPENDENCY_DEPTH = 100;
	var node: ReNode;
	var fun: Void->T;
	var cb: T->Void;
	var observersCb: Int->Void;
	var observable: Observable;
	var cycle = 0;
	var first = true;

	inline function refresh() {
		if (cycle != node.app.ctxCycle) {
			cycle = node.app.ctxCycle;
			if (fun != null) {
				if (node.app.isRefreshing) {
					node.app.stack.push(this);
				}
				try {
					var v:T = cast fun();
					set(v);
				} catch (err:Dynamic) {
					trace('ReValue refresh() ERROR: $err');
				}
				if (node.app.isRefreshing) {
					node.app.stack.pop();
				}
			} else if (first) {
				_set(value);
			}
		}
	}

	function _set(v:T): Bool {
		if (v != value || first) {
			value = v;
			first = false;
			cb != null ? cb(v) : null;
			return true;
		}
		return false;
	}

	// called only at `push` time (i.e. outside of refreshes)
	function observer(s:Re<Dynamic>, oldValue:Dynamic) {
		Ub1Log.value('observer() old: "$oldValue", new: "${s.value}"');
		get();
	}

	// called only at `pull` time (i.e. during refreshes)
	inline function addObserver(o:Observer) {
		if (observable == null) {
			observable = new Observable(observersCb);
		}
		observable.addObserver(o);
	}

}
