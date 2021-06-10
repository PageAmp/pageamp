package pageamp.server.dom;

using StringTools;

class HtmlText extends HtmlNode {
	public var escape: Bool;
	public var text: String;

	public function new(parent:HtmlElement, text:String, i1:Int, i2:Int, origin:Int, escape=true) {
		super(parent, HtmlNode.TEXT_NODE, i1, i2, origin);
		this.escape = escape;
		this.text = (escape ? text.htmlUnescape() : text);
	}

	override public function output(sb:StringBuf): StringBuf {
		sb.add(text != null ? (escape ? text.htmlEscape() : text) : '');
		return sb;
	}

}
