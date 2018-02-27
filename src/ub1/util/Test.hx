package ub1.util;

import htmlparser.HtmlNodeElement;
import htmlparser.HtmlParser;
import htmlparser.HtmlNode;
#if (!nodejs)
	import haxe.Http;
#end
using StringTools;

class Test extends BaseNode {

	public function new(parent:Test, ?cb:Test->Void) {
		parent != null ? testRoot = parent.testRoot : null;
		this.items = [];
		super(parent, null, cb);
	}

	// =========================================================================
	// testing API
	// =========================================================================

	function delay(cb:Void->Void, ms:Int) {
		testRoot._delay(cb, ms);
	}

	function willDelay() {
		testRoot._willDelay();
	}

	function didDelay() {
		testRoot._didDelay();
	}

//	function abort(msg:String) {
//		//TODO
//	}

	function exception(?ex:Dynamic, ?msg:String) {
		var s = ex != null ? '$ex' : '';
		msg != null ? s = '$msg' + (s != '' ? ' ($s)' : '') : null;
		testRoot._addError(s);
	}

	function assert(a:Dynamic, b:Dynamic, ?msg:String) {
		if (a != b) {
			var s = '$a != $b';
			msg != null ? s = '$msg ($s)' : null;
			testRoot._addError(s);
		}
	}

	function assertNot(a:Dynamic, b:Dynamic, ?msg:String) {
		if (a == b) {
			var s = '$a == $b';
			msg != null ? s = '$msg ($s)' : null;
			testRoot._addError(s);
		}
	}

	function assertBool(flag:Bool, ?msg:String) {
		if (!flag) {
			var s = 'false';
			msg != null ? s = '$msg' : null;
			testRoot._addError(s);
		}
	}

	function assertNull(a:Dynamic, ?msg:String) {
		assert(a, null, msg);
	}

	function assertNotNull(a:Dynamic, ?msg:String) {
		assertNot(a, null, msg);
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
			var s = 'invalid actual HTML';
			msg != null ? s = '$msg ($s)' : null;
			testRoot._addError(s);
			return;
		}
		try {
			dom2 = HtmlParser.run(expected, true);
		} catch (ex:Dynamic) {
			var s = 'invalid expected HTML';
			msg != null ? s = '$msg ($s)' : null;
			testRoot._addError(s);
			return;
		}
		if (!compareHtml(dom1, dom2)) {
			var s = '$actual != $expected';
			msg != null ? s = '$msg ($s)' : null;
			testRoot._addError(s);
		}
	}

	// =========================================================================
	// private
	// =========================================================================
	static inline var TEST_PREFIX = 'test';
	var testRoot: TestRoot;
	var testChildren(get,null): Array<Test>;
	var items: Array<TestItem>;

	override function init() {
		// lookup test*() methods
		for (key in Type.getInstanceFields(Type.getClass(this))) {
			var field = Reflect.field(this, key);
			if (key.startsWith(TEST_PREFIX) && Reflect.isFunction(field)) {
				items.push({
					klass: Type.getClassName(Type.getClass(this)),
					name: key.substr(TEST_PREFIX.length),
					instance: this,
					fn: field,
					errors: []
				});
			}
		}
	}

	function get_testChildren(): Array<Test> {
		return cast children;
	}

	function getOutput(xml:Xml, ?counts:Array<Int>, ?nesting=0) {
		var type = 'testcase';
		var li = Xml.createElement('li');
		xml.addChild(li);
		counts == null ? counts = [0, 0] : null;
		if (testChildren.length > 0 || items.length > 0) {
			var ul = Xml.createElement('ul');
			xml.addChild(ul);
			for (child in testChildren) {
				var subcounts = [0, 0];
				child.getOutput(ul, subcounts, nesting + 1);
				counts[0] += subcounts[0];
				counts[1] += subcounts[1];
				type = 'testsuite';
			}
			for (item in items) {
				var li = Xml.createElement('li');
				li.addChild(Xml.createPCData(item.name));
				ul.addChild(li);
				counts[1]++;
				if (item.errors.length > 0) {
					var ul = Xml.createElement('ul');
					li.parent.addChild(ul);
					li.set('class', 'test error');
					for (error in item.errors) {
						var li = Xml.createElement('li');
						li.addChild(Xml.createPCData(error));
						li.set('class', 'test error');
						ul.addChild(li);
					}
				} else {
					li.set('class', 'test');
					counts[0]++;
				}
			}
		}
		var name = Type.getClassName(Type.getClass(this)).split('.').pop();
		if (nesting == 0) {
			#if client
				name = 'ClientJS - $name';
			#elseif php
				name = 'PHP - $name';
			#end
		}
		li.addChild(Xml.createPCData('$name: ${counts[0]}/${counts[1]}'));
		li.set('class', '${type}${(counts[0] != counts[1]) ? " error" : ""}');
	}

	public function recurse(node:BaseNode, cb:BaseNode->Void) {
		cb(this);
		if (_children != null) {
			for (child in _children) {
				recurse(child, cb);
			}
		}
	}

	// =========================================================================
	// HTML compare
	// =========================================================================

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

	// =========================================================================
	// test data
	// =========================================================================

	public function getTestDataUrl(methodName:String): String {
		var ret = null;
		var testClass = Type.getClass(this);
		var className = Type.getClassName(testClass);
		// remove package name
		className = ~/^(.+?\.)+/.replace(className, '');
		ret = testRoot.rpcurl + className + '.' + methodName;
//		#if php
//			var domain = php.Web.getHostName();
//			var path = php.Web.getURI();
//			// remove page name
//			path = ~/(\/[^\/]+?)$/.replace(path, '');
//			ret = 'http://$domain$path/index.php?data=${className}.$methodName';
//		#elseif (js && client)
//			var path = js.Browser.window.location.href;
//		trace(path);//tempdebug
//			// remove page name
//			path = ~/(\/[^\/]+?)$/.replace(path, '');
//			ret = '${path}/index.php?data=${className}.$methodName';
//		#elseif (js || java)
//			ret = 'http://localhost/ubm/test/index.php?data=${className}.$methodName';
//		#end
		return ret;
	}

	public function requestTestData(methodName:String,
	                                ?args:Dynamic): String {
		var url = getTestDataUrl(methodName);
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

// =============================================================================
// TestRoot
// =============================================================================

class TestRoot extends Test {
	public var rpcurl(default,null): String;

	public function new(cb:Test->Void, ?out:Xml->Void, ?rpcurl:String) {
		this.testRoot = this;
		super(null, cb);
		this.out = out;
		this.rpcurl = rpcurl;
		#if php
			// rpc
			var params = php.Web.getParams();
			var rpc = params.get('rpc');
			if (rpc != null) {
				var args = new Map<String,String>();
				for (key in params.keys()) {
					args.set(key, params.get(key));
				}
				callRpcMethod(rpc, args);
				return;
			}
		#end
		start();
	}

	public function _delay(cb:Void->Void, ms:Int) {
		#if (client && !noAsyncTest)
		delaying++;
			haxe.Timer.delay(function() {
			delaying--;
			_call(cb);
			}, ms);
		#else
			cb();
		#end
	}

	public function _willDelay() {
		#if (client)
			delaying++;
		#end
	}

	public function _didDelay() {
		#if (client)
			delaying--;
			#if (client && !noAsyncTest)
				haxe.Timer.delay(function() {
			#end
				index++;
				_go();
			#if (client && !noAsyncTest)
				}, 0);
			#end
		#end
	}

	public function _go() {
		if (index < steps.length) {
			#if client
				js.Browser.document.head.outerHTML = '<head></head>';
				js.Browser.document.body.outerHTML = '<body></body>';
			#end
			_call(steps[index].fn, steps[index].instance);
		} else {
			end();
		}
	}

	function _call(fn:Void->Void, ?obj:Dynamic) {
		try {
			if (obj != null) {
				Reflect.callMethod(obj, fn, []);
			} else {
				fn();
			}
		} catch (ex:Dynamic) {
			exception(ex);
		}
		if (delaying < 1) {
			#if (client && !noAsyncTest)
				haxe.Timer.delay(function() {
			#end
				index++;
				_go();
			#if (client && !noAsyncTest)
				}, 0);
			#end
		}
	}

	public function _addError(s:String) {
		var item = steps[index];
		//item.errors.push(s.htmlEscape(true));
		item.errors.push(s);
	}

	// =========================================================================
	// private
	// =========================================================================
	var out: Xml->Void;
	var steps: Array<TestItem>;
	var index: Int;
	var delaying = 0;

	function start() {
		var fn = null;
		fn = function(test:Test) {
			for (child in test.testChildren) {
				fn(child);
			}
			for (item in test.items) {
				steps.push(item);
			}
		}
		steps = [];
		index = 0;
		fn(this);
		#if client
			js.Browser.document.body.style.opacity = '0';
		#end
		_go();
	}

	function end() {
		var ret = Xml.createDocument();
		var ul = Xml.createElement('ul');
		ret.addChild(ul);
		getOutput(ul);
		if (out != null) {
			out(ret);
		} else {
			var head = '<meta charset="UTF-8">\n' +
					   '<style>\n' +
					   'body{font-family:Arial,Helvetica,sans-serif;' +
					   'padding-bottom:8px}\n' +
					   'ul{list-style:disc;margin: 0 0 2px 0;display:none}\n' +
					   '.testsuite{padding: 3px 0 3px 0; font-weight:bold}\n' +
					   '.testcase{padding: 3px 0 3px 0}\n' +
					   '.test{padding: 2px 0 2px 0}\n' +
					   '.error{color:red}\n' +
					   '</style>';
			#if client
				js.Browser.document.head.innerHTML = head;
				js.Browser.document.body.outerHTML = ret.toString() +
				'<body><script src="../bin/testpage.js"></script></body>';
			#elseif server
				var s = '<html>
				<head>$head</head>
				<body>${ret.toString()}
				<script src="../bin/testpage.js"></script>
				</body></html>';
				#if php
					php.Lib.print(s);
				#end
			#end
		}
		#if client
			js.Browser.document.body.style.opacity = '1';
		#end
	}

	// =========================================================================
	// rpc
	// =========================================================================

	#if php
	function callRpcMethod(key:String, args:Map<String,String>) {
		try {
			var done = false;
			var parts = key.split('.');
			recurse(this, function(test:BaseNode) {
				var klass = Type.getClass(test);
				var name = Type.getClassName(klass);
				// remove package name
				name = ~/^(.+?\.)+/.replace(name, '');
				if (name == parts[0]) {
					var field = Reflect.field(test, parts[1]);
					var text = Std.string(Reflect.callMethod(test, field, [args]));
					var json = (StringTools.startsWith(text, "{") ||
								StringTools.startsWith(text, "["));
					var contentType = (json ? 'text/json' : 'text/xml');
					php.Web.setHeader('Content-Type', contentType);
					php.Lib.print(text);
					done = true;
				}
			});
			if (!done) {
				php.Web.setReturnCode(404);
			}
		} catch (e:Dynamic) {
			php.Web.setReturnCode(404);
		}
	}
	#end

}

// =========================================================================
// TestItem
// =========================================================================

typedef TestItem = {
	klass: String,
	name: String,
	instance: Test,
	fn: Void->Void,
	errors: Array<String>
}
