package ub1.reactivity;

import utest.Assert;
import utest.Test;
import hscript.Interp;
import hscript.Parser;

using ub1.lib.ArrayTools;

class ReInterpTest extends Test {
	var parser:Parser;

	function setupClass():Void {
		parser = new Parser();
	}

	function teardownClass():Void {
		parser = null;
	}

	function testInterp1() {
		var interp = new Interp();
		var v = interp.execute(parser.parseString('1 + 2'));
		Assert.equals(3, v);
		var v = interp.execute(parser.parseString('var s = "x"; s += "y"'));
		Assert.equals('xy', v);
		Assert.isNull(interp.variables.get('s'));
	}

	function testInterp2() {
		var interp = new Interp();
		var v = interp.execute(new Parser().parseString('var f = function(x, y) {
            return x * y;
        };
        f(2,3);'));
		Assert.equals(6, v);
	}

	function testReInterp1() {
		var scope = new ReScope(null, null);
		var interp = new ReInterp();
		var v = interp.run(scope, parser.parseString('1 + 2'));
		Assert.equals(3, v);
		var v = interp.run(scope, parser.parseString('var s = "x"; s += "y"'));
		Assert.equals('xy', v);
		Assert.isNull(interp.variables.get('s'));
	}

	function testReInterp2() {
		var scope = new ReScope(null, null);
		var interp = new ReInterp();
		// inexistent variables give null rather than raising exception
		Assert.isNull(interp.run(scope, parser.parseString('v')));
		var v = interp.run(scope, parser.parseString('this'));
		Assert.equals(scope, v);
		scope.set('v', 1);
		Assert.equals(1, interp.run(scope, parser.parseString('v')));
		Assert.equals(1, interp.run(scope, parser.parseString('this.v')));
	}

	function testReInterp3() {
		var scope = new ReScope(null, null);
		var interp = new ReInterp();
		// by default dereference of inexistent variable gives null
		// rathern than raising `Unknown var` and `Invalid access` exceptions
		Assert.isNull(interp.run(scope, parser.parseString('v.x')));
		Assert.equals(2, interp.run(scope, parser.parseString('v.x = 2')));
	}

	function testReInterp4() {
		var scope = new ReScope(null, null);
		var interp = new ReInterp();
		try {
			// "forgiving" access mode can be disabled
			ReInterp.ENABLE_UNKNOWN_VAR_EXCEPTION = true;
			Assert.raises(() -> interp.run(scope, parser.parseString('v')));
			Assert.raises(() -> interp.run(scope, parser.parseString('v.x')));
			Assert.raises(() -> interp.run(scope, parser.parseString('v.x = 2')));
		} catch (ignored:Dynamic) {}
		ReInterp.ENABLE_UNKNOWN_VAR_EXCEPTION = false;
	}
}
