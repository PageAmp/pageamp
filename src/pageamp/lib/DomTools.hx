package pageamp.lib;

#if client
	import js.Browser;
	import js.html.Document;
	import js.html.Element;
	import js.html.Event;
	import js.html.Node;
	import js.html.NodeList;
	using StringTools;

	typedef DomDocument = Document;
	typedef DomElement = Element;
	typedef DomNode = Node;
	typedef DomNodeList = NodeList;
	typedef DomTextNode = Node;
	typedef DomEvent = Event;
#else
	import pageamp.server.HtmlParser;
	import pageamp.server.dom.*;

	typedef DomDocument = HtmlDocument;
	typedef DomElement = HtmlElement;
	typedef DomNode = HtmlNode;
	typedef DomNodeList = Array<DomNode>;
	typedef DomTextNode = HtmlText;
	typedef DomEvent = Dynamic;
#end

class DomTools {

	#if !debug inline #end
	public static function domDefaultDoc():DomDocument {
		#if client
			return Browser.document;
		#else
			return HtmlParser.parse('<html><head></head><body></body></html>');
		#end
	}

	#if !debug inline #end
	public static function domGetRootElement(d:DomDocument) {
		#if client
			return d.documentElement; //d.firstElementChild;
		#else
			return d.getFirstElementChild();
		#end
	}

	#if !debug inline #end
	public static function domGetHead(doc:DomDocument): DomElement {
		#if client
			var r = doc.getElementsByTagName('head');
			return (r.length > 0 ? r.item(0) : null);
		#else
			var ret:DomElement = null;
			for (n in domGetRootElement(doc).children) {
				if (n.type == HtmlNode.ELEMENT_NODE && untyped n.name == 'HEAD') {
					ret = cast n;
					break;
				}
			}
			return ret;
		#end
	}

	#if !debug inline #end
	public static function domGetBody(doc:DomDocument): DomElement {
		#if client
			var r = doc.getElementsByTagName('body');
			return (r.length > 0 ? r.item(0) : null);
		#else
			var ret:DomElement = null;
			for (n in domGetRootElement(doc).children) {
				if (n.type == HtmlNode.ELEMENT_NODE && untyped n.name == 'BODY') {
					ret = cast n;
					break;
				}
			}
			return ret;
		#end
	}

	// public static function domGetElementById(e:DomElement, id:String) {
	// 	var ee = e.find('#$id');
	// 	return (ee.length > 0 ? ee[0] : null);
	// }

	#if !debug inline #end
	public static function domCreateElement(d:DomDocument, tagname:String) {
		#if client
			return d.createElement(tagname);
		#else
			return new HtmlElement(null, tagname, 0, 0, 0);
		#end
	}

	#if !debug inline #end
	public static function domCreateTextNode(d:DomDocument, text='') {
		#if client
			return d.createTextNode(text);
		#else
			return new HtmlText(null, text, 0, 0, 0);
		#end
	}

	#if !debug inline #end
	public static function domAddChild(e:DomElement,
									   n:DomNode,
									   ?before:DomNode): DomNode {
		#if client
			if (before != null) {
				e.insertBefore(n, before);
			} else {
				e.appendChild(n);
			}
		#else
			e.addChild(n, before);
		#end
		return n;
	}

	#if !debug inline #end
	public static function domRemove(n:DomNode) {
		#if client
			// we don't use n.remove() for backward compatibility (IE...)
			if (n.parentElement != null) {
				n.parentElement.removeChild(n);
			}
		#else
			n.remove();
			n.parent = null;
		#end
	}

	#if !debug inline #end
	public static function domParent(n:DomNode) {
		#if client
			return n.parentElement;
		#else
			return n.parent;
		#end
	}

	#if !debug inline #end
	public static function domFirstChild(e:DomElement): DomNode {
		#if client
			return e.firstChild;
		#else
			return e.children.length > 0 ? e.children[0] : null;
		#end
	}

	#if !debug inline #end
	public static function domChildrenCount(e:DomElement): Int {
		#if client
			return e.childNodes.length;
		#else
			return e.children.length;
		#end
	}

	#if !debug inline #end
	public static function domGetNthChild(e:DomElement, i:Int): DomNode {
		#if client
			return (i >= 0 && i < e.childNodes.length ? e.childNodes[i] : null);
		#else
			return (i >= 0 && i < e.children.length ? e.children[i] : null);
		#end
	}

	#if !debug inline #end
	public static function domFirstElementChild(e:DomElement): DomElement {
		#if client
			return e.firstElementChild;
		#else
			return e.getFirstElementChild();
		#end
	}

	#if !debug inline #end
	public static function domNextSibling(e:DomElement): DomNode {
		#if client
			return e.nextSibling;
		#else
			var p = e.parent;
			var i = p.children.indexOf(e);
			return (i >= 0 && i < (p.children.length - 1) ? cast p.children[i + 1] : null);
		#end
	}

	#if !debug inline #end
	public static function domNextElementSibling(e:DomElement): DomElement {
		#if client
			return e.nextElementSibling;
		#else
			// return e.getNextSiblingElement();
			var p = e.parent;
			var i = p.children.indexOf(e);
			if (i >= 0) {
				i++;
				while (i < p.children.length && p.children[i].type != HtmlNode.ELEMENT_NODE) {
					i++;
				}
			}
			return (i >= 0 && i < p.children.length ? cast p.children[i] : null);
		#end
	}

	public inline static function domAddEventHandler(e:DomElement,
													 type:String,
													 h:DomEvent->Void) {
		#if client
			e.addEventListener(type, h);
		#end
	}

	public inline static function domRemoveEventHandler(e:DomElement,
														type:String,
														h:DomEvent->Void) {
		#if client
			e.removeEventListener(type, h);
		#end
	}

	#if !debug inline #end
	public static function domGetTagname(e:DomElement): String {
		#if client
			return e.tagName;
		#else
			return e.name;
		#end
	}

	#if !debug inline #end
	public static function domSetNodeText(t:DomTextNode, v:Dynamic) {
		#if client
			var s = (v != null ? '$v' : '');
			if (~/(&\w{2,30};)/g.match(s)) {
				var e = t.ownerDocument.createElement('span');
				// we use `innerHTML` to convert html entities into plain text
				// as required by `textContent`
				e.innerHTML = s.replace('<', '&lt;').replace('>', '&gt;');
				t.textContent = e.firstChild.textContent;
			} else {
				t.textContent = s;
			}
		#else
			t.text = (v != null ? '' + v : '');
		#end
	}

	#if !debug inline #end
	public static function domGetNodeText(t:DomTextNode): String {
		#if client
			return t.nodeValue;
		#else
			return t.text;
		#end
	}

	#if !debug inline #end
	public static function domSetText(e:DomElement, v:Dynamic) {
		v = (v != null ? Std.string(v) : '');
		e.innerText = v;
	}

	#if !debug inline #end
	public static function domSetHtml(e:DomElement, v:Dynamic) {
		(v != null ? Std.string(v) : '');
		e.innerHTML = v;
	}

	#if !debug inline #end
	public static function domSet(e:DomElement, k:String, v:String) {
		#if client
			v != null ? e.setAttribute(k, v) : e.removeAttribute(k);
		#else
			e.setAttribute(k, v);
		#end
	}

	#if !debug inline #end
	public static function domSet2(e:DomElement, k:String, v:String) {
		#if client
			e.setAttribute(k, v);
		#else
			var a = e.setAttribute(k, '');
			a.value = v;
		#end
	}

	#if !debug inline #end
	public static function domGet(e:DomElement, key:String) {
		#if client
			return e.getAttribute(key);
		#else
			var a = e.attributes.get(key);
			return (a != null ? a.value : null);
		#end
	}

	#if !debug inline #end
	public static function domCheck(e:DomElement, key:String) {
		#if client
			return e.hasAttribute(key);
		#else
			return e.attributes.exists(key);
		#end
	}

	#if !debug inline #end
	public static function domAttributeNames(e:DomElement): Array<String> {
		#if client
			return []; //TODO
		#else
			return e.getAttributeNames();
		#end
	}

	#if !debug inline #end
	public static function domOuterHTML(e:DomElement) {
		#if client
			return e.outerHTML;
		#else
			return e.output(new StringBuf()).toString();
		#end
	}

}
