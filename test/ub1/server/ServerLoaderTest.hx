package ub1.server;

import ub1.core.Element;
import haxe.io.Path;
import utest.Assert;
import utest.Test;
using ub1.lib.DomTools;

class ServerLoaderTest extends Test {
	var idAttr = Element.ID_ATTR;
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/ub1/server/preprocessor']);
	}

	function test1() {
		var doc = HtmlParser.parse('<html>msg: [["OK"]] <div>[[":-)"]]...</div></html>');
		var p = ServerLoader.loadRoot(doc);
		Assert.equals('<html $idAttr="0"> <div $idAttr="1"> </div></html>', doc.toString());
		p.context.refresh();
		var s = doc.toString();
		Assert.equals('<html $idAttr="0">msg: OK <div $idAttr="1">:-)...</div></html>', s);
	}

	function test2() {
		var doc = HtmlParser.parse('<html :msg="-"><div>msg: [[msg]]</div></html>');
		var p = ServerLoader.loadRoot(doc);
		Assert.equals('<html $idAttr="0"><div $idAttr="1"> </div></html>', doc.toString());
		p.context.refresh();
		Assert.equals('<html $idAttr="0"><div $idAttr="1">msg: -</div></html>', doc.toString());
		p.set('msg', 'HI!');
		Assert.equals('<html $idAttr="0"><div $idAttr="1">msg: HI!</div></html>', doc.toString());
	}

	function testRootTagHasItsNamedScope() {
		var doc = HtmlParser.parse('<html>
		<head>
			<style>
				body {
					color: red;
				}
			</style>
		</head>
		<body>
			<h1>title</h1>
			<p>text</p>
		</body>
		</html>');
		var p = ServerLoader.loadRoot(doc);
		Assert.equals(p.get('page'), p);
	}
	
	function testDirectChldrenOfHtmlTagHaveTheirNamedScope() {
		var doc = HtmlParser.parse('<html>
		<head>
			<style>
				body {
					color: red;
				}
			</style>
		</head>
		<body>
			<h1>title</h1>
			<p>text</p>
		</body>
		</html>');
		var p = ServerLoader.loadRoot(doc);
		Assert.equals(3, p.countScopes());
		Assert.equals(doc.domGetHead(), p.get('head').dom);
		Assert.equals(doc.domGetBody(), p.get('body').dom);
	}

	function testHeadAndBodyHaveSpecialElements() {
		var doc = HtmlParser.parse('<html>
		<head>
			<style>
				body {
					color: red;
				}
			</style>
		</head>
		<body>
			<h1>title</h1>
			<p>text</p>
		</body>
		</html>');
		var p = ServerLoader.loadRoot(doc);
		Assert.equals('ub1.core.Head', Type.getClassName(Type.getClass(p.get('head'))));
		Assert.equals('ub1.core.Body', Type.getClassName(Type.getClass(p.get('body'))));
	}

}
