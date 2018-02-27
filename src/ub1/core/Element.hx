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

import ub1.web.DomTools;
import ub1.util.PropertyTool.Props;
import ub1.data.DataPath;
import ub1.data.DataProvider;
import ub1.react.*;
import ub1.util.BaseNode;
import ub1.util.Util;
using StringTools;
using ub1.util.PropertyTool;
using ub1.web.DomTools;

class Element extends Node {
	public static inline var NODE_PREFIX = 'n_';
	public static inline var ATTRIBUTE_PREFIX = 'a_';
	public static inline var CLASS_PREFIX = 'c_';
	public static inline var STYLE_PREFIX = 's_';
	public static inline var EVENT_PREFIX = 'ev_';
	public static inline var HANDLER_PREFIX = 'on_';
	// static attributes
	public static inline var ELEMENT_PROP = NODE_PREFIX + 'e';
	public static inline var TAG_PROP = NODE_PREFIX + 'tag';
	public static inline var SLOT_PROP = NODE_PREFIX + 'slot';
	public static inline var INDEX_PROP = NODE_PREFIX + 'index';
	public static inline var ID_PROP = NODE_PREFIX + 'id';
	// dynamic
	public static inline var NAME_PROP = 'name';
	public static inline var INNERTEXT_PROP = 'innerText';
	public static inline var INNERHTML_PROP = 'innerHtml';
	// (databinding)
	public static inline var DATAPATH_PROP = 'datapath';
	// (replication)
	public static inline var FOREACH_PROP = 'foreach';
	public static inline var SORT_PROP = 'forsort';
	public static inline var TARGET_PROP = 'fortarget';
	// (replicated nodes)
	public static inline var SOURCE_PROP = NODE_PREFIX + 'src';

	public function new(parent:Element, props:Props, ?cb:Dynamic->Void) {
		this.props = props;
		var slot:String = props.get(SLOT_PROP);
		var index:Int = props.get(INDEX_PROP);
		super(parent, slot, index, cb);
	}

	public inline function getProp(key:String, ?defval:Dynamic) {
		return props.get(key, defval);
	}

	override public function set(key:String, val:Dynamic, push=true): Value {
		var ret = null;
		if (key.startsWith(ATTRIBUTE_PREFIX) && !Node.isDynamicValue(val)) {
			key = Node.makeHyphenName(key.substr(ATTRIBUTE_PREFIX.length));
			attributeValueCB(e, key, val);
		} else {
			scope == null ? makeScope() : null;
			ret = scope.set(key, val, push);
		}
		return ret;
	}

	override public function get(key:String, pull=true): Dynamic {
		return (scope != null ? scope.get(key, pull) : null);
	}

	public inline function getBool(key:String, defval:Bool, pull=true): Bool {
		var ret = get(key, pull);
		return ret != null ? ret == 'true' : defval;
	}

	public inline function getInt(key:String, defval:Int, pull=true): Int {
		return Util.toInt2(get(key, pull), defval);
	}

	public inline function getFloat(key:String, defv:Float, pull=true): Float {
		return Util.toFloat2(get(key, pull), defv);
	}

	// =========================================================================
	// abstract methods
	// =========================================================================

	override public function getDomNode(): DomNode {
		return e;
	}

	override public function cloneTo(parent:Node, ?index:Int): Node {
		var props = this.props.clone();
		props = props.set(INDEX_PROP, index);
		props.remove(NAME_PROP);
		props.remove(INDEX_PROP);
		props.remove(FOREACH_PROP);
		var clone = new Element(cast parent, props);
		// clones must have their own scope in order to have their own data ctx
		clone.scope == null ? clone.makeScope() : null;
		for (child in nodeChildren) {
			child.cloneTo(clone);
		}
		return clone;
	}

	// =========================================================================
	// Define support
	// =========================================================================

	var def: Define;

	override function init() {
		var tagname = props.get(Element.TAG_PROP);
		if ((def = page.defines.get(tagname)) != null) {
			props.remove(Element.TAG_PROP);
			props = props.ensureWith(def.props);
		}
		init2();
		var f = null;
		f = function(p:Element, src:Element) {
			for (n in src.nodeChildren) {
				if (Std.is(n, Element)) {
					var t = new Element(p, PropertyTool.clone(untyped n.props));
					f(t, untyped n);
				} if (Std.is(n, Text)) {
					new Text(p, untyped n.text);
				}
			}
		}
		var f2 = null;
		f2 = function(p:Element, def:Define) {
			def.ext != null ? f2(p, def.ext) : null;
			f(untyped p, def);
		}
		def != null ? f2(this, def) : null;
	}

	// =========================================================================
	// private
	// =========================================================================
	public var props: Props;
	var e: DomElement;

	function init2() {
		super.init();
		makeDomElement();
		props.get(NAME_PROP) != null ? makeScope() : null;
		for (k in props.keys()) {
			if (!k.startsWith(NODE_PREFIX)) {
				set(k, props.get(k));
			}
		}
		if (props.exists(FOREACH_PROP)) {
			e.domSet('style', 'display:none');
		}
	}

	function makeDomElement() {
		if ((e = props.get(ELEMENT_PROP)) == null) {
			e = page.createDomElement(props.get(TAG_PROP, 'div'));
		}
	}

	override function wasAdded(logicalParent:BaseNode,
	                  parent:BaseNode,
	                  ?i:Int) {
		if (props.get(ELEMENT_PROP) == null) {
			var p:DomElement = untyped parent.e;
			var b:Node = (i != null ? untyped parent.children[i] : null);
			p.domAddChild(e, b != null ? b.getDomNode() : null);
		}
	}

	override function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {
		e.domRemove();
	}

	function domGet(name:String) {
		var ret = PropertyTool.get(e, name);
		return ret;
	}

	// =========================================================================
	// react
	// =========================================================================

	override public function makeScope(?name:String) {
		name == null ? name = props.get(NAME_PROP) : null;
		super.makeScope(name);
		set('dom', e);
		set('outer', scope.parent).unlink();
		set('animate', scope.animate).unlink();
		set('delayedSet', scope.delayedSet).unlink();
		set('domGet', domGet).unlink();
#if client
		PropertyTool.set(e, 'set', set);
		PropertyTool.set(e, 'get', get);
#end
		initDatabinding();
		initReplication();
	}

	override function newValueDelegate(v:Value) {
		var name = v.name;
		v.userdata = e;
		if (name.startsWith(ATTRIBUTE_PREFIX)) {
			v.nativeName = makeNativeName(name, ATTRIBUTE_PREFIX.length);
			if (v.nativeName != 'id') {
				if (!props.exists(FOREACH_PROP) || v.nativeName != 'style') {
					v.cb = attributeValueCB;
				}
			}
		} else if (name.startsWith(CLASS_PREFIX)) {
			v.nativeName = makeNativeName(name, CLASS_PREFIX.length);
			v.cb = classValueCB;
		} else if (name.startsWith(STYLE_PREFIX)) {
			v.nativeName = makeNativeName(name, STYLE_PREFIX.length);
			if (!props.exists(FOREACH_PROP)) {
				v.cb = styleValueCB;
			}
		} else if (name.startsWith(EVENT_PREFIX)) {
			v.unlink(); // non refreshed
			if (v.isDynamic()) {
				// contains script
				//TODO: this only supports single expressions (no ';' separator)
				var evname = name.substr(EVENT_PREFIX.length);
				e.domAddEventHandler(evname, v.evGet);
			}
		} else if (name.startsWith(HANDLER_PREFIX)) {
			v.unlink(); // non refreshed
			if (v.isDynamic()) {
				// contains script
				//TODO: this only supports single expressions (no ';' separator)
				var valname = name.substr(HANDLER_PREFIX.length);
				var refname = NODE_PREFIX + page.nextId();
				set(refname, "${" + valname + "}").cb = v.get3;
			}
		} else if (name == INNERTEXT_PROP) {
			// INNERTEXT_PROP is a shortcut for having a Tag create a nested
			// text node and keeping the latter's content updated with
			// possible INNERTEXT_PROP changes.
			// The normal way would be to explicitly create a Text inside
			// the Tag, but Texts with dynamic content also create a nested
			// marker element so the client code can look it up by ID and
			// link it to the proper Text. This cannot be used in tags like
			// <title>, hence this shortcut.
			//
			// NOTE: Preprocessor automatically uses this attribute when it
			// finds elements with a single text node child containing
			// dynamic expressions.
			v.userdata = e;
			v.cb = textValueCB;
		} else if (name == INNERHTML_PROP) {
			v.cb = htmlValueCB;
		}
		if (!v.isDynamic() && v.cb != null) {
			v.cb(v.userdata, v.nativeName, v.value);
		}
	}

	inline function makeNativeName(n:String, off=0) {
		return Node.makeHyphenName(n.substr(off));
	}

	// =========================================================================
	// INNERTEXT_PROP reflection
	// =========================================================================

	function textValueCB(e:DomElement, _, val:Dynamic) {
		if (val != null) {
			var s = Std.string(val);
			s = s.split('<').join('&lt;');
			e.domSetInnerHTML(s);
		} else {
			e.domSetInnerHTML('');
		}
	}

	// =========================================================================
	// INNERHTML_PROP reflection
	// =========================================================================

	function htmlValueCB(e:DomElement, _, val:Dynamic) {
		e.domSetInnerHTML(val != null ? Std.string(val) : '');
	}

	// =========================================================================
	// attribute reflection
	// =========================================================================

	function attributeValueCB(e:DomElement, key:String, val:Dynamic) {
		e.domSet(key, (val != null ? Std.string(val) : null));
	}

	// =========================================================================
	// class reflection
	// =========================================================================
	var classes: Map<String, Bool>;
	var willApplyClasses = false;

	function classValueCB(e:DomElement, key:String, v:Dynamic) {
		classes == null ? classes = new Map<String, Bool>() : null;
		var flag = Util.isTrue(v != null ? '$v' : '1');
		flag ? classes.set(key, true) : classes.remove(key);
		if (!willApplyClasses) {
			willApplyClasses = true;
			scope.context.addApply(applyClasses);
		}
	}

	function applyClasses() {
		willApplyClasses = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in classes.keys()) {
			if (classes.get(key)) {
				sb.add(sep); sep = ' '; sb.add(key);
			}
		}
		var s = sb.toString();
		e.domSet('class', (s.length > 0 ? s : null));
	}

	// =========================================================================
	// style reflection
	// =========================================================================
#if !client
	var styles: Map<String, String>;
	var willApplyStyles = false;
#end

	function styleValueCB(e:DomElement, key:String, val:Dynamic) {
#if !client
		styles == null ? styles = new Map<String, String>() : null;
		val != null ? styles.set(key, Std.string(val)) : styles.remove(key);
		if (!willApplyStyles) {
			willApplyStyles = true;
			scope.context.addApply(applyStyles);
		}
#else
		if (val != null) {
			e.style.setProperty(key, Std.string(val));
		} else {
			e.style.removeProperty(key);
		}
#end
	}

#if !client
	function applyStyles() {
		willApplyStyles = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in styles.keys()) {
			sb.add(sep); sep = ';';
			sb.add(key); sb.add(':'); sb.add(styles.get(key));
		}
		var s = sb.toString();
		e.domSet('style', (s.length > 0 ? s : null));
	}
#end

	// =========================================================================
	// databinding
	// =========================================================================
	var currDatapathSrc: String;
	var currDatapathExp: DataPath;
	var dataQueries: Map<String,DataPath>;

	inline function initDatabinding() {
		scope.set('__clone_dp', null);
		scope.setValueFn('__dp', dpFn);
		scope.set('dataGet', dataGet).unlink();
		scope.set('dataCheck', dataCheck).unlink();
	}

	function dpFn() {
		// dependencies
		var ret:Xml = get('__clone_dp');
		if (ret == null && parent != null) {
			ret = nodeParent.get('__dp');
		}
		var src:String = get(DATAPATH_PROP);

		// evaluation
		if (src != null
		&& Std.is(src,String)
		&& (src = src.trim()).length > 0) {
			var exp = currDatapathExp;
			if (src != currDatapathSrc) {
				currDatapathSrc = src;
				exp = currDatapathExp = new DataPath(src, getDatasource);
			}
			ret = exp.selectNode(ret);
		}

		return ret;
	}

	function dataGet(dpath:String): String {
		var ret = '';

		// dependencies
		var dp:Xml = getScope().get('__dp');

		if (dpath != null
		&& Std.is(dpath,String)
		&& (dpath = dpath.trim()).length > 0) {
			if (dataQueries == null) {
				dataQueries = new Map<String,DataPath>();
			}
			var query:DataPath = dataQueries.get(dpath);
			if (query == null) {
				query = new DataPath(dpath, getDatasource);
				dataQueries.set(dpath, query);
			}
			ret = query.selectValue(dp, '');
		} else {
			ret = (dp != null ? '1' : '');
		}

		return ret;
	}

	function dataCheck(?dpath:String): Bool {
		return (this.dataGet(dpath) != '');
	}

	function getDatasource(name:String): DataProvider {
		var scope = getScope();
		var v = scope.lookup(name);
		var s:ValueScope = Std.is(v, ValueScope) ? untyped v : null;
		var ret:Element = (s != null ? s.owner : null);
		if (ret != null && Std.is(ret, DataProvider)) {
			return untyped ret;
		}
		return null;
	}

	// =========================================================================
	// replication
	// =========================================================================
	public var clones: Array<Node>;
	#if test
		public var testCloneAdds = 0;
		public var testCloneRemoves = 0;
		public var testCloneRefreshes = 0;
		public var testCloneUpdates = 0;
	#end

	inline function initReplication() {
		clones = [];
		scope.setValueFn('__dps', dpsFn);
	}

	function dpsFn() {
		var ret:Array<Xml> = null;
		// dependencies
		var dp = get('__dp');
		var src:String = get(FOREACH_PROP);

		// evaluation
		if (src != null
		&& Std.is(src,String)
		&& (src = src.trim()).length > 0) {
			var exp = currDatapathExp;
			if (src != currDatapathSrc) {
				currDatapathSrc = src;
				exp = currDatapathExp = new DataPath(src, getDatasource);
			}
			ret = exp.selectNodes(dp);
		}

		updateClones(ret);

		return ret;
	}

	//TODO: sorting
	function updateClones(dnodes:Array<Xml>) {
		var parent:Node = null;
		var before:Node = null;

		parent = get(TARGET_PROP);

		if (parent == null) {
			parent = nodeParent;
			//before = nextSibling();
			if (clones.length > 0) {
				before = cast clones[clones.length - 1].getNextSibling();
			} else {
				before = cast getNextSibling();
			}
		}

		var index = 0;
		if (dnodes != null) {
			for (dp in dnodes) {
				if (index < clones.length) {
					// reuse existing clone
					var clone = clones[index];
					//clone.set('__clone_dp', dp, false);
					//clone.set('__clone_index', index, false);
					refreshClone(clone, dp, index);
					#if test
						testCloneUpdates++;
					#end
				} else {
					// create new clone
					var clone = addClone(parent, before, dp, index);
					if (clone != null) {
						clones.push(clone);
						//clone.set('__clone_index', index);
					}
				}
				index++;
			}
		}

		// remove unused clones
		while (index < clones.length) {
			removeClone(clones.pop());
		}
	}

	//TODO: use "index" instead of "before"
	function addClone(parent:Node, before:Node, dp:Xml, ci:Int): Node {
		var index = (before != null ? before.getIndex() : null);
		var ret = cloneTo(parent, index);
		if (Std.is(ret, Element)) {
			var t:Element = untyped ret;
			t.props = t.props.set(SOURCE_PROP, id);
		}
		if (ret != null) {
			refreshClone(ret, dp, ci);
			#if test
				testCloneAdds++;
			#end
		}
		return ret;
	}

	function removeClone(clone:Node) {
		clone.parent.removeChild(clone);
		#if test
			testCloneRemoves++;
		#end
	}

	function refreshClone(clone:Node, dp:Xml, ci:Int) {
		clone.scope.clonedScope = true;
		clone.scope.set('__clone_dp', dp, false);
		clone.scope.set('__clone_index', ci, false);
		page.scope.context.refresh(clone.scope);
		#if test
			testCloneRefreshes++;
		#end
	}

}
