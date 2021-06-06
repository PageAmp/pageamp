package ub1.reactivity;

import utest.Assert;
import utest.Test;

@:access(ub1.reactivity.ReScope)
@:access(ub1.reactivity.ReValue)
class ReScopeTest extends Test {
	function testScope1() {
		var scope = new ReScope(null, null);
		scope.set('v', 3);
		Assert.equals(3, scope.get('v'));
		scope.refresh();
		Assert.equals(3, scope.get('v'));
		scope.set('v', 'foo');
		Assert.equals('foo', scope.get('v'));
		scope.refresh();
		Assert.equals('foo', scope.get('v'));
	}

	function testScope2() {
		var scope = new ReScope(null, null);
		scope.set('v', "[[3]]");
		Assert.equals(null, scope.values.get('v').v);
		Assert.equals(3, scope.get('v'));
		Assert.equals(3, scope.values.get('v').v);
		scope.refresh();
		Assert.equals(3, scope.values.get('v').v);
		Assert.equals(3, scope.get('v'));
		scope.set('v', 'foo');
		Assert.equals('foo', scope.values.get('v').v);
		Assert.equals('foo', scope.get('v'));
		scope.refresh();
		Assert.equals('foo', scope.get('v'));
	}

	function testConsts1() {
		var scope1 = new ReScope(null, null);
		var scope2 = new ReScope(scope1, null);
		Assert.isNull(scope1.get('null'));
		Assert.isNull(scope2.get('null'));
		Assert.isTrue(scope1.get('true'));
		Assert.isTrue(scope2.get('true'));
		Assert.isFalse(scope1.get('false'));
		Assert.isFalse(scope2.get('false'));
		Assert.isTrue(Reflect.isFunction(scope1.get('trace')));
		Assert.isTrue(Reflect.isFunction(scope2.get('trace')));
	}

	function test1() {
		var scope1 = new ReScope(null, null);
		var scope2 = new ReScope(scope1, null);
		var interp = new ReInterp();
		Assert.equals(scope2, interp.run(scope2, ReParser.parse("[[this]]")));
		Assert.equals(scope1, interp.run(scope2, ReParser.parse("[[parent]]")));
		// scope2 sees `root` by ascending to external scopes
		Assert.equals(scope1, interp.run(scope2, ReParser.parse("[[root]]")));
		Assert.equals(null, interp.run(scope1, ReParser.parse("[[parent]]")));
		// interpolated null values become empty strings
		Assert.equals(' ', interp.run(scope1, ReParser.parse(" [[parent]]")));
		Assert.equals(scope1, interp.run(scope1, ReParser.parse("[[root]]")));
	}
}
