package ub1.server;

import haxe.io.Path;
import utest.Assert;
import utest.Test;

using ub1.lib.Util;

class PreprocessorTest extends Test {
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/ub1/server/preprocessor']);
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
		Assert.equals('<html></html>', doc.toString());
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
		Assert.equals('Forbidden file path "../dummy.html"',
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

}
