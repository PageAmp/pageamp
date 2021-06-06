package ub1.server;

import ub1.server.HtmlParser;
import ub1.server.dom.*;
import haxe.io.Path;
import sys.io.File;
import utest.Assert;
import utest.Test;

class HtmlParserTest extends Test {
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/ub1/server/htmlparser']);
	}
	
	function test1() {
		var doc = HtmlParser.parse('<html></html>');
		Assert.notNull(doc);
		Assert.equals(1, doc.children.length);
		Assert.isTrue(Std.is(doc.children[0], HtmlElement));
		var e:HtmlElement = cast doc.children[0];
		Assert.equals('HTML', e.name);
		Assert.equals(0, e.children.length);
		Assert.equals(0, e.getAttributeNames().length);
	}

	function test2() {
		var doc = HtmlParser.parse('<html lang="en"></html>');
		Assert.notNull(doc);
		Assert.equals(1, doc.children.length);
		Assert.isTrue(Std.is(doc.children[0], HtmlElement));
		var e:HtmlElement = cast doc.children[0];
		Assert.equals('HTML', e.name);
		Assert.equals(0, e.children.length);
		Assert.equals(1, e.getAttributeNames().length);
		var a:HtmlAttribute = e.attributes.get('lang');
		Assert.notNull(a);
		Assert.equals('lang', a.name);
		Assert.equals('en', a.value);
		Assert.equals('"', a.quote);
	}

	function test3() {
		var html = '<html>\n'
		+ '<head>\n'
		+ '<title>\n'
		+ 'A Simple HTML Document\n'
		+ '</title>\n'
		+ '</head>\n'
		+ '<body>\n'
		+ '<p>This is a very simple HTML document</p>\n'
		+ '<p>It only has two paragraphs</p>\n'
		+ '</body>\n'
		+ '</html>';
		var doc = HtmlParser.parse(html);
		// dumpDoc(doc);
		Assert.equals(html, doc.toString());
		var counts = countNodes(doc);
		Assert.equals(6, counts.elements);
		Assert.equals(11, counts.texts);
		Assert.equals(0, counts.comments);
	}

	function test4() {
		var doc = HtmlParser.parse('<html :lang="en"></html>');
		var e = doc.getFirstElementChild();
		var a:HtmlAttribute = e.attributes.get(':lang');
		Assert.notNull(a);
		Assert.equals('en', a.value);
	}

	function test5() {
		var doc = HtmlParser.parse('<html><:mytag/></html>');
		Assert.equals('<html><:mytag></:mytag></html>', doc.toString());
	}

	function test6() {
		var doc = HtmlParser.parse('<html title=[[a[0]]]></html>');
		Assert.equals('<html title="a[0]"></html>', doc.toString());
	}

	function test100() {
		var msg = null;
		try {
			HtmlParser.parse('<html></div>');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals('literal:1 col 9: Found </DIV> instead of </HTML>', msg);
	}

	function test101() {
		var msg = null;
		try {
			HtmlParser.parse('<html>');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals('literal:1 col 7: expected </HTML>', msg);
	}

	function test102() {
		var msg = null;
		try {
			HtmlParser.parse('<html');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals('literal:1 col 6: Unterminated tag HTML', msg);
	}

	function test103() {
		var msg = null;
		try {
			HtmlParser.parse('<html lang></html>');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals(null, msg);
	}

	function test104() {
		var msg = null;
		try {
			HtmlParser.parse('<html lang=></html>');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals('literal:1 col 12: Missing attribute value', msg);
	}

	function test105() {
		var msg = null;
		try {
			HtmlParser.parse('<html>\n'
			+ '	<body>\n'
			+ '</html>');
		} catch (ex:Dynamic) {
			msg = ex.toString();
		}
		Assert.equals('literal:3 col 3: Found </HTML> instead of </BODY>', msg);
	}

	function test201() {
		var doc = HtmlParser.parse(
			'<div :data=[[ [{list:[1,2]},{list:[\'a\',\'b\']}] ]]></div>'
		);
		var root:HtmlElement = doc.getFirstElementChild();
		Assert.equals('DIV', root.name);
		Assert.equals(
			' [{list:[1,2]},{list:[\'a\',\'b\']}] ',
			root.attributes.get(':data').value
		);
	}

	function test202() {
		var doc = HtmlParser.parse('<div :data="[[ [
			{list:[1,2]},
			{list:[\'a\',\'b\']}
		] ]]"></div>');
		var root = doc.getFirstElementChild();
		Assert.equals('DIV', root.name);
		var a = root.attributes.get(':data');
		Assert.equals('"', a.quote);
		Assert.equals('[[ [
			{list:[1,2]},
			{list:[\'a\',\'b\']}
		] ]]', a.value
		);
	}

	function test203() {
		var doc = HtmlParser.parse('<div :data=[[ [
			{list:[1,2]},
			{list:[\'a\',\'b\']}
		] ]]></div>');
		var root = doc.getFirstElementChild();
		Assert.equals('DIV', root.name);
		var a = root.attributes.get(':data');
		Assert.equals('[', a.quote);
		Assert.equals(' [
			{list:[1,2]},
			{list:[\'a\',\'b\']}
		] ', a.value
		);
	}

	function test301() {
		var html = File.getContent(rootPath + '/google.txt');
		Assert.notNull(html);
		var doc = HtmlParser.parse(html);
		Assert.notNull(doc);
		var counts = countNodes(doc);
		Assert.equals(148, counts.elements);
		Assert.equals(268, counts.texts);
		Assert.equals(0, counts.comments);
		// File.saveContent(rootPath + '/google-out.txt', doc.toString());
	}

	// ===================================================================================
	// util
	// ===================================================================================

	function countNodes(doc:HtmlDocument): Dynamic {
		var ret = {elements: 0, texts:0, comments:0}
		var f = null;
		f = function(p:HtmlElement) {
			for (n in p.children) {
				if (n.type == HtmlNode.ELEMENT_NODE) {
					ret.elements++;
					f(cast n);
				} else if (n.type == HtmlNode.TEXT_NODE) {
					ret.texts++;
				} else if (n.type == HtmlNode.COMMENT_NODE) {
					ret.comments++;
				}
			}
		}
		f(doc);
		return ret;
	}

	function dumpDoc(e:HtmlElement, level=0) {
		var sb = new StringBuf();
		for (i in 0...level) sb.add('\t');
		for (n in e.children) {
			if (n.type == HtmlNode.ELEMENT_NODE) {
				trace(sb.toString() + '<' + (untyped n.name) + '>');
				dumpDoc(cast n, level + 1);
			} else if (n.type == HtmlNode.TEXT_NODE) {
				var s:String = untyped n.text;
				trace(sb.toString() + '"' + ~/\n/g.replace(s, '\\n') + '"');
			}
		}
	}

}
