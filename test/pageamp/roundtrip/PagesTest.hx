package pageamp.roundtrip;

import haxe.io.Path;
import pageamp.Server;
import pageamp.core.Element;
import utest.Assert;
import utest.Test;

class PagesTest extends Test {
	var idAttr = Element.ID_ATTR;
	var rootPath: String;
	
	function setupClass() {
		rootPath = Path.join([Sys.getCwd(), 'test/pageamp/roundtrip/pages']);
	}

	function test210616() {
		var page = Server.load(rootPath, '/test210616.txt', null, false);
		Assert.equals('', page.doc.toString());
	}

}
