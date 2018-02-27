/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.react;

import ub1.Ub1Log;

//TODO strip line and block comments from expression
class ValueParser {
	static public inline var LF_PLACEHOLDER = '__LINEFEED__';
	//NOTE not thread safe:
	static public var FUNCTION_RE = ~/^\${(\((.*?)\):)?function\((.*?)\)\s*{\s*(.*?)\s*}\s*}$/;
	static public var USE_STRING_FUNCTION = true;
	static var EXP_MARKER_START = "$";
	static var EXP_MARKER1 = "$"+"{";
	static var EXP_MARKER1_CODE = 1;
	static var DATA_MARKER1 = "$"+"data{";
	static var DATA_MARKER1_CODE = 2;
	static var EXP_MARKER2 = "}";

	static public inline function isConstantExpression(val: String) {
		return (val.indexOf(EXP_MARKER1) < 0 && val.indexOf(DATA_MARKER1) < 0);
	}

	static public function parse(s:String, sb:StringBuf): Bool {
		if (s == '') {
			sb.add('"'); sb.add(s); sb.add('"');
		}
		#if traceExpression trace('parseExpression: "$s"'); #end
		var isDynamic = false;
		var sep = "", op;
		var i1, i2 = 0, i3 = 0;
		while ((i1 = s.indexOf(EXP_MARKER_START, i3)) >= i3) {
			if (s.indexOf(EXP_MARKER1, i1) == i1) {
				i3 = i1 + EXP_MARKER1.length;
				op = EXP_MARKER1_CODE;
			} else if (s.indexOf(DATA_MARKER1, i1) == i1) {
				i3 = i1 + DATA_MARKER1.length;
				op = DATA_MARKER1_CODE;
			} else {
				i3 = i1 + 1;
				continue;
			}
			if (i1 > i2) {
				sb.add(sep); sep="+";
				sb.add('"');
				sb.add(StringTools.replace(s.substring(i2, i1), '"', '\\"'));
				sb.add('"');
			}

			i2 = s.indexOf(EXP_MARKER2, i3);
			i2 = (i2 < 0 ? s.length : i2);

			{
				// remove possible trailing semicolon
				while (i2 > i1) {
					if (~/\s|;/.matchSub(s, i2 - 1, 1)) {
						i2--;
					} else {
						break;
					}
				}
			}

			var tostring = op == EXP_MARKER1_CODE && (sep!='' || i2 < (s.length - 1));
			sb.add(sep); sep="+"; sb.add("(");
			var code = StringTools.trim(s.substring(i3, i2));
			//TODO: trailing ';' and or blanks should be trimmed
			if (op == DATA_MARKER1_CODE) {
				var e = StringTools.replace(code, '"', '\\"');
				sb.add(code.length > 0 ? 'dataGet("$e")' : 'dataGet()');
			} else {
				if (USE_STRING_FUNCTION && tostring) {
					code = code.length > 0 ? 'string(${code})' : "''";
				} else {
					code = code.length > 0 ? code : "''";
				}
				sb.add(code);
			}
			if (code.length > 0) {
				isDynamic = true;
			}
			sb.add(")");
			i2 = i3 = i2 + EXP_MARKER2.length;
		}
		if (i2 < s.length) {
			sb.add(sep);
			sb.add('"');
			sb.add(StringTools.replace(s.substring(i2), '"', '\\"'));
			sb.add('"');
		}
		Ub1Log.valueParser('parse("$s"): ${sb.toString()}');
		return isDynamic;
	}

	public inline static function patchLF(s:String) {
		return s != null ? s.split('\n').join(LF_PLACEHOLDER) : null;
	}

	public inline static function unpatchLF(s:String) {
		return s != null ? s.split(LF_PLACEHOLDER).join('\n') : null;
	}

}
