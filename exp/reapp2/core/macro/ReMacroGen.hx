package reapp2.core.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import reapp2.core.ReMacro;
import reapp2.core.macro.ReMacroScan;

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
			var p = (v.expr != null ? v.expr.pos : currentPos());
			trace(v.name);
			if (v.type == null && v.expr != null && v.child == null) {
				try {
					var type = untyped Context.typeof(v.expr);
					v.type = untyped Context.toComplexType(type);
				} catch (ignored:Dynamic) {}
			}
			if (v.type == null) {
				v.type = ComplexType.TPath({pack:[], name:'Dynamic'});
			}

#if passiveVars
			c.fields.push({
				pos: p,
				name: v.name,
				kind: FieldType.FVar(v.type, macro null),
				access: [Access.APublic],
			});
#else
			if (v.child == null) {
				var t = ComplexType.TPath({
					pack: ['reapp', 'core'],
					name: 'ReValue',
					params: [TypeParam.TPType(v.type)],
				});
				c.fields.push({
					pos: p,
					name: v.name,
					kind: FieldType.FProp('get', 'set', v.type),
					access: [Access.APublic],
//					meta: [{name:':isVar', pos:p}],
				});
				c.fields.push({
					pos: p,
					name: '__${v.name}',
					kind: FieldType.FVar(t, macro null),
					access: [Access.APublic],
				});
				c.fields.push({
					pos: p,
					name: 'get_${v.name}',
					kind: FieldType.FFun({
						args: [],
						ret: v.type,
						expr: untyped Context.parse('return __${v.name}.get()', p),
					}),
					access: [Access.APublic,
//					Access.AInline
					],
				});
				c.fields.push({
					pos: p,
					name: 'set_${v.name}',
					kind: FieldType.FFun({
						args: [{name:'v', type:v.type}],
						ret: v.type,
						expr: untyped Context.parse('return __${v.name}.set(v)', p),
					}),
					access: [Access.APublic,
//					Access.AInline
					],
				});
			} else {
				c.fields.push({
					pos: p,
					name: v.name,
					kind: FieldType.FVar(v.type, macro null),
					access: [Access.APublic],
				});
			}
#end

			if (v.expr != null && v.child == null) {
				var name = untyped Context.parse(v.name, v.expr.pos);
				var expr = v.expr;
#if passiveVars
				inits.push(macro $name = $expr);
#else
				inits.push(macro $name = $expr);
#end
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
