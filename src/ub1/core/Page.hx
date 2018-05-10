/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package ub1.core;

import ub1.react.Value;
import ub1.util.PropertyTool.Props;
import ub1.web.DomTools.DomDocument;
import ub1.util.Set;
#if client
	import js.Browser;
	import js.html.ResizeObserver;
#end
#if server
	import haxe.Json;
	import haxe.Resource;
	import ub1.util.ArrayTool;
#end
import ub1.util.PropertyTool;
using ub1.util.PropertyTool;
import ub1.web.DomTools;
using ub1.web.DomTools;
using StringTools;

class Page extends Element implements ServerPage {
	public var doc: DomDocument;
	public static inline var LANG_ATTR = Element.ATTRIBUTE_PREFIX + 'lang';
	public static inline var REDIRECT_ATTR = 'pageRedirect';
	public static inline var FSPATH_PROP = 'pageFSPath';
	public static inline var URI_PROP = 'pageURI';
	public var initializations(default,null) = new Set<String>();
	public var defines(default,null) = new Map<String, Define>();

	public function new(doc:DomDocument, props:Props, ?cb:Dynamic->Void) {
		this.doc = doc;
		props = props.set(Element.ELEMENT_PROP, doc.domGetBody());
		super(null, props, cb);
		set('pageInit', "");
		scope.context.refresh();
	}

	public function createDomElement(name:String,
	                                 ?props:Props,
	                                 ?parent:DomElement,
	                                 ?before:DomNode): DomElement {
		var ret = doc.domCreateElement(name);
		for (k in props.keys()) {
			var v = props.get(k);
			v != null ? ret.domSet(k, Std.string(v)) : null;
		}
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	public function createDomTextNode(text:String,
	                                  ?parent:DomElement,
	                                  ?before:DomNode): DomTextNode {
		var ret = doc.domCreateTextNode(text);
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	public function createDomComment(text:String,
	                                 ?parent:DomElement,
	                                 ?before:DomNode): DomTextNode {
		var ret = doc.domCreateComment(text);
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	#if !debug inline #end
	public function nextId(): Int {
		return currId++;
	}

	#if !debug inline #end
	public function domGetByTagName(n:String): ArrayAccess<DomElement> {
		return doc.domRootElement().domGetElementsByTagName(n);
	}

	// =========================================================================
	// ResizeObserver
	// =========================================================================

#if resizeMonitor
	public static inline var RESIZE_OBSERVER = 'ub1ResizeObserver';
	public static inline var RESIZE_CLASS = 'ub1-resize';
	public static inline var RESIZE_SM = 'SM';
	public static inline var RESIZE_MD = 'MD';
	public static inline var RESIZE_LG = 'LG';
	public static inline var RESIZE_XL = 'XL';
#if client
	var ro: ResizeObserver = PropertyTool.get(Browser.window, RESIZE_OBSERVER);

	public inline function observeResize(e:DomElement) {
		trace('observeResize() - ${ro != null}');//tempdebug
		ro != null ? ro.observe(e) : null;
	}
#end
#end

	// =========================================================================
	// as ServerPage
	// =========================================================================

	public function toMarkup() {
		return doc.domRootElement().domMarkup();
	}

	public function output() {
#if php
		var redirect = get('pageRedirect');
		if (redirect != null) {
			php.Web.redirect(redirect);
		} else {
			var ua = getUserAgent();
			addClient(ua);
			php.Web.setHeader('Content-type', 'text/html');
			php.Lib.println('<!DOCTYPE html>');
			php.Lib.print(toMarkup());
		}
#end
	}

#if php
	public static function getUserAgent() : String {
		var ua = null;
		try {
			ua = untyped __php__("$_SERVER['HTTP_USER_AGENT']");
		} catch (ignored:Dynamic) {}
		return ua;
	}
#end

	// =========================================================================
	// isomorphism
	// =========================================================================
	public static inline var ISOID_PREFIX = 'ub1_';
	public static inline var ISOCHILDREN_PROP = Element.NODE_PREFIX + 'c';
	public static inline var ISOPROPS_ID = ISOID_PREFIX + 'props';

#if server
	//TODO: pre-parsed hscript should be passed to the client rather than source
	public function addClient(ua:String) {
		function getChildren(props:Props): Array<Props> {
			var children:Array<Props> = props.get(Page.ISOCHILDREN_PROP);
			if (children == null) {
				props.set(Page.ISOCHILDREN_PROP, children = []);
			}
			return children;
		}
		var f = null;
		f = function(props:Props, t:Element) {
			var children1:Array<Props> = null;
			var scope = t.getScope();
			if (scope == null) {
				return;
			}
			//var extScope = (t.parent != null ? t.nodeParent.getScope() : null);
			if (scope.owner == t) {
				children1 == null ? children1 = getChildren(props) : null;
				t.e.domSet('id', ISOID_PREFIX + t.id);
				t.props.set(Element.ID_PROP, t.id);
				t.props.remove(Element.ELEMENT_PROP);
				t.props.remove(Element.TAG_PROP);

				//TODO: client shouldn't reload dynamic data we already store here
				if (Std.is(t, Dataset)) {
					var s = t.get(Dataset.DOC_VALUE, false);
					s != null ? t.e.domSetInnerHTML(s) : null;
					t.props.remove(Dataset.XML_PROP);
					t.props.remove(Dataset.JSON_PROP);
				}

				children1.push(t.props);
				props = t.props;
			}
			var children2:Array<Props> = null;
			for (c in t.children) {
				if (Std.is(c, Element)) {
					f(props, untyped c);
				} else if (Std.is(c, Text)) {
					var text:Text = untyped c;
					var n:DomTextNode = untyped text.getDomNode();
					if (text.value != null) {
						var p = n.domGetParent();
						var s = ISOID_PREFIX + text.id;
						var m = createDomElement('b', {
							id: ISOID_PREFIX + text.id
						}, p, n);
						var tp:Props = {};
						tp.set(Element.ID_PROP, text.id);
						tp.set(Text.TEXT_PROP, text.value.source);
						children2 == null ? children2 = getChildren(props) : null;
						children2.push(tp);
					}
				}
			}
		}
		var props:Props = {};
		f(props, this);
		var root = ArrayTool.peek(props.get(Page.ISOCHILDREN_PROP));
		var s = (root != null ? Json.stringify(root) : '{}');
		var body = doc.domGetBody();
		s = ISOPROPS_ID + ' = ' + s + ';';
		createDomElement('script', null, body).domSetInnerHTML(s);
		createDomTextNode('\n', body);
#if resizeMonitor
		var chromeVersion = .0;
		~/(Chrome\/\d+(\.\d+)?)/.map(ua, function(re:EReg) {
			var p = re.matchedPos();
			var s = ua.substr(p.pos, p.len).split('/')[1];
			chromeVersion = Std.parseFloat(s);
			return '';
		});
		if (chromeVersion < 64) {
			var src = Resource.getString("resize-observer.js");
			createDomElement('script', null, body).domSetInnerHTML(src);
			createDomTextNode('\n', body);
		}

		// https://philipwalton.com/articles/responsive-components-a-solution-to-the-container-queries-problem/
		s = ~/(\s{2,})/g.replace("(function() {
			var breakpoints = {SM:384, MD:576, LG:768, XL:960};
			function f(entries) {
				entries.forEach(function(entry) {
					var ub1 = entry.target.ub1;
					if (ub1) {
						ub1.set('resizeWidth', entry.contentRect.width);
						ub1.set('resizeHeight', entry.contentRect.height);
					}
					Object.keys(breakpoints).forEach(function(breakpoint) {
						var minWidth = breakpoints[breakpoint];
						if (entry.contentRect.width >= minWidth) {
							entry.target.classList.add(breakpoint);
						} else {
							entry.target.classList.remove(breakpoint);
						}
					});
				});
			}
			var ro = (ResizeObserver != null ? new ResizeObserver(f) : null);
			if (ro != null) {
				var l = document.querySelectorAll('[class~="+ RESIZE_CLASS +"]');
				for (var e, i = 0; e = l[i]; i++) ro.observe(e);
			}
			"+ RESIZE_OBSERVER +" = ro;
		})();", ' ');
		createDomElement('script', null, body).domSetInnerHTML(s);
		createDomTextNode('\n', body);
#end
		createDomElement('script', {
#if release
			src:'/__ub1/client/bin/ub1.min.js',
			async: 'async',
#else
			src:'/__ub1/client/bin/ub1.js',
#end
		}, body);
		createDomTextNode('\n', body);
	}
#end

	// =========================================================================
	// private
	// =========================================================================
	var currId = 1;

	override function init() {
		var commandKey = 'CTRL';
		super.init();
#if client
		var isMac = ~/^(Mac)/i.match(js.Browser.navigator.platform);
		isMac ? commandKey = 'CMD' : null;
		set('log', function(s) trace(s)).unlink();
		set('window', Browser.window).unlink();
		set(Element.EVENT_PREFIX + 'keydown',
			"${pageKeydown=pageKeydownPatch(ev)}").unlink();
		set('pageKeydownPatch', function(ev:Dynamic) {
			if (ev != null) {
				ev.name = ((isMac ? ev.metaKey : ev.ctrlKey) ? 'CMD-' : '')
						+ ((isMac ? ev.ctrlKey : ev.metaKey) ? 'META-' : '')
						+ (ev.altKey ? 'ALT-' : '')
						+ (ev.shiftKey ? 'SHIFT-' : '')
						+ String.fromCharCode(ev.which);
			} else {
				ev = {name:null, preventDefault:function() {}};
			}
			return ev;
		}).unlink();
		set('pageKeydown', null).unlink();
		set('Timer', haxe.Timer).unlink();
#else
		set('log', function(s) {}).unlink();
//		set('FileSystem', sys.FileSystem).unlink();
		set('pageReadDirectory', function(path:String): Array<String> {
			var root = sys.FileSystem.fullPath(props.get(Page.FSPATH_PROP));
			path = sys.FileSystem.fullPath(path);
			if (path.startsWith(root)) {
				return sys.FileSystem.readDirectory(path);
			} else {
				return [];
			}
		}).unlink();
		set('pageMail', php.Lib.mail);
#end
		set('Xml', Xml).unlink();
		set('pageCommandKey', commandKey).unlink();
	}

	override function isDynamicValue(k:String, v:Dynamic): Bool {
		return k == LANG_ATTR ? true : super.isDynamicValue(k, v);
	}

	override function newValueDelegate(v:Value) {
		if (v.name == LANG_ATTR) {
			v.nativeName = v.name.substr(Element.ATTRIBUTE_PREFIX.length);
			v.userdata = doc.domRootElement();
			v.cb = attributeValueCB;
			v.cb(v.userdata, v.nativeName, v.value);
		} else {
			super.newValueDelegate(v);
		}
	}

}
