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

package ub1;

import haxe.macro.Expr;

class Ub1Log {

	macro public static function data(e:Expr) {
#if (debug && logData)
		return macro trace('Data - ' + $e);
#else
		return macro null;
#end
	}

	macro public static function server(e:Expr) {
#if (logServer)
		return macro trace($e + '<br />\n');
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

	macro public static function valueParser(e:Expr) {
#if (debug && logValueParser)
		return macro trace('ValueParser - ' + $e);
#else
		return macro null;
#end
	}

	macro public static function valueInterp(e:Expr) {
#if (debug && logValueInterp)
		return macro trace('ValueInterp - ' + $e);
#else
		return macro null;
#end
	}

}
