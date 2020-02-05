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

package pageamp_test.react;

import pageamp.util.Test;
import pageamp.react.ValueContext;
import pageamp.react.ValueScope;
import pageamp.web.DomTools;
using pageamp.web.DomTools;

class ScopeTest extends Test {
	var context: ValueContext;
	var scope: ValueScope;

	public function new(p:Test) {
		super(p);
		context = new ValueContext();
		scope = context.main;
	}

	public function testScope1() {
		context.reset();
		scope.set('v', 3);
		assert(scope.get('v'), 3);
		context.refresh();
		assert(scope.get('v'), 3);
		scope.set('v', 'foo');
		assert(scope.get('v'), 'foo');
		context.refresh();
		assert(scope.get('v'), 'foo');
	}

	public function testScope2() {
		context.reset();
		scope.set('v', "${3}");
		assert(scope.get('v'), null);
		context.refresh();
		assert(scope.get('v'), 3);
		scope.set('v', 'foo');
		assert(scope.get('v'), 'foo');
		context.refresh();
		assert(scope.get('v'), 'foo');
	}

}
