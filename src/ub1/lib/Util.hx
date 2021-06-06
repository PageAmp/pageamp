package ub1.lib;

class Util {
	public static inline function areEqual(a:Dynamic, b:Dynamic) {
		return (a != null ? a == b : b == null);
	}

	public static inline function isTrue(v:Dynamic):Bool {
		return !(v == null || v == false || v == 'false');
	}

	public static inline function orEmpty(v:Dynamic):String {
		return (v == null ? '' : Std.string(v));
	}

	public static inline function toInt(s:String):Int {
		return toInt2(s, 0);
	}

	public static inline function toInt2(s:String, defval:Int):Int {
		var ret = Std.parseInt(s);
		return (ret != null ? ret : defval);
	}

	public static inline function toFloat(s:String):Float {
		var ret = Std.parseFloat(s);
		return (ret != Math.NaN ? ret : 0);
	}

	public static inline function toFloat2(s:String, defval:Float):Float {
		var ret = Std.parseFloat(s);
		return (ret != Math.NaN ? ret : defval);
	}

	public static function makeCamelName(n:String):String {
		return ~/(\-\w)/g.map(n, function(re:EReg):String {
			return n.substr(re.matchedPos().pos + 1, 1).toUpperCase();
		});
	}

	public static function makeHyphenName(n:String):String {
		return ~/([0-9a-z][A-Z])/g.map(n, function(re:EReg):String {
			var p = re.matchedPos().pos;
			return n.substr(p, 1).toLowerCase() + '-' + n.substr(p + 1, 1).toLowerCase();
		});
	}

	public static function normalizeText(s:String):String {
		return ~/([\s]+)/gm.map(s, (ereg) -> {
			return ereg.matched(1).indexOf('\n') >= 0 ? return '\n' : return ' ';
		});
	}
}
