package reapp2.core;

import reapp2.core.ReValue;

class ReApp extends ReNode {

	public function new() {
		super();
	}

	// =========================================================================
	// reactive context
	// =========================================================================
	public var ctxCycle = 0;
	public var cycleTime = 0.0;
	public var isRefreshing = false;
	public var stack: Array<ReValue<Dynamic>>;
	public var isApplying = false;

	public function refresh(node:ReNode) {
		stack = new Array<ReValue<Dynamic>>();
		clearDependencies(node);
		var wasRefreshing = isRefreshing;
		if (!wasRefreshing) {
			isRefreshing = true;
			nextCycle();
		}
		refreshNode(node);
		if (!wasRefreshing) {
			isRefreshing = false;
			pushNesting = 0;
			isApplying = true;
			callApplyList();
			isApplying = false;
			callPostApplyList();
			#if server
				applyDelayedSets();
			#end
		}
	}

	public inline function enterValuePush(): Int {
		var ret = ++pushNesting;
		return ret;
	}

	public inline function exitValuePush(): Void {
		var ret = --pushNesting;
		if (ret < 1) {
			pushNesting = 0;
			callApplyList();
		}
	}

	public function nextCycle() {
		cycleTime = Date.now().getTime();
		if (++ctxCycle > 1000000) {
			// cycle == 1 is reserved to first absolute refresh cycle
			ctxCycle = 2;
		}
	}

	public function addApplyItem(item:ReApplicable) {
		if (applyList == null) {
			applyList = [];
		}
		applyList.push(item);
	}

	public function addPostApplyItem(item:ReApplicable) {
		if (postApplyList == null) {
			postApplyList = [];
		}
		postApplyList.push(item);
	}

	// =========================================================================
	// private
	// =========================================================================
	var pushNesting: Int;
	var applyList: Array<ReApplicable>;
	var postApplyList: Array<ReApplicable>;

	function clearDependencies(node:ReNode) {
		for (v in node.getRefreshables()) {
			v.clearObservers();
		}
		for (child in node.getChildren()) {
			clearDependencies(cast child);
		}
	}

	function refreshNode(node:ReNode) {
		for (v in node.getRefreshables()) {
			v.get();
		}
		for (child in node.getChildren()) {
			refreshNode(cast child);
		}
	}

	inline function callApplyList() {
		if (applyList != null) {
			for (item in applyList) {
				item.apply();
			}
		}
		applyList = null;
	}

	inline function callPostApplyList() {
		if (postApplyList != null) {
			for (item in postApplyList) {
				item.apply();
			}
		}
		postApplyList = null;
	}

	function applyDelayedSets() {
		//TODO
	}

}