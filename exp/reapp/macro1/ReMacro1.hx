package reapp.macro1;

import haxe.macro.Expr;
//#if macro
	import haxe.macro.Context;
	import haxe.macro.ExprTools;
	import haxe.macro.MacroStringTools;
	import reapp.macro1.ReMacro1Scan;
	import reapp.macro1.ReMacro1Gen;
//#end

class ReMacro1 {
	public static inline var CLASS_PREFIX = 'Node';
	public static inline var INSTANCE_ARRAY = '_';

	macro public static function APP(block:Expr) {
//#if macro
		var scope = ReMacro1Scan.scan(block);
		ReMacro1Scan.dumpScope(scope);
		return ReMacro1Gen.gen(scope);
//#end
	}

	public static function formatString(s:String, pos:Position): Expr {
#if macro
		return MacroStringTools.formatString(s, pos);
#else
		return null;
#end
	}

}
