/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.server;

import htmlparser.*;

class PreprocessorParser extends HtmlParser {
	static var patched = false;

	static function patch() {
		// bbmark: allow one or more ':' as an id prefix and inhibit
		// XML-style namespacing
		HtmlParser.reNamespacedID = ":*[a-z](?:-?[_a-z0-9])*";

		HtmlParser.reCDATA = "[<]!\\[CDATA\\[[\\s\\S]*?\\]\\][>]";
		HtmlParser.reScript = "[<]\\s*script\\s*([^>]*)>([\\s\\S]*?)"
		+ "<\\s*/\\s*script\\s*>";
		HtmlParser.reStyle = "<\\s*style\\s*([^>]*)>([\\s\\S]*?)"
		+ "<\\s*/\\s*style\\s*>";
		HtmlParser.reElementOpen = "<\\s*(" + HtmlParser.reNamespacedID + ")";
		HtmlParser.reAttr = HtmlParser.reNamespacedID
		+ "(?:\\s*=\\s*(?:'[^']*?'|\"[^\"]*?\"|[-_a-z0-9]+))?";
		HtmlParser.reElementEnd = "(/)?\\s*>";
		HtmlParser.reElementClose = "<\\s*/\\s*("
		+ HtmlParser.reNamespacedID + ")\\s*>";
		HtmlParser.reComment = "<!--[\\s\\S]*?-->";

		HtmlParser.reMain = new EReg("(" + HtmlParser.reCDATA + ")|("
		+ HtmlParser.reScript + ")|(" + HtmlParser.reStyle + ")|("
		+ HtmlParser.reElementOpen + "((?:\\s+"
		+ HtmlParser.reAttr +")*)\\s*" + HtmlParser.reElementEnd
		+ ")|(" + HtmlParser.reElementClose + ")|("
		+ HtmlParser.reComment + ")", "ig");

		HtmlParser.reParseAttrs = new EReg("(" + HtmlParser.reNamespacedID
		+ ")(?:\\s*=\\s*('[^']*'|\"[^\"]*\"|[-_a-z0-9]+))?" , "ig");

		patched = true;
	}

	public static function parseDoc(s:String): HtmlDocument {
		!patched ? patch() : null;
		return new HtmlDocument(s, true);
	}

}