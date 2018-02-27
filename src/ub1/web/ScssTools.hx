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

import ub1.web.ColorTools.Rgba;
using StringTools;

class ScssTools {

	public static function lighten(col:String, factor:Float): String {
		var rgb = ColorTools.color2Components(col);
		var hsb = RGBtoHSB(rgb.r, rgb.g, rgb.b);
		hsb[2] = Math.min(1, hsb[2] + factor);
		var c:Int = HSBtoRGB(hsb[0], hsb[1], hsb[2]) & 0xffffff;
		var ret = '#' + c.hex(6);
		return ret;
	}

	public static function darken(col:String, factor:Float): String {
		factor *= 1.05; //to make it closer to SCSS' darken()
		var rgb = ColorTools.color2Components(col);
		var hsb = RGBtoHSB(rgb.r, rgb.g, rgb.b);
		hsb[2] = Math.max(0, hsb[2] - factor);
		var c:Int = HSBtoRGB(hsb[0], hsb[1], hsb[2]) & 0xffffff;
		var ret = '#' + c.hex(6);
		return ret;
	}

	// =========================================================================
	// from java.awt.Color
	// =========================================================================

	/**
     * Converts the components of a color, as specified by the HSB
     * model, to an equivalent set of values for the default RGB model.
     * <p>
     * The <code>saturation</code> and <code>brightness</code> components
     * should be floating-point values between zero and one
     * (numbers in the range 0.0-1.0).  The <code>hue</code> component
     * can be any floating-point number.  The floor of this number is
     * subtracted from it to create a fraction between 0 and 1.  This
     * fractional number is then multiplied by 360 to produce the hue
     * angle in the HSB color model.
     * <p>
     * The integer that is returned by <code>HSBtoRGB</code> encodes the
     * value of a color in bits 0-23 of an integer value that is the same
     * format used by the method {@link #getRGB() getRGB}.
     * This integer can be supplied as an argument to the
     * <code>Color</code> constructor that takes a single integer argument.
     * @param     hue   the hue component of the color
     * @param     saturation   the saturation of the color
     * @param     brightness   the brightness of the color
     * @return    the RGB value of the color with the indicated hue,
     *                            saturation, and brightness.
     * @see       java.awt.Color#getRGB()
     * @see       java.awt.Color#Color(int)
     * @see       java.awt.image.ColorModel#getRGBdefault()
     * @since     JDK1.0
     */
	static function HSBtoRGB(hue:Float, saturation:Float, brightness:Float): Int {
		var r = 0, g = 0, b = 0;
		if (saturation == 0) {
			r = g = b = Math.round(brightness * 255.0 + 0.5);
		} else {
			var h:Float = (hue - Math.floor(hue)) * 6.0;
			var f:Float = h - Math.floor(h);
			var p:Float = brightness * (1.0 - saturation);
			var q:Float = brightness * (1.0 - saturation * f);
			var t:Float = brightness * (1.0 - (saturation * (1.0 - f)));
			switch (Std.int(h)) {
				case 0:
					r = Std.int(brightness * 255.0 + 0.5);
					g = Std.int(t * 255.0 + 0.5);
					b = Std.int(p * 255.0 + 0.5);
				case 1:
					r = Std.int(q * 255.0 + 0.5);
					g = Std.int(brightness * 255.0 + 0.5);
					b = Std.int(p * 255.0 + 0.5);
				case 2:
					r = Std.int(p * 255.0 + 0.5);
					g = Std.int(brightness * 255.0 + 0.5);
					b = Std.int(t * 255.0 + 0.5);
				case 3:
					r = Std.int(p * 255.0 + 0.5);
					g = Std.int(q * 255.0 + 0.5);
					b = Std.int(brightness * 255.0 + 0.5);
				case 4:
					r = Std.int(t * 255.0 + 0.5);
					g = Std.int(p * 255.0 + 0.5);
					b = Std.int(brightness * 255.0 + 0.5);
				case 5:
					r = Std.int(brightness * 255.0 + 0.5);
					g = Std.int(p * 255.0 + 0.5);
					b = Std.int(q * 255.0 + 0.5);
			}
		}
		return 0xff000000 | (r << 16) | (g << 8) | (b << 0);
	}

	/**
     * Converts the components of a color, as specified by the default RGB
     * model, to an equivalent set of values for hue, saturation, and
     * brightness that are the three components of the HSB model.
     * <p>
     * If the <code>hsbvals</code> argument is <code>null</code>, then a
     * new array is allocated to return the result. Otherwise, the method
     * returns the array <code>hsbvals</code>, with the values put into
     * that array.
     * @param     r   the red component of the color
     * @param     g   the green component of the color
     * @param     b   the blue component of the color
     * @param     hsbvals  the array used to return the
     *                     three HSB values, or <code>null</code>
     * @return    an array of three elements containing the hue, saturation,
     *                     and brightness (in that order), of the color with
     *                     the indicated red, green, and blue components.
     * @see       java.awt.Color#getRGB()
     * @see       java.awt.Color#Color(int)
     * @see       java.awt.image.ColorModel#getRGBdefault()
     * @since     JDK1.0
     */
	static function RGBtoHSB(r:Int, g:Int, b:Int, ?hsbvals:Array<Float>): Array<Float> {
		var hue:Float, saturation:Float, brightness:Float;
		if (hsbvals == null) {
			hsbvals = [];
		}
		var cmax = (r > g) ? r : g;
		if (b > cmax) cmax = b;
		var cmin = (r < g) ? r : g;
		if (b < cmin) cmin = b;

		brightness = cmax / 255.0;
		if (cmax != 0)
			saturation = (cmax - cmin) / cmax;
		else
			saturation = 0;
		if (saturation == 0)
			hue = 0;
		else {
			var redc = (cmax - r) / (cmax - cmin);
			var greenc = (cmax - g) / (cmax - cmin);
			var bluec = (cmax - b) / (cmax - cmin);
			if (r == cmax)
				hue = bluec - greenc;
			else if (g == cmax)
				hue = 2.0 + redc - bluec;
			else
				hue = 4.0 + greenc - redc;
			hue = hue / 6.0;
			if (hue < 0)
				hue = hue + 1.0;
		}
		hsbvals[0] = hue;
		hsbvals[1] = saturation;
		hsbvals[2] = brightness;
		return hsbvals;
	}

}
