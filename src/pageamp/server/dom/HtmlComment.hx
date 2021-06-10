package pageamp.server.dom;

using StringTools;

class HtmlComment extends HtmlNode {
	public var text: String;

	public function new(parent:HtmlElement, text:String, i1:Int, i2:Int, origin:Int) {
		super(parent, HtmlNode.COMMENT_NODE, i1, i2, origin);
		this.text = text;
	}

	override public function output(sb:StringBuf): StringBuf {
		sb.add(text != null ? text : '');
		return sb;
	}

}
