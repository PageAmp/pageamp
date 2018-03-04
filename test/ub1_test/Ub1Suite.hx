/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
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

package ub1_test;

import ub1_test.core.*;
import ub1_test.data.*;
import ub1_test.react.*;
import ub1_test.util.*;
import ub1_test.web.*;
import ub1.util.Test;
#if client
	import ub1_test.client.*;
#end
#if server
	import ub1_test.server.*;
#end

class Ub1Suite extends TestRoot {

	static public function main() {
		new Ub1Suite(function(p:Test) {
#if client
			new Client(p, function(p:Test) {
				new ClientTest1(p);
			});
#end
#if server
			new Server(p, function(p:Test) {
				new ServerTest1(p);
				new ServerTest2(p);
			});
#end
			new Core(p, function(p:Test) {
				new DefineTest(p);
				new ElementTest(p);
				new PageTest(p);
			});
			new Data(p, function(p:Test) {
				new DataPathTest(p);
			});
			new React(p, function(p:Test) {
				new ScopeTest(p);
				new ValueTest(p);
			});
			new Util(p, function(p:Test) {
				new UrlTest(p);
			});
			new Web(p, function(p:Test) {
				new DomToolsTest(p);
			});
		}, null, 'http://localhost/__ubr_test/php/index.php?rpc=');
	}

}

class Client extends Test {}
class Core extends Test {}
class Data extends Test {}
class Server extends Test {
	public static inline var BASEURL = 'http://localhost/__ub1_test/server/';
}
class React extends Test {}
class Util extends Test {}
class Web extends Test {}
