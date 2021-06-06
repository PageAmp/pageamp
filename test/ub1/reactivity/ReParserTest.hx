package ub1.reactivity;

import hscript.Interp;
import hscript.Printer;
import utest.Assert;
import utest.Test;

class ReParserTest extends Test {
	function test1() {
		Assert.equals("''", ReParser.prepare(''));
		Assert.equals("", ReParser.prepare("[[" + "]]"));
		Assert.equals(' ', ReParser.prepare("[[" + " ]]"));
	}

	function test2() {
		Assert.equals("'x'", ReParser.prepare('x'));
		Assert.equals("'\\\"'", ReParser.prepare('"'));
		Assert.equals("'\\\''", ReParser.prepare("'"));
	}

	function test3() {
		Assert.equals('1 + 2', ReParser.prepare("[[1 + 2]]"));
	}

	function test4() {
		Assert.equals('\' \'+${ReScope.NOTNULL_FUNCTION}(1 + 2)', ReParser.prepare(" [[1 + 2]]"));
		Assert.equals('${ReScope.NOTNULL_FUNCTION}(1 + 2)+\' \'', ReParser.prepare("[[1 + 2]] "));
		Assert.equals('\' \'+${ReScope.NOTNULL_FUNCTION}(1 + 2)+\' \'', ReParser.prepare(" [[1 + 2]] "));
		var s = ReParser.prepare('[[f("\"hello\"")]]');
		Assert.equals('f("\"hello\"")', s);
		var s = ReParser.prepare("[[f('\"hello\"')]]");
		Assert.equals('f(\'"hello"\')', s);
	}

	function test7() {
		Assert.equals('function() {return 1}', ReParser.prepare("[[function() {return 1}]]"));
		Assert.equals('function() {return 1\n' + '}', ReParser.prepare("[[function() {return 1\n" + "}]]"));
		Assert.equals("if (true) {
                trace('ok');
            } else {
                trace('ko');
            }", ReParser.prepare("[[if (true) {
                trace('ok');
            } else {
                trace('ko');
            }]]"));
	}

	function test8() {
		var expr = ReParser.parse("sum: [[1 + 2]]");
		var code = new Printer().exprToString(expr);
		Assert.equals("\"sum: \" + " + ReScope.NOTNULL_FUNCTION + "(1 + 2)", code);
		Assert.equals('"sum: " + ${ReScope.NOTNULL_FUNCTION}(1 + 2)', code);
		var expr = ReParser.parse("[[if (true) {
            trace('ok');
        } else {
            trace('ko');
        }]]");
		var code = new Printer().exprToString(expr);
		Assert.equals('if( true ) {\n' + '\ttrace(\"ok\");\n' + '} else {\n' + '\ttrace(\"ko\");\n' + '}', code);
	}

	function test9() {
		var interp = new Interp();
		interp.variables.set(ReScope.NOTNULL_FUNCTION, (s) -> s != null ? s : '');
		Assert.equals('sum: 3', interp.execute(ReParser.parse("sum: [[1 + 2]]")));
		interp.variables.set('f', function(s) return s == 'x');
		Assert.isTrue(interp.execute(ReParser.parse("[[f('x')]]")));
		interp.variables.set('f', function(s) return s == '"hello"');
		Assert.isTrue(interp.execute(ReParser.parse("[[f('\"hello\"')]]")));
		Assert.isTrue(interp.execute(ReParser.parse('[[f(\'"hello"\')]]')));
		// TODO Assert.isTrue(interp.execute(ReParser.parse('$'+'{f("\"hello\"")}')));
	}

	function test10() {
		var code = ReParser.prepare("[[function(x) {return x * 2}]]");
		Assert.equals('function(x) {return x * 2}', code);
		var code = ReParser.prepare("[[function\n(x) {return x * 2}]]");
		Assert.equals('function\n(x) {return x * 2}', code);
		var code = ReParser.prepare("[[function(x)\nreturn x * 2]]");
		Assert.equals('function(x)\nreturn x * 2', code);
		var code = ReParser.prepare("[[(x) -> {return x * 2}]]");
		Assert.equals('(x) -> {return x * 2}', code);
		var code = ReParser.prepare("[[\n(x) -> {return x * 2}]]");
		Assert.equals('\n(x) -> {return x * 2}', code);
		var code = ReParser.prepare("[[(x) ->\nreturn x * 2]]");
		Assert.equals('(x) ->\nreturn x * 2', code);
	}

	function test11() {
		var s = ReParser.prepare("[[function(x, y) {
            return x * y;
        }]]");
		Assert.equals("function(x, y) {
            return x * y;
        }", s);
	}

	function test12() {
		var s = ReParser.prepare('[[ [{list:[1,2]}, {list:["a","b","c"]}] ]]');
		Assert.equals(' [{list:[1,2]}, {list:["a","b","c"]}] ', s);
	}

	function test13() {
		var s = ReParser.prepare('[[ [
			{list:[1,2]},
			{list:["a","b","c"]}
		] ]]');
		Assert.equals(' [
			{list:[1,2]},
			{list:["a","b","c"]}
		] ', s);
	}

	function test14() {
		var s = ReParser.prepare('[[[
			{list:[1,2]},
			{list:["a","b","c"]}
		]]]');
		Assert.equals('[
			{list:[1,2]},
			{list:["a","b","c"]}
		]', s);
	}

}
