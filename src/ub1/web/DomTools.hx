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

package ub1.web;

using StringTools;

#if (!client || test)
	import htmlparser.HtmlDocument;
	import htmlparser.HtmlNode;
	import htmlparser.HtmlNodeElement;
	import htmlparser.HtmlNodeText;
	import htmlparser.HtmlTools;
	import htmlparser.HtmlAttribute;
#end
#if !client
	typedef DomDocument = HtmlDocument;
	typedef DomElement = HtmlNodeElement;
	typedef DomNode = HtmlNode;
	typedef DomNodeList = Array<DomNode>;
	typedef DomTextNode = HtmlNodeText;
	typedef DomEvent = Dynamic;
#else
	import js.Browser;
	import js.html.Document;
	import js.html.Element;
	import js.html.Event;
	import js.html.Node;
	import js.html.NodeList;
	typedef DomDocument = Document;
	typedef DomElement = Element;
	typedef DomNode = Node;
	typedef DomNodeList = NodeList;
	typedef DomTextNode = Node;
	typedef DomEvent = Event;
#end

/**
    Unifies and abstracts client and server DOM.
*/
class DomTools {

	public static function removeMarkup(s:String) {
		s = ~/<.*?>/g.split(s).join('');
		s = ~/\s+/g.split(s).join(' ');
		s = StringTools.htmlUnescape(s);
		s = StringTools.replace(s, '&nbsp;', ' ');
		s = ~/&[a-z]{1,8};/g.split(s).join('');
		return s;
	}

	public inline static function domGetHead(doc:DomDocument): DomElement {
#if !client
//		var r = doc.find('head');
//		return (r.length > 0 ? r[0] : null);
		var ret:DomElement = null;
		for (n in domRootElement(doc).nodes) {
			if (Std.is(n, DomElement) && untyped n.name == 'head') {
				ret = untyped n;
				break;
			}
		}
		return ret;
#else
		var r = doc.getElementsByTagName('head');
		return (r.length > 0 ? r.item(0) : null);
#end
	}

	public inline static function domGetBody(doc:DomDocument): DomElement {
#if !client
//		var r = doc.find('body');
//		return (r.length > 0 ? r[0] : null);
		var ret:DomElement = null;
		for (n in domRootElement(doc).nodes) {
			if (Std.is(n, DomElement) && untyped n.name == 'body') {
				ret = untyped n;
			break;
			}
		}
		return ret;
#else
		var r = doc.getElementsByTagName('body');
		return (r.length > 0 ? r.item(0) : null);
#end
	}

	public inline static function defaultDocument(): DomDocument {
#if !client
		return new HtmlDocument("<html><head></head><body></body></html>");
#else
		return Browser.document;
#end
	}

	public inline static function domCreateElement(d:DomDocument, name:String): DomElement {
#if !client
		return new HtmlNodeElement(name, []);
#else
		return d.createElement(name);
#end
	}

	public inline static function domCreateTextNode(d:DomDocument, s:String): DomTextNode {
#if !client
		return new HtmlNodeText(s);
#else
		return d.createTextNode(s);
#end
	}

	public inline static function domCreateComment(d:DomDocument, s:String): DomTextNode {
#if !client
		return new HtmlNodeText('<!--${s}-->');
#else
		return d.createComment(s);
#end
	}

	public inline static function newElement(n:DomNode, name:String): DomElement {
#if !client
		return new HtmlNodeElement(name, []);
#else
		if (n != null) {
			return n.ownerDocument.createElement(name);
		} else {
			return js.Browser.document.createElement(name);
		}
#end
	}


	public inline static function newTextNode(n:DomNode, s:String): DomTextNode {
#if !client
		return new HtmlNodeText(s);
#else
		return n != null ?
				n.ownerDocument.createTextNode(s) :
				js.Browser.document.createTextNode(s);
#end
	}

	public inline static function newComment(n:DomNode, s:String): DomTextNode {
#if !client
		return new HtmlNodeText('<!--${s}-->');
#else
		return n != null ?
				n.ownerDocument.createComment(s) :
				js.Browser.document.createComment(s);
#end
	}

	public inline static function domGetParent(n:DomNode): DomElement {
#if !client
		return n.parent;
#else
		return n.parentElement;
#end
	}

	public inline static function domNextSibling(n:DomNode): DomNode {
#if !client
		//return n.getNextSiblingNode();
		//TODO: proporre fix sotto in HtmlParser lib
		if (n.parent == null) return null;
		var siblings = n.parent.nodes;
		var i = Lambda.indexOf(siblings, n);
		if (i < 0) return null; //bbmark if (i <= 0) return null;
		if (i+1 < siblings.length) return siblings[i+1];
		return null;
#else
		return n.nextSibling;
#end
	}

	public inline static function domPrevSibling(n:DomNode): DomNode {
#if !client
		//TODO: does this need a fix like above?
		return n.getPrevSiblingNode();
#else
		return n.previousSibling;
#end
	}

	public inline static function domRootElement(d:DomDocument): DomElement {
#if !client
		return d.children[0];
#else
		//return untyped d.firstElementChild; //d.firstChild;
		return d.documentElement;
#end
	}

	public inline static function domFirstChild(e:DomElement): DomNode {
#if !client
			return e.nodes.length > 0 ? e.nodes[0] : null;
#else
			return e.firstChild;
#end
	}

	public inline static function domFirstElementChild(e:DomElement): DomElement {
#if !client
		return e.children.length > 0 ? e.children[0] : null;
#else
		return e.firstElementChild;
#end
	}

	public inline static function domChildren(e:DomElement): DomNodeList {
#if !client
		return e.nodes;
#else
		return e.childNodes;
#end
	}

	public inline static function domIsElement(n:DomNode): Bool {
#if !client
		return Std.is(n, HtmlNodeElement);
#else
		return (n.nodeType == Node.ELEMENT_NODE);
#end
	}

	public inline static function domIsTextNode(n:DomNode): Bool {
#if !client
		return Std.is(n, HtmlNodeText);
#else
		return (n.nodeType == Node.TEXT_NODE);
#end
	}

	public inline static function domTagName(e:DomElement): String {
#if !client
		return e.name;
#else
		return e.tagName.toLowerCase();
#end
	}

	public inline static function domMarkup(e:DomElement): String {
#if !client
		//return e.toString();
		return htmlNodeElementToString(e);
#else
		return e.outerHTML;
#end
	}

#if (!client || test)
	// workaround for bug in HtmlAttribute.toString()
	static inline function htmlAttributeToString(a:HtmlAttribute) {
		return a.name + "=" + a.quote + HtmlTools.escape(a.value, "\r\n" + a.quote) + a.quote;
	}
	static function htmlNodeElementToString(e:HtmlNodeElement) {
		var sAttrs = new StringBuf();

		#if test
			var keys:Array<String> = [];
			var map = new Map<String,HtmlAttribute>();
			for (a in e.attributes) {
				keys.push(a.name);
				map.set(a.name, a);
			}
			ub1.util.ArrayTool.stringSort(keys);
			for (k in keys) {
				var a = map.get(k);
				sAttrs.add(" ");
				sAttrs.add(htmlAttributeToString(a));
			}
		#else
			for (a in e.attributes)
			{
				sAttrs.add(" ");
				sAttrs.add(htmlAttributeToString(a));
			}
		#end

		var innerBuf = new StringBuf();
		for (node in e.nodes)
		{
			if (Std.is(node, HtmlNodeElement)) {
				innerBuf.add(htmlNodeElementToString(cast node));
			} else {
				innerBuf.add(node.toString());
			}
		}
		var inner = innerBuf.toString();

		if (inner == "" && untyped e.isSelfClosing())
		{
			return "<" + e.name + sAttrs.toString() + " />";
		}

		return e.name != null && e.name != ""
		? "<" + e.name + sAttrs.toString() + ">" + inner + "</" + e.name + ">"
		: inner;
	}
#end

#if !client
	public static function domSetAttribute(e:HtmlNodeElement,
										   name:String,
										   value:String): HtmlAttribute {
		var nameLC = name.toLowerCase();

		for (a in e.attributes)
		{
			if (a.name.toLowerCase() == nameLC)
			{
				a.value = value;
				return a;
			}
		}

		var ret = new HtmlAttribute(name, value, '"');
		e.attributes.push(ret);
		return ret;
	}
#end

	public static function domTestMarkup(e:DomElement): String {
		var ret = '';
#if !client
		// server-side version adds auto-close convention " />"
		ret = ~/(\s\/>)/g.replace(domMarkup(e), '>');
#else
	#if test
		var ee:htmlparser.HtmlNodeElement = cast htmlparser.HtmlParser.run(e.outerHTML)[0];
		ret = ~/(\s\/>)/g.replace(htmlNodeElementToString(ee), '>');
	#else
		ret = domMarkup(e);
	#end
#end
		return TEXT_NORMALIZE_RE.replace(ret, ' ');
	}

	public inline static function domGetText(t:DomTextNode): String {
#if !client
		return TEXT_NORMALIZE_RE.replace(t.text, ' ');
#else
//		var s = t.nodeValue;
//		if (TEXT_SOURCE_RE.match(s)) {
//			s = TEXT_SOURCE_RE.matched(1);
//		}
//		return s;
		return TEXT_NORMALIZE_RE.replace(t.nodeValue, ' ');
#end
	}

	public inline static function domSetInnerHTML(t:DomElement, v:Dynamic) {
		v = (v == null ? '' : '$v');
#if !client
		t.innerHTML = v;
#else
		t.innerHTML = v;
#end
	}

	public inline static function domGetInnerHTML(t:DomElement) {
		return t.innerHTML;
	}

	public inline static function domSetInnerText(t:DomElement, v:Dynamic) {
		v = (v == null ? '' : '$v'.htmlEscape());
#if !client
		t.innerHTML = v;
#else
		t.innerHTML = v;
#end
	}

//	public inline static function domGetInnerText(t:DomElement): String {
//		#if !client
//			return t.innerText;
//		#else
//			return t.innerText; //may not work on some browsers
//		#end
//	}

	public inline static function domGetDirectText(t:DomElement): String {
		var sb:StringBuf = null;
		for (child in domChildren(t)) {
			if (domIsTextNode(child)) {
				var s = domGetText(untyped child);
				if (!~/^\s*$/.match(s)) {
					sb == null ? sb = new StringBuf() : null;
					sb.add(s);
				}
			}
		}
		return sb != null ? TEXT_NORMALIZE_RE.replace(sb.toString(), ' ') : null;
	}

	public inline static function domSetText(t:DomTextNode, v:String, ?src:String) {
#if !client
		//TODO: non dovrebbe fare l'escape di `v`?
		//t.text = (src != null ? "<!--$" + src + "$-->" + v : v);
		t.text = v;
#else
		t.nodeValue = v;
#end
	}

	public inline static function domSet(e:DomElement, key:String, val:String) {
		key == 'klass' ? key = 'class' : null;
#if !client
		val != null ? e.setAttribute(key, val) : e.removeAttribute(key);
#else
		try {
			val != null ? e.setAttribute(key, val) : e.removeAttribute(key);
		} catch (ex:Dynamic) {
			trace(ex);
		}
#end
	}

	public inline static function domGet(e:DomElement, key:String) {
#if !client
		return e.getAttribute(key);
#else
		return e.getAttribute(key);
#end
	}

	public inline static function domCheck(e:DomElement, key:String) {
#if !client
		return e.hasAttribute(key);
#else
		return e.hasAttribute(key);
#end
	}

	public inline static function domScanAttributes(e:DomElement,
	                                                cb:String->String->Void) {
#if !client
		for (a in e.attributes) {
			cb(a.name, a.value);
		}
#else
		for (i in 0...e.attributes.length) {
			var a = e.attributes.item(i);
			cb(a.name, a.value);
		}
#end
	}

    public inline static function domRemoveAttribute(e:DomElement, name:String) {
#if !client
		e.removeAttribute(name);
#else
		e.removeAttribute(name);
#end
	}

	public inline static function domParent(n:DomNode): DomElement {
#if !client
		return n.parent;
#else
		return n.parentElement;
#end
	}

	public inline static function domAddChild(e:DomElement, n:DomNode, ?before:DomNode) {
#if !client
		e.addChild(n, before);
#else
		if (before != null) {
			e.insertBefore(n, before);
		} else {
			e.appendChild(n);
		}
#end
	}

	public inline static function domRemoveChild(e:DomElement, n:DomNode) {
#if !client
		e.removeChild(n);
#else
		e.removeChild(n);
#end
	}

//	public inline static function domRemove(n:DomNode) {
	public static function domRemove(n:DomNode) {
#if !client
		n.remove();
#else
		if (n.parentElement != null) {
			n.parentElement.removeChild(n);
		}
#end
	}

	public inline static function domToString(doc:DomDocument): String {
#if !client
		return domRootElement(doc).toString();
#else
		//return doc.firstElementChild.outerHTML;
		return doc.documentElement.outerHTML;
#end
	}

	public inline static function domOwnerDocument(e:DomElement): DomDocument {
#if !client
		var ret = null;
		var p = e;
		while (p != null) {
			if (Std.is(p, HtmlDocument)) {
				ret = p;
				break;
			}
			p = p.parent;
		}
		return untyped ret;
#else
		return e.ownerDocument;
#end
	}

	public inline static function domFireEvent(e:DomElement, type:String): Bool {
#if !client
		return true;
#else
		if (untyped e.fireEvent != null) {
			untyped e.fireEvent(type);
			return true;
		}
		return false;
#end
	}

	public inline static function domCreateEvent(d:DomDocument, type:String) {
#if !client
		return null;
#else
		return d.createEvent(type);
#end
	}

	public inline static function domDispatchEvent(e:DomElement, ev:Dynamic) {
#if !client
#else
		ev != null ? e.dispatchEvent(ev) : null;
#end
	}

	public inline static function domAddEventHandler(e:DomElement,
	                                                 type:String,
	                                                 h:DomEvent->Void) {
#if !client
#else
		e.addEventListener(type, h);
#end
	}

	public inline static function domRemoveEventHandler(e:DomElement,
	                                                    type:String,
	                                                    h:DomEvent->Void) {
#if !client
#else
		e.removeEventListener(type, h);
#end
	}

//	public static function domFind(e:DomElement, q:String): DomNodeList {
//#if !client
//		return cast e.find(q);
//#else
//		return e.querySelectorAll(q);
//#end
//	}
//
//	public static function domFindOne(e:DomElement, q:String): DomNode {
//#if !client
//		return cast e.domFindOne(q);
//#else
//		return e.querySelectorAll(q);
//#end
//	}

#if test
	public static function testDoc(s:String,
	                               cb:DomDocument->TestDocCleanup->Void) {
		s = (s != null ? s : '<html><head></head><body></body></html>');
#if !client
		cb(new HtmlDocument(s), function() {});
#else
		var iframe = Browser.document.createIFrameElement();
		iframe.onload = function(ev) {
			// microsoft edge engine doesn't currently support iframe@srcdoc
			var r1 = new htmlparser.HtmlDocument(s).children[0];
			var r2 = iframe.contentDocument.documentElement;
			r2.innerHTML = r1.innerHTML;
			cb(iframe.contentDocument, function() {
				Browser.document.body.removeChild(iframe);
			});
		}
		iframe.style.display = 'none';
		iframe.srcdoc = s;
		Browser.document.body.appendChild(iframe);
#end
	}
#end

	public static function normalizeText(s:String): String {
		return TEXT_NORMALIZE_RE.replace(s, ' ');
	}

	public static function domGetComputedStyle(e:DomElement,
	                                           ?pseudoElt:String): Dynamic {
#if client
			return e.ownerDocument.defaultView.getComputedStyle(e, pseudoElt);
#else
			return '';
#end
	}

	public static function domOwnsClientPoint(e:DomElement, x:Int, y:Int): Bool {
#if client
		//TODO: scrollLeft, scrollTop
		return ((x >= e.clientLeft && x < (e.clientLeft + e.clientWidth))
			 && (y >= e.clientTop && y < (e.clientTop + e.clientHeight)));
#else
		return false;
#end
	}

	public static function domGetClientWidth(e:DomElement): Int {
#if client
		return e.clientWidth;
#else
		return 0;
#end
	}

	public static function domGetClientHeight(e:DomElement): Int {
#if client
		return e.clientHeight;
#else
		return 0;
#end
	}

	public static function domPreventDefault(ev:DomEvent) {
#if client
		ev.preventDefault();
#end
	}

	public static function domStopPropagation(ev:DomEvent) {
#if client
		ev.stopPropagation();
#end
	}

	public static function domGetElementById(doc:DomDocument,
	                                         id:String): DomElement {
#if client
		return cast doc.getElementById(id);
#else
		var ret = doc.find('#$id');
		return (ret.length > 0 ? ret[0] : null);
#end
	}

	public static function domGetElementsByTagName(e:DomElement,
	                                               n:String):
	ArrayAccess<DomElement> {
#if client
		return cast e.getElementsByTagName(n);
#else
		//TODO: test
		return cast e.find(n);
#end
	}

//	public static function domCancelDrag(doc:DomDocument) {
//#if client
//		// http://stackoverflow.com/a/12187302
//		untyped __js__("var keyboardEvent = doc.createEvent('KeyboardEvent');
//		var initMethod = typeof keyboardEvent.initKeyboardEvent != 'undefined' ? 'initKeyboardEvent' : 'initKeyEvent';
//
//		keyboardEvent[initMethod](
//			'keydown', // event type : keydown, keyup, keypress
//			true, // bubbles
//			true, // cancelable
//			window, // viewArg: should be window
//			false, // ctrlKeyArg
//			false, // altKeyArg
//			false, // shiftKeyArg
//			false, // metaKeyArg
//			27, // keyCodeArg : unsigned long the virtual key code, else 0
//			0 // charCodeArgs : unsigned long the Unicode character associated with the depressed key, else 0
//		);
//		doc.dispatchEvent(keyboardEvent);");
//#end
//	}

	// =========================================================================
	// private
	// =========================================================================
	static var TEXT_SOURCE_RE = ~/<!--$(.+?)$-->/;
	static var TEXT_NORMALIZE_RE = ~/(\s{2,})/g;

}

#if test
typedef TestDocCleanup = Void->Void;
#end
