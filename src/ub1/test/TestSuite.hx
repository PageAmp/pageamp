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

typedef TestCaseResult = {
	var name: String;
	var testcase: TestCase;
};

class TestSuite {
	var name: String;
	var testcases: Array<TestCaseResult>;
	var index: Int;
	var cb: String->Void;
	public var results:String;

	//macro public static function BUILD_DATE() {
	//	var date = Date.now().toString();
	//	return Context.makeExpr(date, Context.currentPos());
	//}

	public function new(name:String,
	                    testcases:Array<TestCaseResult>,
	                    cb:String->Void=null) {
		//trace('new()');
		this.name = name;
		this.testcases = testcases;
		this.cb = cb;
		#if (js && client)
			js.Browser.document.body.parentElement.style.display = 'none';
		#end
		#if php
			// Tests are modeled as asynchronous in JS but in PHP they become
			// nested call in order to accommodate PHP fully synchronous model.
			// We therefore need to set a pretty high max nesting lavel while
			// executing tests.
			//
			// http://stackoverflow.com/questions/17488505/php-error-maximum-function-nesting-level-of-100-reached-aborting
			// ini_set('xdebug.max_nesting_level', 200);
			untyped __php__("ini_set('xdebug.max_nesting_level', 1000);");

			// test data
			var params = php.Web.getParams();
			var data = params.get('data');
			var args = new Map<String,String>();
			for (key in params.keys()) args.set(key, params.get(key));
			if (data != null) {
				deliverTestData(data, args);
				return;
			}
			// nodejs results
			if (params.get('nodejs') != null) {
				php.Web.setHeader('Content-Type', 'text/xml');
				var s = untyped __call__("shell_exec", "/usr/local/bin/node nodejs/test.js");
				php.Lib.print(s);
				return;
			}
			// java results
			if (params.get('java') != null) {
				php.Web.setHeader('Content-Type', 'text/xml');
				var s = untyped __call__("shell_exec", "/usr/bin/java -cp java/obj ubr.test.Test");
				php.Lib.print(s);
				return;
			}
		#end
		// #if (php && debug)
		// 	// haxe sources (for debugging)
		// 	var path = php.Web.getURI();
		// 	if (StringTools.startsWith(path, '/ubm/test/usr/lib/haxe/')) {
		// 		var s = path.substr('/ubm/test'.length);
		// 		//trace(s);
		// 		php.Lib.printFile(s);
		// 		return;
		// 	}
		// #end
		#if nodejs
			untyped __js__("global.XMLHttpRequest = require(\"xmlhttprequest\").XMLHttpRequest");
		#end
		index = 0;
		next();
	}

	function next() {
		//trace('next()');
		if (index < testcases.length) {
			testcases[index++].testcase.next();
		} else {
			var sb = new StringBuf();
			var total = 0;
			var passed = 0;
			sb.add('<?xml version="1.0" encoding="ISO-8859-1"?>\n');
			sb.add('<?xml-stylesheet type="text/xsl" href="test.xsl"?>\n');
			sb.add('<test-suite name="${name}">\n');
			for (testcase in testcases) {
				sb.add('<class name="${testcase.name}">\n');
				var lastname = null;
				var testcaseok = 'ok';
				var classPassed = 0;
				var classTotal = 0;
				for (res in testcase.testcase.results) {
					var name = res.name;
					if (name != lastname) {
						var testok = 'ok';
						if (res.result != 'OK') {
							testcaseok = testok = 'ko';
						} else {
							classPassed++;
							passed++;
						}
						classTotal++;
						total++;
						sb.add('<method name="${name}" result="${testok}">');
						if (testok == 'ko') {
							sb.add(res.result);
						}
						sb.add('</method>\n');
					}
					lastname = name;
				}
				sb.add('<passed>${classPassed}</passed>');
				sb.add('<total>${classTotal}</total>');
				sb.add('<result>${testcaseok}</result>');
				sb.add('</class>\n');
			}
			sb.add('<passed>${passed}</passed>\n');
			sb.add('<total>${total}</total>\n');
			sb.add('<result>${passed == total ? "ok" : "ko"}</result>');
			sb.add('<built>-</built>\n');
			#if js
				sb.add('<switchto name="PHP">index.php</switchto>\n');
			#else
				sb.add('<switchto name="JS">index.html</switchto>\n');
			#end
			sb.add('</test-suite>\n');
			//trace(sb.toString());
			if (cb != null) {
				cb(sb.toString());
			} else {
				output(sb.toString());
			}
		}
	}

	function output(s:String, contentType:String='text/xml') {
		#if (js && client)
			var query = js.Browser.location.search;
			if (query == '?plain') {
				//js.Browser.document.body.innerHTML = '${testSession.okCount}/${testSession.totalCount}';
				return;
			}
			// trace(s);
			s = StringTools.replace(s, '\n', '\\n');
			s = StringTools.replace(s, '"', '\\"');
			js.Lib.eval('
				// http://stackoverflow.com/questions/649614/xml-parsing-of-a-variable-string-in-javascript
				if (typeof window.DOMParser != "undefined") {
					window.parseXml = function(xmlStr) {
						return ( new window.DOMParser() ).parseFromString(xmlStr, "text/xml");
					};
				} else if (typeof window.ActiveXObject != "undefined" &&
					new window.ActiveXObject("Microsoft.XMLDOM")) {
					window.parseXml = function(xmlStr) {
						var xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM");
						xmlDoc.async = "false";
						xmlDoc.loadXML(xmlStr);
						return xmlDoc;
					};
				} else {
				    throw new Error("No XML parser found");
				}

				// http://www.w3schools.com/XSL/xsl_client.asp
				window.loadXMLDoc = function(dname) {
					if (window.ActiveXObject) {
						var xhttp = new ActiveXObject("Msxml2.XMLHTTP.3.0");
					} else {
						var xhttp = new XMLHttpRequest();
					}
					xhttp.open("GET",dname,false);
					xhttp.send("");
					return xhttp.responseXML;
				}

				window.xml = window.parseXml("$s");
				window.xsl = window.loadXMLDoc("test.xsl");

				if (window.ActiveXObject) {
					var ex = xml.transformNode(xsl);
					document.body.innerHTML = ex;
				} else if (document.implementation && document.implementation.createDocument) {
					var xsltProcessor = new XSLTProcessor();
					xsltProcessor.importStylesheet(xsl);
					var resultDocument = xsltProcessor.transformToFragment(xml, document);
					document.body.appendChild(resultDocument);
				}

				eval(document.getElementById("toggleDisclose").text);
				document.title = "$name Test Suite";
			');
			js.Browser.document.body.parentElement.style.display = null;
		#elseif nodejs
			s = StringTools.replace(s, '\n', '\\n');
			s = StringTools.replace(s, "'", "\\'");
			/*js.Lib.eval('var http = require("http"), fs = require("fs");
				var server = http.createServer(function (req, res) {
					if (req.url == "/") {
						res.writeHead(200, {"Content-Type": "text/xml"});
						res.end(\'$s\');
					} else if (req.url == "/test.xsl") {
						fs.readFile("../test.xsl", function(err, file) {
							res.writeHead(200, {"Content-Type": "text/xml"});
							res.write(file);
							res.end();
						});
					} else {
						res.writeHead(404);
						res.end();
					}
				})
				server.listen(8081, "127.0.0.1");
				console.log("Server running at http://127.0.0.1:8081/");
			');*/
			js.Lib.eval('console.log(\'${s}\');');
		#elseif (js)
			s = StringTools.replace(s, '\n', '\\n');
			s = StringTools.replace(s, "'", "\\'");
			// js.Lib.eval('var {writeln} = require("ringo/term");');
			// js.Lib.eval('writeln(\'$s\');');
			js.Lib.eval('try { console.log(\'$s\'); } catch (e) { print(\'$s\'); }');
		#elseif php
			php.Web.setHeader('Content-Type', contentType);
			php.Lib.print(s);
		#elseif java
			Sys.println(s);
			results = s;
		#elseif neko
			neko.Lib.print(s);
		#else
			trace('must be run as either JS, PHP, Java or Neko');
		#end
	}

	// =========================================================================
	// test data
	// =========================================================================

	#if (php || java)
	function deliverTestData(key:String, args:Map<String,String>) {
		try {
			var parts = key.split('.');
			for (c in testcases) {
				var klass = Type.getClass(c.testcase);
				var name = Type.getClassName(klass);
				// remove package name
				name = ~/^(.+?\.)+/.replace(name, '');
				if (name == parts[0]) {
					var obj = c.testcase;
					var field = Reflect.field(obj, parts[1]);
					var text = Std.string(Reflect.callMethod(obj, field, [args]));
					var json = (StringTools.startsWith(text, "{") ||
								StringTools.startsWith(text, "["));
					output(text, (json ? 'text/json' : 'text/xml'));
					break;
				}
			}
		} catch (e:Dynamic) {
			#if php
				php.Web.setReturnCode(404);
			#end
		}
	}
	#end

}
