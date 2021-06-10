package pageamp.reactivity;

import hscript.Expr;
import hscript.Parser;

using StringTools;

class ReParser {
	static inline var E1 = '[[';
	static inline var E2 = ']]';

	#if !debug
	inline
	#end
	public static function isDynamic(s:String) {
		var i1 = s.indexOf(E1);
		var i2 = (i1 < 0 ? -1 : s.indexOf(E2, i1 + 2));
		return (i1 >= 0 && i2 > i1);
	}

	public static function parse(s:String, ?origin:String):Expr {
		var code = prepare(s);
		var ret = parser.parseString(code, origin);
		return ret;
	}

	#if !debug inline #end
	public static function prepare(s:String): String {
		var sb = new StringBuf();
		var sep = '';
		var exprStart, exprEnd;
		if (s.startsWith(E1) && s.endsWith(E2)) {
			exprStart = exprEnd = '';
		} else {
			exprStart = ReScope.NOTNULL_FUNCTION + '(';
			exprEnd = ')';
		}
		var i = 0, i1, i2;
		while ((i1 = s.indexOf(E1, i)) >= 0 && (i2 = s.indexOf(E2, i1)) >= 0) {
			while ((i2 + 2) < s.length && s.charAt(i2 + 2) == ']') i2++;
			sb.add(sep); sep = '+';
			if (i1 > i) {
				sb.add("'" + escape(s.substring(i, i1)) + "'+");
			}
			sb.add(exprStart);
			sb.add(s.substring(i1 + E1.length, i2));
			sb.add(exprEnd);
			i = i2 + E2.length;
		}
		if (i < s.length || sep == '') {
			sb.add(sep);
			sb.add("'" + escape(s.substr(i)) + "'");
		}
		return sb.toString();
	}

	static inline function escape(s:String): String {
		return ~/[']/g.replace(~/["]/g.replace(s, '\\"'), "\\'");
	}

	// =========================================================================
	// private
	// =========================================================================
	static inline var BLOCK_PREFIX = ReScope.NOTNULL_FUNCTION + '(';
	static inline var BLOCK_SUFFIX = ')';
	static var parser: Parser;

	static function __init__() {
		parser = new Parser();
		parser.allowJSON = true;
	}
}
