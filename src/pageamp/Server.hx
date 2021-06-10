package pageamp;

import haxe.Json;
import pageamp.core.Page;
import pageamp.lib.Url;
import pageamp.server.Preprocessor;
import pageamp.server.ServerLoader;
import pageamp.server.dom.HtmlElement;
import pageamp.server.dom.HtmlText;

using pageamp.lib.DomTools;

class Server {
	public static inline var CLIENT_JS_PATHNAME = '/.pageamp/client/pageamp.js';
	
	public static function main() {}
	
	public static function load(root:String, uri:String, domain='localhost',
			addClient=true, clientUrlPrefix=''): Page {
		var url = new Url(uri);
		var doc = new Preprocessor(root).read(url.path);
		var page = ServerLoader.loadRoot(doc);
		page.context.refresh();
		if (addClient) {
			Server.addClient(page, clientUrlPrefix);
		}
		return page;
	}

	#if !debug inline #end
	static function addClient(p:Page, clientUrlPrefix:String) {
		// page properties
		var e = new HtmlElement(p.doc.domGetBody(), 'script', 0, 0, 0);
		var s = Common.PAGE_PROPS_VAR + ' = ' + Json.stringify(p.getProps()) + ';';
		new HtmlText(e, s, 0, 0, 0, false);
		// client code
		var e = p.doc.domCreateElement('script');
		e.domSet('src', clientUrlPrefix + CLIENT_JS_PATHNAME);
		e.setAttribute('defer', '');
		p.doc.domGetBody().domAddChild(e);
	}

}
