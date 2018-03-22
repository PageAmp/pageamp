package reapp.macro1;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import reapp.core.ReMacro;

class ReMacro1Scan {
	static inline var APP_CALL = 'APP';
	static inline var NODE_CALL = 'NODE';
	static var RESERVED_CALLS = [APP_CALL, NODE_CALL];
	static var classIndex = 0;

	public static function scan(block:Expr): ReScope {
		return scanBlock(null, null, {
			name: APP_CALL,
			pos: block.pos,
			params: [block]
		});
	}

	public static function dumpScope(scope:ReScope) {
		var sb = new StringBuf();
		var fun = null;
		fun = function(s:ReScope, prefix:String) {
			var p = prefix + '    ';
			sb.add('[class ${ReMacro1.CLASS_PREFIX}${s.nr}');
			sb.add(' extends ${s.superc}] {\n');
			for (f in s.fields) {
				sb.add('${p}${f.name}');
				if (f.dependencies != null) {
					var sep = '';
					sb.add('{');
					for (dep in f.dependencies.keys()) {
						sb.add('${sep}${dep}');
						sep = ', ';
					}
					sb.add('}');
				}
				sb.add(': ');
				if (f.type != null) {
					sb.add(f.type + ' ');
				} else {
					sb.add('untyped ');
				}
				if (f.child != null) {
					fun(f.child, p);
				} else if (f.expr != null) {
					sb.add(ExprTools.toString(f.expr) + ',\n');
				} else {
					sb.add('null,\n');
				}
			}
			for (f in s.functions) {
				var sep = '';
				sb.add('${p}function ${f.name}(');
				for (a in f.fun.args) {
					sb.add(sep); sep = ', ';
					sb.add(a.name);
				}
				sb.add('),\n');
			}
			sb.add(prefix + '},\n');
		}
		fun(scope, '');
		trace(sb.toString());
	}

	static function scanBlock(p:ReScope, f: String, call:ReCall): ReScope {
		var block:Expr = switch (call.name) {
			case APP_CALL, NODE_CALL:
				if (call.params.length != 1) {
					error('Block expected', call.pos);
					null;
				} else {
					call.params[0];
				}
			//TODO remaining calls
			default:
				error('Unknown type', call.pos);
				null;
		}
		var superName = switch (call.name) {
			case APP_CALL: 'reapp.core.ReApp';
			//TODO: remaining calls
			default: 'reapp.core.ReNode';
		}
		var ret:ReScope = {
			nr: classIndex++,
			pos: call.pos,
			superc: superName,
			parent: p,
			pfield: f,
			fields: [],
			functions: [],
		};
		if (block != null) {
			switch (block.expr) {
				case ExprDef.EBlock(ee):
					scanExpressions(ret, f, ee, ret);
				default:
					error('Block expected', block.pos);
			}
		}
		return ret;
	}

	static function scanExpressions(p:ReScope,
	                                f:String,
	                                ee:Array<Expr>,
	                                ret:ReScope) {
		for (e in ee) {
			switch (e.expr) {
				case ExprDef.EVars(vv):
					scanVariables(p, f, vv, ret);
				case ExprDef.EFunction(n,f):
					if (n == null) {
						error('Anonymous function not allowed here', e.pos);
					} else {
						ret.functions.push({
							name: n,
							fun: scanFunction(p, f),
						});
					}
				default:
					error('Variable/function declaration expected', e.pos);
			}
		}
	}

	static function scanFunction(p:ReScope, f:Function): Function {
		var ret:Function = {
			args: scanFunctionArgs(p, f.args),
			ret: f.ret,
			expr: (f.expr != null ? patchIds(p, f.expr) : null),
			params: f.params,
		}
		return ret;
	}

	static function scanFunctionArgs(p:ReScope,
	                                 args:Array<FunctionArg>):
	Array<FunctionArg> {
		var ret = new Array<FunctionArg>();
		for (arg in args) {
			ret.push({
				name: arg.name,
				opt: arg.opt,
				type: arg.type,
				value: (arg.value != null ? patchIds(p, arg.value) : null),
				meta: arg.meta,
			});
		}
		return ret;
	}

	static function scanVariables(p:ReScope,
	                              f:String,
	                              vv:Array<Var>,
	                              ret:ReScope) {
		for (v in vv) {
			var depencencies = new Map<String, ReField>();
			if (v.expr != null) {
				v.expr = patchIds(p, v.expr, depencencies);
			}
			!depencencies.keys().hasNext() ? depencencies = null : null;
			var call = checkRecursion(v);
			if (call != null) {
				ret.fields.push({
					scope: ret,
					name: v.name,
					child: scanBlock(p, f, call),
					dependencies: depencencies,
				});
			} else {
				ret.fields.push({
					scope: ret,
					name: v.name,
					type: v.type,
					expr: v.expr,
					dependencies: depencencies,
				});
			}
		}
	}

	static function patchIds(p:ReScope,
	                         e:Expr,
	                         ?deps:Map<String,ReField>): Expr {
		var f;
		f = function(e:Expr) {
			return switch(e.expr) {
				case ExprDef.EConst(Constant.CIdent(id)):
					var f = RESERVED_CALLS.indexOf(id) < 0
					? lookupId(p, id)
					: null;
					var s = (f != null ? f.scope : null);
					if (f != null && deps != null) {
						var key = '${s.nr}.${f.name}';
						deps.set(key, f);
					}
					if (s != null && s != p) {
						var k = '${ReMacro1.CLASS_PREFIX}${s.nr}';
						var ia = ReMacro1.INSTANCE_ARRAY;
						var src = 'cast(reapp.core.ReNode.$ia[${s.nr}],$k).$id';
						return untyped Context.parse(src, e.pos);
					} else {
						return e;
					}
				case ExprDef.EConst(Constant.CString(s)):
					ReMacro1.formatString(s, e.pos);
				default:
					ExprTools.map(e, f);
			}
		}
		return f(e);
	}

	static function lookupId(p:ReScope, id:String): ReField {
		while (p != null) {
			for (f in p.fields) {
				if (id == f.name) {
					return f;
				}
			}
			p = p.parent;
		}
		return null;
	}

	static function checkRecursion(v:Var): ReCall {
		var ret:ReCall = null;
		if (v.expr != null) {
			switch (v.expr.expr) {
				case ExprDef.ECall(e,pp):
					if ((ret = isRecursionCall(e)) != null) {
						ret.pos = v.expr.pos;
						ret.params = pp;
					}
				default:
			}
		}
		return ret;
	}

	static function isRecursionCall(e:Expr): ReCall {
		return switch (e.expr) {
			case ExprDef.EConst(c): isRecursionCallId(c);
			default: null;
		}
	}

	static function isRecursionCallId(c:Constant): ReCall {
		return switch (c) {
			case Constant.CIdent(s):
				RESERVED_CALLS.indexOf(s) >= 0 ? {
					name:s, pos:null, params:null
				} : null;
			default: null;
		}
	}

	static inline function error(msg:String, pos:Position) {
		untyped Context.error(msg, pos);
	}

}

typedef ReCall = {
	name: String,
	pos: Position,
	params: Array<Expr>,
}

typedef ReScope = {
	nr: Int,
	pos: Position,
	superc: String,
	parent: ReScope,
	pfield: String,
	fields: Array<ReField>,
	functions: Array<ReFunction>,
}

typedef ReField = {
	scope: ReScope,
	name: String,
	?type: ComplexType,
	?expr: Expr,
	?child: ReScope,
	?cname: String,
	?dependencies: Map<String, ReField>,
}

typedef ReFunction = {
	name: String,
	fun: Function,
}
