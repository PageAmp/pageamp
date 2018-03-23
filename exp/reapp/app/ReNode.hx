package reapp.app;

import reapp.core.*;
import reapp.util.ReLog;
import ub1.util.BaseNode;

class ReNode extends BaseNode {
	public static var _ = new Array<ReNode>();
	public var id: Int;
	public var app: ReApp;
	public var nodeParent(get,null): ReNode;
	public var nodeChildren(get,null): Array<ReNode>;
	public var values: Map<String, Re<Dynamic>>;

	public function new(parent:ReNode,
	                    ?plug:String,
	                    ?index:Int,
	                    ?cb:Dynamic->Void) {
		app == null ? app = parent.app : null;
		id = _.length;
		_.push(this);
		super(parent, plug, index, cb);
	}

	public function add(name:String, value:Re<Dynamic>) {
		values == null ? values = new Map<String, Re<Dynamic>>() : null;
		values.set(name, value);
		value.ctx.outdated.set(value.id, value);
	}

	public function val(key:String): Re<Dynamic> {
		var ret = getValue(key);
		var node = nodeParent;
		while (ret == null && node != null) {
			ret = node.getValue(key);
			node = node.nodeParent;
		}
		return ret;
	}

//	public function get(key:String): Dynamic {
//		var value = lookup(key);
//		return (value != null ? value.get() : null);
//	}

//	public function set(key:String, val:Dynamic): Dynamic {
//		var value = lookup(key);
//		value != null ? value.set(val) : ReLog.value('$id.set($key) failed');
//		return val;
//	}

	public inline function get_nodeParent(): ReNode {
		return untyped parent;
	}

	public inline function get_nodeChildren(): Array<ReNode> {
		return untyped children;
	}

	// ========================================================================
	// private
	// ========================================================================

	inline function getValue(key:String): Re<Dynamic> {
		return (values != null ? values.get(key) : null);
	}

}
