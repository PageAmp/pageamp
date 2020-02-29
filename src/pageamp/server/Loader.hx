/*
 * Copyright (c) 2018-2020 Ubimate Technologies Ltd and PageAmp contributors.
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

package pageamp.server;

import htmlparser.*;
import pageamp.core.*;
import pageamp.util.PropertyTool;
import pageamp.util.SourceTools;
import pageamp.util.Url;
import pageamp.web.DomTools;

using StringTools;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;
using pageamp.util.SourceTools;

//TODO: verifica e logging errori
class Loader {

	public static function loadPage(src:HtmlDocument,
	                                dst:DomDocument,
	                                rootpath:String,
	                                domain:String,
	                                uri:String,
                                    ?cb:Page->Void): ServerPage {
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, rootpath, domain, uri, cb);
		return ret;
	}

	public static function loadPage2(text:String, ?dst:DomDocument): ServerPage {
//		text = normalizeText(text);
		var src = PreprocessorParser.parseDoc(text);
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, null, null, null);
		return ret;
	}

//	public static function normalizeText(s:String, lineSep='\n'): String {
//		var re2 = ~/\n/;
//		var ret = ~/(\s{2,})/g.map(s, function(re:EReg): String {
//			var p = re.matchedPos();
//			return (re2.matchSub(s, p.pos, p.len) ? lineSep : ' ');
//		});
//		return ret.trim();
//	}

	// =========================================================================
	// private
	// =========================================================================

	static function loadRoot(doc:DomDocument,
	                         src:HtmlDocument,
	                         rootpath:String,
	                         domain:String,
	                         uri='/',
                             ?cb:Page->Void): Page {
		var e = src.children[0];
		var url = new Url(uri);
		url.domain = domain;
		var props = loadProps(e, false);
		props.set(Page.FSPATH_PROP, rootpath);
		props.set(Page.URI_PROP, url);
		var ret = new Page(doc, props, function(p:Page) {
			loadChildren(p, e);
            cb != null ? cb(p) : null;
		});
		return ret;
	}

	static function loadElement(p:Element, e:HtmlNodeElement): Element {
		var ret:Element;
		var props = loadProps(e);
		ret = switch (e.name) {
			case 'head':
				new Head(p, props);
			case 'body':
				new Body(p, props);
			case Datasource.TAGNAME:
				new Datasource(p, LoaderHelper.loadDataProps(e, props));
			case Define.TAGNAME:
				new Define(p, LoaderHelper.loadDefineProps(props));
			default:
				new Element(p, props);
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
            if (key.startsWith('::')) {
                continue;
            } else if (key.startsWith(':')) {
				key = key.substr(1);
			} else if (!~/^\w_/.match(key)) {
				key = Element.ATTRIBUTE_PREFIX + key;
			}
            if (key.startsWith(Element.CLASS_PREFIX) && val == null) {
                val = '1';
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
				if (StringTools.startsWith(untyped n.text, '<!---')/* &&
					StringTools.endsWith(untyped n.text, '-->')*/) {
					// nop
				} else {
					loadText(p, untyped n);
				}
			}
		}
	}

	static function loadText(p:Element, n:HtmlNodeText): Text {
		var ret = new Text(p, n.text);
		return ret;
	}

}
