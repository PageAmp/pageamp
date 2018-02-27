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

import ub1.core.Element;
import ub1.react.Value;
import htmlparser.*;
#if !js
	import sys.io.File;
#end

import haxe.io.Path;
using haxe.io.Path;
import ub1.util.ArrayTool;
using ub1.util.ArrayTool;
using StringTools;

class Preprocessor {
	public static inline var MAXNESTING = 100;
	public static inline var TRANSPARENT_TAGNAME = 'ub1-group';
	public static inline var ESCAPED_TAGNAME = 'ub1-escaped';
	public static inline var ESCAPED_TABSPACESATTR = 'tabspaces';
	public static inline var INCLUDE_TAGNAME = 'ub1-include';
	public static inline var INCLUDE_NAMEATTR = 'href';
	public static inline var MACRODEF_TAGNAME = 'ub1-macro';
	public static inline var MACRODEF_NAMEATTR = 'name';
	public static inline var SLOTDEF_TAGNAME = 'ub1-slot';
	public static inline var SLOTDEF_NAMEATTR = 'name';
	public static inline var SLOTREF_NAMEATTR = 'slot';
	public static inline var DEFAULTSLOT_NAME = 'default';
	public static inline var PARAMREF_RE = "(\\$\\[\\s*\\w+\\s*\\])";
	public static inline var PARAMNAME_RE = "\\$\\[\\s*(\\w+)\\s*\\]";
	public var doc: HtmlDocument;

	public function new() {}

	public function loadFile(pathname:String, basepath:String) {
		this.basepath = new Path(basepath);
		doc = load(new Path(pathname));
		process();
		return doc;
	}

	public function loadText(pathname:String, basepath:String, text:String) {
		this.basepath = new Path(basepath);
		doc = load2(new Path(pathname), text);
		process();
		return doc;
	}

	// =========================================================================
	// loading
	// =========================================================================
	var basepath: Path;

#if !js
	function load(path:Path, nesting=0): HtmlDocument {
		if (nesting > MAXNESTING) {
			throw 'too many nested includes';
		}
		var text = File.getContent(path.toString());
		return load2(path, text, nesting);
	}

	function load2(path:Path, text:String, nesting=0): HtmlDocument {
//		var lineSep = '__{[(LN)]}__';
//		text = normalizeHtml(text, lineSep);
//		text = ~/(<!---.*?--->)/g.replace(text, '');
//		text = text.replace(lineSep, '\n');

		text = normalizeHtml(text);
		var ret = PreprocessorParser.parseDoc(text);

		var includes = lookupByName(ret, INCLUDE_TAGNAME);
		for (include in includes) {
			var href = include.getAttribute(INCLUDE_NAMEATTR);
			if (href != null) {
				var basepath = path.dir + '/';
				href.startsWith('/') ? basepath = this.basepath.toString() : null;
				var pathname = Path.normalize(basepath + href);
				var path2 = new Path(pathname);
				//TODO: check against pathnames outside allowed scope
				var root = load(path2, nesting + 1).children[0];
				var p = include.parent;
				var emptyText = false;
				while (root.nodes.length > 0) {
					var e = root.nodes.shift();
					p.parent.removeChild(e);
					p.addChild(e, include);
				}
				p.removeChild(include);
			}
		}
		return ret;
	}
#end

	// =========================================================================
	// macros
	// =========================================================================
	var macros = new Map<String, HtmlNodeElement>();

	function process() {
		// escape markup in ESCAPED_TAGNAME tags
		var ee = lookupByName(doc.children[0], ESCAPED_TAGNAME);
		for (e in ee) {
			var tabSpaces = Std.parseInt(e.getAttribute(ESCAPED_TABSPACESATTR));
			tabSpaces == 0 ? tabSpaces = 4 : null;
			var tab = new StringBuf();
			for (i in 0...tabSpaces) tab.add(' ');
			var s = e.innerHTML.htmlEscape();
			s = s.replace('\t', tab.toString());
			e.parent.addChild(new HtmlNodeText(s), e);
			e.remove();
		}
		// collect and remove macro definitions
		var ee = lookupByName(doc.children[0], MACRODEF_TAGNAME);
		for (e in ee) {
			var name = e.getAttribute(MACRODEF_NAMEATTR);
			if (name != null) {
				macros.set(name, e);
				e.parent.removeChild(e);
			}
		}
		// process macro references
		processMacros(doc.children[0], null);
		// process single text nodes
		var f = null;
		f = function(e:HtmlNodeElement) {
			if (e.nodes.length == 1 && Std.is(e.nodes[0], HtmlNodeText)) {
				var t:HtmlNodeText = untyped e.nodes[0];
				if (!Value.isConstantExpression(t.text)) {
					e.setAttribute(':' + Element.INNERTEXT_PROP, t.text);
					t.remove();
				}
			} else {
				for (n in e.nodes) {
					if (Std.is(n, HtmlNodeElement)) {
						f(untyped n);
					}
				}
			}
		}
		f(doc.children[0]);
		// remove <group> tags
		var f2 = null;
		f2 = function(p:HtmlNodeElement) {
			for (n in p.nodes.slice(0)) {
				if (Std.is(n, HtmlNodeElement)) {
					var e:HtmlNodeElement = untyped n;
					f2(e);
					if (e.name == TRANSPARENT_TAGNAME) {
						cloneNodes(e.parent, e, e);
						e.remove();
					}
				}
			}
		}
		f2(doc.children[0]);
	}

	function processMacros(p:HtmlNodeElement, macroRef:MacroRef) {
		var nesting = (macroRef != null ? macroRef.nesting : 0);
		if (nesting > MAXNESTING) {
			throw 'too many nested macros';
		}
		var m = macros.get(p.name);
		if (m != null) {
			processMacro(p, m, macroRef);
		} else {
			// NOTE: due to HtmlParser's limitations, newly added elements don't
			// always appear in HtmlNodeElement.children array, so we scan the
			// nodes array and ignored non elements here
			var nn:Array<HtmlNode> = p.nodes.slice(0);
			for (n in nn) {
				if (Std.is(n, HtmlNodeElement)) {
					processMacros(untyped n, macroRef);
				}
			}
		}
	}

	function processMacro(e:HtmlNodeElement,
	                      m:HtmlNodeElement,
	                      outerRef:MacroRef) {
		var ref:MacroRef = {
			params: new Map<String, String>(),
			outer: outerRef,
			nesting: (outerRef != null ? outerRef.nesting + 1 : 1),
		}
		for (a in m.attributes) {
			ref.params.set(a.name, a.value);
		}
		for (a in e.attributes) {
			ref.params.set(a.name, a.value);
		}
		var clones = cloneNodes(e.parent, e, m);
		var slots = lookupSlots(clones);
		fillMacro(e, clones, slots);
		e.parent.removeChild(e);
		for (c in clones) {
			if (Std.is(c, HtmlNodeElement)) {
				processMacros(untyped c, ref);
			}
		}
		replaceParams(clones, ref);
	}

	function cloneNodes(p:HtmlNodeElement,
	                    before:HtmlNode,
	                    m:HtmlNodeElement): Array<HtmlNode> {
		var ret = new Array<HtmlNode>();
		for (src in m.nodes) {
			var clone:HtmlNode;
			if (Std.is(src, HtmlNodeElement)) {
				var se:HtmlNodeElement = untyped src;
				var de = new HtmlNodeElement(se.name, []);
				for (a in se.attributes) {
					de.setAttribute(a.name, a.value);
				}
				de.innerHTML = se.innerHTML;
				p.addChild((clone = de), before);
			} else {
				clone = new HtmlNodeText(src.toString());
				p.addChild(clone, before);
			}
			ret.push(clone);
		}
		return ret;
	}

	function fillMacro(e:HtmlNodeElement,
	                   clones:Array<HtmlNode>,
	                   slots:Map<String,MacroSlot>) {
		var nn:Array<HtmlNode> = e.nodes.slice(0);
		for (n in nn) {
			var slotName = DEFAULTSLOT_NAME;
			if (Std.is(n, HtmlNodeElement)) {
				var s = cast(n, HtmlNodeElement).getAttribute(SLOTREF_NAMEATTR);
				s != null ? slotName = s : null;
				cast(n, HtmlNodeElement).removeAttribute(SLOTREF_NAMEATTR);
			}
			var slot:MacroSlot = slots.get(slotName);
			if (slot != null) {
				moveToSlot(n, slot);
			}
		}
	}

	inline function moveToSlot(n:HtmlNode, slot:MacroSlot) {
		var p = slot.parent;
		var b = slot.before;
		n.remove();
		if (slot.dom != null && slot.dom.nodes.length > 0) {
			if (!isBlankText(n)) {
				var clones = cloneNodes(slot.parent, slot.before, slot.dom);
				var slots = lookupSlots(clones);
				var slotName = null;
				if (Std.is(n, HtmlNodeElement)) {
					slotName = untyped n.getAttribute(SLOTREF_NAMEATTR);
				}
				slotName == null ? slotName = DEFAULTSLOT_NAME : null;
				var nestedSlot = slots.get(slotName);
				p = (nestedSlot != null ? nestedSlot.parent : null);
				if (p == null) {
					for (c in clones) {
						Std.is(c, HtmlNodeElement) ? p = untyped c : null;
					}
				}
				p == null ? p = slot.parent : b = null;
			}
		}
		p.addChild(n, b);
	}

	// =========================================================================
	// macro parameters
	// =========================================================================
	var paramRefRE = new EReg(PARAMREF_RE, 'g');
	var paramNameRE = new EReg(PARAMNAME_RE, '');

	function replaceParams(clones:Array<HtmlNode>, ref:MacroRef) {
		var f = null;
		f = function(n:HtmlNode) {
			if (Std.is(n, HtmlNodeElement)) {
				var e:HtmlNodeElement = untyped n;
				for (a in e.attributes) {
					a.value = replaceParamRefs(a.value, ref);
				}
				for (c in e.nodes) {
					f(c);
				}
			} else if (Std.is(n, HtmlNodeText)) {
				var t:HtmlNodeText = untyped n;
				t.text = replaceParamRefs(t.text, ref);
			}
		}
		for (c in clones) {
			f(c);
		}
	}

	function replaceParamRefs(s:String, ref:MacroRef): String {
		function getParam(name:String) {
			var ret = '';
			var r = ref;
			while (r != null) {
				if (r.params.exists(name)) {
					ret = r.params.get(name);
				}
				r = r.outer;
			}
			return ret;
		}
		var ret = paramRefRE.map(s, function(re:EReg) {
			var p = re.matchedPos();
			paramNameRE.matchSub(s, p.pos, p.len);
			var key = paramNameRE.matched(1);
			var val = getParam(key);
			return val;
		});
		return ret;
	}

	// =========================================================================
	// util
	// =========================================================================

	public static function normalizeHtml(s:String, lineSep='\n'): String {
		var re2 = ~/\n/;
		var ret = ~/(\s{2,})/g.map(s, function(re:EReg): String {
			var p = re.matchedPos();
			return (re2.matchSub(s, p.pos, p.len) ? lineSep : ' ');
		});
		return ret.trim();
	}

	function lookupSlots(ee:Array<HtmlNode>): Map<String, MacroSlot> {
		var ret = new Map<String, MacroSlot>();
		for (n in ee) {
			if (Std.is(n, HtmlNodeElement)) {
				var e:HtmlNodeElement = untyped n;
				for (s in lookupByName(e, SLOTDEF_TAGNAME)) {
					var name = s.getAttribute(SLOTDEF_NAMEATTR);
					if (name != null) {
						var slot:MacroSlot = {
							parent: s.parent,
							before: domNextSibling(s),
							dom: s,
						};
						ret.set(name, slot);
					}
					s.remove();
				}
			}
		}
		// make sure default slot exists
		if (!ret.exists(DEFAULTSLOT_NAME) && ee.length > 0) {
			var e = getLastElement(ee);
			if (e != null) {
				var slot:MacroSlot = {
					parent: e,
					before: null,
					dom: null,
				}
				ret.set(DEFAULTSLOT_NAME, slot);
			} else {
				var n:HtmlNode = ee.peek();
				var slot:MacroSlot = {
					parent: n.parent,
					before: domNextSibling(n),
					dom: null,
				}
				ret.set(DEFAULTSLOT_NAME, slot);
			}
		}
		return ret;
	}

	function lookupByName(root:HtmlNodeElement,
	                      name:String): Array<HtmlNodeElement> {
		var ret = new Array<HtmlNodeElement>();
		var f = null;
		f = function(p:HtmlNodeElement) {
			if (p.name == name) {
				ret.push(p);
			} else {
				for (n in p.nodes) {
					if (Std.is(n, HtmlNodeElement)) {
						f(untyped n);
					}
				}
			}
		}
		f(root);
		return ret;
	}

	function getLastElement(nn:Array<HtmlNode>) {
		var ret:HtmlNodeElement = null;
		for (n in nn) {
			if (Std.is(n, HtmlNodeElement)) {
				ret = untyped n;
			}
		}
		return ret;
	}

	static function domNextSibling(n:HtmlNode): HtmlNode {
		//return n.getNextSiblingNode();
		//TODO: proporre fix sotto in HtmlParser lib
		if (n.parent == null) return null;
		var siblings = n.parent.nodes;
		var i = Lambda.indexOf(siblings, n);
		if (i < 0) return null; //bbmark if (i <= 0) return null;
		if (i+1 < siblings.length) return siblings[i+1];
		return null;
	}

	static inline function isBlankText(n:HtmlNode): Bool {
		return Std.is(n, HtmlNodeText) && !~/\S/g.match(untyped n.text);
	}

}

typedef MacroSlot = {
	parent: HtmlNodeElement,
	before: HtmlNode,
	dom: HtmlNodeElement,
}

typedef MacroRef = {
	params: Map<String, String>,
	outer: MacroRef,
	nesting: Int,
}
