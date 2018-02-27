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

import ub1.react.ValueScope;
import ub1.util.BaseNode;
import ub1.react.Value;
using ub1.util.PropertyTool;

/**
	Definition of a custom tag.
	TODO: slots
**/
class Define extends Element {
	public static inline var TAGNAME = 'ub1-define';
	public static inline var DEFNAME_PROP = Element.NODE_PREFIX + 'def';
	public static inline var EXTNAME_PROP = Element.NODE_PREFIX + 'ext';
	public var ext(default,null): Define;

	// =========================================================================
	// no scope, detached DOM element
	// =========================================================================

	override public function set(key:String,
	                             val:Dynamic,
	                             push=true): Value {
		return null;
	}
	override public function getScope(): ValueScope {
		return null;
	}
	override function wasAdded(logicalParent:BaseNode,
	                           parent:BaseNode,
	                           ?i:Int) {}
	override function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {}

	// =========================================================================
	// private
	// =========================================================================

	override function init() {
		props.remove(Element.ELEMENT_PROP);
		var defname = props.getString(DEFNAME_PROP, '_');
		var extname = props.getString(EXTNAME_PROP, 'div');
		ext = page.defines.get(extname);
		page.defines.set(defname, this);
		if (ext != null) {
			props.remove(Element.NAME_PROP);
			props = inherit(this, {});
		} else {
			props = props.set(Element.TAG_PROP, extname);
		}
		super.init();
	}

	function getRootDefine(): Define {
		var def = this;
		while (def.ext != null) def = def.ext;
		return def;
	}

	function inherit(ext:Define, ret:Props) {
		ext.ext != null ? inherit(ext.ext, ret) : null;
		ret.overwriteWith(ext.props);
		return ret;
	}

}
