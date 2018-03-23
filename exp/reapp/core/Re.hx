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

	public function new(ctx:ReContext,
	                    val:T,
	                    fun:Void->T,
	                    ?name:String,
	                    ?cb:String->Re<T>->Void) {
		this.id = ++ctx.currId;
		this.ctx = ctx;
		this._val = val;
		this.fun = fun;
		cb != null ? cb(name, this) : null;
	}

	public function addSrc(src:Re<Dynamic>): Re<T> {
		src.dsts == null ? src.dsts = new Map<Int, Re<Dynamic>>() : null;
		src.dsts.set(id, this);
		return this;
	}

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

	#if !debug inline #end function _set(v:T) {
		if (v != _val || cycle == 1) {
			cb != null ? cb(this, _val, v) : null;
			_val = v;
		}
	}

}
