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

package ub1.react;

import ub1.util.DoubleLinkedItem;
#if !server
	import haxe.Timer;
#end
#if feffects
	import feffects.Tween;
	import feffects.easing.Cubic;
#end

class ValueScope {
	public var context(default,null): ValueContext;
	public var parent(default,null): ValueScope;
	public var children(get,null): Array<ValueScope>;
	public var uid(default,null): String;
	public var name(default,null): String;
	public var values(default,null): Map<String,Value>;
	public var refreshableList(default,null): DoubleLinkedItem;
	public var owner: Dynamic;
	public var newValueDelegate: Value->Void;
	//public var deferredApplyDelegate: ValueScope->Void;
	public var clonedScope = false;

	public function new(context:ValueContext,
	                    parent:ValueScope,
	                    uid:String,
	                    ?name:String,
	                    ?owner:Dynamic,
	                    ?before:ValueScope) {
		this.context = context;
		this.parent = parent;
		this.uid = uid;
		this.name = name;
		owner != null ? this.owner = owner : null;
		values = new Map<String,Value>();
		if (name != null && parent != null) {
			new Value(this, name, null, parent).unlink();
		}
		refreshableList = new DoubleLinkedItem();
		//init();
		if (parent != null) {
			parent._children == null ? parent._children = [] : null;
			var pos = (before != null ? parent._children.indexOf(before) : -1);
			pos = (pos < 0 ? parent._children.length : pos);
			parent._children.insert(pos, this);
		}
	}

	inline public function get_children(): Array<ValueScope> {
		return (_children != null ? _children : NO_CHILDREN);
	}

	public function removeChild(child:ValueScope) {
		for (c in child.children) {
			child.removeChild(c);
		}
		if (child.name != null) {
			removeValue(values.get(child.name));
		}
		var keys = new Array<String>();
		for (key in child.values.keys()) keys.push(key);
		for (key in keys) child.removeValue(child.values.get(key));
		children.remove(child);
		child.parent = null;
		child.wasRemoved();
	}

	public inline function addValue(v:Value) {
		values.set(v.name, v);
		v.linkAfter(refreshableList);
		newValueDelegate != null ? newValueDelegate(v) : null;
	}

	public function removeValue(v:Value) {
		if (v != null) {
			if (values.get(v.name) == v) {
				values.remove(v.name);
				v.unlink();
			}
		}
	}

	public function renameValue(name:String, v:Value) {
		if (v != null && v.name != name) {
			values.remove(v.name);
			values.set((v.name = name), v);
		}
	}

	public function reset() {
		owner = null;
		values = new Map<String,Value>();
	}

	public inline function get(key:String, pull=true): Dynamic {
		var value:Value = values.get(key);
		return (value != null ? (pull ? value.get() : value.value) : null);
	}

	public function lookup(key:String, pull=true): Dynamic {
		var ret = null;
		var scope = this;
		while (scope != null) {
			if (scope.exists(key)) {
				ret = scope.get(key, pull);
				break;
			}
			scope = scope.parent;
		}
		return ret;
	}

	public inline function exists(key:String) {
		return values.exists(key);
	}

	@:access(ub1.react.Value)
	public function set(key:String, val:Dynamic, push=true): Value {
		var ret:Value = values.get(key);
		if (ret != null) {
			ret.exp = null;
			ret.source = null;
			ret.valueFn = null;
			push ? ret.set(val) : ret.value = val;
		} else {
			var name = ~/(\-)/g.replace(key, '_');
			ret = new Value(val, name, key, this);
		}
		return ret;
	}

	public inline function setValueFn(key:String,
									  fn:Void->Dynamic,
									  ?val0:Dynamic): Value {
		var ret = set(key, val0);
		ret.valueFn = fn;
		return ret;
	}

	// =========================================================================
	// private
	// =========================================================================
	static var NO_CHILDREN = new Array<ValueScope>();
	var _children: Array<ValueScope>;

//	function init() {}

	function wasRemoved() {}

	function clearScope() {
		for (v in values.iterator()) {
			v.clearObservers();
		}
		for (child in children) {
			child.clearScope();
		}
	}

	function refreshScope() {
//		trace('=====');//tempdebug
//		for (v in values.iterator()) {
//			trace(v.name);//tempdebug
////			v.get();
//		}
		var v:Value = untyped refreshableList.next;
//		trace('-----');//tempdebug
		while (v != null) {
//			trace(v.name);//tempdebug
			v.get();
			v = untyped v.next;
		}
		for (child in children) {
			if (!child.clonedScope) {
				child.refreshScope();
			}
		}
	}

	// =========================================================================
	// animation
	// =========================================================================
#if feffects
	#if !java static #end var suffixRE = ~/([^\d^-^\.]+)\s*$/;
	var animations = new Map<String,ValueScopeAnimation>();
#end

	public function animate(key:String,
	                        val:Dynamic,
	                        secs=.0,
	                        delay=.0,
	                        ?cb:Void->Void,
	                        ?easing:Dynamic): Void {
		var scope = this;
		var s = scope;
		while (s != null) {
			if (s.exists(key)) {
				scope = s;
				break;
			}
			s = s.parent;
		}
#if feffects
		var animation:ValueScopeAnimation = animations.get(key);
		if (animation != null) {
			// prevent starting
			animation.delay = null;
			if (animation.tween != null) {
				animation.tween.stop();
			}
		}
		animation = {
			scope: scope,
			key: key,
			delay: function() startAnimation(animation),
			val: val,
			secs: secs,
			easing: (easing != null ? easing : feffects.easing.Cubic.easeInOut),
			tween: null,
			cb: cb
		};
		animations.set(key, animation);
		haxe.Timer.delay(animation.delay, Std.int(delay * 1000));
#else
		scope.delayedSet(key, val, delay, cb);
#end
	}

#if feffects
	static function startAnimation(a:ValueScopeAnimation) {
		var v1 = toFloat(a.scope.get(a.key, false));
		var v2 = toFloat(a.val);
		var suffix = (suffixRE.match(a.val + '') ? suffixRE.matched(1) : null);
		var t = new Tween(v1, v2, Std.int(a.secs * 1000), a.easing);
//		feffects.easing.Cubic.easeInOut);
		if (suffix != null) {
			t.onUpdate(function(e) {
				a.scope.set(a.key, (Math.round(e * 100) / 100) + suffix);
			});
		} else {
			t.onUpdate(function(e) {
				a.scope.set(a.key, Math.round(e * 100) / 100);
			});
		}
		t.onFinish(function() {
			a.scope.set(a.key, a.val);
			a.scope.animations.remove(a.key);
			a.cb != null ? a.cb() : null;
		});
		t.start();
		a.delay = null;
		a.tween = t;
	}
#end

	public static inline function toFloat(s:Dynamic, defval=0): Float {
		var ret = Std.parseFloat(Std.string(s));
		return (ret != Math.NaN ? ret : defval);
	}

	public static inline function toInt(s:Dynamic, defval=0): Int {
		var ret = Std.parseInt(Std.string(s));
		return (ret != null ? ret : defval);
	}

	public function delayedSet(key:String, val:Dynamic, secs=.0, ?cb:Void->Void) {
#if server
		var value:Value = values.get(key);
		if (value != null) {
			context.delayedSet(value.uid, this, key, val, cb);
		}
#else
		Timer.delay(function() {
			set(key, val);
			cb != null ? cb() : null;
		}, Std.int(secs * 1000));
#end
	}

	public function delay(cb:Void->Void, secs=.0) {
#if server
		context.delayedCall(cb);
#else
		Timer.delay(cb, Std.int(secs * 1000));
#end
	}

}

#if feffects
typedef ValueScopeAnimation = {
	scope: ValueScope,
	key: String,
	delay: Void->Void,
	val: Float,
	secs: Float,
	easing: Easing,
	tween: Tween,
	cb: Void->Void
}
#end
