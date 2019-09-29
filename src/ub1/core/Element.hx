/*
 * Copyright (c) 2018-2019 Ubimate Technologies Ltd and Ub1 contributors.
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

import ub1.web.DomTools;
import ub1.util.PropertyTool;
import ub1.data.DataPath;
import ub1.data.DataProvider;
import ub1.react.*;
import ub1.util.BaseNode;
import ub1.util.Util;
#if client
	import js.html.Window;
	import js.html.ResizeObserver;
#end

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
	public static inline var PLUG_PROP = NODE_PREFIX + 'plug';
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
	public static inline var CLONE_INDEX = 'cloneIndex';

	public static inline var START_PROP = 'forstart';
	public static inline var COUNT_PROP = 'forcount';
	// (replicated nodes)
	public static inline var SOURCE_PROP = NODE_PREFIX + 'src';

	public function new(parent:Element, props:Props, ?cb:Dynamic->Void) {
		this.props = props;
		var plug:String = props.get(PLUG_PROP);
		var index:Int = props.get(INDEX_PROP);
		super(parent, plug, index, cb);
	}

	#if !debug inline #end
	public function getProp(key:String, ?defval:Dynamic) {
		return props.get(key, defval);
	}

	override public function set(key:String, val:Dynamic, push=true): Value {
		var ret = null;
		if (key.startsWith(ATTRIBUTE_PREFIX) && !isDynamicValue(key, val)) {
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

	#if !debug inline #end
	public function getBool(key:String, defval:Bool, pull=true): Bool {
		var ret = get(key, pull);
		return ret != null ? ret == 'true' : defval;
	}

	#if !debug inline #end
	public function getInt(key:String, defval:Int, pull=true): Int {
		return Util.toInt2(get(key, pull), defval);
	}

	#if !debug inline #end
	public function getFloat(key:String, defv:Float, pull=true): Float {
		return Util.toFloat2(get(key, pull), defv);
	}

	// =========================================================================
	// abstract methods
	// =========================================================================

	override public function getDomNode(): DomNode {
		return e;
	}

	override public function cloneTo(parent:Node, index:Int, nesting=0): Node {
		var props = this.props.clone();
		props = props.set(INDEX_PROP, index);
		if (nesting == 0) {
			props.remove(NAME_PROP);
			props.remove(INDEX_PROP);
			props.remove(FOREACH_PROP);
		}
		var clone = new Element(cast parent, props);
		// clones must have their own scope in order to have their own data ctx
		clone.scope == null ? clone.makeScope() : null;
		for (child in nodeChildren) {
			child.cloneTo(clone, null, nesting + 1);
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
					collectSlot(t);
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

	function collectSlot(n:Element) {
		var slot:String = n.props.get(SLOT_PROP);
		if (slot != null) {
			slots == null ? slots = new Map<String, BaseNode>() : null;
			for (s in slot.split(',')) {
				if ((s = s.trim()) != '') {
					slots.set(s, n);
				}
			}
		}
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
#if client
		PropertyTool.set(e, 'ub1', this);
#end
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
			var b:Node = (i != null ? untyped parent.baseChildren[i] : null);
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

	function getBrotherScopes(?having:String,
	                          ?equal:Dynamic,
	                          ?nonEqual:Dynamic) {
		var ret = [];
		if (baseParent != null) {
			for (node in nodeParent.nodeChildren) {
				if (node != this && node.scope != null) {
					var v = (having != null
							? node.scope.values.get(having)
							: null);
					if (having != null && v == null) {
						continue;
					}
					if (equal != null && (v == null || v.value != equal)) {
						continue;
					}
					if (nonEqual != null && v != null && v.value == nonEqual) {
						continue;
					}
					ret.push(node.scope);
				}
			}
		}
		return ret;
	}

	function getChildScopes() {
		var ret = [];
		for (node in nodeChildren) {
			node.scope == null ? node.makeScope() : null;
			ret.push(node.scope);
		}
		return ret;
	}

	function remove() {
		baseParent != null ? baseParent.removeChild(this) : null;
	}

	function send(target:Dynamic, key:String, val:Dynamic) {
		if (target != null) {
			if (Std.is(target, Array)) {
				var a:Array<ValueScope> = cast target;
				for (i in a) {
					send(i, key, val);
				}
			} else if (Std.is(target, ValueScope)) {
				cast(target, ValueScope).delayedSet(key, val);
			}
		}
	}

	function getComputedStyle(name:String, pseudoElt=''): String {
		#if client
			var w:Window = page.props.get('window');
			var s:Props = (w != null ? w.getComputedStyle(e, pseudoElt) : null);
			return s.get(name, '');
		#else
			return '';
		#end
	}

	// =========================================================================
	// react
	// =========================================================================

	override public function makeScope(?name:String) {
		name == null ? name = props.get(NAME_PROP) : null;
		super.makeScope(name);
		set('this', scope);
		set('dom', e);
		set('outer', scope.parent).unlink();
		set('animate', scope.animate).unlink();
		set('delayedSet', scope.delayedSet).unlink();
		set('domGet', domGet).unlink();
		set('getBrothers', getBrotherScopes).unlink();
		set('send', send).unlink();
		set('computedStyle', getComputedStyle).unlink();
		set('childrenCount', "${dom.children.length}");
		set('getChildren', getChildScopes).unlink();
		set('remove', remove).unlink();
		initDatabinding();
		initReplication();
	}

	override public function addChild(child:BaseNode,
	                                  ?plug:String,
	                                  ?before:Int): BaseNode {
		var ret = super.addChild(child, plug, before);
		scope != null ? scope.set('childrenCount', e.children.length) : null;
		return ret;
	}

	override public function removeChild(child:BaseNode): BaseNode {
		var ret = super.removeChild(child);
		scope != null ? scope.set('childrenCount', e.children.length) : null;
		return ret;
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

	#if !debug inline #end
	function makeNativeName(n:String, off=0) {
		return Node.makeHyphenName(n.substr(off));
	}

	// =========================================================================
	// INNERTEXT_PROP reflection
	// =========================================================================

	function textValueCB(e:DomElement, _, val:Dynamic) {
		if (val != null) {
			e.domSetInnerHTML(Std.string(val).split('<').join('&lt;'));
		}
	}

	// =========================================================================
	// INNERHTML_PROP reflection
	// =========================================================================

	function htmlValueCB(e:DomElement, _, val:Dynamic) {
		if (val != null) {
			e.domSetInnerHTML(val != null ? Std.string(val) : '');
		}
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
#if !client
	var classes: Map<String, Bool>;
	var willApplyClasses = false;
#else
	var resizeMonitor = false;
#end

	function classValueCB(e:DomElement, key:String, v:Dynamic) {
		var flag = Util.isTrue(v != null ? '$v' : '1');
#if !client
		classes == null ? classes = new Map<String, Bool>() : null;
		flag ? classes.set(key, true) : classes.remove(key);
		if (!willApplyClasses) {
			willApplyClasses = true;
			scope.context.addApply(applyClasses);
		}
#else
		if (flag) {
			e.classList.add(key);
		} else {
			e.classList.remove(key);
		}
	#if resizeMonitor
		if (key == Page.RESIZE_CLASS && flag && !resizeMonitor) {
			resizeMonitor = true;
			//TODO: these should be defined earlier in case ub1-resize class is
			//set, so other values can reliably depend on them; they should also
			//be reliably initializated with the actual clientWidth/Height after
			//the first refresh
			set('resizeWidth', -1).unlink();
			set('resizeHeight', -1).unlink();
			page.observeResize(e);
		}
	#end
#end
	}

#if !client
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
#end

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

	#if !debug inline #end
	function initDatabinding() {
		scope.set('__clone_dp', null);
		scope.setValueFn('__dp', dpFn);
		scope.set('dataGet', dataGet).unlink();
		scope.set('dataCheck', dataCheck).unlink();
		scope.set('dataNode', dataNode).unlink();
		scope.set('dataEach', dataEach).unlink();
	}

	function dpFn() {
		// dependencies
		var ret:Xml = get('__clone_dp');
		if (ret == null && baseParent != null) {
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

	function dataNode(dpath:String): Xml {

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
			dp = query.selectNode(dp);
		}

		return dp;
	}

	function dataEach(dpath:String, obj:Props, cb:Xml->Props->Void): Props {

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
				for (node in query.selectNodes(dp)) {
					cb(node, obj);
				}
			}

		return obj;
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
	//TODO: add support for cloneAddDelegate() and cloneRemoveDelegate()
	//in order to allow for add/remove animations
	public var clones: Array<Node>;
	#if test
		public var testCloneAdds = 0;
		public var testCloneRemoves = 0;
		public var testCloneRefreshes = 0;
		public var testCloneUpdates = 0;
	#end

	#if !debug inline #end
	function initReplication() {
		clones = [];
		scope.setValueFn('__dps', dpsFn);
	}

	function dpsFn() {
		var ret:Array<Xml> = null;
		// dependencies
		var dp = get('__dp');
		var src:String = get(FOREACH_PROP);
		var start:Int = get(START_PROP);
		var count:Int = get(COUNT_PROP);
		start == null ? start = 0 : null;
		count == null ? count = 100000 : null;

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

		updateClones(ret, start, count);

		if (nodeParent != null && nodeParent.scope != null) {
			nodeParent.scope.values.get('childrenCount').refresh(true);
		}

		return ret;
	}

	//TODO: sorting
	function updateClones(dnodes:Array<Xml>, start:Int, count:Int) {
		var parent:Node = null;
		var before:Node = null;

		parent = get(TARGET_PROP);

		if (parent == null) {
			parent = nodeParent;
			if (clones.length > 0) {
				before = cast clones[clones.length - 1].getNextSibling();
			} else {
				before = cast getNextSibling();
			}
		}

		var index = 0, len = (dnodes != null ? dnodes.length : 0);
		len > (start + count) ? len = start + count : null;
		var blockLen = #if client 20 #else len #end;
		var f = null;
		f = function(cycle:Int) {
			if (cycle != updateCycle) {
				// a new updateClone() invocation was done after we started
				// this cycle and before we completed it: abandon
				return;
			}
			var i = 0;
			while ((start + index) < len) {
				if (i++ >= blockLen) {
					break;
				}
				var dp = dnodes[start + index];
				if (index < clones.length) {
					// reuse existing clone
					var clone = clones[index];
					refreshClone(clone, dp, index);
					#if test
						testCloneUpdates++;
					#end
				} else {
					// create new clone
					var clone = addClone(parent, before, dp, index);
					if (clone != null) {
						clones.push(clone);
					}
				}
				index++;
			}
			if ((start + index) < len) {
				haxe.Timer.delay(function() f(cycle), 10);
			} else {
				// remove unused clones
				while (index < clones.length) {
					removeClone(clones.pop());
				}
			}
		}

		f(++updateCycle);
	}
	var updateCycle = 0;

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
		clone.baseParent.removeChild(clone);
		#if test
			testCloneRemoves++;
		#end
	}

	function refreshClone(clone:Node, dp:Xml, ci:Int) {
		clone.scope.clonedScope = true;
		clone.scope.set('__clone_dp', dp, false).unlink();
		clone.scope.set(CLONE_INDEX, ci, false).unlink();
		page.scope.context.refresh(clone.scope);
		#if test
			testCloneRefreshes++;
		#end
	}

}
