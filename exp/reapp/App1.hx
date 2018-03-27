package reapp;

import reapp.app.*;
import reapp.core.*;
import reapp.macro.RE;
import ub1.web.DomTools;
using ub1.web.DomTools;

class App1 {

	public static function main() {
		var doc = DomTools.defaultDocument();
		var app = RE.APP(doc, {
			var v0:Int;
			var lang = 'it';
//			lang = 'en';
//			trace(lang);
			var a_dataLang:String = 'lang: ' + lang;
			function f1(lang): Void {
				var v1 = 1;
				trace(lang);
			}
			function f2(lang:String): String {
				trace(lang);
				return lang;
			}
			TAG(doc.domGetHead(), {
				var a_dataLang:String = '$lang';
			});
			var body = TAG(doc.domGetBody(), {
				var a_dataLang:String = '$lang';
			});
		});
		haxe.Timer.delay(function() {
			app.values.get('lang').value = 'en';
		}, 1000);
	}

//	public static function main() {
//		var doc = DomTools.defaultDocument();
//		var app = APP(doc, function() {
//			var a_lang = 'it';
//			TAG(doc.domGetBody(), function() {
//				var a_dataUb1 = a_lang + '-lang';
//				var c_base = true;
//				var c_es = a_lang == 'es';
//				var s_textAlign = (a_lang == 'es' ? 'right' : 'left');
//			});
//		});
//	}

//	public static function main() {
//		var doc = DomTools.defaultDocument();
//		var app = APP(doc, {
//			var a_lang = 'it';
//			TAG(doc.domGetBody(), {
//				var a_dataUb1 = {a_lang + '-lang'};
//				var c_base = true;
//				var c_es = {a_lang == 'es'};
//				var s_textAlign = {a_lang == 'es' ? 'right' : 'left'};
//			});
//		});
//	}

//	public static function main1() {
//		var doc = DomTools.defaultDocument();
//		var ctx = new ReContext();
//		var a_lang:Re<String>;
//		var app = new ReApp(doc, ctx, function(p:ReApp) {
//			a_lang = untyped p.add('a_lang', new Re<String>(ctx, 'it', null));
//			new ReElement(p, doc.domGetBody(), function(p:ReElement) {
//				p.add('a_dataUb1', new Re<String>(ctx, null, function() {
//					return a_lang.get() + '-lang';
//				})).addSrc(a_lang);
//				p.add('c_base', new Re<Bool>(ctx, true, null));
//				p.add('c_es', new Re<Bool>(ctx, null, function() {
//					return a_lang.get() == 'es';
//				})).addSrc(a_lang);
//				p.add('s_textAlign', new Re<String>(ctx, null, function() {
//					return a_lang.get() == 'es' ? 'right' : 'left';
//				})).addSrc(a_lang);
//			});
//		});
//		haxe.Timer.delay(function() a_lang.set('es'), 1000);
//	}

}

//class App {
//	public function new(doc:DomDocument, cb:Void->Void) {}
//}
//
//class Tag {
//	public function new(e:Dynamic, cb:Void->Void) {}
//}