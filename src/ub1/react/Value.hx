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

import hscript.Expr;
import hscript.Parser;
import ub1.Ub1Log;
import ub1.util.DoubleLinkedItem;
import ub1.util.Observable;

using ub1.util.ArrayTool;

// function arguments: userdata, nativeName, value
typedef ValueCallback = Dynamic->String->Dynamic->Void;

class Value extends DoubleLinkedItem {
	public static inline var MAX_DEPENDENCY_DEPTH = 100;
	public var name: String;
	public var nativeName: String;
	public var scope: ValueScope;
	public var uid: String;
	public var source: String;
	public var value: Dynamic;
	public var prevValue: Dynamic; // only valid during `cb` calls
	public var valueFn: Void->Dynamic;
	public var cycle: Int;
	public var userdata: Dynamic;
	public var cb: ValueCallback;
	public var first = true;

	public function new(value:Dynamic,
	                    name:Null<String>,
	                    nativeName:Null<String>,
	                    scope:ValueScope,
	                    ?userdata:Dynamic,
	                    ?cb:ValueCallback,
	                    callOnNull=true,
	                    ?valueFn:Void->Dynamic) {
		super();
		this.uid = scope.context.newUid();
		this.name = (name != null ? name : uid);
		this.nativeName = nativeName;
		this.scope = scope;
		this.userdata = userdata;
		reset(value, cb, callOnNull, valueFn);
		scope.addValue(this);
    }

	public function reset(value:Dynamic,
						  ?cb:ValueCallback,
						  callOnNull=true,
						  ?valueFn:Void->Dynamic) {
		this.valueFn = valueFn;
		source = null;
		exp = null;
		if (Std.is(value, String) && !ValueParser.isConstantExpression(value)) {
			this.source = value;
			var s = ValueParser.patchLF(value);
			if (ValueParser.FUNCTION_RE.match(s)) {
				var on = ValueParser.FUNCTION_RE.matched(2);
				var args = ValueParser.FUNCTION_RE.matched(3);
				var body = ValueParser.FUNCTION_RE.matched(4);
				on = ValueParser.unpatchLF(on);
				args = ValueParser.unpatchLF(args);
				body = ValueParser.unpatchLF(body);
				Ub1Log.value('new(): parsed function: [$on] ($args) -> {$body}');
				var keys = ~/\s*,\s*/.split(StringTools.trim(args));
				var e = null;
				try {
					e = parser.parseString(body);
				} catch (ex:Dynamic) {
					Ub1Log.value('new(): $ex');
				}
				if (e != null) {
					on == 'undefined' ? on = null : null;
					if (on != null) {
						// handler
						//this.source = "${" + on + "}";
						try {
							exp = parser.parseString(on);
						} catch (ex:Dynamic) {
							Ub1Log.value('new(): $ex');
						}
						cb = function(u:Dynamic, k:String, v:Dynamic) {
							Ub1Log.value('parsed handler activated with ' + v);
							var locals = new Map<String,Dynamic>();
							if (keys.length > 0) {
								locals.set(keys[0], v);
							}
							scope.context.interp.evaluateWith(e, scope, locals);
						}
					} else {
						// method
						this.value = Reflect.makeVarArgs(function(v:Array<Dynamic>) {
							var loc = new Map<String,Dynamic>();
							var count = 0, len = v.length;
							for (key in keys) {
								loc.set(key, (count < len ? v[count++] : null));
							}
							var res = scope.context.interp.evaluateWith(e, scope, loc);
							Ub1Log.value('parsed function result: $res');
							return res;
						});
					}
				}
			} else {
				var sb = new StringBuf();
				try {
					ValueParser.parse(value, sb);
					Ub1Log.value('new(): parsed expression: ${sb.toString()}');
					exp = parser.parseString(sb.toString());
					// Log.value('new(): compiled: $exp');
					// #if (debug && logValue)
					//     var s = new haxe.Serializer();
					//     s.serialize(exp);
					//     Log.value('new(): serialized: ${s.toString()}');
					// #end
				} catch (ex:Dynamic) {
					Ub1Log.value('new(): $ex');
				}
			}
		} else {
			this.value = value;
		}
		cycle = 0;
		this.cb = (callOnNull ? cb : function(u,n,v) if (v != null) cb(u,n,v));
	}

	public function dispose(): Value {
		scope.removeValue(this);
		return null;
	}

	public inline function isDynamic(): Bool {
		return (exp != null || valueFn != null);
	}

	public function get(): Dynamic {
		Ub1Log.value('${name}.get()');
		refresh();
		if (scope.context.isRefreshing) {
			// while refreshing, get() performs a "dependencies pull"
			var v:Value = scope.context.stack.peek();
			if (v != null) {
				// we're being pulled by a dynamic value: make it observe us
				addObserver(v.observer);
			}
		}
		return value;
	}

	public function get0() {cycle = 0; get();}
	public function get1(_) {cycle = 0; get();}
	public function get2(a, b) {cycle = 0; get();}
	public function get3(a, b, c) {cycle = 0; get();}
	public function evGet(ev) {
		if (ev != null) {
			cycle = 0; scope.set('ev', ev, false); get();
		}
	}

	public function set(v:Dynamic) {
		Ub1Log.value('${name}.set("$v")');
		var oldValue = value;
		if (_set(v) && !scope.context.isRefreshing) {
			// while not refreshing, set() performs a "dependencies push"
			var depth = scope.context.enterValuePush();
			if (depth == 1) {
				scope.context.nextCycle();
				cycle = scope.context.cycle;
			}
			if (depth <= MAX_DEPENDENCY_DEPTH && observable != null) {
				observable.notifyObservers(this, oldValue);
			}
			scope.context.exitValuePush();
		}
	}

	public function clearObservers() {
		if (observable != null) {
			observable.clearObservers();
		}
	}

	public inline function refresh(force=false) {
		Ub1Log.value('${name}.refresh()');
		if (cycle != scope.context.cycle || force) {
			cycle = scope.context.cycle;
			if (isDynamic()) {
				if (scope.context.isRefreshing) {
					//
					// By executing our expression, we might call other
					// values' get() methods: by pushing ourselves onto the stack
					// they can trace us as dependent on them and add us to their
					// list of observers (they "pull" our dependency).
					//
					// Outside of refresh cycles, observers are notified by the
					// set() method when a value changes, thus propagating the
					// change to all dependent values (it "pushes" the change).
					//
					scope.context.stack.push(this);
				}
				try {
					var v = null;
					if (valueFn != null) {
						v = valueFn();
					} else {
						v = scope.context.interp.evaluate(exp, scope);
					}
					Ub1Log.value('${name}.refresh(): $v');
					set(v);
				} catch (ex:Dynamic) {
					Ub1Log.value('${name}.refresh() error: $ex');
				}
				if (scope.context.isRefreshing) {
					scope.context.stack.pop();
				}
			} else if (first) {
			_set(value);
			}
		}
	}

	public inline function setObservableCallback(cb:Int->Void) {
		if (observable == null) {
			observable = new Observable();
		}
		observable.setCallback(cb);
	}

	// =========================================================================
	// public static
	// =========================================================================
	public static var parser = new Parser();

	public static inline function isConstantExpression(s:String): Bool {
		return ValueParser.isConstantExpression(s);
	}

	// =========================================================================
	// private
	// =========================================================================
	var observable: Observable;
	var exp: Expr;

	function _set(v:Dynamic): Bool {
		if (v != value || first) {
//			trace('${untyped scope.owner.e.className}.$name._set($v)');//tempdebug
			prevValue = value;
			value = v;
			first = false;
			cb != null ? cb(userdata, nativeName, v) : null;
			prevValue = null;
			return true;
		}
		return false;
	}

	// called only at `push` time (i.e. outside of refreshes)
	function observer(s:Value, oldValue:Dynamic) {
		Ub1Log.value('${name}.observer() old: "$oldValue", new: "${s.value}"');
		get();
	}

	// called only at `pull` time (i.e. during refreshes)
	inline function addObserver(o:Observer) {
		if (observable == null) {
			observable = new Observable();
		}
		observable.addObserver(o);
	}

}
