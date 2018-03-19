package reapp2.util;

class ArrayTool {

	public static function copyTo(src:Array<Dynamic>,
	                              dst:Array<Dynamic>): Array<Dynamic> {
		for (i in 0...src.length) {
			dst[i] = src[i];
		}
		return dst;
	}

	public static inline function peek(a:Array<Dynamic>): Dynamic {
		return (a != null && a.length > 0 ? a[a.length - 1] : null);
	}

	public static function stringSort(a:Array<String>): Array<String> {
		a.sort(function(a:String, b:String):Int {
			a = a.toLowerCase();
			b = b.toLowerCase();
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
		return a;
	}

	public static inline function clear(a:Array<Dynamic>,
	                                    ?cb:Dynamic->Void) {
		while (a.length > 0) {
			var val = a.pop();
			cb != null ? cb(val) : null;
		}
	}

	//untested
	public static function equals(a:Array<Dynamic>, b:Array<Dynamic>): Bool {
		var len1 = (a != null ? a.length : 0);
		var len2 = (b != null ? b.length : 0);
		if (len1 != len2) {
			return false;
		}
		for (i in 0...len1) {
			if (a[i] != b[i]) {
				return false;
			}
		}
		return true;
	}

	public static function shuffle(array:Array<Dynamic>): Void {
		// http://stackoverflow.com/a/2450976
		var currentIndex = array.length, temporaryValue, randomIndex;

		// While there remain elements to shuffle...
		while (0 != currentIndex) {

			// Pick a remaining element...
			randomIndex = Math.floor(Math.random() * currentIndex);
			currentIndex -= 1;

			// And swap it with the current element.
			temporaryValue = array[currentIndex];
			array[currentIndex] = array[randomIndex];
			array[randomIndex] = temporaryValue;

		}
	}

}
