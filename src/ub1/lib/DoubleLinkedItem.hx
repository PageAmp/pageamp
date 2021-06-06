package ub1.lib;

class DoubleLinkedItem {
	public var prev(default, null):DoubleLinkedItem;
	public var next(default, null):DoubleLinkedItem;

	public function new() {}

	public function linkAfter(other:DoubleLinkedItem) {
		prev = other;
		if ((next = other.next) != null) {
			next.prev = this;
		}
		other.next = this;
		return this;
	}

	public function unlink() {
		if (prev != null) {
			prev.next = next;
		}
		if (next != null) {
			next.prev = prev;
		}
		return this;
	}
}
