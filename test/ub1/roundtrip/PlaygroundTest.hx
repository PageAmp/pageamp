package ub1.roundtrip;

import haxe.Json;
import ub1.server.HtmlParser;
import haxe.io.Path;
import ub1.Ub1Client;
import ub1.Ub1Server;
import ub1.core.Body;
import ub1.core.Element;
import ub1.core.Head;
import ub1.core.Page;
import utest.Assert;
import utest.Test;

class PlaygroundTest extends Test {
	var idAttr = Element.ID_ATTR;
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/ub1/roundtrip/playground']);
	}

	function test_01() {
		var page = Ub1Server.load(rootPath, '/samples/01_It-starts-with-HTML.txt', null, false);
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style>\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: red;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="2">\n'
		+ '\n'
		+ '\tA plain HTML page\n'
		+ '\n'
		// + '<script>ub1Props = ['
		// 	+ '{\"clone\":null,\"name\":\"page\",\"id\":0,\"dom\":null},'
		// 	+ '{\"clone\":null,\"name\":\"head\",\"id\":1,\"dom\":null},'
		// 	+ '{\"clone\":null,\"name\":\"body\",\"id\":2,\"dom\":null}'
		// + '];</script>'
		// + '<script src="/.ub1/client/ub1.js"></script>'
		+ '</body>\n'
		+ '</html>', page.doc.toString());
	}

	function test_02() {
		var page = Ub1Server.load(rootPath, '/samples/02_Includes.txt', null, false);
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t\n'
		+ '\t<style>\n'
		+ '\tbody {\n'
		+ '\t\tcolor: red;\n'
		+ '\t\tfont-family: sans-serif;\n'
		+ '\t}\n'
		+ '\t</style>\n'
		+ '\n'
		+ '</head>\n'
		+ '<body $idAttr="2">\n'
		+ '\n'
		+ '\tA plain HTML page w/ include\n'
		+ '\n'
		// + '<script>ub1Props = ['
		// 	+ '{\"clone\":null,\"name\":\"page\",\"id\":0,\"dom\":null},'
		// 	+ '{\"clone\":null,\"name\":\"head\",\"id\":1,\"dom\":null},'
		// 	+ '{\"clone\":null,\"name\":\"body\",\"id\":2,\"dom\":null}'
		// + '];</script>'
		// + '<script src="/.ub1/client/ub1.js"></script>'
		+ '</body>\n'
		+ '</html>', page.doc.toString());
		// expected scopes: page, head and body
		Assert.equals(3, page.countScopes());
		Assert.isTrue(Std.isOfType(page.get('page'), Page));
		Assert.isTrue(Std.isOfType(page.get('head'), Head));
		Assert.isTrue(Std.isOfType(page.get('body'), Body));
	}

	function test_03() {
		//
		// server
		//
		var serverPage = Ub1Server.load(rootPath, '/samples/03_Styling.txt', null, false);
		serverPage.set('color', 'red');
		var serverHTML = serverPage.doc.toString();
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style $idAttr="2">\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: red;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="3">\n'
		+ '\n'
		+ '\tThis text is red\n'
		+ '\n'
		+ '</body>\n'
		+ '</html>', serverHTML);
		// expected scopes: page, head, style and body
		Assert.equals(4, serverPage.countScopes());
		var head:Head = serverPage.get('head');
		Assert.equals(1, head.childScopes.length);
		var style:Element = cast head.childScopes[0];
		Assert.equals(1, style.countRefreshableValues());
		//
		// client
		//
		var doc = HtmlParser.parse(serverHTML);
		var pageProps = serverPage.getProps();
		var clientPage = Ub1Client.load(doc, pageProps);
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style $idAttr="2">\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: red;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="3">\n'
		+ '\n'
		+ '\tThis text is red\n'
		+ '\n'
		+ '</body>\n'
		+ '</html>', clientPage.doc.toString());
		// expected scopes: page, head, style and body
		Assert.equals(4, clientPage.countScopes());
		var head:Head = clientPage.get('head');
		Assert.equals(1, head.childScopes.length);
		var style:Element = cast head.childScopes[0];
		Assert.equals(1, style.countRefreshableValues());
	}

	function test_04() {
		//
		// server
		//
		var serverPage = Ub1Server.load(rootPath, '/samples/04_Interaction.txt', null, false);
		var serverHTML = serverPage.doc.toString();
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style data-id="2">\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: blue;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t\t-moz-user-select: none;-webkit-user-select: none;-ms-user-select: none;user-select: none;\n'
		+ '\t\t\tcursor: pointer;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="3">\n'
		+ '\n'
		+ '\tClick this blue text\n'
		+ '\n'
		+ '</body>\n'
		+ '</html>', serverHTML);
		//
		// client
		//
		var doc = HtmlParser.parse(serverHTML);
		var pageProps = serverPage.getProps();
		var clientPage = Ub1Client.load(doc, pageProps);
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style data-id="2">\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: blue;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t\t-moz-user-select: none;-webkit-user-select: none;-ms-user-select: none;user-select: none;\n'
		+ '\t\t\tcursor: pointer;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="3">\n'
		+ '\n'
		+ '\tClick this blue text\n'
		+ '\n'
		+ '</body>\n'
		+ '</html>', clientPage.doc.toString());
		
		var body:Element = clientPage.get('body');
		body.set('ev_click', {});
		Assert.equals('<html $idAttr="0">\n'
		+ '<head $idAttr="1">\n'
		+ '\t<style data-id="2">\n'
		+ '\t\tbody {\n'
		+ '\t\t\tcolor: red;\n'
		+ '\t\t\tfont-family: sans-serif;\n'
		+ '\t\t\t-moz-user-select: none;-webkit-user-select: none;-ms-user-select: none;user-select: none;\n'
		+ '\t\t\tcursor: pointer;\n'
		+ '\t\t}\n'
		+ '\t</style>\n'
		+ '</head>\n'
		+ '<body $idAttr="3">\n'
		+ '\n'
		+ '\tClick this red text\n'
		+ '\n'
		+ '</body>\n'
		+ '</html>', clientPage.doc.toString());
	}

}
