package reapp;

import reapp.app.*;
import reapp.core.*;
import ub1.web.DomTools;
using ub1.web.DomTools;

class App1 {

	public static function main() {
		var doc = DomTools.defaultDocument();
		var ctx = new ReContext();
		var a_lang:Re<String>;
		var app = new ReApp(doc, ctx, function(p:ReApp) {
			a_lang = untyped p.add('a_lang', new Re<String>(ctx, 'it', null));
			new ReElement(p, doc.domGetBody(), function(p:ReElement) {
				p.add('a_dataUb1', new Re<String>(ctx, null, function() {
					return a_lang.get() + '-lang';
				})).addSrc(a_lang);
				p.add('c_base', new Re<Bool>(ctx, true, null));
				p.add('c_es', new Re<Bool>(ctx, null, function() {
					return a_lang.get() == 'es';
				})).addSrc(a_lang);
				p.add('s_textAlign', new Re<String>(ctx, null, function() {
					return a_lang.get() == 'es' ? 'right' : 'left';
				})).addSrc(a_lang);
			});
		});
		haxe.Timer.delay(function() a_lang.set('es'), 1000);
	}

//	public static function main() {
//		var doc = DomTools.defaultDocument();
//		var ctx = new ReContext();
//		var v1;
//		var app = new ReApp(doc, ctx, function(p:ReApp) {
//			v1 = p.add('a_lang', new Re<String>(ctx, 'it', null));
//			new ReElement(p, doc.domGetBody(), function(p:ReElement) {
//				p.add('a_dataUb1', new Re<String>(ctx, null, function() {
//					return cast(p.get('a_lang'), String) + '-lang';
//				})).addSrc(p.lookup('a_lang'));
//				p.add('c_base', new Re<Bool>(ctx, true, null));
//				p.add('c_es', new Re<Bool>(ctx, null, function() {
//					return cast(p.get('a_lang'), String) == 'es';
//				})).addSrc(p.lookup('a_lang'));
//				p.add('s_textAlign', new Re<String>(ctx, null, function() {
//					return p.get('a_lang') == 'es' ? 'right' : 'left';
//				})).addSrc(p.lookup('a_lang'));
//			});
//		});
//		haxe.Timer.delay(function() v1.set('es'), 1000);
//	}

//	public static function main() {
//		var doc = DomTools.defaultDocument();
//		var ctx = new ReContext();
//		var n: ReNode;
//		var a = new ReApp(doc, ctx, function(p:ReApp) {
//			p.add('v0', new Re<Int>(ctx, 1, null));
//			p.add('v1', new Re<Int>(ctx, null, function() {
//				return cast(p.get('v0'), Int) * 2;
//			})).addSrc(p.lookup('v0'));
//			p.add('v2', new Re<Int>(ctx, null, function() {
//				return cast(p.get('v0'), Int) * 3;
//			})).addSrc(p.lookup('v0'));
//			n = new ReNode(p, function(p:ReNode) {
//				p.add('v3', new Re<Int>(ctx, null, function() {
//					return cast(p.get('v0'), Int) * 4;
//				})).addSrc(p.lookup('v0'));
//			});
//		});
//		trace('${a.get('v0')}, ${a.get('v1')}, ${a.get('v2')}, ${n.get('v3')}');
//		a.set('v0', 4);
//		trace('${a.get('v0')}, ${a.get('v1')}, ${a.get('v2')}, ${n.get('v3')}');
//	}

//	public static function main() {
//		var ctx = new ReContext();
//		var v0 = new Re<Int>(ctx, 1, null);
//		var v1 = new Re<Int>(ctx, null, function() return v0.get() * 2)
//				.addSrc(v0);
//		var v2 = new Re<Int>(ctx, null, function() return v0.get() * 3)
//				.addSrc(v0);
//		trace('${v1.get()}, ${v2.get()}');
//		v0.set(2);
//		trace('${v1.get()}, ${v2.get()}');
//	}

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

































