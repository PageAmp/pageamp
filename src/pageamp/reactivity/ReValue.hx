package pageamp.reactivity;

import pageamp.lib.Observable;
import pageamp.lib.DoubleLinkedItem;
import hscript.Expr;

using pageamp.lib.ArrayTools;

@:access(pageamp.react.ReScope)
class ReValue extends DoubleLinkedItem {
	public static inline var MAX_DEPENDENCY_DEPTH = 100;

	public var k(default,null): String;
	public var v(default,null): Dynamic;
	public var isFunction(default,null): Bool;

	public var userData: Dynamic;
	public var callback: (v:Dynamic, k:String, userData:Dynamic) -> Dynamic;
	public var valueFn: Void->Dynamic;

	public function new(scope:ReScope, k:String, v:Dynamic, ?handler:String,
						refreshable = true, handleFirst = true, parse = true) {
		super();
		this.scope = scope;
		this.k = k;
		this.isFunction = false;
		this.handleFirst = handleFirst;
		handler != null ? handlerExpr = ReParser.parse(handler) : null;
		if (parse && Std.is(v, String) && ReParser.isDynamic(v)) {
			expr = ReParser.parse(v);
			#if hscriptPos
			switch (expr.e) {
			#else
			switch (expr) {
			#end
				case EFunction(params, fexpr, name, _):
					isFunction = true;
					refreshable = false;
					//TODO: hscript functions should be executed in the context of the owner scope
					//(now they're executed in the context of the caller scope)
				default:
			}
			this.v = null;
		} else {
			refreshable = !Reflect.isFunction(v);
			this.v = v;
		}
		scope.addValue(k, this, refreshable);
	}

	public inline function setState(v:Dynamic) {
		this.v = v;
	}

	public inline function clearCycle() {
		cycle = 0;
	}

	public inline function isRefreshable() {
		return (prev != null);
	}

	public function get(pull = true): Dynamic {
		if (isRefreshable() || first) {
			refresh();
			if (pull && scope.context.isRefreshing) {
				// while refreshing, get() performs a "dependencies pull"
				var v:ReValue = scope.context.stack.arrayPeek();
				if (v != null) {
					// we're being pulled by a dynamic value: make it observe us
					addObserver(v.observer);
				}
			}
		}
		return v;
	}

	public function set(v:Dynamic, push=true): Dynamic {
		expr = null;
		valueFn = null;
		unlink();
		return _set(v, false, push);
	}

	public function _set(v:Dynamic, force=false, push=true): Dynamic {
		var oldValue = this.v;
		if (__set(v, force) && !scope.context.isRefreshing) {
			// while not refreshing, set() performs a "dependencies push"
			var depth = scope.context.enterValuePush();
			if (depth == 1) {
				//TODO: by incrementing cycle count we potentially cause
				//subsequent unneeded value refreshes: is there a better way?
				scope.context.nextCycle();
				cycle = scope.context.cycle;
			}
			if (push && depth <= MAX_DEPENDENCY_DEPTH && observable != null) {
				observable.notifyObservers(this, oldValue);
			}
			scope.context.exitValuePush();
		}
		return this.v;
	}

	#if !debug inline #end
	public function trigger() {
		#if client
		haxe.Timer.delay(() -> _set(v, true), 0);
		#end
	}

	#if utest
	public function toString() {
		return '$k: $v ($expr)';
	}
	#end

	// =========================================================================
	// private
	// =========================================================================
	var scope: ReScope;
	var expr: Expr;
	var handlerExpr: Expr;
	var handleFirst: Bool;
	var cycle = 0;
	var first = true;
	public var observable(default,null): Observable;

	#if !debug inline #end
	function refresh() {
		if (cycle != scope.context.cycle) {
			cycle = scope.context.cycle;
			if (expr != null || valueFn != null) {
				if (scope.context.isRefreshing) {
					scope.context.stack.push(this);
				}
				try {
					var v = null;
					if (valueFn != null) {
						v = valueFn();
					} else {
						v = scope.context.run(scope, expr);
					}
					_set(v);
				} catch (ex:Dynamic) {
					#if utest
						trace('ReValue($k).refresh() ERROR: ' + ex);
					#end
					// TODO
				}
				if (scope.context.isRefreshing) {
					scope.context.stack.pop();
				}
			} else if (first) {
				__set(v);
			}
		}
	}

	function __set(v:Dynamic, force=false):Bool {
		if (v != this.v || first || force) {
			var nTh = !first;
			first = false;
			callback != null ? v = callback(v, k, userData) : null;
			this.v = v;
			if (handlerExpr != null && (nTh || handleFirst))
				try {
					scope.context.run(scope, handlerExpr);
				} catch (ex:Dynamic) {
					// TODO
				}
			return true;
		}
		return false;
	}

	#if !debug inline #end
	function addObserver(o:Observer) {
		observable == null ? observable = new Observable() : null;
		observable.addObserver(o);
		if (observable.prev == null) {
			// add to context's observedList
			observable.linkAfter(scope.context.observedList);
		}
	}

	function observer(sender:Sender, v:Dynamic) {
		get();
	}
}
