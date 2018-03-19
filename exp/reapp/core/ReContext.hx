package reapp.core;

import ub1.util.DoubleLinkedItem;

interface ReApplicable {
	public var next: ReApplicable;
	public function apply(): Void;
}

class ReContext {
	public var cycle = 1;
	public var time = Date.now().getTime();
	public var pushing = 0;
	public var pending = new RePendingList();

	public function new() {
	}

	public inline function enterPush() {
		if (++pushing == 1) {
			nextCycle();
		}
	}

	public inline function exitPush() {
		if (--pushing < 1) {
			pushing = 0;
			pending.apply();
		}
	}

	public inline function nextCycle() {
		if (++cycle > 1000000) {
			// cycle == 1 is reserved to absolute first cycle
			cycle = 2;
			time = Date.now().getTime();
		}
	}

}

class RePendingList implements ReApplicable {
	public var next: ReApplicable;
	public function new() {}
	public function apply(): Void {
		//TODO
	}
}