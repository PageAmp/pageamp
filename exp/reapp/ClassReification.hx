package reapp;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
using haxe.macro.ExprTools;

class ClassReification {

	public static function main() {
		var n = NODE({
			var x = 'foo';
			var child = NODE({
				var y = 'bar';
			});
		});
		trace(n.child.y);
	}

	/**
	* Expects an EBlock
	**/
	macro static function NODE(block:Expr) {

		// =====================================================================
		// scan
		// =====================================================================
		var scanBlock:Expr->MBlock = null;

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

		function scanVariables(vv:Array<Var>, ret:MBlock) {
			for (v in vv) {
				var block = checkRecursion(v);
				if (block != null) {
					ret.push({
						name: v.name,
						block: scanBlock(block),
					});
				} else {
					ret.push({
						name: v.name,
						type: v.type,
						expr: v.expr,
					});
				}
			}
		}

		function scanExpressions(ee:Array<Expr>, ret:MBlock) {
			for (e in ee) {
				switch (e.expr) {
					case ExprDef.EVars(vv):
						scanVariables(vv, ret);
					default:
						//TODO
				}
			}
		}

		scanBlock = function(block:Expr): MBlock {
			trace('scanBlock()');
			var ret:MBlock = [];
			switch (block.expr) {
				case ExprDef.EBlock(ee):
					scanExpressions(ee, ret);
				default:
					//TODO
			}
			return ret;
		}

		// =====================================================================
		// gen
		// =====================================================================
		var classNr = 0;
		var genBlock:MBlock->Expr = null;

		genBlock = function(mblock): Expr {
			var className = 'NodeClass' + (++classNr);
			for (v in mblock) {
				if (v.block != null) {
					v.expr = genBlock(v.block);
				}
			}
			var c:TypeDefinition = macro class $className {
				public function new() {}
			}
			var fields:Array<Field> = c.fields;
			for (v in mblock) {
				fields.push({
					pos: (v.expr != null ? v.expr.pos : Context.currentPos()),
					name: v.name,
					kind: FieldType.FVar(v.type, v.expr),
					access: [Access.APublic],
				});
			}
			Context.defineType(c);
			return Context.parse('new $className()', Context.currentPos());
		}

		// =====================================================================
		// main
		// =====================================================================

		var mblock = scanBlock(block);
//		var s = haxe.Json.stringify(mblock);
//		trace(s);

		return genBlock(mblock);
	}

}

typedef MBlock = Array<MVar>;

typedef MVar = {
	name: String,
	?type: ComplexType,
	?expr: Expr,
	?block: MBlock,
}
