package reapp.util;

interface LinkedItem {
	public var next: LinkedItem;
}

class LinkedList implements LinkedItem {
	public var next: LinkedItem;

	public function new() {
		next = untyped this;
	}

	public inline function push(i:LinkedItem) {
		i.next = next; next = i;
	}

	public inline function pop(): LinkedItem {
		var ret = null;
		if (next != this) {
			ret = next; next = ret.next; ret.next = null;
		}
		return ret;
	}
}
