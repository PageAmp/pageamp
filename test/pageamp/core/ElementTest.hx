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
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
	}

	function test2() {
		var doc = HtmlParser.parse('<html lang=[["en"]]></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0" lang=""></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-pa-id="0" lang="en"></html>', doc.toString());
	}

	function test3() {
		var doc = HtmlParser.parse('<html>msg: [["hi!"]]</html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"> </html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-pa-id="0">msg: hi!</html>', doc.toString());
	}

	// ===================================================================================
	// class attributes
	// ===================================================================================

	function testClass1() {
		var doc = HtmlParser.parse('<html :class-app="true"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html class="app" data-pa-id="0"></html>', doc.toString());
		e.set('class-app', false);
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
	}

	function testClass2() {
		var doc = HtmlParser.parse('<html :class-appSection="true"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html class="app-section" data-pa-id="0"></html>', doc.toString());
		e.set('class-appSection', false);
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
	}

	// ===================================================================================
	// style attributes
	// ===================================================================================

	function testStyle1() {
		var doc = HtmlParser.parse('<html :style-display="block"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals(
			'<html data-pa-id="0" style="display:block"></html>', doc.toString());
		e.set('style-display', 'none');
		Assert.equals(
			'<html data-pa-id="0" style="display:none"></html>', doc.toString());
		e.set('style-display', null);
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
	}

	function testStyle2() {
		var doc = HtmlParser.parse('<html :style-paddingBottom="1em"></html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
		e.context.refresh();
		Assert.equals(
			'<html data-pa-id="0" style="padding-bottom:1em"></html>', doc.toString());
		e.set('style-paddingBottom', '0');
		Assert.equals(
			'<html data-pa-id="0" style="padding-bottom:0"></html>', doc.toString());
		e.set('style-paddingBottom', null);
		Assert.equals('<html data-pa-id="0"></html>', doc.toString());
	}

	// ===================================================================================
	// data binding
	// ===================================================================================

	function testData1() {
		var doc = HtmlParser.parse(
			'<html :data=[[{title:"hi!"}]]>msg: [[data.title]]</html>');
		var root = doc.domGetRootElement();
		var e = new Page(doc, ServerLoader.getElementProps(root));
		Assert.equals('<html data-pa-id="0"> </html>', doc.toString());
		e.context.refresh();
		Assert.equals('<html data-pa-id="0">msg: hi!</html>', doc.toString());
	}

	function testData2() {
		var doc = HtmlParser.parse('<html :data=[[{title:"hi!"}]]>'
		+ '<div :data=[[parent.data.title]]>msg: [[data]]</div>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals(
			'<html data-pa-id="0"><div data-pa-id="1">msg: hi!</div></html>',
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
		Assert.equals('<html data-pa-id="0">'
		+ '<div data-pa-clone="0" data-pa-id="1">msg: hi!</div>'
		+ '<div data-pa-clone="1" data-pa-id="1">msg: ciao!</div>'
		+ '<div data-pa-id="1">msg: hello!</div>'
		+ '</html>', doc.toString());
	}

	function testReplication2() {
		var doc = HtmlParser.parse('<html>'
		+ '<div :data=[[ ["hi", "hello"] ]]><span>msg: [[data]]!</span></div>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals('<html data-pa-id="0">'
		+ '<div data-pa-clone="0" data-pa-id="1"><span data-pa-id="2">msg: hi!</span></div>'
		+ '<div data-pa-id="1"><span data-pa-id="2">msg: hello!</span></div>'
		+ '</html>', doc.toString());
	}

	function testReplication3() {
		var doc = HtmlParser.parse('<ul :data=[[{list:[1, 2, 3]}]]>'
		+ '<li :data=[[parent.data.list]]><span>nr: [[data]]</span></li>'
		+ '</ul>');
		var p = ServerLoader.loadRoot(doc);

		p.context.refresh();
		Assert.equals('<ul data-pa-id=\"0\">'
		+ '<li data-pa-clone=\"0\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 1</span></li>'
		+ '<li data-pa-clone=\"1\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 2</span></li>'
		+ '<li data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 3</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:['a', 'b', 'c']});
		Assert.equals('<ul data-pa-id=\"0\">'
		+ '<li data-pa-clone=\"0\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: a</span></li>'
		+ '<li data-pa-clone=\"1\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: b</span></li>'
		+ '<li data-pa-id=\"1\"><span data-pa-id=\"2\">nr: c</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:[1, 2, 3, 4]});
		Assert.equals('<ul data-pa-id=\"0\">'
		+ '<li data-pa-clone=\"0\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 1</span></li>'
		+ '<li data-pa-clone=\"1\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 2</span></li>'
		+ '<li data-pa-clone=\"2\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 3</span></li>'
		+ '<li data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 4</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:['a', 'b', 'c', 'd']});
		Assert.equals('<ul data-pa-id=\"0\">'
		+ '<li data-pa-clone=\"0\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: a</span></li>'
		+ '<li data-pa-clone=\"1\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: b</span></li>'
		+ '<li data-pa-clone=\"2\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: c</span></li>'
		+ '<li data-pa-id=\"1\"><span data-pa-id=\"2\">nr: d</span></li>'
		+ '</ul>', doc.toString());

		p.set('data', {list:[1, 2, 3]});
		Assert.equals('<ul data-pa-id=\"0\">'
		+ '<li data-pa-clone=\"0\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 1</span></li>'
		+ '<li data-pa-clone=\"1\" data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 2</span></li>'
		+ '<li data-pa-id=\"1\"><span data-pa-id=\"2\">nr: 3</span></li>'
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
		Assert.equals('<div data-pa-id=\"0\">'
		+ '<ul data-pa-clone=\"0\" data-pa-id=\"1\">'
			+ '<li data-pa-clone=\"0\" data-pa-id=\"2\">1</li>'
			+ '<li data-pa-id=\"2\">2</li>'
		+ '</ul>'
		+ '<ul data-pa-id=\"1\">'
			+ '<li data-pa-clone=\"0\" data-pa-id=\"2\">a</li>'
			+ '<li data-pa-clone=\"1\" data-pa-id=\"2\">b</li>'
			+ '<li data-pa-id=\"2\">c</li>'
		+ '</ul>'
		+ '</div>', doc.toString());
	}

	// ===================================================================================
	// handlers
	// ===================================================================================

	function testHandler1() {
		var doc = HtmlParser.parse('<html>'
		+ '<body :v="1" :on-v=[[dom.innerHTML = v]]></body>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals('<html data-pa-id="0"><body data-pa-id="1">1</body></html>', doc.toString());
		var body:Element = p.get('body');
		body.set('v', '2');
		Assert.equals('<html data-pa-id="0"><body data-pa-id="1">2</body></html>', doc.toString());
	}

	// ===================================================================================
	// functions
	// ===================================================================================

	function testFunction1() {
		var doc = HtmlParser.parse('<html>'
		+ '<body :v=[[f()]] :f=[[function() {return 1;}]]>[[v]]</body>'
		+ '</html>');
		var p = ServerLoader.loadRoot(doc);
		p.context.refresh();
		Assert.equals('<html data-pa-id="0"><body data-pa-id="1">1</body></html>', doc.toString());
	}

}
