package ub1;

import haxe.Json;
import ub1.core.Page;
import ub1.lib.Url;
import ub1.server.Preprocessor;
import ub1.server.ServerLoader;
import ub1.server.dom.HtmlElement;
import ub1.server.dom.HtmlText;

using ub1.lib.DomTools;

class Ub1Server {
	
	public static function main() {}
	
	public static function load(root:String, uri:String, domain='localhost', addClient=true): Page {
		var url = new Url(uri);
		var doc = new Preprocessor(root).read(url.path);
		var page = ServerLoader.loadRoot(doc);
		page.context.refresh();
		if (addClient) {
			Ub1Server.addClient(page);
		}
		return page;
	}

	#if !debug inline #end
	static function addClient(p:Page) {
		// page properties
		var e = new HtmlElement(p.doc.domGetBody(), 'script', 0, 0, 0);
		var s = Ub1Common.PAGE_PROPS_VAR + ' = ' + Json.stringify(p.getProps()) + ';';
		new HtmlText(e, s, 0, 0, 0, false);
		// client code
		var e = p.doc.domCreateElement('script');
		e.domSet('src', '/.ub1/client/ub1.js');
		p.doc.domGetBody().domAddChild(e);
	}

}
