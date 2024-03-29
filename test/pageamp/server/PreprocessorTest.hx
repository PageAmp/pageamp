package pageamp.server;

import haxe.io.Path;
import pageamp.core.Page;
import utest.Assert;
import utest.Test;

using pageamp.lib.DomTools;
using pageamp.lib.Util;

class PreprocessorTest extends Test {
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/pageamp/server/preprocessor']);
	}

	function test0() {
		var msg = null;
		try {
			var doc = new Preprocessor(rootPath).read('inexistent.html');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals(
			'Could not read file inexistent.html',
			msg
		);
	}

	function test001() {
		var doc = new Preprocessor(rootPath).read('test001.html');
		Assert.equals('<html utf8-value="€"></html>', doc.toString());
	}

	function test002() {
		var doc = new Preprocessor(rootPath).read('test002.html');
		Assert.equals('<html><div>Test 2</div></html>', doc.toString());
	}

	function test002includes() {
		var doc = new Preprocessor(rootPath).read('test002includes.html');
		Assert.equals('<html><div>Test 2</div><div>Test 2</div></html>', doc.toString());
	}

	function test002imports() {
		var doc = new Preprocessor(rootPath).read('test002imports.html');
		Assert.equals('<html><div>Test 2</div></html>', doc.toString());
	}

	function test003() {
		var msg = null;
		try {
			var doc = new Preprocessor(rootPath).read('test003.html');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals('Forbidden file path "../dummy.htm"',
			msg
		);
	}

	function test004() {
		var msg = null;
		try {
			var doc = new Preprocessor(rootPath).read('test004.html');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals(
			'test004.html:1 col 8: Missing \"src\" attribute',
			msg
		);
	}

	function test005() {
		var doc = new Preprocessor(rootPath).read('test005.html');
		Assert.equals('<html><div>Test 5</div></html>', doc.toString());
	}

	function testIncludedRootAttributesShouldPassToTargetElement() {
		var doc = new Preprocessor(rootPath).read('testIncludedRootAttributesShouldPassToTargetElement.html');
		var head = doc.domGetHead();
		Assert.equals('1', head.getAttribute(':overriddenAttribute'));
		Assert.equals('hi', head.getAttribute(':attribute1'));
		Assert.equals('there', head.getAttribute(':attribute2'));
		Assert.equals('2', head.getAttribute(':attribute3'));
	}

	function testTextualInclude() {
		var doc = new Preprocessor(rootPath).read('testTextualInclude.html');
		Assert.equals('<html><body>This is a "text"</body></html>', doc.toString());
	}

	// ===================================================================================
	// macros
	// ===================================================================================

	function test101() {
		var doc = new Preprocessor(rootPath).read('test101.html');
		Assert.equals('<html><div></div></html>', doc.toString());
	}

	function test102() {
		var doc = new Preprocessor(rootPath).read('test102.html');
		Assert.equals('<html><span>[[text]]</span></html>', doc.toString());
	}

	function test103() {
		var doc = new Preprocessor(rootPath).read('test103.html');
		Assert.equals('<html><span><b>[[text]]</b></span></html>', doc.toString());
	}

	function test104() {
		var doc = new Preprocessor(rootPath).read('test104.html');
		Assert.equals(
			'<html><span class="title"><b>[[text]]</b>OK</span></html>',
			doc.toString()
		);
	}

	function test201() {
		var doc = new Preprocessor(rootPath).read('test201.html');
		Assert.equals('<html>
				<body>
					<div class="pippo">localhost</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function test202() {
		var doc = new Preprocessor(rootPath).read('test202.html');
		Assert.equals('<html>
				<body>
					<div class="pluto">localhost</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function test203() {
		var doc = new Preprocessor(rootPath).read('test203.html');
		Assert.equals('<html>
				<body>
					
					<div class="pippo">
						title: <b>localhost</b>
					</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function test204() {
		var doc = new Preprocessor(rootPath).read('test204.html');
		Assert.equals('<html>
				<head>
				</head>
				<body>
					<div class=\"kit-page\">
						<div class=\"kit-nav\"></div>
					</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function testNestedMacros1() {
		var doc = new Preprocessor(rootPath).read('testNestedMacros1.html');
		var page = ServerLoader.loadRoot(doc);
		page.refresh();
		page.set(Page.PAGE_SCROLL_Y, 44);
		Assert.equals('<html data-pa-id=\"0\">
			<head data-pa-id=\"1\">
			</head>
			<body data-pa-id=\"2\">
				<div class=\"kit-page\">
					<div class=\"kit-nav\"><div data-pa-id=\"3\">44 (0)</div></div>
				</div>
			</body>
		</html>'.normalizeText(), doc.toString().normalizeText());
	}

}
