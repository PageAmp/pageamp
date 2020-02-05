package reapp1;

import haxe.macro.Expr;
import pageamp.util.PropertyTool;
using pageamp.util.PropertyTool;

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
