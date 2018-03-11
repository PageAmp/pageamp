package reapp;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
using haxe.macro.ExprTools;

class ClassReification {

	public static function main() {
		var c = NODE({
			var s = 'foo';
//			var child = NODE({
//				var x =  'bar';
//			});
		});
		trace(c.s);
	}

	macro static function NODE(e:Expr) {
		// https://haxe.org/manual/macro-reification-class.html
		var c:TypeDefinition = macro class Class1 {
			public function new() { }
		}
		var fields:Array<Field> = c.fields;
		e.iter(function(p:Expr) {
			var pos = p.pos;
			//trace(p.expr);
			switch (p.expr) {
				case ExprDef.EVars(vv):
					for (v in vv) {
						fields.push({
							pos: pos,
							name: v.name,
							kind: FieldType.FVar(v.type, v.expr),
							access: [Access.APublic],
						});
					}
				default:
			}
		});
		Context.defineType(c);
		return macro new Class1();
	}

}
