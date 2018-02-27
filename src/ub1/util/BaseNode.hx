/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.util;

class BaseNode {
	public static inline var SELF_SLOT = 'self';
	public static inline var DEFAULT_SLOT = 'default';

	public var logicalParent(default,null): BaseNode;
	public var parent(default,null): BaseNode;
	public var children(get,null): Array<BaseNode>;
	public function get_children() return _children != null ? _children : NOCHN;
	public var before: BaseNode;

	public function new(parent:BaseNode,
	                    ?slot:String,
	                    ?index:Int,
	                    ?cb:Dynamic->Void) {
		this.root = ((this.parent = parent) != null ? parent.root : this);
		init();
		if (parent != null) {
			parent.addChild(this, slot, index);
		}
		cb != null ? cb(this) : null;
	}

	public function getSlot(name:String, ?cb:Dynamic->Void): BaseNode {
		var ret = null;
		if (slots != null && name != SELF_SLOT) {
			name == null ? name = DEFAULT_SLOT : null;
			ret = slots.get(name);
		}
		ret = (ret != null ? ret : this);
		cb != null ? cb(ret) : null;
		return ret;
	}

	public function addChild(child:BaseNode,
	                         ?slot:String,
	                         ?before:Int): BaseNode {
		var p = getSlot(slot);
		if (p._children == null) {
			p._children = [];
		}
		var i, pos = (before != null ? before : p._children.length);
		if (this.before != null) {
			if ((i = this.before.getIndex()) >= 0) {
				i < pos ? pos = i : null;
			}
		}
		p._children.insert(pos, child);
		pos >= 0 ? pos++ : null;
		child.logicalParent = this;
		child.parent = p;
		child.wasAdded(this, p, pos);
		return this;
	}

	public function removeChild(child:BaseNode): BaseNode {
		if (_children != null && _children.remove(child)) {
			var logicalParent = child.logicalParent;
			child.logicalParent = null;
			child.parent = null;
			child.wasRemoved(logicalParent, this);
		}
		return child;
	}

	public function removeChildren(): BaseNode {
		while (hasChildren()) {
			removeChild(_children[_children.length - 1]);
		}
		return this;
	}

	public inline function hasChildren(): Bool {
		return (_children != null && _children.length > 0);
	}

//	public function directChild(child:BaseNode): BaseNode {
//		while (child != null && child.parent != this) {
//			child = child.parent;
//		}
//		return child;
//	}

	public function getPrevSibling(): BaseNode {
		var ret:BaseNode = null;
		if (parent != null) {
			var i = parent.children.indexOf(this);
			i > 0 ? ret = parent.children[i - 1] : null;
		}
		return ret;
	}

	public function getNextSibling(): BaseNode {
		var ret:BaseNode = null;
		if (parent != null) {
			var len = parent.children.length;
			var i = parent.children.indexOf(this);
			i >= 0 && i < (len - 1) ? ret = parent.children[i + 1] : null;
		}
		return ret;
	}

	public function getIndex(): Int {
		var ret = (parent != null ? parent.children.indexOf(this) : -1);
		return ret;
	}

	// =========================================================================
	// private
	// =========================================================================
	static var NOCHN: Array<BaseNode> = [];
	var _children: Array<BaseNode>;
	var root: BaseNode;
	var slots: Map<String, BaseNode>;

	function init() {}

	function wasAdded(logicalParent:BaseNode,
	                  parent:BaseNode,
	                  ?before:Int) {}

	function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {}

}