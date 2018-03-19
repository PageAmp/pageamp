package reapp;

import ub1.web.DomTools;
import reapp.core.*;

class App1 {

	public static function main() {
		var ctx = new ReContext();
		var v0 = new Re<Int>(ctx, 1, null);
		var v1 = new Re<Int>(ctx, null, function() return v0.get() * 2)
				.addSrc(v0);
		var v2 = new Re<Int>(ctx, null, function() return v0.get() * 3)
				.addSrc(v0);
		trace('${v1.get()}, ${v2.get()}');
		v0.set(2);
		trace('${v1.get()}, ${v2.get()}');
	}

//	public static function main() {
//		var app = new ReApp();
//		//var v1 = new ReValue<Int>(app, function() return 1);
//	}

//	public static function main() {
//		var app = ReMacro.APP({
//			var untypedVar;
//			var v = 1;
//			var x = 'foo';
//			var fun = function() {
//				return '1';
//			}
//			var child = NODE({
//				var x = x + '_ops';
//				var y = '_bar';
//				var z = x + y;
//				var fun = function() {
//					return fun() + '_2';
//				}
//				function fun2() {
//					return fun() + '_2';
//				}
//				function addBar() {
//					return x + '_bar';
//				}
//				function prefixFoo() {
//					return 'foo' + y;
//				}
//				var s = 'v says: $v';
//			});
//		});
//		trace(app.child.z);
//		trace(app.child.fun());
//		trace(app.child.s);
//	}

//	public static function main() {
//		var app = ReMacro.APP({
//			var v = 1;
//			var child = NODE({
//				var s = 'v says: $v';
////				function f() {
////					var a = 'x=$v';
////					return a;
////				}
//			});
//		});
//		trace(app.child.s);
////		trace(app.child.f());
//	}

//	public static function main() {
//		var app = ReMacro.APP({
//			var child = NODE({
//				function f(a:Int, ?b:Int) {
//					return a + b;
//				}
//			});
//		});
//		trace(app.child.f(1, 2));
//	}

}

































