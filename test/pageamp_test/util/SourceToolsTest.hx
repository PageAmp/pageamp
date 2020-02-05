/*
 * Copyright (c) 2018-2019 Ubimate Technologies Ltd and Ub1 contributors.
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

package pageamp_test.util;

import pageamp.util.Test;

using pageamp.util.SourceTools;

class SourceToolsTest extends Test {

	public function testSrcDocument() {
		var doc = '<html><body> </body></html>'.srcDocument();
		assert(doc.srcString(), '<html><body> </body></html>');
	}

	public function testSrcRoot() {
		var doc = '<html><head/><body/></html>'.srcDocument();
		assert(doc.srcRoot().srcName(), 'html');
	}

	public function testSrcElements() {
		var doc = '<html> <head/><body/></html>'.srcDocument();
		var names = '';
		for (child in doc.srcRoot().srcElements()) {
			names != '' ? names += ', ' : null;
			names += child.srcName();
		}
		assert(names, 'head, body');
	}

	public function testSrcInnerHTML() {
		var doc = '<html><head> </head><body>text</body></html>'.srcDocument();
		assert(doc.srcRoot().srcInnerHTML(), '<head> </head><body>text</body>');
	}

	public function testSrcInnerText() {
		var doc = '<html><head> </head><body>text</body></html>'.srcDocument();
		assert(doc.srcRoot().srcInnerText(), ' text');
	}

	public function testSrcRemoveChild() {
		var doc = '<html><head> </head><body>text</body></html>'.srcDocument();
		var html = doc.srcRoot();
		var head = html.srcElements().next();
		html.srcRemoveChild(head);
		assert(doc.srcString(), '<html><body>text</body></html>');
	}

}
