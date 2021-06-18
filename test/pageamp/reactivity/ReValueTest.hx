package pageamp.reactivity;

import utest.Assert;
import utest.Test;

@:access(pageamp.reactivity.ReScope)
@:access(pageamp.reactivity.ReValue)
class ReValueTest extends Test {

	public function testValue1a() {
		var scope = new ReScope(null, null).refresh();
		var count = 0;
		var v = new ReValue(scope, 'v1', 'foo');
		v.callback = (v, k, _) -> {
			Assert.equals('bar', v);
			count++;
			return v;
		};
		Assert.equals('foo', v.v);
		v.set('bar');
		Assert.equals(1, count);
		Assert.equals('bar', scope.get('v1'));
	}

	public function testValue1b() {
		var scope = new ReScope(null, null).refresh();
		var count = 0;
		var v = new ReValue(scope, 'v1', 'foo');
		v.callback = (v, k, _) -> {
			Assert.equals(count == 0 ? 'foo' : 'bar', v);
			count++;
			return v;
		};
		Assert.equals('foo', v.v);
		// this triggers the first callback invocation
		Assert.equals('foo', v.get());
		// and this the second
		v.set('bar');
		Assert.equals(2, count);
		Assert.equals('bar', scope.get('v1'));
	}

	public function testValue2() {
		var scope = new ReScope(null, null).refresh();
		var count = 0;
		var v = new ReValue(scope, 'v1', 'foo');
		v.callback = (v, k, _) -> {
			Assert.equals(count == 0 ? 'foo' : 'bar', v);
			count++;
			return v;
		};
		Assert.equals('foo', v.v);
		// this triggers the first callback invocation
		scope.refresh();
		// and this the second
		v.set('bar');
		Assert.equals(2, count);
		Assert.equals('bar', scope.get('v1'));
	}

	public function testValue3() {
		var scope = new ReScope(null, null).refresh();
		var count = 0;
		var v = new ReValue(scope, 'v1', 1);
		v.callback = function(v, k, _) {
			Assert.equals(count == 0 ? 1 : 2, v);
			count++;
			return v;
		};
		Assert.equals(1, v.v);
		Assert.equals(1, v.get());
		scope.refresh();
		Assert.equals(1, count);
		v.set(2);
		Assert.equals(2, count);
	}

	public function testValue4() {
		var scope = new ReScope(null, null).refresh();
		var count = 0;
		var v = new ReValue(scope, 'v1', "[['foo']]");
		v.callback = function(v, k, _) {
			count++;
			return v;
		};
		Assert.equals(0, count);
		Assert.equals(null, v.v);
		Assert.equals('foo', v.get());

		Assert.equals(1, count);
		Assert.equals('foo', v.v);
		Assert.equals('foo', v.get());

		v.set('bar');
		Assert.equals(2, count);
		Assert.equals('bar', v.v);
		Assert.equals('bar', v.get());

		scope.refresh();
		Assert.equals(2, count);
		Assert.equals('bar', v.v);
		Assert.equals('bar', v.get());
	}

	public function testDependency1() {
		var scope = new ReScope(null, null).refresh();

		var v1Count = 0;
		var v2Count = 0;
		var v1 = new ReValue(scope, 'v1', 1);
		v1.callback = function(v, k, _) {
			v1Count++;
			return v;
		};
		var v2 = new ReValue(scope, 'v2', "[[v1 + 1]]");
		v2.callback = function(v, k, _) {
			v2Count++;
			return v;
		};

		Assert.equals(false, scope.context.isRefreshing);
		Assert.equals(1, scope.context.cycle);
		Assert.equals(0, v1.cycle);
		Assert.equals(0, v2.cycle);
		Assert.equals(0, v1Count);
		Assert.equals(0, v2Count);
		Assert.equals(1, v1.v);
		Assert.equals(null, v2.v);

		scope.refresh();

		Assert.equals(false, scope.context.isRefreshing);
		Assert.equals(2, scope.context.cycle);
		Assert.equals(2, v1.cycle);
		Assert.equals(2, v2.cycle);
		Assert.equals(1, v1Count);
		Assert.equals(1, v2Count);
		Assert.equals(1, v1.v);
		Assert.equals(2, v2.v);
	}

	public function testDependency2() {
		var scope = new ReScope(null, null).refresh();

		var v1Count = 0;
		var v2Count = 0;
		var s1 = new ReScope(scope, 's1');
		var v1 = new ReValue(scope, 'v1', 1);
		v1.callback = function(v, k, _) {
			v1Count++;
			return v;
		};
		var v2 = new ReValue(scope, 'v2', "[[s1.v1 + 1]]");
		v2.callback = function(v, k, _) {
			v2Count++;
			return v;
		};

		Assert.equals(false, scope.context.isRefreshing);
		Assert.equals(1, scope.context.cycle);
		Assert.equals(0, v1.cycle);
		Assert.equals(0, v2.cycle);
		Assert.equals(0, v1Count);
		Assert.equals(0, v2Count);
		Assert.equals(1, v1.v);
		Assert.equals(null, v2.v);

		scope.refresh();

		Assert.equals(false, scope.context.isRefreshing);
		Assert.equals(2, scope.context.cycle);
		Assert.equals(2, v1.cycle);
		Assert.equals(2, v2.cycle);
		Assert.equals(1, v1Count);
		Assert.equals(1, v2Count);
		Assert.equals(1, v1.v);
		Assert.equals(2, v2.v);
	}

	function test1() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('x', 1);
			s.set('y', "[[x * 2]]");
		}).refresh();
		Assert.equals(2, scope.get('y'));

		scope.set('x', 2);
		// change is pushed to `y` because it's dependent on `x`
		Assert.equals(4, scope.values.get('y').v);
		Assert.equals(4, scope.get('y'));
		Assert.equals(4, scope.values.get('y').v);

		scope.context.clearDependencies();
		scope.set('x', 3);
		// change is not pushed to `y` because its not dependent anymore
		Assert.equals(4, scope.values.get('y').v);
		Assert.equals(6, scope.get('y'));
		Assert.equals(6, scope.values.get('y').v);
	}

	// =========================================================================
	// function
	// =========================================================================

	function test2a() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[function() {return 2;}]]");
			s.set('v1', "[[f()]]");
		}).refresh();
		Assert.equals(1, scope.context.cycle);
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.notNull(scope.values.get('v1').prev);
		Assert.equals(2, scope.get('v1'));
		scope.refresh();
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.values.get('v1').cycle);
	}

	function test2b() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[function(x) {return x * 2;}]]");
			s.set('v1', "[[f(1)]]");
			s.set('v2', "[[f(2)]]");
		}).refresh();
		Assert.equals(1, scope.context.cycle);
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.notNull(scope.values.get('v1').prev);
		Assert.equals(2, scope.get('v1'));
		Assert.equals(4, scope.get('v2'));
		scope.refresh();
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.values.get('v1').cycle);
	}

	function test3() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[(x) -> x * 2]]");
			s.set('v1', "[[f(1)]]");
			s.set('v2', "[[f(2)]]");
		}).refresh();
		Assert.equals(1, scope.context.cycle);
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.get('v1'));
		Assert.equals(4, scope.get('v2'));
		scope.refresh();
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.values.get('v1').cycle);
	}

	function test4() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', (x) -> x * 2);
			s.set('v1', "[[f(1)]]");
			s.set('v2', "[[f(2)]]");
		}).refresh();
		Assert.equals(1, scope.context.cycle);
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.get('v1'));
		Assert.equals(4, scope.get('v2'));
		scope.refresh();
		// functions are only refreshed once
		Assert.equals(1, scope.values.get('f').cycle);
		Assert.equals(2, scope.values.get('v1').cycle);
	}

	function test5() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', (x, y) -> x * y);
			s.set('v', "[[f(1, 2)]]");
		}).refresh();
		Assert.equals(2, scope.get('v'));
	}

	function test6() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[function(x, y) {return x * y;}]]");
			s.set('v', "[[f(1, 3)]]");
		}).refresh();
		Assert.equals(3, scope.get('v'));
	}

	function test7() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[(x, y) -> x * y]]");
			s.set('v', "[[f(1, 4)]]");
		}).refresh();
		Assert.equals(4, scope.get('v'));
	}

	function test8() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('f', "[[function(x, y) {
                return x * y;
            }]]");
			s.set('v', "[[f(1, 100)]]");
		}).refresh();
		Assert.equals(100, scope.get('v'));
	}

	// =========================================================================
	// handlers
	// =========================================================================

	function testHandler1() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('v1', 1);
			s.set('count', 0);
			new ReValue(s,
				null, // anonymous value
				"[[v1]]", // when v1 changes...
				"[[count++]]" // ...increment count
			);
		}).refresh();
		Assert.equals(1, scope.get('v1'));
		// handler was executed once during initial refresh since v1 was set
		Assert.equals(1, scope.get('count'));

		scope.set('v1', 1);
		// handler was not executed again since v1 didn't actually change
		Assert.equals(1, scope.get('count'));

		scope.set('v1', 10);
		// handler was executed again since v1 changed
		Assert.equals(2, scope.get('count'));
	}

	function testHandler2() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('v1', 1);
			s.set('count', 0);
			new ReValue(s, null, // anonymous value
				"[[v1]]", // when v1 changes...
				"[[count++]]", // ...increment count
				true,
				false // doesn't execute handler on initial refresh
			);
		}).refresh();
		Assert.equals(1, scope.get('v1'));
		// handler was executed once during initial refresh since v1 was set
		Assert.equals(0, scope.get('count'));

		scope.set('v1', 1);
		// handler was not executed again since v1 didn't actually change
		Assert.equals(0, scope.get('count'));

		scope.set('v1', 10);
		// handler was executed again since v1 changed
		Assert.equals(1, scope.get('count'));
	}

	function testHandler3() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			s.set('v1', 1);
			s.set('v2', 20);
			s.set('count', 0);
			new ReValue(s, null, // anonymous value
				"[[v1+v2]]", // when v1 or v2 changes...
				"[[count++]]" // ...increment count
			);
		}).refresh();
		Assert.equals(1, scope.get('v1'));
		// handler was executed once during initial refresh since v1 and v2 were
		// both set during the same refresh cycle
		Assert.equals(1, scope.get('count'));

		scope.set('v1', 1);
		// handler was not executed again since v1 didn't actually change
		Assert.equals(1, scope.get('count'));

		Assert.equals(1, scope.get('v1'));
		// handler was executed once during initial refresh since v1 was set
		Assert.equals(1, scope.get('count'));

		scope.set('v1', 1);
		// handler was not executed again since v1 didn't actually change
		Assert.equals(1, scope.get('count'));

		scope.set('v1', 10);
		// handler was executed again since v1 changed
		Assert.equals(2, scope.get('count'));

		scope.set('v2', 20);
		// handler was not executed again since v1 didn't actually change
		Assert.equals(2, scope.get('count'));

		scope.set('v2', 21);
		// handler was executed again since v1 changed
		Assert.equals(3, scope.get('count'));
	}

	// =========================================================================
	// constants
	// =========================================================================

	function testConst1() {
		var scope = new ReScope(null, null, function(s:ReScope) {
			new ReConst(s, 'k1', 1);
			new ReConst(s, 'k2', "[[k1 * 2]]");
			new ReConst(s, 'k3', "[[k2 * v1]]");
			s.set('v1', 0);
			new ReConst(s, 'k4', "[[k2 * v2]]");
			s.set('v2', 5);
		}).refresh();
		Assert.equals(1, scope.get('k1'));
		Assert.equals(2, scope.get('k2'));
		Assert.equals(0, scope.get('k3'));
		Assert.equals(10, scope.get('k4'));
		scope.set('k1', 10);
		Assert.equals(1, scope.get('k1'));
		Assert.equals(2, scope.get('k2'));
		Assert.equals(0, scope.get('k3'));
		Assert.equals(10, scope.get('k4'));
		scope.set('k2', 11);
		Assert.equals(1, scope.get('k1'));
		Assert.equals(2, scope.get('k2'));
		Assert.equals(0, scope.get('k3'));
		Assert.equals(10, scope.get('k4'));
		scope.set('v1', 5);
		Assert.equals(1, scope.get('k1'));
		Assert.equals(2, scope.get('k2'));
		// constants depending on variables only use their value at init time
		Assert.equals(0, scope.get('k3'));
		Assert.equals(10, scope.get('k4'));
		scope.set('v2', 6);
		Assert.equals(1, scope.get('k1'));
		Assert.equals(2, scope.get('k2'));
		// constants depending on variables only use their value at init time
		Assert.equals(0, scope.get('k3'));
		Assert.equals(10, scope.get('k4'));
	}
}
