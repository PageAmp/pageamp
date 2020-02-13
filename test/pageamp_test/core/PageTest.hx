/*
 * Copyright (c) 2018-2020 Ubimate Technologies Ltd and PageAmp contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package pageamp_test.core;

import pageamp.core.*;
import pageamp.util.Test;
import pageamp.web.DomTools;
using pageamp.web.DomTools;

class PageTest extends Test {

	function testTestDoc() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var s = doc.domToString();
			assertHtml(s, '<html><head></head><body></body></html>');
			cleanup();
			didDelay();
		});
	}

	function testPage1() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var p = new Page(doc, {a_lang:'en', a_class:'app'});
			assertHtml(doc.domToString(), '<html lang="en"><head></head>'
			+ '<body class="app"></body></html>');
			p.set('a_lang', 'es');
			assertHtml(doc.domToString(), '<html lang="es"><head></head>'
			+ '<body class="app"></body></html>');
			p.set('a_class', 'demo');
			assertHtml(doc.domToString(), '<html lang="es"><head></head>'
			+ '<body class="demo"></body></html>');
			cleanup();
			didDelay();
		});
	}

	function testPage2() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var p = new Page(doc, null);
			assertHtml(doc.domToString(), '<html><head></head>'
			+ '<body></body></html>');
			p.set('a_lang', 'es');
			assertHtml(doc.domToString(), '<html lang="es"><head></head>'
			+ '<body></body></html>');
			p.set('a_class', 'demo');
			assertHtml(doc.domToString(), '<html lang="es"><head></head>'
			+ '<body class="demo"></body></html>');
			cleanup();
			didDelay();
		});
	}

	function testPage3() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var p = new Page(doc, null, function(p:Page) {
				new Element(p, {innerText:'foo'});
			});
			assertHtml(doc.domToString(), '<html><head></head>'
			+ '<body><div>foo</div></body></html>');
			cleanup();
			didDelay();
		});
	}

	function testPage4() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var p = new Page(doc, {v:'bar'}, function(p:Page) {
				new Element(p, {innerText:"v: ${v}"});
			});
			assertHtml(doc.domToString(), '<html><head></head>'
			+ '<body><div>v: bar</div></body></html>');
			cleanup();
			didDelay();
		});
	}

}
