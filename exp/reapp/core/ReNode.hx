package reapp.core;

import ub1.util.BaseNode;

class ReNode extends BaseNode {
	public static var _ = new Array<ReNode>();
	public var app: ReApp;
	public var nodeParent(get,null): ReNode;
	public var nodeChildren(get,null): Array<ReNode>;
	public var vars: Map<String, Re<Dynamic>>;

	public inline function get_nodeParent(): ReNode {
		return untyped parent;
	}

	public inline function get_nodeChildren(): Array<ReNode> {
		return untyped children;
	}

	public function get(key:String): Dynamic {
		var value = (vars != null ? vars.get(key) : null);
		return (value != null ? value.get() : null);
	}

	public function set(key:String, val:Dynamic): Dynamic {
		var value = lookupValue(key);
		if (value == null) {
			vars == null ? vars = new Map<String, Re<Dynamic>>() : null;

		}
		return val;
	}

	// ========================================================================
	// private
	// ========================================================================

	override function init() {
		super.init();
	}

	function lookupValue(key): Re<Dynamic> {
		var ret = getValue(key);
		var node = nodeParent;
		while (ret == null && node != null) {
			ret = node.getValue(key);
			node = node.nodeParent;
		}
		return ret;
	}

	inline function getValue(key): Re<Dynamic> {
		return (vars != null ? vars.get(key) : null);
	}

}
