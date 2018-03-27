package reapp.macro;

import reapp.app.*;
import reapp.core.*;
import haxe.macro.Expr;
//#if macro
	import haxe.macro.Context;
	import haxe.macro.ExprTools;
	import haxe.macro.MacroStringTools;
	import haxe.macro.Type;
	import haxe.macro.TypeTools;
//#end

// =============================================================================
// RE
// =============================================================================

class RE {

	macro public static function APP(doc:Expr, block:Expr) {
#if macro
		block = formatStrings(block);
		var scope = new ReScope(null, 'APP', doc, block);
		scope.transform();
//		trace(scope.dump());
		var ret = scope.output();
		trace(ExprTools.toString(ret));
		return ret;
#end
	}

	static function formatStrings(e:Expr): Expr {
#if macro
		return switch (e.expr) {
			case ExprDef.EConst(Constant.CString(s)):
				MacroStringTools.formatString(s, e.pos);
			default:
				ExprTools.map(e, formatStrings);
		}
#else
		return e;
#end
	}

	public static function error(msg:String, pos:Position) {
#if macro
		Context.error(msg, pos);
#end
	}

}

//#if macro
// =============================================================================
// ReScope
// =============================================================================

class ReScope {
	public var parent: ReScope;
	public var name: String;
	public var arg: Expr;
	public var pos: Position;
	public var vars = new Array<ReVar>();
	public var nameVarMap = new Map<String, ReVar>();

	public function new(parent:ReScope, name:String, arg:Expr, block:Expr) {
		this.parent = parent;
		this.name = name;
		this.arg = arg;
		this.pos = block.pos;
		load(block);
	}

	public function dump(prefix='') {
		var sb = new StringBuf();
		var p = prefix + '    ';
		sb.add(' [\n');
			for (v in vars) {
				var src = v.expr != null ? ExprTools.toString(v.expr) : '';
				src = src.split('\n').join(' ');
				var deps = new Array<String>();
				for (key in v.deps.keys()) deps.push(key);
				sb.add('${p}var ${v.name}:${v.type}${deps} = ${src}');
				if (v.inner != null) {
					sb.add(v.inner.dump(p));
				}
				sb.add('\n');
			}
		sb.add('$prefix]');
		return sb.toString();
	}

	public function addVar(v:ReVar) {
		vars.push(v);
		v.name != null ? nameVarMap.set(v.name, v) : null;
	}

	public function getVar(id:String): ReVar {
//		for (v in vars) {
//			if (v.name == id) {
//				return v;
//			}
//		}
//		return null;
		return nameVarMap.get(id);
	}

	// =========================================================================
	// load
	// =========================================================================

	function load(block:Expr) {
		// collect var/function/TAG declarations
		switch (block.expr) {
		case EBlock(ee):
			for (e in ee) {
				switch (e.expr) {
				// var declaration
				case EVars(vv):
					for (v in vv) {
						addVar(new ReVar(
							v.name,
							v.type,
							v.expr,
							v.expr != null ? v.expr.pos : e.pos,
							this
						));
					}
				// function declaration
				case EFunction(n,f):
					n == null ? RE.error('Missing function name', e.pos) : null;
					addVar(new ReVar(
						n,
						f.ret,
						e,
						e.pos,
						this,
						true
					));
				// anonymous TAG declaration
				case ECall(e,pp):
					var tag = switch (e.expr) {
						case EConst(CIdent(s)): s == 'TAG';
						default: false;
					}
					if (tag == true) {
						if (pp.length == 2) {
							var v = new ReVar(
								null,
								getComplexType('ReTag'),
								null,
								e.pos,
								this
							);
							v.inner = new ReScope(this, null, pp[0], pp[1]);
							addVar(v);
						} else {
							RE.error('Bad tag parameters', e.pos);
						}
					} else {
						RE.error('Var/function/tag expected', e.pos);
					}
				default:
					RE.error('Var/function/tag expected', e.pos);
				}
			}
		default:
			RE.error('Block expected', block.pos);
		}
		// look up named nested TAGs
		for (v in vars) {
			if (v.expr != null) {
				switch (v.expr.expr) {
				case ECall(e,pp):
					switch (e.expr) {
					case EConst(CIdent(s)):
						if (pp.length == 2) {
							v.type = getComplexType('ReTag');
							v.inner = new ReScope(this, v.name, pp[0], pp[1]);
							v.expr = null;
						} else {
							RE.error('Bad tag parameters', e.pos);
						}
					default:
					}
				default:
				}
			}
		}
	}

	// =========================================================================
	// transform
	// =========================================================================

	public function transform() {
		ensureTypes();
		makeReactive();
		setDependencies();
	}

	function ensureTypes() {
		for (v in vars) v.ensureType();
		for (v in vars) v.inner != null ? v.inner.ensureTypes() : null;
	}

	function makeReactive() {
		for (v in vars) v.makeReactive();
		for (v in vars) v.inner != null ? v.inner.makeReactive() : null;
	}

	function setDependencies() {
		for (v in vars) v.setDependencies();
		for (v in vars) v.inner != null ? v.inner.setDependencies() : null;
	}

	// =========================================================================
	// output
	// =========================================================================

	public function output(): Expr {
		var ret;
		var callback = outputCallback();
		if (parent == null) {
			ret = macro {
				var _ctx_ = new ReContext();
				new ReApp($arg, _ctx_, $callback);
			}
		} else if (name == null) {
			ret = macro new ReTag(_n_, $arg, $callback);
		} else {
			ret = macro var $name = new ReTag(_n_, $arg, $callback);
		}
		return ret;
	}

	function outputCallback(): Expr {
		return {
			expr: ExprDef.EFunction(null, {
				args: [{
					name:'_n_', type:getComplexType('ReElement')
				}, {
					name:'_ctx_', type:getComplexType('ReContext')
				}],
				ret: null,
				expr: outputCallbackBody(),
			}),
			pos: pos,
		}
	}

	function outputCallbackBody() {
		var ee = new Array<Expr>();
		// vars
		for (v in vars) {
			if (v.inner != null) {
				ee.push(v.inner.output());
			} else if (v.expr != null) {
				ee.push(v.expr);
			}
		}
		// dependencies
		for (v in vars) {
			if (v.setDeps != null) {
				ee.push(v.setDeps);
			}
		}
		return {
			expr: ExprDef.EBlock(ee),
			pos: pos,
		}
	}

	// =========================================================================
	// util
	// =========================================================================

	public static function getComplexType(name:String): ComplexType {
#if macro
		return TypeTools.toComplexType(Context.getType(name));
#else
		return null;
#end
	}

}

// =============================================================================
// ReVar
// =============================================================================

class ReVar {
	public var name: String;
	public var type: ComplexType;
	public var expr: Expr;
	public var pos: Position;
	public var isFunction: Bool;
	public var react: Bool;
	public var passiveIds: Map<String, Bool>;
	public var deps: Map<String, ReVar>;
	public var setDeps: Expr;
	public var outer: ReScope;
	public var inner: ReScope;

	public function new(name: String,
	                    type: ComplexType,
	                    expr: Expr,
	                    pos: Position,
	                    outer: ReScope,
	                    isFunction=false) {
		this.name = name;
		this.type = type;
		this.expr = expr;
		this.pos = pos;
		this.isFunction = isFunction;
		this.react = false;
		this.deps = new Map<String, ReVar>();
		this.setDeps = null;
		this.outer = outer;
		this.inner = null;
	}

	public function ensureType() {
		if (type == null && expr != null) {
			try {
				var t = untyped Context.typeof(expr);
				type = untyped Context.toComplexType(t);
			} catch (ignored:Dynamic) {
				trace(ignored);
			}
		}
		if (type == null) {
			RE.error('Missing type', pos);
		}
	}

	public function makeReactive() {
		if (name != null && inner == null) {
			expr != null ? null : expr = macro null;
			var fun:Function = null;
			var const = switch (expr.expr) {
				case EConst(c): switch (c) {
					case CIdent(id): id == 'null';
					default: true;
				}
				case EFunction(n,f): fun = f; true;
				default: false;
			}
			if (fun != null) {
				makeFunction(fun);
			} else {
				makeVar(const);
			}
		}
	}

	function makeFunction(fun:Function) {
		passiveIds = new Map<String,Bool>();
		for (a in fun.args) passiveIds.set(a.name, true);
		expr = patchIds(expr);
	}

	function makeVar(const:Bool) {
		var fun = macro null;
		if (!const) {
			fun = {
				expr: ExprDef.EFunction(null, {
					args: [],
					ret: type,
					expr: {
						expr: ExprDef.EReturn(patchIds(expr)),
						pos: pos,
					}
				}),
				pos: pos,
			};
			expr = macro null;
		}
		var t = #if macro Context.getType('Re'); #else null; #end
		var ct:ClassType = switch (t) {
			case TInst(ctref,pp): ctref.get();
			default: null;
		}
		ct == null ? RE.error('Missing type Re<>', pos) : null;
		expr = {
			expr: ExprDef.EVars([{
				name: name,
				type: null,
				expr: {
					expr: ExprDef.ENew({
						pack: ct.pack,
						name: ct.name,
						params: [TypeParam.TPType(type)],
					}, [
						macro _ctx_,
						expr,
						fun,
						untyped Context.parse('"$name"', pos),
						macro _n_.add,
					]),
					pos: pos,
				}
			}]),
			pos: pos,
		}
		react = true;
	}

	public function setDependencies() {
		var list = new Array<Expr>();
		for (v in deps) {
			if (v.react) {
				list.push(untyped Context.parse(v.name, pos));
			}
		}
		setDeps = (list.length == 0) ? null : {
			expr: ExprDef.ECall(
				untyped Context.parse(name + '.setDeps', pos),
				[{expr:ExprDef.EArrayDecl(list), pos:pos}]
			),
			pos: pos,
		};
	}

	function patchIds(e:Expr): Expr {
		return patchVarAccess(patchFieldAccess(e));
	}

	function patchVarAccess(e:Expr): Expr {
		return switch (e.expr) {
			case EConst(CIdent(id)):
				var s = id;
				var v = lookupVar(id);
				if (v != null && v.react) {
					if (passiveIds == null || !passiveIds.exists(id)) {
						deps.set(id, v);
						s = '$id.value';
					}
				}
				untyped Context.parse(s, e.pos);
			default:
				ExprTools.map(e, patchVarAccess);
		}
	}

	function patchFieldAccess(expr:Expr): Expr {
		return switch (expr.expr) {
		case EField(e,f):
			switch (e.expr) {
			case EConst(CIdent(id)):
				var s = '$id.$f';
				var x = lookupVar(id);
				var y = (x != null && x.inner != null)
						? x.inner.getVar(f)
						: null;
				y != null && !y.isFunction && y.inner == null
					? s = '$id.values.get("$f").value'
					: null;
				untyped Context.parse(s, pos);
			default:
				ExprTools.map(expr, patchFieldAccess);
			}
		default:
			ExprTools.map(expr, patchFieldAccess);
		}
	}

	function lookupVar(id:String): ReVar {
		var ret = null;
		var s = outer;
		while (s != null && (ret = s.getVar(id)) == null) {
			s = s.parent;
		}
		return ret;
	}

}

//// =============================================================================
//// ReFunction
//// =============================================================================
//
//class ReFunction {
//	public var name: String;
//	public var fun: Function;
//
//	public function new(name:String, fun:Function) {
//		this.name = name;
//		this.fun = fun;
//	}
//
//	public function output(): Expr {
//
//	}
//
//}

//#end
