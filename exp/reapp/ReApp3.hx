package reapp;

import haxe.macro.Expr;
import ub1.util.PropertyTool;
using ub1.util.PropertyTool;

class ReApp3 {

	public static function main() new ReApp3();

	function new() {
		var app = NODE({
			var s = 'foo';
			var child = NODE({
				var print = function() trace(s);
			});
		});
	}

	macro static function NODE(e:Expr) {

	}

}
