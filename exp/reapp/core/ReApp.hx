package reapp.core;

import reapp.core.IsoSource;
import ub1.util.PropertyTool;
import ub1.web.DomTools;
using ub1.util.PropertyTool;
using ub1.web.DomTools;

/**
* Represents the document's root element and provides the reactive context.
**/
class ReApp extends ReElement {

	public function new(doc:DomDocument, props:IsoElement, ?cb:Dynamic->Void) {
		this.doc = doc;
		super(null, props, cb);
		// so we set opacity to 1 after refresh
//		addApplyItem(this);
		refresh(this);
	}

	public function newDomElement(name:String,
	                              ?klass:String,
	                              ?props:Props,
	                              ?parent:DomElement,
	                              ?before:DomNode): DomElement {
		var ret:DomElement = doc.domCreateElement(name);
		klass != null ? ret.domSet('class', klass) : null;
		if (props != null) {
			for (key in props.keys()) {
				ret.domSet(key, props.get(key));
			}
		}
		if (parent != null) {
			parent.domAddChild(ret, before);
		}
		return ret;
	}

	public function newDomTextNode(text:String,
	                               ?parent:DomElement,
	                               ?before:DomNode): DomTextNode {
		var ret:DomTextNode = e.newTextNode(text);
		if (parent != null) {
			parent.domAddChild(ret, before);
		}
		return ret;
	}

//	override public function apply() {
//		super.apply();
//		op.set(1);
//	}

	// =========================================================================
	// private
	// =========================================================================
	var doc: DomDocument;

	override function init() {
		super.init();
//		head = doc.domGetHead();
//		var te = head.domGetElementsByTagName('title')[0];
//		te == null ? te = newElement('title', null, null, head) : null;
//		title = new Re<String>(this, props.get('title'), function(s) {
//			te.domSetInnerText(s);
//		});
	}

	// =========================================================================
	// reactive context
	// =========================================================================
	public var ctxCycle = 0;
	public var cycleTime = 0.0;
	public var isRefreshing = false;
	public var stack: Array<Re<Dynamic>>;
	public var isApplying = false;

	public function refresh(node:ReNode) {
		stack = new Array<Re<Dynamic>>();
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

	public function addApplyItem(item:Applicable) {
		if (applyList == null) {
			applyList = [];
		}
		applyList.push(item);
	}

	public function addPostApplyItem(item:Applicable) {
		if (postApplyList == null) {
			postApplyList = [];
		}
		postApplyList.push(item);
	}

	// =========================================================================
	// private
	// =========================================================================
	var pushNesting: Int;
	var applyList: Array<Applicable>;
	var postApplyList: Array<Applicable>;

	function clearDependencies(node:ReNode) {
		for (v in node.getRefreshables()) {
			v.clearObservers();
		}
		for (child in node.children) {
			clearDependencies(cast child);
		}
	}

	function refreshNode(node:ReNode) {
		for (v in node.getRefreshables()) {
			v.get();
		}
		for (child in node.children) {
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
