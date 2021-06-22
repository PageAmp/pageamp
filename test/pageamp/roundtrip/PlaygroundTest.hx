package pageamp.roundtrip;

import haxe.io.Path;
import pageamp.Client;
import pageamp.Server;
import pageamp.core.Body;
import pageamp.core.Element;
import pageamp.core.Head;
import pageamp.core.Page;
import pageamp.server.HtmlParser;
import utest.Assert;
import utest.Test;

class PlaygroundTest extends Test {
	var idAttr = Element.ID_ATTR;
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/pageamp/roundtrip/playground']);
	}

	function test_01() {
		var page = Server.load(rootPath, '/samples/01_It-starts-with-HTML.html', null, false);
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
		// + '<script>pageampProps = ['
		// 	+ '{\"clone\":null,\"aka\":\"page\",\"id\":0,\"dom\":null},'
		// 	+ '{\"clone\":null,\"aka\":\"head\",\"id\":1,\"dom\":null},'
		// 	+ '{\"clone\":null,\"aka\":\"body\",\"id\":2,\"dom\":null}'
		// + '];</script>'
		// + '<script src="/.pageamp/client/pageamp.js"></script>'
		+ '</body>\n'
		+ '</html>', page.doc.toString());
	}

	function test_02() {
		var page = Server.load(rootPath, '/samples/02_Includes.html', null, false);
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
		// + '<script>pageampProps = ['
		// 	+ '{\"clone\":null,\"aka\":\"page\",\"id\":0,\"dom\":null},'
		// 	+ '{\"clone\":null,\"aka\":\"head\",\"id\":1,\"dom\":null},'
		// 	+ '{\"clone\":null,\"aka\":\"body\",\"id\":2,\"dom\":null}'
		// + '];</script>'
		// + '<script src="/.pageamp/client/pageamp.js"></script>'
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
		var serverPage = Server.load(rootPath, '/samples/03_Styling.html', null, false);
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
		var clientPage = Client.load(doc, pageProps);
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
		var serverPage = Server.load(rootPath, '/samples/04_Interaction.html', null, false);
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
		var clientPage = Client.load(doc, pageProps);
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
		body.set('event-click', {});
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
