package ub1.lib;

class BaseNode {
	public static inline var SELF_SLOT = 'self';
	public static inline var DEFAULT_SLOT = 'default';
	public static inline var CATCHALL_SLOT = 'catchall';

	public var logicalParent(default, null):BaseNode;
	public var baseParent(default, null):BaseNode;
	public var baseChildren(get, null):Array<BaseNode>;

	public function get_baseChildren()
		return _cdn != null ? _cdn : NOCHILDREN;

	public var before:BaseNode;

	public function new(parent:BaseNode, ?plug:String, ?index:Int, ?cb:Dynamic->Void) {
		this.baseRoot = ((this.baseParent = parent) != null ? parent.baseRoot : this);
		init();
		if (parent != null) {
			parent.addChild(this, plug, index);
		}
		cb != null ? cb(this) : null;
	}

	public function getSlot(name:String, ?cb:Dynamic->Void):BaseNode {
		var ret = null;

		//		if (slots != null && name != SELF_SLOT) {
		//			name == null ? name = DEFAULT_SLOT : null;
		//			ret = slots.get(name);
		//		}

		if (name == SELF_SLOT || slots == null) {
			ret = this;
		} else {
			name == null ? name = DEFAULT_SLOT : null;
			if ((ret = slots.get(name)) == null) {
				ret = slots.get(CATCHALL_SLOT);
			}
		}

		ret = (ret != null ? ret : this);
		cb != null ? cb(ret) : null;
		return ret;
	}

	public function addChild(child:BaseNode, ?plug:String, ?before:Int):BaseNode {
		var p = getSlot(plug);
		if (p != null) {
			if (p._cdn == null) {
				p._cdn = [];
			}
			var i, pos = (before != null ? before : p._cdn.length);
			if (this.before != null) {
				if ((i = this.before.getIndex()) >= 0) {
					i < pos ? pos = i : null;
				}
			}
			p._cdn.insert(pos, child);
			pos >= 0 ? pos++ : null;
			child.logicalParent = this;
			child.baseParent = p;
			child.wasAdded(this, p, pos);
		}
		return this;
	}

	public inline function remove() {
		baseParent != null ? baseParent.removeChild(this) : null;
	}

	public function removeChild(child:BaseNode):BaseNode {
		if (_cdn != null && _cdn.remove(child)) {
			var logicalParent = child.logicalParent;
			child.logicalParent = null;
			child.baseParent = null;
			child.wasRemoved(logicalParent, this);
		}
		return child;
	}

	public function removeChildren():BaseNode {
		while (hasChildren()) {
			removeChild(_cdn[_cdn.length - 1]);
		}
		return this;
	}

	public inline function hasChildren():Bool {
		return (_cdn != null && _cdn.length > 0);
	}

	//	public function directChild(child:BaseNode): BaseNode {
	//		while (child != null && child.parent != this) {
	//			child = child.parent;
	//		}
	//		return child;
	//	}

	public function getPrevSibling():BaseNode {
		var ret:BaseNode = null;
		if (baseParent != null) {
			var i = baseParent.baseChildren.indexOf(this);
			i > 0 ? ret = baseParent.baseChildren[i - 1] : null;
		}
		return ret;
	}

	public function getNextSibling():BaseNode {
		var ret:BaseNode = null;
		if (baseParent != null) {
			var len = baseParent.baseChildren.length;
			var i = baseParent.baseChildren.indexOf(this);
			i >= 0 && i < (len - 1) ? ret = baseParent.baseChildren[i + 1] : null;
		} return ret;
	}

	public function getIndex():Int {
		var ret = (baseParent != null ? baseParent.baseChildren.indexOf(this) : -1);
		return ret;
	}

#if utest
	public function assertEquals(bn:BaseNode, ?msg:String) {
		if (baseChildren.length != bn.baseChildren.length) {
			trace('');
		}
		utest.Assert.equals(baseChildren.length,
							bn.baseChildren.length,
							'BaseNode.hx: $msg: different child count'
							+ ' ${baseChildren.length} !='
							+ ' ${bn.baseChildren.length}');
		if (baseChildren.length == bn.baseChildren.length) {
			for (i in 0...ub1.lib.ArrayTools.arrayLength(baseChildren)) {
				baseChildren[i].assertEquals(bn.baseChildren[i]);
			}
		}
	}
#end

	// =========================================================================
	// private
	// =========================================================================
	static var NOCHILDREN:Array<BaseNode> = [];

	var _cdn:Array<BaseNode>;
	var baseRoot:BaseNode;
	var slots:Map<String, BaseNode>;

	function init() {}

	function wasAdded(logicalParent:BaseNode, parent:BaseNode, ?before:Int) {}

	function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {}
}
