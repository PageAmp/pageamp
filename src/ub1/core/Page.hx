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

package ub1.core;

import ub1.util.PropertyTool.Props;
import ub1.web.DomTools.DomDocument;
import ub1.util.ArrayTool;
import ub1.util.Set;
#if server
	import haxe.Json;
#end
using ub1.util.PropertyTool;
using ub1.web.DomTools;
using StringTools;

class Page extends Element implements ServerPage {
	public var doc: DomDocument;
//	public static inline var LANG_ATTR = 'lang';
	public static inline var REDIRECT_ATTR = 'sysRedirect';
	public static inline var FSPATH_PROP = 'sysFSPath';
	public static inline var URI_PROP = 'sysURI';
	public var initializations(default,null) = new Set<String>();
	public var defines(default,null) = new Map<String, Define>();

	public function new(doc:DomDocument, props:Props, ?cb:Dynamic->Void) {
		this.doc = doc;
		props = props.set(Element.ELEMENT_PROP, doc.domGetBody());
		super(null, props, cb);
		set('sysInit', "");
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

	public inline function nextId(): Int {
		return currId++;
	}

	public inline function domGetByTagName(n:String): ArrayAccess<DomElement> {
		return doc.domRootElement().domGetElementsByTagName(n);
	}

	// =========================================================================
	// as ServerPage
	// =========================================================================

	public function toMarkup() {
		return doc.domRootElement().domMarkup();
	}

	public function output() {
#if php
		var redirect = get('sysRedirect');
		if (redirect != null) {
			php.Web.redirect(redirect);
		} else {
			addClient();
			php.Web.setHeader('Content-type', 'text/html');
			php.Lib.print(toMarkup());
		}
#end
	}

	// =========================================================================
	// isomorphism
	// =========================================================================
	public static inline var ISOID_PREFIX = 'ub1_';
	public static inline var ISOCHILDREN_PROP = Element.NODE_PREFIX + 'c';
	public static inline var ISOPROPS_ID = ISOID_PREFIX + 'props';

#if server
	//TODO: pre-parsed hscript should be passed to the client rather than source
	public function addClient() {
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
		createDomElement('script', {
			src:'/__ub1/client/bin/ub1.js',
			async: 'async',
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
		set('window', js.Browser.window).unlink();
		set(Element.EVENT_PREFIX + 'keydown',
			"${sysKeydown=sysKeydownPatch(ev)}").unlink();
		set('sysKeydownPatch', function(ev:Dynamic) {
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
		set('sysKeydown', null).unlink();
		set('Timer', haxe.Timer).unlink();
#else
		set('log', function(s) {}).unlink();
//		set('FileSystem', sys.FileSystem).unlink();
		set('sysReadDirectory', function(path:String): Array<String> {
			var root = sys.FileSystem.fullPath(props.get(Page.FSPATH_PROP));
			path = sys.FileSystem.fullPath(path);
			if (path.startsWith(root)) {
				return sys.FileSystem.readDirectory(path);
			} else {
				return [];
			}
		}).unlink();
		set('sysMail', php.Lib.mail);
#end
		set('Xml', Xml).unlink();
		set('sysCommandKey', commandKey).unlink();
	}

}
