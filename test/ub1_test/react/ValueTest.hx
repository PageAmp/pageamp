/*
 * Copyright (c) 2018 Ubimate Technologies Ltd. and Ub1 contributors. and Ub1 contributors.
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

package ub1_test.react;

import ub1.util.Test;
import ub1.react.Value;
import ub1.react.ValueContext;
import ub1.react.ValueScope;

using ub1.util.MapTool;

class ValueTest extends Test {
    var context: ValueContext;
    var scope: ValueScope;

    public function new(p:Test) {
	    super(p);
	    context = new ValueContext();
	    scope = context.main;
	}

	public function testValue1() {
        context.reset();
        var count = 0;
        var v = new Value('foo', null, null, scope, null, function(u,k,v) {
            assert(v, 'bar');
            count++;
        });
        assert(v.value, 'foo');
        assert(v.get(), 'foo');
        v.set('bar');
        assert(count, 1);
	}
	
	public function testValue2() {
        context.reset();
        var count = 0;
        var v = new Value('foo', null, null, scope, null, function(u,k,v) {
            assert(v, count == 0 ? 'foo' : 'bar');
            count++;
        });
        assert(v.value, 'foo');
        assert(v.get(), 'foo');
        context.refresh();
        assert(count, 1);
        v.set('bar');
        assert(count, 2);
	}
	
	public function testValue3() {
        context.reset();
        var count = 0;
        var v = new Value(1, null, null, scope, null, function(u,k,v) {
            assert(v, count == 0 ? 1 : 2);
            count++;
        });
        assert(v.value, 1);
        assert(v.get(), 1);
        context.refresh();
        assert(count, 1);
        v.set(2);
        assert(count, 2);
	}
	
	public function testValue4() {
        context.reset();
        var count = 0;
        var v = new Value("${'foo'}", null, null, scope, null, function(u,k,v) {
            count++;
        });
        assert(count, 0);
        assert(v.value, null);
        assert(v.get(), null);
        
        context.refresh();
        assert(count, 1);
        assert(v.value, 'foo');
        assert(v.get(), 'foo');
        
        v.set('bar');
        assert(count, 2);
        assert(v.value, 'bar');
        assert(v.get(), 'bar');
        
        context.refresh();
        assert(count, 3);
        assert(v.value, 'foo');
        assert(v.get(), 'foo');
	}
	
	public function testDependency1() {
        context.reset();
        
        var v1Count = 0;
        var v2Count = 0;
        var v1 = new Value(1, 'v1', null, scope, null, function(u,k,v) {
            v1Count++;
        });
        var v2 = new Value("${v1 + 1}", 'v2', null, scope, null, function(u,k,v) {
            v2Count++;
        });
        
//        assert(context.valueInstances.mapSize(), 2);
//        assert(context.valueInstances.get(v1.uid), v1);
//        assert(context.valueInstances.get(v2.uid), v2);
        assert(context.isRefreshing, false);
        assert(context.cycle, 0);
        assert(v1.cycle, 0);
        assert(v2.cycle, 0);
        assert(v1Count, 0);
        assert(v2Count, 0);
        assert(v1.value, 1);
        assert(v2.value, null);
        
        context.refresh();
        
        assert(context.isRefreshing, false);
        assert(context.cycle, 1);
        assert(v1.cycle, 1);
        assert(v2.cycle, 1);
        assert(v1Count, 1);
        assert(v2Count, 1);
        assert(v1.value, 1);
        assert(v2.value, 2);
	}
	
	public function testDependency2() {
        context.reset();
        
        var v1Count = 0;
        var v2Count = 0;
        var s1 = context.newScope();
        context.setGlobal('s1', s1);
        var v1 = new Value(1, 'v1', null, s1, null, function(u,k,v) {
            v1Count++;
        });
        var v2 = new Value("${s1.v1 + 1}", 'v2', null, scope, null, function(u,k,v) {
            v2Count++;
        });
        
//        assert(context.valueInstances.mapSize(), 2);
//        assert(context.valueInstances.get(v1.uid), v1);
//        assert(context.valueInstances.get(v2.uid), v2);
        assert(context.isRefreshing, false);
        assert(context.cycle, 0);
        assert(v1.cycle, 0);
        assert(v2.cycle, 0);
        assert(v1Count, 0);
        assert(v2Count, 0);
        assert(v1.value, 1);
        assert(v2.value, null);
        
        context.refresh();
        
        assert(context.isRefreshing, false);
        assert(context.cycle, 1);
        assert(v1.cycle, 1);
        assert(v2.cycle, 1);
        assert(v1Count, 1);
        assert(v2Count, 1);
        assert(v1.value, 1);
        assert(v2.value, 2);
	}
	
}
