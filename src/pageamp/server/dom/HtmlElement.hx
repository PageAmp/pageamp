package pageamp.server.dom;

using pageamp.lib.ArrayTools;
using pageamp.lib.PropertyTools;
using pageamp.lib.Set;
using StringTools;

@:access(pageamp.server.dom.HtmlAttribute)
class HtmlElement extends HtmlNode {
	public var name: String;
	public var attributes: Map<String, HtmlAttribute>;
	public var children: Array<HtmlNode>;
	public var selfclose: Bool;
	public var innerHTML(get,set): String;
	public inline function get_innerHTML() return getInnerHTML();
	public inline function set_innerHTML(s:String) return setInnerHTML(s);
	public var innerText(null,set): String;
	public inline function set_innerText(s:String) return setInnerText(s);

	public function new(parent:HtmlElement, name:String, i1:Int, i2:Int, origin:Int) {
		super(parent, HtmlNode.ELEMENT_NODE, i1, i2, origin);
		this.name = name != null ? name.toUpperCase() : null;
		this.attributes = new Map();
		this.children = [];
		this.selfclose = false;
	}

	public function addChild(child:HtmlNode, ?before:HtmlNode) {
		child.parent = this;
		var i = before != null ? children.indexOf(before) : -1;
		if (i < 0) {
			children.push(child);
		} else {
			children.insert(i, child);
		}
	}

	public function setAttribute(name:String, ?value:String, ?quote:String,
								 ?i1:Int, ?i2:Int, ?origin:Int): HtmlAttribute {
		var a = attributes.get(name);
		if (a == null) {
			if (value != null) {
				attributes.set(
					name,
					(a = new HtmlAttribute(name, value, quote, i1, i2, origin))
				);
			}
		} else {
			if (value == null) {
				attributes.remove(name);
			} else {
				a.value = value;
				quote != null ? a.quote = quote : null;
				i1 != null ? a.i1 = i1 : null;
				i2 != null ? a.i2 = i2 : null;
				origin != null ? a.origin = origin : null;
			}
		}
		return a;
	}

	public function getAttribute(name:String): String {
		var a = attributes.get(name);
		return (a != null ? a.value : null);
	}

	public function getAttributeNames(): Array<String> {
		var ret = new Array<String>();
		for (key in attributes.keys()) ret.push(key);
		return ret;
	}

	public inline function isVoid(): Bool {
		return VOID_ELEMENTS.exists(name);
	}

	public function getFirstElementChild(): HtmlElement {
		for (n in children) {
			if (n.type == HtmlNode.ELEMENT_NODE) {
				return cast n;
			}
		}
		return null;
	}

	public function getInnerHTML() {
		var sb = new StringBuf();
		for (n in children) {
			n.output(sb);
		}
		return sb.toString();
	}

	public function setInnerHTML(s:String): String {
		while (children.length > 0) children[children.length - 1].remove();
		var doc = HtmlParser.parse(s);
		for (c in doc.children) {
			addChild(c);
		}
		return s;
	}

	public function setInnerText(s:String): String {
		if (children.length == 1 && children[0].type == HtmlNode.TEXT_NODE) {
			cast(children[0], HtmlText).text = s;
		} else {
			while (children.length > 0) children[children.length - 1].remove();
			new HtmlText(this, s, 0, 0, 0);
		}
		return s;
	}

	override public function output(sb:StringBuf): StringBuf {
		var name = this.name.toLowerCase();
		sb.add('<'); sb.add(name);
	#if utest
		var keys = getAttributeNames().arraySort();
		for (key in keys) {
	#else
		for (key in attributes.keys()) {
	#end
			var a = attributes.get(key);
			sb.add(' '); sb.add(key);
			if (a.value != '' || a.quote != null) {
				var q = a.quote == "'" ? "'" : '"';
				sb.add('='); sb.add(q);
				sb.add(escape(a.value, "\r\n" + q));
				sb.add(q);
			}
		}
		if (isVoid()) {
			sb.add(' />');
		} else {
			sb.add('>');
			for (n in children) {
				n.output(sb);
			}
			sb.add('</'); sb.add(name); sb.add('>');
		}
		return sb;
	}

	// ===================================================================================
	// private
	// ===================================================================================
	// http://xahlee.info/js/html5_non-closing_tag.html
	public static var VOID_ELEMENTS:Props = {
		AREA:true, BASE:true, BR:true, COL:true, EMBED:true, HR:true, IMG:true,
		INPUT:true, LINK:true, META:true, PARAM:true, SOURCE:true, TRACK:true, WBR:true,
		// obsolete
		COMMAND:true, KEYGEN:true, MENUITEM:true,
	};

	// from haxe-htmlparser: htmlparser.HtmlTools.hx
	static function escape(text:String, chars=""): String {
		var r = text; //text.split("&").join("&amp;");
		r = r.split("<").join("&lt;");
		r = r.split(">").join("&gt;");
		if (chars.indexOf('"') >= 0) r = r.split('"').join("&quot;");
		if (chars.indexOf("'") >= 0) r = r.split("'").join("&apos;");
		if (chars.indexOf(" ") >= 0) r = r.split(" ").join("&nbsp;");
		if (chars.indexOf("\n") >= 0) r = r.split("\n").join("&#xA;");
		if (chars.indexOf("\r") >= 0) r = r.split("\r").join("&#xD;");
		return r;
	}

}
