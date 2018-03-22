package reapp.core;

class ReContext {
	public var cycle = 1;
	public var time = Date.now().getTime();
	public var updating = 0;
	public var outdated = new Map<Int, Re<Dynamic>>();
	public var callbacks = new Array<Void->Void>();
	public var currId = 0;

	public function new() {}

	public inline function enterUpdate() {
		if (++updating == 1) {
			nextCycle();
		}
	}

	public inline function exitUpdate() {
		if (--updating < 1) {
			updating = 0;
			refresh();
		}
	}

	public inline function nextCycle() {
		if (++cycle > 1000000000) {
			// cycle 1 is reserved to absolute first cycle
			cycle = 2;
			time = Date.now().getTime();
		}
	}

	public function refresh() {
		// so side-effects don't start new cycles
		updating++;
		for (v in outdated) {
			v.value;
		}
		// restore correct value
		updating--;
		outdated = new Map<Int, Re<Dynamic>>();
		var cb: Void->Void;
		while ((cb = callbacks.pop()) != null) {
			cb();
		}
	}

}
