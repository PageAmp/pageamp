package reapp.core;

import reapp.core.ReContext.ReApplicable;
import ub1.util.DoubleLinkedItem;

class Re<T> implements ReApplicable {
	public var node: ReNode;
	public var ctx: ReContext;
	public var cycle = 0;
	public var val: T;
	public var fun: Void->T;
	public var next: ReApplicable;

	public function new(node:ReNode, val:T, fun:Void->T) {
		this.node = node;
		this.ctx = node.app.ctx;
		this.val = val;
		this.fun = fun;
	}

	public function get(): T {
		var ret = val;
		if (fun != null && cycle != ctx.cycle) {
			try {
				ret = val = fun();
			} catch (e:Dynamic) {
				ReLog.value(e);
			}
		}
		return ret;
	}

	public function set(v:T): T {
		if (++ctx.pushing == 1) {
//			ctx.
		}
		//TODO
		return v;
	}

	public function apply(): Void {
		//TODO
	}

}
