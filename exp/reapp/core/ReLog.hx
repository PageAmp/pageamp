package reapp.core;

import haxe.macro.Expr;

class ReLog {

	macro public static function error(e:Expr) {
#if (debug && logError)
		return macro trace('ERROR - ' + $e);
#else
		return macro null;
#end
	}

	macro public static function value(e:Expr) {
#if (debug && logValue)
		return macro trace('Value - ' + $e);
#else
		return macro null;
#end
	}

}
