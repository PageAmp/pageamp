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

package ub1.test;

import htmlparser.HtmlNodeElement;
import htmlparser.HtmlNode;
import htmlparser.HtmlParser;
import ub1.util.Logger;
import ub1.util.PropertyTool;
import haxe.Timer;
#if (!java)
	#if (!nodejs)
		import haxe.Http;
	#end
#else
	import lib.javapatch.Http;
#end

using StringTools;

typedef TestFunction = Void -> Void;

typedef Result = {
	var name: String;
	var result: String;
};

class TestCase implements Logger {
	public var errors: Array<LoggerItem>;
	//public var name: String;
	public var done: TestFunction;
	public var tests: Array<TestFunction>;
	public var index = 0;
	public var testname: String;
	public var testcount: Int;
	public var results: Array<Result>;

	public function new(done:TestFunction) {
		errors = [];
		//this.name = name;
		this.done = done;
		tests = [];
		testname = '';
		results = [];
	}

	public function add(name:String, test:TestFunction, autonext:Bool=true) {
		var that = this;
		tests.push(function() {
			that.testname = name;
			try {
				test();
			} catch (e:Dynamic) {
				e = (Std.is(e, UnblockedException) ? untyped e.exception : e);
				that.exception(e);
				autonext = true;
			}
			if (autonext) {
				next();
			}
		});
	}

	public function next() {
		if (testname != '') {
			var ok = (testcount == results.length);
			results.push({name:testname, result:(ok ? 'OK' : 'KO')});
		}
		testname = '';
		testcount = results.length;
		var test = (index < tests.length ? tests[index++] : done);
		/*
		#if js
			Timer.delay(function() {
				test();
			}, 0);
		#else
			test();
		#end
		*/
		schedule(test, 0);
	}

	public static function schedule(fun:Void->Void, time:Int) {
		#if js
			Timer.delay(function() {
				fun();
			}, time);
		#else
			fun();
		#end
	}

	public function assert(actual:Dynamic, expected:Dynamic, ?msg:String) {
		#if (php || java)
		if (actual != expected && Std.string(actual) != Std.string(expected)) {
		#else
		if (actual != expected) {
		#end
			actual = Std.string(actual).htmlEscape();
			expected = Std.string(expected).htmlEscape();
			results.push({
				name: testname,
				result: (msg != null ? msg : '$actual != $expected')
			});
			#if php
			throw new UnblockedException('skip-test');
			#end
		#if (php || java)
		}
		#else
		}
		#end
	}

	public function assertNot(actual:Dynamic, expected:Dynamic, ?msg:String) {
		#if (php || java)
		if (actual == expected || Std.string(actual) == Std.string(expected)) {
		#else
		if (actual == expected) {
		#end
			results.push({
				name: testname,
				result: (msg != null ? msg : '$actual == $expected')
			});
			#if php
			throw new UnblockedException('skip-test');
			#end
		#if (php || java)
		}
		#else
		}
		#end
	}

	public function assertHtml(actual:String, expected:String, ?msg:String) {
		if (actual == null && expected == null) {
			return;
		}
		var dom1:Array<HtmlNode> = null;
		var dom2:Array<HtmlNode> = null;
		try {
			dom1 = HtmlParser.run(actual, true);
		} catch (ex:Dynamic) {
			results.push({name:testname, result:'invalid actual HTML'});
			#if php
			throw new UnblockedException('skip-test');
			#end
			return;
		}
		try {
			dom2 = HtmlParser.run(expected, true);
		} catch (ex:Dynamic) {
			results.push({name:testname, result:'invalid expected HTML'});
			#if php
			throw new UnblockedException('skip-test');
			#end
			return;
		}
		if (!compareHtml(dom1, dom2)) {
			var result = (msg != null ? msg : '$actual == $expected');
			results.push({
				name: testname,
				result: result.htmlEscape()
			});
			#if php
			throw new UnblockedException('skip-test');
			#end
		}
	}

	function compareHtml(dom1:Array<HtmlNode>, dom2:Array<HtmlNode>): Bool {
		if (dom1.length != dom2.length) {
			return false;
		}
		for (i in 0...dom1.length) {
			var node1 = dom1[i];
			var node2 = dom2[i];
			if (!compareHtmlNode(node1, node2)) {
				return false;
			}
		}
		return true;
	}

	function compareHtmlNode(node1:HtmlNode, node2:HtmlNode): Bool {
		if (Std.is(node1, HtmlNodeElement) != Std.is(node2, HtmlNodeElement)) {
			return false;
		}
		if (Std.is(node1, HtmlNodeElement)) {
			var element1:HtmlNodeElement = cast node1;
			var element2:HtmlNodeElement = cast node2;
			if (element1.attributes.length != element2.attributes.length) {
				return false;
			}
			for (attr1 in element1.attributes) {
				if (!element2.hasAttribute(attr1.name)) {
					return false;
				}
				if (attr1.value != element2.getAttribute(attr1.name)) {
					return false;
				}
			}
			if (element1.children.length != element1.children.length) {
				return false;
			}
			for (i in 0...element1.children.length) {
				var child1 = element1.children[i];
				var child2 = element2.children[i];
				if (!compareHtmlNode(child1, child2)) {
					return false;
				}
			}
		} else {
			var s1 = ~/(\s+)/.replace(node1.toText(), ' ');
			var s2 = ~/(\s+)/.replace(node2.toText(), ' ');
			if (s1 != s2) {
				return false;
			}
		}
		return true;
	}

	public function exception(e:Dynamic) {
		#if php
			if (e == 'skip-test') {
				return;
			}
		#end
		results.push({
			name: testname,
			result: 'EXCEPTION: ' + Std.string(e)
		});
	}

	// =========================================================================
	// Logger
	// =========================================================================

	public function addError(xml:Xml, obj:Dynamic, msg:String, ex:Dynamic=null) {
		errors.push({type: ERROR, xml: xml, obj: obj, msg: msg, ex: ex});
	}

	public function addWarning(xml:Xml, obj:Dynamic, msg:String, ex:Dynamic=null) {
		errors.push({type: WARNING, xml: xml, obj: obj, msg: msg, ex: ex});
	}

	public function addInfo(xml:Xml, obj:Dynamic, msg:String, ex:Dynamic=null) {
		errors.push({type: INFO, xml: xml, obj: obj, msg: msg, ex: ex});
	}

	public function addTrace(xml:Xml, obj:Dynamic, msg:String, ex:Dynamic=null) {
		errors.push({type: TRACE, xml: xml, obj: obj, msg: msg, ex: ex});
	}

	public function addDebug(xml:Xml, obj:Dynamic, msg:String, ex:Dynamic=null) {
		errors.push({type: DEBUG, xml: xml, obj: obj, msg: msg, ex: ex});
	}

	public function clearLog(): Void {
		errors = [] ;
	}

	// =========================================================================
	// test data
	// =========================================================================

	public function testDataUrl(methodName:String): String {
		var testClass = Type.getClass(this);
		var className = Type.getClassName(testClass);
		// remove package name
		className = ~/^(.+?\.)+/.replace(className, '');
		#if php
			var domain = php.Web.getHostName();
			var path = php.Web.getURI();
			// remove page name
			path = ~/(\/[^\/]+?)$/.replace(path, '');
			var url = 'http://$domain$path/index.php?data=${className}.$methodName';
			return url;
		#elseif (js && client)
			var path = js.Browser.window.location.href;
			// remove page name
			path = ~/(\/[^\/]+?)$/.replace(path, '');
			var url = '${path}/index.php?data=${className}.$methodName';
			return url;
		// #elseif (js || java)
		// 	var url = 'http://localhost/ubm/test/index.php?data=${className}.$methodName';
		// 	return url;
		#end
		return null;
	}

	public function requestTestData(methodName:String,
	                                ?args:Dynamic): String {
		var url = testDataUrl(methodName);
		if (args != null) {
			var sb = new StringBuf();
			sb.add(url);
			for (key in PropertyTool.keys(args)) {
				sb.add('&');
				sb.add(StringTools.urlEncode(key));
				sb.add('=');
				sb.add(StringTools.urlEncode(PropertyTool.get(args, key)));
			}
			url = sb.toString();
		}
		var ret = null;
		#if (!nodejs)
			Http.requestUrl(url);
		#end
		return ret;
	}

}
