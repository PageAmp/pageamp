package pageamp.core;

import pageamp.server.ServerLoader;
import pageamp.server.HtmlParser;
import utest.Assert;
import utest.Test;

using pageamp.lib.DomTools;

class ElementTest extends Test {
	
	function test1() {
		var doc = HtmlParser.parse('<html></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals(0, e.id);
		Assert.equals('<html data-id="0"></html>', doc.toString());
	}

	function test2() {
		var doc = HtmlParser.parse('<html lang=[["en"]]></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0" lang=""></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-id="0" lang="en"></html>', doc.toString());
	}

	function test3() {
		var doc = HtmlParser.parse('<html>msg: [["hi!"]]</html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"> </html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-id="0">msg: hi!</html>', doc.toString());
	}

	// ===================================================================================
	// class attributes
	// ===================================================================================

	function testClass1() {
		var doc = HtmlParser.parse('<html :c_app="true"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html class="app" data-id="0"></html>', doc.toString());
		e.set('c_app', false);
		Assert.equals('<html data-id="0"></html>', doc.toString());
	}

	function testClass2() {
		var doc = HtmlParser.parse('<html :c_appSection="true"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html class="app-section" data-id="0"></html>', doc.toString());
		e.set('c_appSection', false);
		Assert.equals('<html data-id="0"></html>', doc.toString());
	}

	// ===================================================================================
	// style attributes
	// ===================================================================================

	function testStyle1() {
		var doc = HtmlParser.parse('<html :s_display="block"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals(
			'<html data-id="0" style="display:block"></html>', doc.toString());
		e.set('s_display', 'none');
		Assert.equals(
			'<html data-id="0" style="display:none"></html>', doc.toString());
		e.set('s_display', null);
		Assert.equals('<html data-id="0"></html>', doc.toString());
	}

	function testStyle2() {
		var doc = HtmlParser.parse('<html :s_paddingBottom="1em"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals(
			'<html data-id="0" style="padding-bottom:1em"></html>', doc.toString());
		e.set('s_paddingBottom', '0');
		Assert.equals(
			'<html data-id="0" style="padding-bottom:0"></html>', doc.toString());
		e.set('s_paddingBottom', null);
		Assert.equals('<html data-id="0"></html>', doc.toString());
	}

	// ===================================================================================
	// data binding
	// ===================================================================================

	function testData1() {
		var doc = HtmlParser.parse(
			'<html :data=[[{title:"hi!"}]]>msg: [[data.title]]</html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-id="0"> </html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-id="0">msg: hi!</html>', doc.toString());
	}

	function testData2() {
		var doc = HtmlParser.parse('<html :data=[[{title:"hi!"}]]>'
		+ '<div :data=[[parent.data.title]]>msg: [[data]]</div>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals(
			'<html data-id="0"><div data-id="1">msg: hi!</div></html>',
			doc.toString());
	}

	// ===================================================================================
	// replication
	// ===================================================================================

	function testReplication1() {
		var doc = HtmlParser.parse('<html>'
		+ '<div :data=[[ ["hi", "ciao", "hello"] ]]>msg: [[data]]!</div>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals('<html data-id="0">'
		+ '<div data-clone="0" data-id="1">msg: hi!</div>'
		+ '<div data-clone="1" data-id="1">msg: ciao!</div>'
		+ '<div data-id="1">msg: hello!</div>'
		+ '</html>', doc.toString());
	}

	function testReplication2() {
		var doc = HtmlParser.parse('<html>'
		+ '<div :data=[[ ["hi", "hello"] ]]><span>msg: [[data]]!</span></div>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals('<html data-id="0">'
		+ '<div data-clone="0" data-id="1"><span data-id="2">msg: hi!</span></div>'
		+ '<div data-id="1"><span data-id="2">msg: hello!</span></div>'
		+ '</html>', doc.toString());
	}

	function testReplication3() {
		var doc = HtmlParser.parse('<ul :data=[[{list:[1, 2, 3]}]]>'
		+ '<li :data=[[parent.data.list]]><span>nr: [[data]]</span></li>'
		+ '</ul>');
		var p = ServerLoader.loadRoot(doc);

		p.context.refresh();
		Assert.equals('<ul data-id=\"0\">'
		+ '<li data-clone=\"0\" data-id=\"1\"><span data-id=\"2\">nr: 1</span></li>'
		+ '<li data-clone=\"1\" data-id=\"1\"><span data-id=\"2\">nr: 2</span></li>'
		+ '<li data-id=\"1\"><span data-id=\"2\">nr: 3</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:['a', 'b', 'c']});
		Assert.equals('<ul data-id=\"0\">'
		+ '<li data-clone=\"0\" data-id=\"1\"><span data-id=\"2\">nr: a</span></li>'
		+ '<li data-clone=\"1\" data-id=\"1\"><span data-id=\"2\">nr: b</span></li>'
		+ '<li data-id=\"1\"><span data-id=\"2\">nr: c</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:[1, 2, 3, 4]});
		Assert.equals('<ul data-id=\"0\">'
		+ '<li data-clone=\"0\" data-id=\"1\"><span data-id=\"2\">nr: 1</span></li>'
		+ '<li data-clone=\"1\" data-id=\"1\"><span data-id=\"2\">nr: 2</span></li>'
		+ '<li data-clone=\"2\" data-id=\"1\"><span data-id=\"2\">nr: 3</span></li>'
		+ '<li data-id=\"1\"><span data-id=\"2\">nr: 4</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:['a', 'b', 'c', 'd']});
		Assert.equals('<ul data-id=\"0\">'
		+ '<li data-clone=\"0\" data-id=\"1\"><span data-id=\"2\">nr: a</span></li>'
		+ '<li data-clone=\"1\" data-id=\"1\"><span data-id=\"2\">nr: b</span></li>'
		+ '<li data-clone=\"2\" data-id=\"1\"><span data-id=\"2\">nr: c</span></li>'
		+ '<li data-id=\"1\"><span data-id=\"2\">nr: d</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:[1, 2, 3]});
		Assert.equals('<ul data-id=\"0\">'
		+ '<li data-clone=\"0\" data-id=\"1\"><span data-id=\"2\">nr: 1</span></li>'
		+ '<li data-clone=\"1\" data-id=\"1\"><span data-id=\"2\">nr: 2</span></li>'
		+ '<li data-id=\"1\"><span data-id=\"2\">nr: 3</span></li>'
		+ '</ul>', doc.toString());
	}

	function testReplication4() {
		var doc = HtmlParser.parse('<div>'
		+ '<ul :data=[[ [{list:[1,2]}, {list:["a","b","c"]}] ]]>'
			+ '<li :data=[[parent.data.list]]>[[data]]</li>'
		+ '</ul>'
		+ '</div>');
		var p = ServerLoader.loadRoot(doc);

		p.context.refresh();
		Assert.equals('<div data-id=\"0\">'
		+ '<ul data-clone=\"0\" data-id=\"1\">'
			+ '<li data-clone=\"0\" data-id=\"2\">1</li>'
			+ '<li data-id=\"2\">2</li>'
		+ '</ul>'
		+ '<ul data-id=\"1\">'
			+ '<li data-clone=\"0\" data-id=\"2\">a</li>'
			+ '<li data-clone=\"1\" data-id=\"2\">b</li>'
			+ '<li data-id=\"2\">c</li>'
		+ '</ul>'
		+ '</div>', doc.toString());
	}

}
