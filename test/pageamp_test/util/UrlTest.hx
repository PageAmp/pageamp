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
import pageamp.util.Url;

class UrlTest extends Test {

	public function testUrl0() {
		var url = new Url('');
		assert(url.protocol, null);
		assert(url.path, null);
		assert(url.getParamCount(), 0, 'wrong params count');
		assert(url.fragment, '');
		assert(url.toString(), '');
	}

	public function testUrl0b() {
		var url = new Url('#10');
		assert(url.protocol, null);
		assert(url.path, null);
		assert(url.getParamCount(), 0, 'wrong params count');
		assert(url.fragment, '10');
		assert(url.toString(), '#10');
	}

	public function testUrl1() {
		var url = new Url('http://foo.com/index.php?a=1;b=2');
		assert(url.protocol, 'http');
		assert(url.domain, 'foo.com');
		assert(url.path, '/index.php');
		assert(url.getParamCount(), 2, 'wrong params count');
		assert(url.getParam('a'), '1');
		assert(url.getParam('b'), '2');
		//assert(url.toString(), 'http://foo.com/index.php?a=1&b=2');
		var s = url.toString();
		if (s != 'http://foo.com/index.php?a=1&b=2' &&
			s != 'http://foo.com/index.php?b=2&a=1') {
			assert(false, true, 'toString(): $s');
		}
		assert(url.fragment, '');
	}

	public function testUrl1b() {
		var url = new Url('http://foo.com/index.php?a=1;b=2#foo');
		assert(url.protocol, 'http');
		assert(url.domain, 'foo.com');
		assert(url.path, '/index.php');
		assert(url.getParamCount(), 2, 'wrong params count');
		assert(url.getParam('a'), '1');
		assert(url.getParam('b'), '2');
		//assert(url.toString(), 'http://foo.com/index.php?a=1&b=2');
		var s = url.toString();
		if (s != 'http://foo.com/index.php?a=1&b=2#foo' &&
		s != 'http://foo.com/index.php?b=2&a=1#foo') {
			assert(false, true, 'toString(): $s');
		}
		assert(url.fragment, 'foo');
	}

	public function testUrl2() {
		var url = new Url('https://foo.com/index.php?a=1;b=2');
		assert(url.protocol, 'https');
		assert(url.domain, 'foo.com');
		assert(url.path, '/index.php');
		assert(url.getParamCount(), 2, 'wrong params count');
		assert(url.getParam('a'), '1');
		assert(url.getParam('b'), '2');
		//assert(url.toString(), 'https://foo.com/index.php?a=1&b=2');
		var s = url.toString();
		if (s != 'https://foo.com/index.php?a=1&b=2' &&
			s != 'https://foo.com/index.php?b=2&a=1') {
			assert(false, true, 'toString(): $s');
		}
	}

	public function testUrl3() {
		var url = new Url('foo.com/index.php?a=1&b=2');
		assert(url.protocol, null);
		assert(url.domain, null);
		assert(url.path, 'foo.com/index.php');
		assert(url.getParamCount(), 2, 'wrong params count');
		assert(url.getParam('a'), '1');
		assert(url.getParam('b'), '2');
		//assert(url.toString(), 'foo.com/index.php?a=1&b=2');
		var s = url.toString();
		if (s != 'foo.com/index.php?a=1&b=2' &&
			s != 'foo.com/index.php?b=2&a=1') {
			assert(false, true, 'toString(): $s');
		}
	}

	public function testUrl4() {
		var url = new Url('foo.com/index.php?a');
		assert(url.protocol, null);
		assert(url.domain, null);
		assert(url.path, 'foo.com/index.php');
		assert(url.getParamCount(), 1, 'wrong params count');
		assert(url.getParam('a'), '');
		assert(url.toString(), 'foo.com/index.php?a=');
	}

	public function testUrl5() {
		var url = new Url('foo.com/index.php?');
		assert(url.protocol, null);
		assert(url.domain, null);
		assert(url.path, 'foo.com/index.php');
		assert(url.getParamCount(), 0, 'wrong params count');
		assert(url.toString(), 'foo.com/index.php');
	}

	public function testUrl6() {
		var url = new Url('foo.com/index.php');
		assert(url.protocol, null);
		assert(url.domain, null);
		assert(url.path, 'foo.com/index.php');
		assert(url.getParamCount(), 0, 'wrong params count');
		assert(url.toString(), 'foo.com/index.php');
	}

	public function testUrl7() {
		var url = new Url('?a=1;b=2');
		assert(url.protocol, null);
		assert(url.domain, null);
		assert(url.path, null);
		assert(url.getParamCount(), 2, 'wrong params count');
		assert(url.getParam('a'), '1');
		assert(url.getParam('b'), '2');
		//assert(url.toString(), '?a=1&b=2');
		var s = url.toString();
		if (s != '?a=1&b=2' &&
			s != '?b=2&a=1') {
			assert(false, true, 'toString(): $s');
		}
	}

	public function testCompare() {
		assert(Url.urlsAreEqual(null, null), true);

		var url0_1 = new Url('');
		var url0_2 = new Url('?');
		var url0_3 = new Url(' ');
		assert(Url.urlsAreEqual(url0_1, url0_2), true, 'url0_1 != url0_2');
		assert(Url.urlsAreEqual(url0_2, url0_1), true, 'url0_2 != url0_1');
		assert(Url.urlsAreEqual(url0_1, url0_3), true, 'url0_1 != url0_3');
		var url0_4 = new Url('http://?x');
		assert(Url.urlsAreEqual(url0_1, url0_4), false);

		var url1_1 = new Url('http://foo.com/index.php?a=1;b=2');
		var url1_2 = new Url('http://foo.com/index.php?a=1&b=2');
		assert(Url.urlsAreEqual(url1_1, url1_2), true);
		assert(Url.urlsAreEqual(url1_2, url1_1), true);
		var url1_3 = new Url('https://foo.com/index.php?a=1;b=2');
		assert(Url.urlsAreEqual(url1_1, url1_3), false);
		assert(Url.urlsAreEqual(url1_1, null), false);
		assert(Url.urlsAreEqual(null, url1_1), false);

		var url4_1 = new Url('foo.com/index.php?a=');
		var url4_2 = new Url('foo.com/index.php?a');
		assert(Url.urlsAreEqual(url4_1, url4_2), true);
		var url4_3 = new Url('foo.org/index.php?a');
		assert(Url.urlsAreEqual(url4_1, url4_3), false);

		var url6_1 = new Url('foo.com/index.php?');
		var url6_2 = new Url('foo.com/index.php');
		assert(Url.urlsAreEqual(url6_1, url6_2), true);
		var url6_3 = new Url('foo.com/home.php');
		assert(Url.urlsAreEqual(url6_1, url6_3), false);

		var url7_1 = new Url('?a=1;b=2');
		var url7_2 = new Url('?a=1&b=2');
		assert(Url.urlsAreEqual(url7_1, url7_2), true);
		var url7_3 = new Url('?a=0&b=2');
		assert(Url.urlsAreEqual(url7_1, url7_3), false);

		var url8_1 = new Url('?a=1;b=2#x');
		var url8_2 = new Url('?b=2&a=1');
		assert(Url.urlsAreEqual(url8_1, url8_2), false);
		var url8_3 = new Url('?a=1&b=2#y');
		assert(Url.urlsAreEqual(url8_1, url8_3), false);
		var url8_4 = new Url('?b=2&a=1#x');
		assert(Url.urlsAreEqual(url8_1, url8_4), true);
	}

}
