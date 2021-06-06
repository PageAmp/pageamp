package ub1.server.dom;

class HtmlNode {
	public static inline var ELEMENT_NODE = 1;
	public static inline var TEXT_NODE = 2;
	public static inline var COMMENT_NODE = 3;
	public var parent: HtmlElement;
	public var type: Int;
	public var i1: Int;
	public var i2: Int;
	public var origin: Int;

	public function new(parent:HtmlElement, type:Int, i1:Int, i2:Int, origin:Int) {
		parent != null ? parent.addChild(this) : null;
		this.type = type;
		this.i1 = i1;
		this.i2 = i2;
		this.origin = origin;
	}

	public function remove(): HtmlNode {
		if (parent != null) {
			parent.children.remove(this);
			parent = null;
		}
		return this;
	}

	public function toString() {
		var sb = new StringBuf();
		output(sb);
		return sb.toString();
	}

	public function output(sb:StringBuf): StringBuf {
		return sb;
	}

}
