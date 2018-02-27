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

package ub1.util;

typedef XmlUid = Int;

class XmlTools {
	public static inline var UID_ATTR = '__uid';

	// root node's UID is always the highest UID in the whole document;
	// this convention is taken advantage of in order to assign new UIDs
	// to newly linked nodes
	public static function setUniqueIds(xml:Xml, uid=1): Xml {
		//UbbLog.project('setUniqueIds() in: ${xml.toString()}');
		var f = null;
		f = function(node:Xml) {
			for (e in node.elements()) {
				f(e);
			}
			setUid(node, uid++);
		}
		f(xml);
		//UbbLog.project('setUniqueIds() out: ${xml.toString()}');
		return xml;
	}

	public static function getUid(node:Xml): XmlUid {
		var s = (node != null && node.nodeType == Xml.Element ? node.get(UID_ATTR) : null);
		return (s != null ? Std.parseInt(s) : 0);
	}

	public static function setUid(node:Xml, uid:XmlUid) {
		node.set(UID_ATTR, Std.string(uid));
	}

	// recursively search excluding root itself
	public static function lookupByUid(root:Xml, uid:Int): Xml {
		var ret = null;
		var f:Xml->Bool = null;
		f = function(node:Xml): Bool {
			for (child in node.elements()) {
				if (getUid(child) == uid) {
					ret = child;
					return false;
				} else if (!f(child)) {
					return false;
				}
			}
			return true;
		}
		f(root);
		return ret;
	}

	public static function make(s:String): Xml {
		var ret = Xml.parse(s).firstElement();
		ret.parent.removeChild(ret);
		return ret;
	}

	public static function recur(node:Xml, cb:Xml->Int->Bool): Bool {
		var f:Xml->Int->Bool = null;
		f = function(n:Xml, depth:Int): Bool {
			if (cb(n, depth)) {
				for (child in n.elements()) {
					if (!f(child, depth + 1)) {
						return false;
					}
				}
				return true;
			} else {
				return false;
			}
		}
		return f(node, 0);
	}

//	public static function recurDepthFirst(node:Xml, cb:Xml->Int->Bool): Bool {
//		var f:Xml->Int->Bool = null;
//		f = function(n:Xml, depth:Int): Bool {
//			for (child in n.elements()) {
//				if (!f(child, depth + 1)) {
//					return false;
//				}
//			}
//			if (!cb(n, depth)) {
//				return first;
//			}
//			return true;
//		}
//		return f(node, 0);
//	}

	public static function scan(node:Xml, cb:Xml->Bool): Bool {
		if (node != null) {
			for (child in node.elements()) {
				if (!cb(child)) {
					return false;
				}
			}
		}
		return true;
	}

	public static function root(xml:Xml): Xml {
		if (xml.nodeType == Xml.Document) {
			return xml.firstElement();
		} else {
			while (xml.parent != null && xml.parent.nodeType != Xml.Document) {
				xml = xml.parent;
			}
			return (xml.parent != null ? xml : null);
		}
	}

	public static function childByNodeName(node:Xml, nodeName:String): Xml {
		for (child in node.elements()) {
			if (child.nodeName == nodeName) {
				return child;
			}
		}
		return null;
	}

	public static function getNodeIndex(node:Xml): Int {
		if (node != null && node.parent != null) {
			var i = 0;
			for (child in node.parent) {
				if (child == node) {
					return i;
				}
				i++;
			}
		}
		return -1;
	}

	public static function getNodeAt(parent:Xml, index:Int): Xml {
		var i = 0;
		for (child in parent) {
			if (i == index) {
				return child;
			}
			i++;
		}
		return null;
	}

	public static function getNextElementSibling(node:Xml): Xml {
		var ret = (node != null ? getNextSibling(node) : null);
		while (ret != null && ret.nodeType != Xml.Element) {
			ret = getNextSibling(ret);
		}
		return ret;
	}

	public static function getNextSibling(node:Xml): Xml {
		if (node != null && node.parent != null) {
			var flag = false;
			for (child in node.parent) {
				if (flag) {
					return child;
				}
				if (child == node) {
					flag = true;
				}
			}
		}
		return null;
	}

	public static function insertAt(parent:Xml, child:Xml, index:Int) {
		var before = getNodeAt(parent, index);
		if (before != null) {
			insertBefore(parent, child, before);
		} else {
			parent.addChild(child);
		}
	}

	public static function insertBefore(parent:Xml, child:Xml, ref:Xml) {
		var i = 0;
		for (node in parent) {
			if (node == ref) {
				parent.insertChild(child, i);
				return;
			}
			i++;
		}
		parent.addChild(child);
	}

	public static function insertAfter(parent:Xml, child:Xml, ref:Xml) {
		var i = 0;
		for (node in parent) {
			if (node == ref) {
				parent.insertChild(child, i + 1);
				return;
			}
			i++;
		}
		parent.addChild(child);
	}

	public static function get2(xml:Xml, key:String, defval:String=null): String {
		var ret = xml.get(key);
		return (ret != null ? ret : defval);
	}

	public static function removeChildren(xml:Xml): Xml {
		var child = xml.firstChild();
		while (child != null) {
			xml.removeChild(child);
			child = xml.firstChild();
		}
		return xml;
	}

	public static function clone(xml:Xml): Xml {
		return Xml.parse(xml.toString()).firstElement();
	}

// doesn't seem to work
//	public static function removeBlanks(xml:Xml) {
//		var blanks:Array<Xml> = [];
//		for (child in xml) {
//			if (child.nodeType != Xml.Element && child.nodeType != Xml.Document) {
//				if (StringTools.trim(child.nodeValue) == '') {
//					blanks.push(child);
//				} else {
//					removeBlanks(child);
//				}
//			}
//		}
//		for (blank in blanks) {
//			blank.parent.removeChild(blank);
//		}
//	}

	public static function getElementText(xml:Xml): String {
		var sb = new StringBuf();
		for (child in xml.iterator()) {
			if (child.nodeType == Xml.CData || child.nodeType == Xml.PCData) {
				sb.add(child.nodeValue);
			}
		}
		return sb.toString();
	}

}
