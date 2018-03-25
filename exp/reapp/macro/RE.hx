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

//TODO: anonymous nested scopes
//TODO: allow function <name>() syntax
class RE {

	macro public static function APP(doc:Expr, block:Expr) {
#if macro
		block = formatStrings(block);
		var scope = new ReScope(null, 'APP', doc, block);
		scope.transform();
		//trace(scope.dump());
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

	public function getVar(id:String): ReVar {
		for (v in vars) {
			if (v.name == id) {
				return v;
			}
		}
		return null;
	}

	// =========================================================================
	// load
	// =========================================================================

	function load(block:Expr) {
		// collect var declarations
		switch (block.expr) {
		case EBlock(ee):
			for (e in ee) {
				switch (e.expr) {
				case EVars(vv):
					for (v in vv) {
						vars.push(new ReVar(
							v.name,
							v.type,
							v.expr,
							v.expr != null ? v.expr.pos : e.pos,
							this
						));
					}
				default:
					RE.error('var declaration expected', e.pos);
				}
			}
		default:
			RE.error('block expected', block.pos);
		}
		// look up nested scopes and functions
		for (v in vars) {
			if (v.expr != null) {
				switch (v.expr.expr) {
				case ECall(e,pp):
					switch (e.expr) {
					case EConst(CIdent(s)):
						if (pp.length == 2) {
							v.type = getComplexType('ReTag');
							v.inner = new ReScope(this, 'TAG', pp[0], pp[1]);
							v.expr = null;
						} else {
							RE.error('bad parameters', e.pos);
						}
					default:
					}
//				case EFunction(n,f):
//					v.fun = f;
//					v.expr = null;
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
		ret = (parent == null
			? macro {
				var _ctx_ = new ReContext();
				new ReApp($arg, _ctx_, $callback);
			}
			: macro new ReTag(_n_, $arg, $callback));
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
		for (v in vars) {
			if (v.expr != null) {
				ee.push(v.expr);
			}
		}
		//TODO: functions
		for (v in vars) {
			if (v.inner != null) {
				ee.push(v.inner.output());
			}
		}
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
	public var fun: Function;
	public var pos: Position;
	public var react: Bool;
	public var deps: Map<String, ReVar>;
	public var setDeps: Expr;
	public var outer: ReScope;
	public var inner: ReScope;

	public function new(name: String,
	                    type: ComplexType,
	                    expr: Expr,
	                    pos: Position,
	                    outer: ReScope) {
		this.name = name;
		this.type = type;
		this.expr = expr;
		this.fun = null;
		this.pos = pos;
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
			RE.error('missing type', pos);
		}
	}

	public function makeReactive() {
		if (inner == null && this.fun == null) {
			expr != null ? null : expr = macro null;
			var const = switch (expr.expr) {
				case EConst(c): switch (c) {
					case CIdent(id): id == 'null';
					default: true;
				}
				default: false;
			}
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
			ct == null ? RE.error('missing type Re<>', pos) : null;
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
		return switch (e.expr) {
		case EConst(CIdent(id)):
			var s = id;
			var v = lookupVar(id);
			if (v != null && v.react) {
				deps.set(id, v);
				s = '$id.value';
			}
			untyped Context.parse(s, e.pos);
		default:
			ExprTools.map(e, patchIds);
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
//#end
