package reapp.core;

import haxe.macro.Expr;
#if macro
	import haxe.macro.Context;
	import haxe.macro.ExprTools;
	import haxe.macro.MacroStringTools;
#end

class ReMacro {
	public static inline var CLASS_PREFIX = 'Node';
	public static inline var INSTANCE_ARRAY = '_';

	macro public static function APP(block:Expr) {
#if macro
		var scope = ReMacroScan.scan(block);
		ReMacroScan.dumpScope(scope);
		return ReMacroGen.gen(scope);
#end
	}

	public static function formatString(s:String, pos:Position): Expr {
#if macro
		return MacroStringTools.formatString(s, pos);
#else
		return null;
#end
	}

}

#if macro

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

// =============================================================================
// ReMacroScan
// =============================================================================

class ReMacroScan {
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
			sb.add('[class ${ReMacro.CLASS_PREFIX}${s.nr}');
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
						var k = '${ReMacro.CLASS_PREFIX}${s.nr}';
						var ia = ReMacro.INSTANCE_ARRAY;
						var src = 'cast(reapp.core.ReNode.$ia[${s.nr}],$k).$id';
						return untyped Context.parse(src, e.pos);
					} else {
						return e;
					}
				case ExprDef.EConst(Constant.CString(s)):
					ReMacro.formatString(s, e.pos);
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

// =============================================================================
// ReMacroGen
// =============================================================================

class ReMacroGen {

	public static function gen(scope:ReScope): Expr {
		genClasses(scope);
		var steps = new Array<Expr>();
		genObjects(scope, steps);
		initObjects(scope, scope, steps);
		var src = 'cast(reapp.core.ReNode.${ReMacro.INSTANCE_ARRAY}[0], Node0)';
		steps.push(untyped Context.parse(src, currentPos()));
		return {
			expr: ExprDef.EBlock(steps),
			pos: currentPos(),
		};
	}

	static inline function currentPos(): Position {
		return untyped Context.currentPos();
	}

	static function genClasses(scope:ReScope) {
		var className = ReMacro.CLASS_PREFIX + scope.nr;
		var pack = scope.superc.split('.');
		var name = pack.pop();
		var superPath = {pack:pack, name:name};
		var c:TypeDefinition = macro class $className extends $superPath {}
		var inits:Array<Expr> = [];
		inits.push(untyped Context.parse('super.init(app)', currentPos()));
		for (v in scope.fields) {
			if (v.type == null && v.expr != null && v.child == null) {
				try {
					var type = untyped Context.typeof(v.expr);
					v.type = untyped Context.toComplexType(type);
				} catch (ignored:Dynamic) {}
			}
			c.fields.push({
				pos: (v.expr != null ? v.expr.pos : currentPos()),
				name: v.name,
				kind: FieldType.FVar(v.type, macro null),
				access: [Access.APublic],
			});
			if (v.expr != null && v.child == null) {
				var name = untyped Context.parse(v.name, v.expr.pos);
				var expr = v.expr;
				inits.push(macro $name = $expr);
			} else if (v.child != null) {
				var nr = v.child.nr;
				var name = ReMacro.CLASS_PREFIX + nr;
				var ia = ReMacro.INSTANCE_ARRAY;
				var src = '${v.name} = cast(addChild('
									 + 'reapp.core.ReNode.$ia[$nr]), $name)';
				inits.push(untyped Context.parse(src, currentPos()));
			}
		}
		c.fields.push({
			name: 'init',
			access: [Access.APublic, Access.AOverride],
			pos: currentPos(),
			kind: FFun({
				args: [{name:'app', type:ComplexType.TPath({
					pack: ['reapp', 'core'],
					name: 'ReApp',
				})}],
				expr: {expr:ExprDef.EBlock(inits), pos:currentPos()},
				params: [],
				ret: null
			})
		});
		for (f in scope.functions) {
			c.fields.push({
				name: f.name,
				access: [Access.APublic],
				pos: currentPos(),
				kind: FFun({
					args: f.fun.args,
					expr: f.fun.expr,
					params: f.fun.params,
					ret: f.fun.ret,
				})
			});
		}
		untyped Context.defineType(c);
		for (v in scope.fields) {
			if (v.child != null) {
				genClasses(v.child);
			}
		}
	}

	static function genObjects(scope:ReScope, steps:Array<Expr>) {
		var className = ReMacro.CLASS_PREFIX + scope.nr;
		var ia = ReMacro.INSTANCE_ARRAY;
		var src = 'reapp.core.ReNode.$ia[${scope.nr}] = new $className()';
		steps.push(untyped Context.parse(src, currentPos()));
		for (v in scope.fields) {
			if (v.child != null) {
				genObjects(v.child, steps);
			}
		}
	}

	static function initObjects(app:ReScope, scope:ReScope, steps:Array<Expr>) {
		var src = 'reapp.core.ReNode._[${scope.nr}].init('
				+ 'untyped reapp.core.ReNode._[${app.nr}])';
		steps.push(untyped Context.parse(src, currentPos()));
		for (v in scope.fields) {
			if (v.child != null) {
				initObjects(app, v.child, steps);
			}
		}
	}

}

#end
