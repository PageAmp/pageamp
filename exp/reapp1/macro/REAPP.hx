package reapp1.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
using haxe.macro.ExprTools;

class REAPP {

	macro public static function NODE(block:Expr) {

		// =====================================================================
		// scan
		// =====================================================================
		var scopeNr = 0;
		var scanBlock:NScope->String->Expr->NScope = null;

		function isRecursionCallId(c:Constant): Bool {
			var ret = false;
			switch (c) {
				case Constant.CIdent(s):
					ret = (s == 'NODE');
				default:
				//TODO
			}
			return ret;
		}

		function isRecursionCall(e:Expr): Bool {
			var ret = false;
			switch (e.expr) {
				case ExprDef.EConst(c):
					ret = isRecursionCallId(c);
				default:
			}
			return ret;
		}

		function checkRecursion(v:Var): Expr {
			var ret:Expr = null;
			if (v.expr != null) {
				switch (v.expr.expr) {
					case ExprDef.ECall(e,pp):
						if (isRecursionCall(e)) {
							if (pp != null && pp.length == 1) {
								ret = pp[0];
							} else {
								//TODO
							}
						}
					default:
					//TODO
				}
			}
			return ret;
		}

		function scanVariables(p:NScope, f:String, vv:Array<Var>, ret:NScope) {
			for (v in vv) {
				var block = checkRecursion(v);
				if (block != null) {
					ret.fields.push({
						name: v.name,
						child: scanBlock(p, f, block),
					});
				} else {
					ret.fields.push({
						name: v.name,
						type: v.type,
						expr: v.expr,
					});
				}
			}
		}

		function scanExpressions(p:NScope, f:String, ee:Array<Expr>, ret:NScope) {
			for (e in ee) {
				switch (e.expr) {
					case ExprDef.EVars(vv):
						scanVariables(p, f, vv, ret);
					default:
					//TODO
				}
			}
		}

		scanBlock = function(p:NScope, f: String, block:Expr): NScope {
			trace('scanBlock()');
			var ret:NScope = {
				nr: ++scopeNr,
				parent: p,
				pfield: f,
				fields: [],
			};
			switch (block.expr) {
				case ExprDef.EBlock(ee):
					scanExpressions(p, f, ee, ret);
				default:
				//TODO
			}
			return ret;
		}

		// =====================================================================
		// gen
		// =====================================================================
		var genBlock:NScope->Expr = null;

		genBlock = function(mblock:NScope): Expr {
			var className = 'AutoGen' + (mblock.nr);
			for (v in mblock.fields) {
				if (v.child != null) {
					v.expr = genBlock(v.child);
				}
			}
			var c:TypeDefinition = macro class $className {
				public var parent: Dynamic;
				public function new(p) {parent = p;}
			}
			var fields:Array<Field> = c.fields;
			for (v in mblock.fields) {
				fields.push({
					pos: (v.expr != null ? v.expr.pos : Context.currentPos()),
					name: v.name,
					kind: FieldType.FVar(v.type, v.expr),
					access: [Access.APublic],
				});
			}
			Context.defineType(c);
			var p = (mblock.parent != null ? 'this' : 'null');
			return Context.parse('new $className($p)', Context.currentPos());
		}

		// =====================================================================
		// main
		// =====================================================================

		var mblock = scanBlock(null, null, block);
		return genBlock(mblock);
	}

}

typedef NScope = {
	nr: Int,
	parent: NScope,
	pfield: String,
	fields: Array<NField>,
}

typedef NField = {
	name: String,
	?type: ComplexType,
	?expr: Expr,
	?child: NScope,
}
