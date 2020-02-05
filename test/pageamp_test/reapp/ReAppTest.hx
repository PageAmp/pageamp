package pageamp_test.reapp;

import reapp1.core.*;
import pageamp.util.Test;

import pageamp.web.DomTools;
using pageamp.web.DomTools;

class ReAppTest extends Test {

	function test1() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			assertHtml(doc.domToString(),
			'<html><head></head><body></body></html>');
			var app = new ReApp(doc, null);
			assertHtml(doc.domToString(),
			'<html><head></head><body></body></html>');
			cleanup();
			didDelay();
		});
	}

}
