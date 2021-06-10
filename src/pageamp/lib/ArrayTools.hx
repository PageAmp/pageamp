package pageamp.lib;

class ArrayTools {

	#if !debug inline #end
	public static function arrayPeek(a:Array<Dynamic>): Dynamic {
		var len = a.length;
		return (len > 0 ? a[len - 1] : null);
	}

	#if !debug inline #end
	public static function arrayLength(a:Array<Dynamic>): Int {
		return (a != null ? a.length : 0);
	}

	#if !debug inline #end
	public static function arraySort(array:Array<Dynamic>): Array<Dynamic> {
		array.sort((a:String, b:String) -> a > b ? 1 : a < b ? -1 : 0);
		return array;
	}

}
