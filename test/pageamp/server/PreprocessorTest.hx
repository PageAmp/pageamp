package pageamp.server;

import haxe.io.Path;
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
			var doc = new Preprocessor(rootPath).read('inexistent.txt');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals(
			'Could not read file inexistent.txt',
			msg
		);
	}

	function test001() {
		var doc = new Preprocessor(rootPath).read('test001.txt');
		Assert.equals('<html utf8-value="€"></html>', doc.toString());
	}

	function test002() {
		var doc = new Preprocessor(rootPath).read('test002.txt');
		Assert.equals('<html><div>Test 2</div></html>', doc.toString());
	}

	function test002includes() {
		var doc = new Preprocessor(rootPath).read('test002includes.txt');
		Assert.equals('<html><div>Test 2</div><div>Test 2</div></html>', doc.toString());
	}

	function test002imports() {
		var doc = new Preprocessor(rootPath).read('test002imports.txt');
		Assert.equals('<html><div>Test 2</div></html>', doc.toString());
	}

	function test003() {
		var msg = null;
		try {
			var doc = new Preprocessor(rootPath).read('test003.txt');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals('Forbidden file path "../dummy.txt"',
			msg
		);
	}

	function test004() {
		var msg = null;
		try {
			var doc = new Preprocessor(rootPath).read('test004.txt');
		} catch (ex:Dynamic) {
			msg = '' + ex;
		}
		Assert.equals(
			'test004.txt:1 col 8: Missing \"src\" attribute',
			msg
		);
	}

	function test005() {
		var doc = new Preprocessor(rootPath).read('test005.txt');
		Assert.equals('<html><div>Test 5</div></html>', doc.toString());
	}

	function testIncludedRootAttributesShouldPassToTargetElement() {
		var doc = new Preprocessor(rootPath).read('testIncludedRootAttributesShouldPassToTargetElement.txt');
		var head = doc.domGetHead();
		Assert.equals('1', head.getAttribute(':overriddenAttribute'));
		Assert.equals('hi', head.getAttribute(':attribute1'));
		Assert.equals('there', head.getAttribute(':attribute2'));
		Assert.equals('2', head.getAttribute(':attribute3'));
	}

	// ===================================================================================
	// macros
	// ===================================================================================

	function test101() {
		var doc = new Preprocessor(rootPath).read('test101.txt');
		Assert.equals('<html><div></div></html>', doc.toString());
	}

	function test102() {
		var doc = new Preprocessor(rootPath).read('test102.txt');
		Assert.equals('<html><span>[[text]]</span></html>', doc.toString());
	}

	function test103() {
		var doc = new Preprocessor(rootPath).read('test103.txt');
		Assert.equals('<html><span><b>[[text]]</b></span></html>', doc.toString());
	}

	function test104() {
		var doc = new Preprocessor(rootPath).read('test104.txt');
		Assert.equals(
			'<html><span class="title"><b>[[text]]</b>OK</span></html>',
			doc.toString()
		);
	}

	function test201() {
		var doc = new Preprocessor(rootPath).read('test201.txt');
		Assert.equals('<html>
				<body>
					<div class="pippo">localhost</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function test202() {
		var doc = new Preprocessor(rootPath).read('test202.txt');
		Assert.equals('<html>
				<body>
					<div class="pluto">localhost</div>
				</body>
			</html>'.normalizeText(),
			doc.toString().normalizeText()
		);
	}

	function test203() {
		var doc = new Preprocessor(rootPath).read('test203.txt');
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

}
