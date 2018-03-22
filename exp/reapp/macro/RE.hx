package reapp.macro;

import reapp.app.*;
import reapp.core.*;
import haxe.macro.Expr;
//#if macro
	import haxe.macro.Context;
	import haxe.macro.ExprTools;
	import haxe.macro.MacroStringTools;
	import haxe.macro.TypeTools;
//#end

class RE {

	macro public static function APP(doc:Expr, callback:Expr) {
//#if macro
		callback = patchCallback(callback);
		return macro {
			var _ctx_ = new ReContext();
			new ReApp($doc, _ctx_, $callback);
		}
//#end
	}

//#if macro
	static function patchCallback(callback:Expr): Expr {
		var nodeType = getComplexType('ReNode');
		switch (callback.expr) {
			case ExprDef.EFunction(_, f):
				return {
					expr: ExprDef.EFunction(null, {
						args: [{name:'_n_', type:nodeType}],
						ret: null,
						expr: patchCallbackBody(f.expr),
					}),
					pos: callback.pos,
				}
			default:
				error('function expected', callback.pos);
				return macro null;
		}
	}

	static function patchCallbackBody(block:Expr): Expr {
		switch (block.expr) {
			case ExprDef.EBlock(ee):
				return patchIds(block);
			default:
				error('block expected', block.pos);
				return macro null;
		}
	}

	static function patchIds(e:Expr): Expr {
		return switch (e.expr) {
			case EVars(vv):
				patchDefs(vv, e.pos);
			case EConst(CIdent(id)):
				patchRef(id, e.pos);
			case ExprDef.EConst(Constant.CString(s)):
				formatString(s, e.pos);
			default:
				ExprTools.map(e, patchIds);
		}
	}

	static function patchDefs(vv:Array<Var>, pos:Position): Expr {
		var ee = new Array<Expr>();
		for (v in vv) {
			ee.push(patchDef(v, pos));
		}
		return {expr:ExprDef.EBlock(ee), pos:pos};
	}

	static function patchDef(v:Var, pos:Position): Expr {
		if (v.type == null && v.expr != null) {
			try {
				var type = untyped Context.typeof(v.expr);
				v.type = untyped Context.toComplexType(type);
			} catch (ignored:Dynamic) {}
		}
		var t = switch (v.type) {
			case TPath(p): p.name;
			default: 'Dynamic';
		}
		trace(v.name + ': ' + t);//tempdebug
		return parse('_n_.add("${v.name}", new Re<$t>(_ctx_, null, null))', pos);
		//return parse('var ${v.name}=new Re<$t>(_ctx_, null, null))', pos);
	}

	static function patchRef(id:String, pos:Position): Expr {
		return parse('_n_.val("$id")', pos);
	}
//#end

	// =========================================================================
	// util
	// =========================================================================

	static function getComplexType(name:String): ComplexType {
#if macro
		return TypeTools.toComplexType(Context.getType(name));
#else
		return null;
#end
	}

	static function parse(src:String, pos:Position): Expr {
#if macro
		return Context.parse(src, pos);
#else
		return null;
#end
	}

	static function error(msg:String, pos:Position) {
#if macro
		Context.error(msg, pos);
#end
	}

	static function formatString(s:String, pos:Position): Expr {
#if macro
		return MacroStringTools.formatString(s, pos);
#else
		return null;
#end
	}

}
