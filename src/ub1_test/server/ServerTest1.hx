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

package ub1_test.server;

import htmlparser.HtmlDocument;
import haxe.Http;
import ub1.util.Test;
import ub1_test.Ub1Suite.Server;
using StringTools;

class ServerTest1 extends Test {
	public static inline var BASEURL = Server.BASEURL + '1/';

	/*
	missing file
	 */
	function test0() {
		try {
			Http.requestUrl(BASEURL + 0);
			assertBool(false, '404 was expected');
		} catch (e:Dynamic) {
			assert('$e', 'Http Error #404');
		}
	}

	/*
	empty file
	 */
	function test1() {
		try {
			Http.requestUrl(BASEURL + 1);
			assertBool(false, '404 was expected');
		} catch (e:Dynamic) {
			assert('$e', 'Http Error #404');
		}
	}

	/*
	minimal file
	 */
	function test2() {
		var s = getVerbatimPage(2);
		assert(s, '<!DOCTYPE html>\n'
		+ '<html><head></head><body id="ub1_1">'
		+ '<script>ub1_props = {'
			+ '"pageFSPath":"__ub1/domains/localhost/__ub1_test/server/1",'
			+ '"pageURI":{'
				+ '"protocol":null,'
				+ '"domain":"localhost",'
				+ '"path":"/__ub1_test/server/1/2",'
				+ '"query":null,'
				+ '"params":null,'
				+ '"paramCount":-1,'
				+ '"pathSlices":null'
			+ '},'
			+ '"n_id":1'
		+ '};</script>\n'
		+ '<script src="/__ub1/client/bin/ub1.js" async="async"></script>\n'
		+ '</body></html>');
		s = removeClient(s);
		assert(s, '<!DOCTYPE html>\n'
		+ '<html><head></head><body id="ub1_1"></body></html>');
	}

	// =========================================================================
	// utilities
	// =========================================================================

	public static function getVerbatimPage(id:Int): String {
		var s = Http.requestUrl(BASEURL + id);
		s = s.replace('\\/', '/');
		s = s.replace('ub1.min.js', 'ub1.js');
		return s;
	}

	public static function getCleanPage(id:Int): String {
		var s = Http.requestUrl(BASEURL + id);
		s = removeClient(s);
		return s;
	}

	public static function removeClient(s:String): String {
		s = ~/(<script>ub1_props.+?<\/script>\s)/.replace(s, '');
		s = ~/(<script src=".+?\/ub1\.(min\.)?js".+?<\/script>\s)/.replace(s, '');
		return s;
	}

}
