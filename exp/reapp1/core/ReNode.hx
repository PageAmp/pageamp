package reapp1.core;

import ub1.util.BaseNode;

class ReNode extends BaseNode {
	public var app(get,null): ReApp;
	public inline function get_app(): ReApp return cast root;
	public var reParent(get,null): ReNode;
	public inline function get_reParent(): ReNode return cast parent;

	public function new(parent:ReNode, ?cb:Dynamic->Void) {
		super(parent, cb);
	}

	public function addRefreshable(v:Re<Dynamic>) {
		if (refreshables == null) {
			refreshables = [];
		}
		refreshables.push(v);
	}

	public function removeRefreshable(v:Re<Dynamic>): Bool {
		return (refreshables != null ? refreshables.remove(v) : false);
	}

	public function getRefreshables(): Array<Re<Dynamic>> {
		return (refreshables != null ? refreshables : noRefreshables);
	}

	// =========================================================================
	// private
	// =========================================================================
	static var noRefreshables = new Array<Re<Dynamic>>();
	var refreshables: Array<Re<Dynamic>>;

}
