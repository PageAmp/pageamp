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

class ValueContext {
	public static inline var DID_UPDATE_EVENT = 1;
	public static inline var UID_PREFIX = '__uid__';
	public var main(get,null): ValueScope;
	public var cycle(default,null) = 0;
	public var cycleTime(default,null) = 0.0;
	public var isRefreshing: Bool;
	public var uidCount: Int;
	public var scopeUidCount: Int;
	public var interp: ValueInterp;
	public var stack: Array<Value>;
	public var applyList(default,null): Array<Void->Void>;
	public var owner: Dynamic;

	public function new(?owner:Dynamic) {
		reset(owner);
	}

	public function dispose(): ValueContext {
		// nop
		return null;
	}

	public inline function get_main() {
		return interp.mainScope;
	}

	public function setGlobal(key:String, val:Dynamic) {
		interp.variables.set(key, val);
	}

	public function getGlobal(key:String): Dynamic {
		return interp.variables.get(key);
	}

	public function newScope(?parent:ValueScope,
	                         ?id:String,
	                         ?name:String,
	                         ?owner:Dynamic): ValueScope {
		var ret = new ValueScope(this, parent, newScopeUid(), owner);
		if (id != null) {
			main.set(id, ret);
			parent != null && name == null ? parent.set(id, ret) : null;
		} else if (parent != null && name != null) {
			parent.set(name, ret);
		}
		return ret;
	}

	@:access(ub1.react.ValueScope)
	public function refresh(?scope:ValueScope, ?cb:Void->Void) {
		scope == null ? scope = main : null;

		// clear dependencies
		scope.clearScope();

		var wasRefreshing = isRefreshing;
		if (!wasRefreshing) {
			isRefreshing = true;
			nextCycle();
		}

		// refresh and create dependencies
		if (cb != null) {
			cb();
		} else {
			scope.refreshScope();
		}

		if (!wasRefreshing) {
			isRefreshing = false;
			pushNesting = 0;
			callApplyList();
			#if server
				applyDelayedSets();
			#end
		}
	}

	public inline function nextCycle() {
		cycleTime = Date.now().getTime();
		if (++cycle > 1000000) {
			cycle = 1;
		}
	}

	public function reset(?owner:Dynamic) {
		cycle = 0;
		isRefreshing = false;
		scopeUidCount = uidCount = 0;
		if (interp == null) {
			var id = newScopeUid();
			interp = new ValueInterp(new ValueScope(this, null, id, null, owner));
		} else {
			interp.reset();
		}
		stack = new Array<Value>();
		pushNesting = 0;
		applyList = [];
		this.owner = owner;
	}

		public function newScopeUid(): String {
			var ret = '__scope__${scopeUidCount++}';
			return ret;
		}

	public inline function newUid(): String {
		return '${UID_PREFIX}${uidCount++}';
	}

	public inline function enterValuePush(): Int {
		var ret = ++pushNesting;
		return ret;
	}

	public inline function exitValuePush(): Void {
		var ret = --pushNesting;
		if (ret < 1) {
			pushNesting = 0;
			callApplyList();
		}
	}

	public function addApply(cb:Void->Void) {
		if (isRefreshing || pushNesting > 0) {
			applyList.push(cb);
		} else {
			cb();
		}
	}

	// =========================================================================
	// private
	// =========================================================================
	var pushNesting: Int;

	inline function callApplyList() {
		while (applyList.length > 0) {
			applyList.pop()();
		}
	}

	// =========================================================================
	// delayed sets (e.g. server-mode animation fallback support in ubr.Node)
	// =========================================================================
#if server
	var delayedSets(default,null) = new Map<String,DelayedSet>();
	var delayedCalls(default,null) = new Array<Void->Void>();

	inline public function delayedSet(uid:String,
	                                  obj:ValueScope,
	                                  key:String,
	                                  val:Dynamic,
	                                  ?cb:Void->Void) {
		if (isRefreshing) {
			delayedSets.set(uid, {obj:obj, key:key, val:val, cb:cb});
		} else {
			obj.set(key, val);
		}
	}

	inline public function delayedCall(cb:Void->Void) {
		delayedCalls.push(cb);
	}

	function applyDelayedSets() {
		for (uid in delayedSets.keys()) {
			var d:DelayedSet = delayedSets.get(uid);
			d.obj.set(d.key, d.val);
			d.cb != null ? d.cb() : null;
		}
		delayedSets = new Map<String,DelayedSet>();
		while (delayedCalls.length > 0) {
			delayedCalls.pop()();
		}
	}

#end
}

#if server
typedef DelayedSet = {
	obj: ValueScope,
	key: String,
	val: Dynamic,
	?cb: Void->Void,
}
#end
