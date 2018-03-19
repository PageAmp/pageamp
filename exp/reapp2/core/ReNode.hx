package reapp2.core;

class ReNode {
	public static var _ = new Array<ReNode>();
	public var app(default,null): ReApp;
	public var parent(default,null): ReNode;

	public function new() {}

	public function init(app:ReApp) {
		this.app = app;
	}

	public function addChild(child:ReNode): ReNode {
		children == null ? children = [] : null;
		children.push(child);
		child.wasAddedTo(this);
		return child;
	}

	public function getChildren(): Array<ReNode> {
		return (children != null ? children : noChildren);
	}

	public function addRefreshable(v:ReValue<Dynamic>) {
		if (refreshables == null) {
			refreshables = [];
		}
		refreshables.push(v);
	}

	public function removeRefreshable(v:ReValue<Dynamic>): Bool {
		return (refreshables != null ? refreshables.remove(v) : false);
	}

	public function getRefreshables(): Array<ReValue<Dynamic>> {
		return (refreshables != null ? refreshables : noRefreshables);
	}

	// =========================================================================
	// private
	// =========================================================================
	static var noChildren = new Array<ReNode>();
	var children: Array<ReNode>;
	static var noRefreshables = new Array<ReValue<Dynamic>>();
	var refreshables: Array<ReValue<Dynamic>>;

	function wasAddedTo(parent:ReNode): Void {
		this.parent = parent;
	}

}
