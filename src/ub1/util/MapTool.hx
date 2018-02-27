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

package ub1.util;

class MapTool {

	public static function mapCopy(src:Map<String,Dynamic>,
	                               dst:Map<String,Dynamic>) {
		for (key in src.keys()) {
			dst.set(key, src.get(key));
		}
	}

	public static function mapIsEmpty(map:Map<String,Dynamic>): Bool {
		if (map != null) {
			for (key in map.keys()) {
				return false;
			}
		}
		return true;
	}

	// untested
	public static function mapRemoveObject(map:Map<Dynamic,Dynamic>,
	                                 obj:Dynamic): Bool {
		var ret = false, key;
		while ((key = mapKeyOf(map, obj)) != null) {
			map.remove(key);
			ret = true;
		}
		return ret;
	}

	// untested
	public static function mapKeyOf(map:Map<Dynamic,Dynamic>,
	                                obj:Dynamic): Dynamic {
		if (map != null) {
			for (key in map.keys()) {
				if (map.get(key) == obj) {
					return key;
				}
			}
		}
		return null;
	}

	public static function mapsAreEqual(a:Map<String,Dynamic>,
	                                    b:Map<String,Dynamic>): Bool {
		if (a == null && b == null) {
			return true;
		} else if (a == null || b == null) {
			return false;
		} else if (mapSize(a) != mapSize(b)) {
			return false;
		} else {
			for (key in a.keys()) {
				if (a.get(key) != b.get(key)) {
					return false;
				}
			}
		}
		return true;
	}

	public static function mapSize(map:Map<String,Dynamic>): Int {
		var ret = 0;
		if (map != null) {
			for (key in map.keys()) {
				ret++;
			}
		}
		return ret;
	}

	public static function mapClear(map:Map<Dynamic,Dynamic>,
									?cb:Dynamic->Dynamic->Void) {
		var keys = [];
		for (key in map.keys()) keys.push(key);
		for (key in keys) {
			cb != null ? cb(key, map[key]) : null;
			map.remove(key);
		}
	}

}