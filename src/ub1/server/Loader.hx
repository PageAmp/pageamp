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

package ub1.server;

import ub1.util.PropertyTool;
import ub1.web.DomTools;
import ub1.util.Url;
import htmlparser.*;
import ub1.core.*;
using StringTools;
using ub1.util.PropertyTool;
using ub1.web.DomTools;

//TODO: verifica e logging errori
class Loader {

	public static function loadPage(src:HtmlDocument,
	                                ?dst:DomDocument,
	                                ?rootpath:String,
	                                ?uri:String): ServerPage {
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, rootpath, uri);
		return ret;
	}

	public static function loadPage2(text:String, ?dst:DomDocument): ServerPage {
		text = normalizeText(text);
		var src = PreprocessorParser.parseDoc(text);
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, null, null);
		return ret;
	}

	public static function normalizeText(s:String, lineSep='\n'): String {
		var re2 = ~/\n/;
		var ret = ~/(\s{2,})/g.map(s, function(re:EReg): String {
			var p = re.matchedPos();
			return (re2.matchSub(s, p.pos, p.len) ? lineSep : ' ');
		});
		return ret.trim();
	}

	// =========================================================================
	// private
	// =========================================================================

	static function loadRoot(doc:DomDocument,
	                         src:HtmlDocument,
	                         rootpath:String,
	                         uri='/'): Page {
		var e = src.children[0];
		var props = loadProps(e, false);
		props.set(Page.FSPATH_PROP, rootpath);
		props.set(Page.URI_PROP, new Url(uri));
		var ret = new Page(doc, props, function(p:Page) {
			loadChildren(p, e);
		});
		return ret;
	}

	static function loadElement(p:Element, e:HtmlNodeElement): Element {
		var ret:Element;
		var props = loadProps(e);
		var def = p.page.defines.get(e.name);
		ret = switch (e.name) {
			case 'head': new Head(p, props);
			case 'body': new Body(p, props);
			case Dataset.TAGNAME: new Dataset(p, loadDataProps(e, props));
			case Define.TAGNAME: new Define(p, loadDefineProps(e, props));
			default: new Element(p, props);
		}
		loadChildren(ret, e);
		return ret;
	}

	static function loadProps(e:HtmlNodeElement, tagname=true): Props {
		var props:Props = {};
		tagname ? props.set(Element.TAG_PROP, e.name) : null;
		for (a in e.attributes) {
			var key = a.name;
			var val = a.value;
			if (key.startsWith(Element.CLASS_PREFIX) && val == null) {
				val = '1';
			}
			if (key.startsWith(':')) {
				key = key.substr(1);
			} else if (!~/^\w_/.match(key)) {
				key = Element.ATTRIBUTE_PREFIX + key;
			}
			props.set(key, val);
		}
		return props;
	}

	static function loadChildren(p:Element, e:HtmlNodeElement) {
		for (n in e.nodes) {
			if (Std.is(n, HtmlNodeElement)) {
				loadElement(p, untyped n);
			} else if (Std.is(n, HtmlNodeText)) {
				loadText(p, untyped n);
			}
		}
	}

	static function loadText(p:Element, n:HtmlNodeText): Text {
		var ret = new Text(p, n.text);
		return ret;
	}

	static function loadDataProps(e:HtmlNodeElement, ?p:Props): Props {
		for (c in e.children.slice(0)) {
			if (c.name == 'xml') {
				p = p.set(Dataset.XML_PROP, c.innerHTML);
				c.remove();
				break;
			} else if (c.name == 'json') {
				p = p.set(Dataset.JSON_PROP, c.innerText);
				c.remove();
				break;
			}
		}
		return p;
	}

	static function loadDefineProps(e:HtmlNodeElement, ?p:Props): Props {
		var tagname = p.getString('a_tag', '');
		var parts = tagname.split(':');
		var name1 = '';
		var name2 = '';
		if (parts.length == 2) {
			name1 = parts[0].trim();
			name2 = parts[1].trim();
		}
		~/^([a-zA-Z0-9_\-]+)$/.match(name1) ? null : name1 = '_';
		~/^([a-zA-Z0-9_\-]+)$/.match(name2) ? null : name2 = 'div';
		p.remove('a_tag');
		p.remove(Element.TAG_PROP);
		p = p.set(Define.DEFNAME_PROP, name1);
		p = p.set(Define.EXTNAME_PROP, name2);
		return p;
	}

}
