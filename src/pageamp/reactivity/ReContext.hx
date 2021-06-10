package pageamp.reactivity;

import pageamp.lib.DoubleLinkedItem;
import pageamp.lib.Observable;
import pageamp.lib.Set;
import hscript.Expr;

class ReContext {
	public var interp(default, null):ReInterp;
	public var cycle(default, null):Int;
	public var cycleTime(default, null):Float;
	public var isRefreshing(default, null):Bool;
	public var stack(default, null):Array<ReValue>;
	public var observedList(default, null):DoubleLinkedItem;
	public var applyList(default, null):DoubleLinkedItem;

	public function new(root:ReScope) {
		this.root = root;
		cycle = 0;
		cycleTime = 0;
		isRefreshing = false;
		interp = new ReInterp();
		stack = new Array<ReValue>();
		observedList = new DoubleLinkedItem();
		applyList = new DoubleLinkedItem();
		pushNesting = 0;
	}

	@:access(pageamp.reactivity.ReScope)
	public function refresh(?scope:ReScope, ?cb:Void->Void) {
		// clear dependencies
		if (scope == null) {
			// global refresh
			scope = root;
			clearDependencies();
		}

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
			#if !client
			applyDelayedSets();
			#end
		}
	}

	#if !debug
	inline
	#end
	public function clearDependencies() {
		while (observedList.next != null) {
			cast(observedList.next, Observable).clearObservers();
			observedList.next.unlink();
		}
	}

	#if !debug
	inline
	#end
	public function nextCycle() {
		cycleTime = Date.now().getTime();
		if (++cycle > 1000000) {
			cycle = 1;
		}
	}

	#if !debug
	inline
	#end
	public function enterValuePush():Int {
		var ret = ++pushNesting;
		return ret;
	}

	#if !debug
	inline
	#end
	public function exitValuePush():Void {
		var ret = --pushNesting;
		if (ret < 1) {
			pushNesting = 0;
			callApplyList();
		}
	}

	public function addApplier(a:Applier) {
		if (isRefreshing || pushNesting > 0) {
			a.unlink().linkAfter(applyList);
		} else {
			a.apply();
		}
	}

	#if !debug
	inline
	#end
	public function run(scope:ReScope, expr:Expr) {
		return interp.run(scope, expr);
	}

	// =========================================================================
	// private
	// =========================================================================
	var root(default, null):ReScope;
	var pushNesting = 0;

	#if !debug
	inline
	#end
	function callApplyList() {
		while (applyList.next != null) {
			cast(applyList.next.unlink(), Applier).apply();
		}
	}

	// =========================================================================
	// delayed sets (e.g. server-mode animation fallback support in pageamp.core.Element)
	// =========================================================================
	#if !client
	var delayedSets(default, null) = new Set<DelayedSet>();
	var delayedCalls(default, null) = new Array<Void->Void>();

	inline public function delayedSet(obj:ReScope,
									  key:String,
									  val:Dynamic,
									  ?cb:Void->Void) {
		if (isRefreshing) {
			delayedSets.add({
				obj: obj,
				key: key,
				val: val,
				cb: cb
			});
		} else {
			obj.set(key, val);
		}
	}

	inline public function delayedCall(cb:Void->Void) {
		delayedCalls.push(cb);
	}

	function applyDelayedSets() {
		for (d in delayedSets) {
			d.obj.set(d.key, d.val);
			d.cb != null ? d.cb() : null;
		}
		delayedSets = new Set<DelayedSet>();
		while (delayedCalls.length > 0) {
			delayedCalls.pop()();
		}
	}
	#end
}

#if !client
typedef DelayedSet = {
	obj:ReScope,
	key:String,
	val:Dynamic,
	?cb:Void->Void,
}
#end

class Applier extends DoubleLinkedItem {
	var cb:Void->Void;

	public function new(cb:Void->Void) {
		super();
		this.cb = cb;
	}

	public inline function apply() {
		cb();
	}
}
