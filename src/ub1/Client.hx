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

package ub1;

import js.Browser;
import ub1.util.Util;
import ub1.core.*;

import ub1.util.PropertyTool;
using ub1.util.PropertyTool;
import ub1.web.DomTools;
using ub1.web.DomTools;
using StringTools;

class Client {

	public static function main() {
		var globals:Props = untyped __js__("window");
		var props = globals.get(Page.ISOPROPS_ID);
		var ids = new Map<Int, Node>();
		new Page(DomTools.defaultDocument(), props, function(t:Page) {
			ids.set(t.id, t);
			loadChildren(t, ids);
		});
	}

	//TODO: pre-parsed hscript should be assumed in dynamic attributes rather than source;
	//this would also allow us not to include nether ValueParser nor hscript.Parser
	//and save a lot in client runtime size
	static function loadChildren(p:Element, ids:Map<Int,Node>) {
		var doc = Browser.document;
		var children:Array<Props> = p.props.get(Page.ISOCHILDREN_PROP);
		if (children != null) {
			for (props in children) {
				var id = Util.toInt(props.get(Element.NODE_PREFIX + 'id'));
				var e = doc.getElementById(Page.ISOID_PREFIX + id);
				var text = props.get(Text.TEXT_PROP);
				if (text != null) {
					var n = e.nextSibling;
					new Text(p, text, n).id = id;
					e.remove();
				} else {
					props.set(Element.ELEMENT_PROP, e);
					props.set(Element.TAG_PROP, e.tagName);
					var tag:Element = switch (e.tagName) {
						case 'HEAD': new Head(p, props);
						case 'BODY': new Body(p, props);
						case 'SCRIPT':
							var s = e.innerHTML.trim();
							s != '' ? props.set(Dataset.XML_PROP, s) : null;
							new Dataset(p, props);
						default: new Element(p, props);
					}
					ids.set((tag.id = id), tag);
					var sourceId = Util.toInt(props.get(Element.SOURCE_PROP));
					if (sourceId != 0) {
						// it's a cloned node
						var sourceNode = ids.get(sourceId);
						if (Std.is(sourceNode, Element)) {
							var st:Element = untyped sourceNode;
							st.clones == null ? st.clones = [] : null;
							st.clones.push(tag);
						}
						// clones always have their own scope
						tag.scope == null ? tag.makeScope() : null;
						tag.scope.clonedScope = true;
					}
					props.remove(Element.ELEMENT_PROP);
					loadChildren(tag, ids);
				}
			}
		}
	}

}
