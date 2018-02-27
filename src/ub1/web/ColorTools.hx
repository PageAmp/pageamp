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

package ub1.web;

using StringTools;

class ColorTools {

	// e.g. fullRgb('#abc') returns '#aabbcc
	public static function fullRgb(s:String): String {
		var ret = s;
		var re = ~/^#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])$/;
		if (re.match(s)) {
			var r = re.matched(1);
			var g = re.matched(2);
			var b = re.matched(3);
			ret = '#$r$r$g$g$b$b';
		}
		return ret;
	}

	public static function color2Components(s:String): Rgba {
		var ret:Rgba = null;
		var re1 = ~/#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/;
		var re2 = ~/rgb\s*[(]\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*[)]/;
		var re3 = ~/rgb\s*[(]\s*([0-9]+)[%]\s*,\s*([0-9]+)[%]\s*,\s*([0-9]+)[%]\s*[)]/;
		var re4 = ~/rgba\s*[(]\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([.0-9]+)\s*[)]/;
		var re5 = ~/rgba\s*[(]\s*([0-9]+)[%]\s*,\s*([0-9]+)[%]\s*,\s*([0-9]+)[%]\s*,\s*([.0-9]+)\s*[)]/;
		s = fullRgb(s);
		if (re1.match(s)) {
			ret = {
				r: Std.parseInt('0x' + re1.matched(1)),
				g: Std.parseInt('0x' + re1.matched(2)),
				b: Std.parseInt('0x' + re1.matched(3)),
				a: null
			}
		} else if (re2.match(s)) {
			ret = {
				r: Std.parseInt(re2.matched(1)),
				g: Std.parseInt(re2.matched(2)),
				b: Std.parseInt(re2.matched(3)),
				a: null
			}
		} else if (re3.match(s)) {
			ret = {
				r: Std.int(Std.parseInt(re3.matched(1)) * 255 / 100),
				g: Std.int(Std.parseInt(re3.matched(2)) * 255 / 100),
				b: Std.int(Std.parseInt(re3.matched(3)) * 255 / 100),
				a: null
			}
		} else if (re4.match(s)) {
			ret = {
				r: Std.parseInt(re4.matched(1)),
				g: Std.parseInt(re4.matched(2)),
				b: Std.parseInt(re4.matched(3)),
				a: Std.parseFloat(re4.matched(4))
			}
		} else if (re5.match(s)) {
			ret = {
				r: Std.int(Std.parseInt(re5.matched(1)) * 255 / 100),
				g: Std.int(Std.parseInt(re5.matched(2)) * 255 / 100),
				b: Std.int(Std.parseInt(re5.matched(3)) * 255 / 100),
				a: Std.parseFloat(re5.matched(4))
			}
		}
		return ret;
	}

	public static function components2Color(rgba:Rgba): String {
		var ret = '#000';
		if (rgba != null) {
			if (rgba.a != null) {
				ret = 'rgba(${rgba.r},${rgba.g},${rgba.b},${rgba.a})';
			} else {
				//ret = 'rgb(${rgba.r},${rgba.g},${rgba.b})';
				ret = '#${rgba.r.hex(2)}${rgba.g.hex(2)}${rgba.b.hex(2)}';
			}
		}
		return ret;
	}

	public static function components2hex(rgba:Rgba): String {
		return '#${StringTools.hex(rgba.r, 2)}${StringTools.hex(rgba.g, 2)}${StringTools.hex(rgba.b, 2)}';
	}

//	public static function colorSaturation(col:String,
//										   sat:Dynamic,
//										   ?alpha:Float): String {
//		var s = Std.parseFloat('$sat');
//		var rgba:Rgba = color2Components(col);
//		if (rgba != null) {
//			var rr = rgba.r / 255.0;
//			var rg = rgba.g / 255.0;
//			var rb = rgba.b / 255.0;
//			var r = rr + rg + rb / 3.0;
//			rr -= r; rg -= r; rb -= r;
//			rgba.r = Std.int(Math.max(0, Math.min(255, (r + rr * sat) * 255)));
//			rgba.g = Std.int(Math.max(0, Math.min(255, (r + rg * sat) * 255)));
//			rgba.b = Std.int(Math.max(0, Math.min(255, (r + rb * sat) * 255)));
//			rgba.a = alpha;
//		}
//		return components2Color(rgba);
//	}

	public static function colorOffset(col:String,
	                                   offset:Dynamic,
	                                   saturation=1.0,
	                                   ?alpha:Float): String {
		var o = Std.parseInt('$offset');
		var s = saturation;
		var rgba:Rgba = color2Components(col);
		if (rgba != null) {
			var rr = rgba.r / 255.0;
			var rg = rgba.g / 255.0;
			var rb = rgba.b / 255.0;
			var v = (rr + rg + rb) / 3.0;
			//trace('colorOffset() v: ${StringTools.hex(Std.int(v * 255))}');
			rr -= v; rg -= v; rb -= v;
			rgba.r = Std.int(Math.max(0, Math.min(255, (v + rr * s) * 255 + o)));
			rgba.g = Std.int(Math.max(0, Math.min(255, (v + rg * s) * 255 + o)));
			rgba.b = Std.int(Math.max(0, Math.min(255, (v + rb * s) * 255 + o)));
			rgba.a = alpha;
		}
		//trace('colorOffset($col, $offset, $saturation, $alpha): ${components2hex(rgba)}');//tempdebug
		return components2Color(rgba);
	}

	public static function counterColor(col:String,
	                                    col1='black',
	                                    col2='white',
	                                    threshold=176): String {
		var rgba:Rgba = color2Components(col);
		// https://stackoverflow.com/a/11868398
		var yiq = ((rgba.r * 299) + (rgba.g * 587) + (rgba.b * 114)) / 1000;
		return (yiq >= threshold) ? col1 : col2;
	}

	// =========================================================================
	// HTML5up SCSS-style functions
	// =========================================================================

	public static function mix(col1:String, col2:String, ratio:Float): String {
		var rgba1 = color2Components(col1);
		var rgba2 = color2Components(col2);
		ratio = Math.max(Math.min(ratio, 1), 0);
		var r1 = rgba1.r / 255.0;
		var r2 = rgba2.r / 255.0;
		var g1 = rgba1.g / 255.0;
		var g2 = rgba2.g / 255.0;
		var b1 = rgba1.b / 255.0;
		var b2 = rgba2.b / 255.0;
		var ret = components2Color({
			r: Math.round((r2 * ratio + r1 * (1.0 - ratio)) * 255),
			g: Math.round((g2 * ratio + g1 * (1.0 - ratio)) * 255),
			b: Math.round((b2 * ratio + b1 * (1.0 - ratio)) * 255),
			a:null
		});
		return ret;
	}

}

typedef Rgba = {
	r: Int,
	g: Int,
	b: Int,
	a: Float
}
