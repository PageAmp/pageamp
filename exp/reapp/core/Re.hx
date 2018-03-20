package reapp.core;

import reapp.util.ReLog;
import reapp.core.ReContext;

class Re<T> {
	public var id: Int;
	public var ctx: ReContext;
	public var cycle = 0;
	public var val: T;
	public var fun: Void->T;
	public var key: String;
	public var cb: Re<Dynamic>->T->T->Void;
	public var dsts: Map<Int, Re<Dynamic>>;

	public function new(ctx:ReContext, val:T, fun:Void->T) {
		this.id = ++ctx.currId;
		this.ctx = ctx;
		this.val = val;
		this.fun = fun;
	}

	public function addSrc(src:Re<Dynamic>): Re<T> {
		src.dsts == null ? src.dsts = new Map<Int, Re<Dynamic>>() : null;
		src.dsts.set(id, this);
		return this;
	}

	public function get(): T {
		if (cycle != ctx.cycle) {
			cycle = ctx.cycle;
			try {
				_set(fun != null ? fun() : val);
			} catch (e:Dynamic) {
				ReLog.value('$id: $e');
			}
		}
		return val;
	}

	public function set(v:T): T {
		if (v != val) {
			ctx.enterUpdate();
			_set(v);
			if (dsts != null) {
				for (dst in dsts) {
					ctx.outdated.set(dst.id, dst);
				}
			}
			ctx.exitUpdate();
		}
		return v;
	}

	inline function _set(v:T) {
		if (v != val || cycle == 1) {
			cb != null ? cb(this, val, v) : null;
			val = v;
		}
	}

}
