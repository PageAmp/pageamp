package reapp.core;

import reapp.util.ReLog;
import reapp.core.ReContext;

class Re<T> {
	public var id: Int;
	public var ctx: ReContext;
	public var cycle = 0;
	public var fun: Void->T;
	public var value(get,set): T;

	public var key: String;
	public var cb: Re<Dynamic>->T->T->Void;

	public var dsts: Map<Int, Re<Dynamic>>;

	public function new(ctx:ReContext, val:Dynamic, ?cb:Re<T>->Void) {
		this.id = ++ctx.currId;
		this.ctx = ctx;
		cb != null ? cb(this) : null;
	}

	public function addSrc(src:Re<Dynamic>): Re<T> {
		src.dsts == null ? src.dsts = new Map<Int, Re<Dynamic>>() : null;
		src.dsts.set(id, this);
		return this;
	}

//	public function get(): T {
//		if (cycle != ctx.cycle) {
//			cycle = ctx.cycle;
//			try {
//				_set(fun != null ? fun() : _val);
//			} catch (e:Dynamic) {
//				ReLog.value('$id: $e');
//			}
//		}
//		return _val;
//	}
//
//	public function set(v:T): T {
//		if (v != _val) {
//			ctx.enterUpdate();
//			_set(v);
//			if (dsts != null) {
//				for (dst in dsts) {
//					ctx.outdated.set(dst.id, dst);
//				}
//			}
//			ctx.exitUpdate();
//		}
//		return v;
//	}

	public function get_value(): T {
		if (cycle != ctx.cycle) {
			cycle = ctx.cycle;
			try {
				_set(fun != null ? fun() : _val);
			} catch (e:Dynamic) {
				ReLog.value('$id get_val(): $e');
			}
		}
		return _val;
	}

	public function set_value(v:T): T {
		if (v != _val) {
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

	// =========================================================================
	// private
	// =========================================================================
	var _val: T;

	inline function _set(v:T) {
		if (v != _val || cycle == 1) {
			cb != null ? cb(this, _val, v) : null;
			_val = v;
		}
	}

}
