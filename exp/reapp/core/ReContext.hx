package reapp.core;

class ReContext {
	public var cycle = 1;
	public var time = Date.now().getTime();
	public var updating = 0;
	public var schedule = new Map<Int, Re<Dynamic>>();
	public var nextId = 0;

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
		if (++cycle > 1000000) {
			// cycle == 1 is reserved to absolute first cycle
			cycle = 2;
			time = Date.now().getTime();
		}
	}

	public function refresh() {
		for (value in schedule) {
			value.get();
		}
		schedule = new Map<Int, Re<Dynamic>>();
	}

}
