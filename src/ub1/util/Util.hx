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

import haxe.Json;

class Util {
	//http://stackoverflow.com/a/15123777
	static var comments = ~/(?:\/\*(?:[\s\S]*?)\*\/)|(?:([\s;])+\/\/(?:.*)$)/gm;

	public static inline function areEqual(a:Dynamic, b:Dynamic): Bool {
		return (a == null ? b == null : a == b);
	}

	public static function cleanScriptSource(s:String): String {
		//TODO s = StringTools.trim(comments.replace(s, ''));
		return StringTools.endsWith(s, ';') ? s : s + ';';
	}

	public static inline function isTrue(s:String, defval=false): Bool {
		s = (s != null ? StringTools.trim(s) : null);
		return (s != null && s.length > 0 ?
			s != '0' && s != 'null' && s.toLowerCase() != 'false' : defval
		);
	}

	public static inline function toInt(s:String): Int {
		return toInt2(s, 0);
	}

	public static inline function toInt2(s:String, defval:Int): Int {
		var ret = Std.parseInt(s);
		return (ret != null ? ret : defval);
	}

	public static inline function toFloat(s:String): Float {
		var ret = Std.parseFloat(s);
		return (ret != Math.NaN ? ret : 0);
	}

	public static inline function toFloat2(s:String, defval:Float): Float {
		var ret = Std.parseFloat(s);
		return (ret != Math.NaN ? ret : defval);
	}

	public static function getXmlAttribute(node:Xml, key:String,
	                                       defval:String=null) {
		var ret = node.get(key);
		return (ret != null ? StringTools.htmlUnescape(ret) : defval);
	}

	public static function getXmlText(node:Xml, defval:String=null) {
		if (node != null) {
			var child = node.firstChild();
			if (child != null &&
				(child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
				return child.nodeValue;
			} else {
				return defval;
			}
		}
		return defval;
	}

	public static function setXmlText(node:Xml, text:String) {
		if (node != null) {
			var child = node.firstChild();
			if (child != null) {
				if (text != null) {
					child.nodeValue = text;
				} else {
					node.removeChild(child);
				}
			} else if (text != null) {
				child = Xml.createCData(text);
				node.insertChild(child, 0);
			}
		}
	}

	public static inline function getTextFileContent(fname: String): String {
		#if (!js)
			return sys.io.File.getContent(fname);
		#else
			return null;
		#end
	}

	public static function indexIn(item:Dynamic, array:Array<Dynamic>): Int {
		var i = -1;
		if (array != null) {
			for (e in array) {
				i++;
				if (e == item) {
					return i;
				}
			}
		}
		return -1;
	}

	public static inline function defval(v:Dynamic, defval:Dynamic): Dynamic {
		return (v != null ? v : defval);
	}

	public static inline function xmlAttribute(xml:Xml, key:String,
	                                           defval:String=null): String {
		var val = xml.get(key);
		if (val != null) {
			val = StringTools.replace(val, "&quot;", '"');
			val = StringTools.replace(val, "&apos;", "'");
		}
		return (val != null ? StringTools.htmlUnescape(val) : defval);
	}

	public static function xmlChildIndex(xml:Xml): Int {
		if (xml.parent != null) {
			var i = 0;
			for (child in xml.parent) {
				if (child == xml) {
					return i;
				}
				i++;
			}
		}
		return -1;
	}

	public static function parseStyles(s:String,
	                                   map:Map<String, String> =null,
	                                   forbiddenKeys:Map<String,Bool> =null) {
		if (map == null) {
			map = new Map<String, String>();
		}
		if (s != null) {
			var styles = split(StringTools.trim(s), ';');
			for (style in styles) {
				var v = split(style, ':');
				if (v.length > 0) {
					var key = StringTools.trim(v[0]);
					var val = (v.length > 1 ? StringTools.trim(v[1]) : '');
					if (forbiddenKeys == null || !forbiddenKeys.exists(key)) {
						map.set(key, val);
					}
				}
			}
		}
		return map;
	}

	public static function unparseStyles(map:Map<String, String>): String {
		var sb = new StringBuf();
		var sep = '';
		for (key in map.keys()) {
			sb.add(sep); sep = ';';
			sb.add(key); sb.add(':'); sb.add(map.get(key));
		}
		return sb.toString();
	}

	// for IE6 compatibility
	public static function split(s:String, delim:String): Array<String> {
		//#if debug trace('Util.split 1: "' + s + '", "' + delim + '"'); #end
		var ret = new Array<String>();
		var i2 = 0, i;
		do {
			//i = s.indexOf(delim, i2);
			i = indexOf(s, delim, i2);
			if (i >= 0) {
				ret.push(s.substring(i2, i));
				i2 = i + delim.length;
			} else if (i2 <= s.length) {
				ret.push(s.substring(i2));
				i2 = s.length + 1;
			}
		} while (i2 <= s.length);
		//#if debug trace('Util.split 2: "' + ret + '"'); #end
		return ret;
	}

	// for IE6 compatibility
	public static inline function indexOf(s:String, marker:String, i:Int): Int {
		var ret = -1;
		var len = s.length;
		while (i < len) {
			if (s.charAt(i) == marker) {
				ret = i;
				break;
			}
			i++;
		}
		return ret;
	}

	public static function xmlChildrenNamed(xml:Xml, key:String, cb:Xml->Void) {
		for (child in xml.elementsNamed(key)) {
			cb(child);
		}
	}

	public static function xmlValue(xml:Xml) {
		var ret = xml.get('value');
		return StringTools.trim(ret != null ? ret : getXmlText(xml, ''));
	}

	// throws Dynamic
	public static function jsonTextToXml(jsonText:String,
										 rootName='root',
										 arrayItemName='item'): Xml {
		// syntax extension for setting XML root tag name:
		// "<root-name":<json-text>
		if (StringTools.startsWith(jsonText, '"')) {
			var i = jsonText.indexOf('":');
			rootName = jsonText.substring(1, i);
			jsonText = jsonText.substr(i + 2);
		}
		var json = Json.parse(jsonText);
		var doc = jsonToXml(json, rootName, arrayItemName);
		return doc;
	}

	// throws Dynamic
	public static function jsonToXml(json:Dynamic,
									 rootName='root',
									 arrayItemName='item'): Xml {
		var doc = Xml.createDocument();
		var root = Xml.createElement(rootName);
		doc.addChild(root);
		parseJson(json, root, arrayItemName);
		return doc;
	}

	static var JSON_FIELD_RE = ~/(.+?)#(\d+)$/;
	static function parseJson(json:Dynamic, parent:Xml, arrayItemName:String) {
		if (Std.is(json, Array)) {
			var a = cast(json, Array<Dynamic>);
			for (item in a) {
				var e = Xml.createElement(arrayItemName);
				parseJson(item, e, arrayItemName);
				parent.addChild(e);
			}
		} else {
			for (field in Reflect.fields(json)) {
				var key;
				Util.atomic(function() {
					key = JSON_FIELD_RE.match(field)
						? JSON_FIELD_RE.matched(1)
						: field;
				});
				var obj = Reflect.getProperty(json, field);
				if (obj == null || Std.is(obj, String)) {
					//TODO: blanks normalization (and \n -> ' ')
					var s = Util.normalizeText(cast obj);
					parent.set(field, s);
				} else {
					var e = Xml.createElement(key);
					parseJson(obj, e, arrayItemName);
					parent.addChild(e);
				}
			}
		}
	}

//	public static function xmlToJson(xml:Xml): Dynamic {
//		var ret = {};
//		scanNodeChildren(xml, ret);
//		return ret;
//	}
//
//	static function scanNodeChildren(xml:Xml, ret:Dynamic) {
//		for (x in xml) {
//			var child:Xml = x;
//			var sb = new StringBuf();
//			if (child.nodeType == Xml.Element) {
//				var key = child.nodeName;
//				var obj = {};
//				//Reflect.setProperty(ret, key, obj);
//				if (PropertyMixin.exists(ret, key)) {
//					var p = PropertyMixin.get(ret, key);
//					if (Std.is(p, Array)) {
//						cast(p, Array<Dynamic>).push(obj);
//					} else {
//						var a = [];
//						a.push(p);
//						a.push(obj);
//						PropertyMixin.set(ret, key, a);
//					}
//				} else {
//					PropertyMixin.set(ret, key, obj);
//				}
//				scanNodeChildren(child, obj);
//			} else if (child.nodeType == Xml.CData ||
//					   child.nodeType == Xml.PCData) {
//				sb.add(child.nodeValue);
//			}
//			var s = sb.toString();
//			if (StringTools.trim(sb.toString()).length > 0) {
//				var text = normalizeText(s);
//			}
//		}
//	}

	static var NORMALIZE_RE = ~/([\s]+)/g;
	public static function normalizeText(src:String): String {
		return (src != null ? NORMALIZE_RE.replace(src, ' ') : null);
	}

	static public inline function clear(array:Array<Dynamic>, size:Int) {
		for (i in 0...size) array[i] = null;
		return array;
	}

	public static function atomic(fun:Void->Void): Void {
#if java
		// synchronization to keep .match() and .matched() safe
		// https://github.com/HaxeFoundation/haxe/issues/2465
		var mutex = {};
		untyped __lock__(mutex, {
#end
			fun();
#if java
			// fix for java code generation: force putting synchronized code
			// in a '{...}' block, otherwise we get a java syntax error
			// (i.e. something like "synchronized(obj) fun();")
			// java compiler should elide dummy() call anyway as part of code
			// optimization
			dummy();
		});
#end
	}

#if java
	static function dummy() {}
#end

	public static function removeMarkup(s:String) {
		s = ~/<.*?>/g.split(s).join('');
		s = ~/\s+/g.split(s).join(' ');
		s = StringTools.htmlUnescape(s);
		s = StringTools.replace(s, '&nbsp;', ' ');
		s = ~/&[a-z]{1,8};/g.split(s).join('');
		return s;
	}

	public static function containsMarkup(s:String) {
		return (~/(<.+?>)|(&\w+;)/.match(s));
	}

	public static function getClassName(o:Dynamic) {
		var k = (o != null ? Type.getClass(o) : null);
		var n = (k != null ? Type.getClassName(k) : null);
		return n;
	}

}
