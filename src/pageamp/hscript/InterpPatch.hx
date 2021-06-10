package pageamp.hscript;

import haxe.macro.Context;
import haxe.macro.Expr;

// https://code.haxe.org/category/macros/build-map.html
// https://code.haxe.org/category/macros/add-parameters-as-fields.html
class InterpPatch {
	public static macro function patch():Array<Field> {
		var fields = Context.getBuildFields();

		for (field in fields) {
			if (field.name == 'variables') {
				field.kind = FieldType.FVar(macro:Dynamic);
			}
		}

		return fields;
	}
}
