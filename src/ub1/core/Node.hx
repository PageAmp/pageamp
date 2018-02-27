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

import ub1.react.*;
import ub1.util.BaseNode;
import ub1.web.DomTools;
using ub1.web.DomTools;

class Node extends BaseNode {
	public var nodeParent(get,null): Node;
	public inline function get_nodeParent(): Node return untyped parent;
	public var nodeChildren(get,null): Array<Node>;
	public inline function get_nodeChildren(): Array<Node> return cast children;
	public var id: Int;
	public var page(get,null): Page;
	public inline function get_page(): Page return untyped root;

	function new(parent:Node, ?slot:String, ?index:Int, ?cb:Dynamic->Void) {
		super(parent, slot, index, cb);
		var key = Type.getClassName(Type.getClass(this));
		if (!page.initializations.exists(key)) {
			page.initializations.add(key);
			staticInit();
		}
	}

	public function set(key:String, val:Dynamic, push=true): Value {
		return null;
	}

	public function get(key:String, pull=true): Dynamic {
		return null;
	}

	public function toString() {
		var name = Type.getClassName(Type.getClass(this)).split('.').pop();
		var content = '';
		var slot = 'default';
		var scope = 'n';
		var domNode = getDomNode();
		if (domNode.domIsElement()) {
			content = cast(domNode, DomElement).domTagName();
			slot = cast(this, Element).getProp(Element.SLOT_PROP, 'default');
			this.scope != null ? scope = 'y' : null;
		} else if (domNode.domIsTextNode()) {
			content = cast(domNode, DomTextNode).domGetText();
		}
		return '$name:${id}:$slot:$scope:$content';
	}

	public function dump() {
		var sb = new StringBuf();
		var f = null;
		f = function(n:Node, level:Int) {
			for (i in 0...level) sb.add('\t');
			sb.add(n.toString() + '\n');
			for (c in n.children) {
				f(untyped c, level + 1);
			}
		}
		f(this, 0);
		return sb.toString();
	}

	// =========================================================================
	// abstract methods
	// =========================================================================

	public function staticInit() {}
	public function getDomNode(): DomNode return null;
	public function cloneTo(parent:Node, ?index:Int): Node return null;

	// =========================================================================
	// util
	// =========================================================================

	public static inline function isDynamicValue(v:Dynamic) {
		return v != null
		&& Std.is(v, String)
		&& !Value.isConstantExpression(untyped v);
	}

	public static function makeCamelName(n:String): String {
		return ~/(\-\w)/g.map(n, function(re:EReg): String {
			return n.substr(re.matchedPos().pos + 1, 1).toUpperCase();
		});
	}

	public static function makeHyphenName(n:String): String {
		return ~/([a-z][A-Z])/g.map(n, function(re:EReg): String {
			var p = re.matchedPos().pos;
			return n.substr(p, 1).toLowerCase()
			+ '-'
			+ n.substr(p + 1, 1).toLowerCase();
		});
	}

	// =========================================================================
	// private
	// =========================================================================

	override function init() {
		parent == null ? makeScope() : null;
		id = page.nextId();
	}

	// =========================================================================
	// react
	// =========================================================================
	public var scope: ValueScope;

	public function getScope(): ValueScope {
		var ret:ValueScope = scope;
		if (ret == null && parent != null) {
			ret = nodeParent.getScope();
		}
		return ret;
	}

	public function makeScope(?name:String) {
		var pn = parent;
		var ps:ValueScope = null;
		while (pn != null) {
			if (Std.is(pn, Element)) {
				var pe:Element = untyped pn;
				if (pe.scope != null) {
					ps = pe.scope;
					break;
				}
			}
			pn = pn.parent;
		}
		if (ps == null) {
			scope = new ValueContext(this).main;
		} else {
			var ctx = ps.context;
			scope = new ValueScope(ctx, ps, ctx.newScopeUid(), name);
			scope.set('parent', ps).unlink();
		}
		name != null ? scope.set('name', name).unlink() : null;
		scope.newValueDelegate = newValueDelegate;
		scope.owner = this;
	}

	function newValueDelegate(v:Value) {}

}
