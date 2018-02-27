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

package ub1.data;

import hscript.Interp;
import hscript.Parser;

using ub1.util.XmlTools;

private typedef Step = Xml -> Void;
private class SingleException {
	public function new() {}
}

class DataPath {
	static var parser: Parser;
	static var interp: Interp;
	static var attributeRE: EReg;
	static var compareRE: EReg;
	#if (php || neko || java)
		static var equalRightNumberRE: EReg;
		static var equalLeftNumberRE: EReg;
	#end

	var steps:Array<Step>;
	var index: Int;
	var single: Bool;
	var nodes: Array<Xml>;
	var values:Array<String>;

	static function __init__() {
		parser = new Parser();
		interp = new Interp();
		#if java
			interp.variables.set("num", function(v:Dynamic) {
				return Std.parseFloat(Std.string(v));
			});
		#end
		attributeRE = ~/(@)([_0-9a-z]+)/ig;
		compareRE = ~/([^<|>|!])(=)/g;
		// TODO: PHP- and Java-specific fixes concerning comparison between
		// strings and numbers should go into hscript
		#if (php || neko)
			equalRightNumberRE = ~/(!?=)\s*([0-9]+)/g;
			equalLeftNumberRE = ~/([0-9]+)\s*(!?=)/g;
		#end
		#if java
			equalRightNumberRE = ~/([^\s^!^<^>^=]+)\s*(!?<?>?=|<|>)\s*([0-9]+)/g;
			equalLeftNumberRE = ~/([0-9]+)\s*(!?<?>?=|<|>)\s*([^\s^!^<^>^=]+)/g;
		#end
	}

	static public function getNode(exp:String, xml:Xml): Xml {
		return new DataPath(exp).selectNode(xml);
	}

	static public function getNodes(exp:String, xml:Xml): Array<Xml> {
		return new DataPath(exp).selectNodes(xml);
	}

	static public function getValue(exp:String, xml:Xml): String {
		return new DataPath(exp).selectValue(xml);
	}

	static public function getValues(exp:String, xml:Xml): Array<String> {
		return new DataPath(exp).selectValues(xml);
	}

	public function new(exp:String, ?sources:String->DataProvider) {
		steps = parse(exp, sources);
	}

	public function selectNode(node:Xml): Xml {
		var res = selectNodes(node, true);
		return (res.length > 0 ? res[0] : null);
	}

	public function selectNodes(node:Xml, single=false): Array<Xml> {
		index = 0;
		this.single = single;
		nodes = new Array<Xml>();
		values = null;
		if (steps.length > 0) {
			try {
				steps[0](node);
			} catch (s:SingleException) {
				// empty
			} catch (e:Dynamic) {
				//TODO log error?
			}
		}
		return nodes;
	}

	public function selectValue(node:Xml, defval=null): String {
		var res = selectValues(node, true);
		var ret = (res.length > 0 ? res[0] : null);
		return (ret != null ? ret : defval);
	}

	public function selectValues(node:Xml, single=false): Array<String> {
		index = 0;
		this.single = single;
		nodes = null;
		values = new Array<String>();
		if (steps.length > 0) {
			try {
				steps[0](node);
			} catch (s:SingleException) {
			} catch (e:Dynamic) {
				//TODO log error?
			}
		}
		return values;
	}

	// =========================================================================
	// private
	// =========================================================================

	function parse(exp:String, ?sources:String->DataProvider): Array<Step> {
//trace('----------------- XPathLite.parse("${exp}")');
		var ret = new Array<Step>();
		var recur = false;
		if (exp != null) {
			var parts = exp.split('/');
			var i = 0;
			for (part in parts) {
				part = StringTools.trim(part);
				if (part.length == 0) {
					if (i == 0 && !StringTools.startsWith(exp, "//")) {
						// doc (trailing slash) operator
//trace('----------------- XPathLite.parse(): doc operator');
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): doc operator');
							if (node != null) {
								while (node.parent != null) {
									node = node.parent;
								}
								nextStep([node]);
							}
						});
					} else {
						// recur (double slash) operator
//trace('----------------- XPathLite.parse(): recur operator');
						recur = true;
					}
				} else {
					var arg = null;
					var i1 = part.indexOf('[');
					if (i1 >= 0) {
						var i2 = part.indexOf(']', i1);
						i2 = (i2 > i1 ? i2 : part.length);
						arg = StringTools.trim(part.substr(i1 + 1, i2 - i1 - 1));
						part = StringTools.trim(part.substr(0, i1));
					}
					var code = (arg != null ? parseArg(arg) : null);

					if (part == '*') {
						// wildcard operator
//trace('----------------- XPathLite.parse(): wildcard operator');
						var flag = Std.string(recur);
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): wildcard operator');
							if (node != null) {
								var res = new Array<Xml>(), i = 0;
								for (child in getIterator(node, flag == 'true')) {
									if (code == null || checkArg(child, ++i, code)) {
										res.push(child);
									}
								}
								nextStep(res);
							}
						});
					} else if (StringTools.startsWith(part, '@')) {
						// attribute operator
//trace('----------------- XPathLite.parse(): attribute operator');
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): attribute operator');
							if (node != null && values != null) {
								var s = node.get(part.substr(1));
								if (s != null) {
									values.push(s);
									if (single) throw new SingleException();
								}
							}
						});
					} else if (part == 'text()') {
						// text operator
//trace('----------------- XPathLite.parse(): text operator');
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): text operator');
							if (node != null && values != null) {
								var value = node.getElementText();
								value == null ? value = '' : null;
								values.push(value);
								if (single) throw new SingleException();
							}
						});
					} else if (part == 'last()') {
						// last operator
						//TODO
					} else if (part == 'position()') {
						// position operator
						//TODO
					} else if (i == 0 && StringTools.endsWith(part, ':')) {
//trace('----------------- XPathLite.parse(): datasource operator');
						// datasource operator
						var name = part.substr(0, part.length - 1);
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): datasource operator 1');
							if (sources != null) {
//trace('----------------- XPathLite.select(): datasource operator 2');
								var source = (sources != null
											  ? sources(name)
											  : null);
								if (source != null) {
//trace('----------------- XPathLite.select(): datasource operator 3');
									nextStep([source.getData()]);
								}
							}
						});
					} else if (part == '.') {
						// current operator
//trace('----------------- XPathLite.parse(): current operator');
					} else if (part == '..') {
						// parent operator
//trace('----------------- XPathLite.parse(): parent operator');
						//TODO
					} else {
						// descendant operator
//trace('----------------- XPathLite.parse(): descendant operator');
						var flag = Std.string(recur);
						ret.push(function(node:Xml): Void {
//trace('----------------- XPathLite.select(): descendant operator');
							if (node != null) {
								var res = new Array<Xml>(), i = 0;
								for (child in getIterator(node, flag == 'true')) {
									if (child.nodeName == part && (code == null
									|| checkArg(child, ++i, code))) {
										res.push(child);
									}
								}
								nextStep(res);
							}
						});
					}
					recur = false;
				}
				i++;
			}
		}
		return ret;
	}

	//TODO: implementare come iteratore ad hoc
	function getIterator(node:Xml, recur:Bool=false) {
		if (recur) {
			var ret = new Array<Xml>();
			collectElements(node, ret);
			return ret.iterator();
		} else {
			return node.elements();
		}
	}

	function collectElements(node:Xml, ret:Array<Xml>) {
		for (child in node.elements()) {
			ret.push(child);
			collectElements(child, ret);
		}
	}

	function parseArg(src:String): Dynamic {
		var source = '0';
		var ret: Dynamic = null;
		try {
			if (~/^[0-9]+$/.match(src)) {
				// node index
				source = 'index==' + src;
			} else {
				source = src;
#if (php || neko)
				// equality and inequality test against a literal number fails in php:
				// turn it to string literal instead
				source = equalRightNumberRE.replace(source, "$1'$2'");
				source = equalLeftNumberRE.replace(source, "'$1'$2");
#end
#if java
				//source = equalRightNumberRE.replace(source, "num($1)$2$3");
				source = equalRightNumberRE.map(source, function(e:EReg): String {
					var g1 = e.matched(1);
					var g2 = e.matched(2);
					var g3 = e.matched(3);
					return 'num(${g1})${g2}${g3}';
				});
				//source = equalLeftNumberRE.replace(source, "$1$2num($3)");
				source = equalLeftNumberRE.map(source, function(e:EReg): String {
					var g1 = e.matched(1);
					var g2 = e.matched(2);
					var g3 = e.matched(3);
					return '${g1}${g2}num(${g3})';
				});
				//source = compareRE.replace(source, "$1==");
				source = compareRE.map(source, function(e:EReg): String {
					var g1 = e.matched(1);
					return '${g1}==';
				});
				//source = attributeRE.replace(source, "node.get('$2')");
				source = attributeRE.map(source, function(e:EReg): String {
					var g2 = e.matched(2);
					return 'node.get(\'${g2}\')';
				});
#else
				source = compareRE.replace(source, "$1==");
				source = attributeRE.replace(source, "node.get('$2')");
#end
			}
			//trace('parseArg: "' + src + '" -> "' + source + '"');
			ret = parser.parseString(source);
		} catch (e:Dynamic) {
			#if hscriptPos
				trace('XPathLite.parseArg() ERROR: ${e.e} in "${source}"'); //TODO
			#else
				trace('XPathLite.parseArg() ERROR: ${e} in "${source}"'); //TODO
			#end
		}
		return ret;
	}

	function checkArg(node:Xml, i:Int, code:Dynamic): Bool {
			interp.variables.set('node', node);
			interp.variables.set('index', i);
			var res = null;
			try {
				res = interp.execute(code);
			} catch (e:Dynamic) {
#if hscriptPos
				trace('DataPath.checkArg() ERROR: ${e.e} on ${node}'); //TODO
#else
				trace('DataPath.checkArg() ERROR: ${e} on ${node}'); //TODO
#end
			}
			return (res == true);
	}

	function nextStep(src:Array<Xml>) {
		index++;
		if (index < steps.length) {
			for (node in src) {
				steps[index](node);
			}
		} else if (nodes != null) {
			for (node in src) {
				nodes.push(node);
				if (single) {
					throw new SingleException();
				}
			}
		}
	}

}
