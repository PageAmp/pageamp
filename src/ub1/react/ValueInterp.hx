/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.react;

import ub1.Ub1Log;
import hscript.Expr;
import hscript.Interp;
import ub1.react.Value;

using ub1.util.ArrayTool;
using ub1.util.MapTool;

class ValueInterp extends Interp {
    public var mainScope: ValueScope;
    
	public function new(mainScope:ValueScope) {
		super();
		this.mainScope = mainScope;
		variables.set('string', function(v:Dynamic): String {
			return v != null ? Std.string(v) : '';
		});
		variables.set('trim', function(v:Dynamic): String {
			return v != null ? StringTools.trim(Std.string(v)) : '';
		});
		variables.set('orNull', function(v:String): String {
			return v == null || v.length <1 ? null : v;
		});
		variables.set('trimOrNull', function(v:Dynamic): String {
		    var s = (v != null ? StringTools.trim(Std.string(v)) : null);
			return s == null || s.length <1 ? null : s;
		});
		variables.set('num', function(v:Dynamic): Float {
			return v != null ? v - 0 : 0;
		});
		variables.set('upperCase', function(v:Dynamic): String {
			return v != null ? '$v'.toUpperCase() : '';
		});
		variables.set('lowerCase', function(v:Dynamic): String {
			return v != null ? '$v'.toLowerCase() : '';
		});
		variables.set('capitalize', function(s:String): String {
			s == null ? s = '' : s;
			return ~/((^\w)|(\s+\w))/g.map(s, function(re:EReg): String {
				return re.matched(1).toUpperCase();
			});
		});
		variables.set('regex', function(v:Dynamic, opt=''): EReg {
			return v != null ? new EReg(Std.string(v), opt) : null;
		});
		variables.set('stringSort', ub1.util.ArrayTool.stringSort);
		variables.set('Math', Math);
		variables.set('String', String);
		variables.mapCopy(resetVars);
	}

	public function reset() {
		mainScope.reset();
		variables = new Map<String,Dynamic>();
		resetVars.mapCopy(variables);
		currentScope = null;
	}

	public inline function evaluate(exp:Expr, scope:ValueScope): Dynamic {
		var ret = null;
		var old = currentScope;
		currentScope = scope;
		try {
			ret = execute(exp);
		} catch (ex:Dynamic) {
			currentScope = old;
			throw ex;
		}
		currentScope = old;
		return ret;
	}

	public inline function evaluateWith(exp:Expr,
	                                    scope:ValueScope,
	                                    locals:Map<String,Dynamic>): Dynamic {
		var ret = null;
		var old = currentScope;
		currentScope = scope;
		try {
			ret = executeWith(exp, locals);
		} catch (ex:Dynamic) {
			currentScope = old;
			throw ex;
		}
		currentScope = old;
		return ret;
	}

	public inline function executeWith(expr:Expr,
	                                   locals:Map<String,Dynamic>): Dynamic {
		depth = 0;
		this.locals = untyped locals;
		declared = new Array();
		return exprReturn(expr);
	}

	// =========================================================================
	// private
	// =========================================================================
	var resetVars = new Map<String,Dynamic>();
	var currentScope: ValueScope;

	override function assign(e1:Expr, e2:Expr): Dynamic {
		var v = expr(e2);
		switch (edef(e1)) {
		case EIdent(id):
		    _resolveWrite(id, v);
		case EField(e,f):
			v = set(expr(e), f, v);
		case EArray(e,index):
			expr(e)[expr(index)] = v;
		default:
			error(EInvalidOp("="));
		}
		return v;
	}
    
	override function increment( e : Expr, prefix : Bool, delta : Int ) : Dynamic {
		#if hscriptPos
		curExpr = e;
		var e = e.e;
		#end
		switch(e) {
		case EIdent(id):
// 			var l = locals.get(id);
// 			var v : Dynamic = (l == null) ? variables.get(id) : l.r;
// 			if( prefix ) {
// 				v += delta;
// 				if( l == null ) variables.set(id,v) else l.r = v;
// 			} else
// 				if( l == null ) variables.set(id,v + delta) else l.r = v + delta;
// 			return v;
			var v = resolve(id);
			//TODO: test preincrement/postincrement
			var ret = (prefix ? (v + delta) : v);
			_resolveWrite(id, v + delta);
			return v;
		case EField(e,f):
			var obj = expr(e);
			var v : Dynamic = get(obj,f);
			if( prefix ) {
				v += delta;
				set(obj,f,v);
			} else
				set(obj,f,v + delta);
			return v;
		case EArray(e,index):
			var arr = expr(e);
			var index = expr(index);
			var v = arr[index];
			if( prefix ) {
				v += delta;
				arr[index] = v;
			} else
				arr[index] = v + delta;
			return v;
		default:
			return error(EInvalidOp((delta > 0)?"++":"--"));
		}
	}

	inline function _resolveWrite(id:String, v:Dynamic) {
		// local vars
		var l = locals.get(id);
		if (l != null) {
			l.r = v;
		} else {
			// scope values
			var done = false;
			var scope:ValueScope;
			if ((scope = currentScope) != null) {
				do {
					if (scope.values.exists(id)) {
						scope.set(id, v);
						done = true;
					}
				} while (!done && (scope = scope.parent) != null);
			}
			// global vars
			if (!done) {
				variables.set(id, v);
			}
		}
	}

	override function resolve(id:String): Dynamic {
		var ret = _resolveRead(id);
		if (Std.is(ret, Value)) {
			var locals = this.locals;
			ret = cast(ret, Value).get();
			this.locals = locals;
		}
		Ub1Log.valueInterp('resolve($id): $ret');
		return ret;
	}

	function _resolveRead(id:String): Dynamic {
		var scope:ValueScope;

		// local vars
		if (locals.exists(id)) {
//			return locals.get(id); //.r;
			var v = locals.get(id);
			v != null && v.r != null ? v = v.r : null;
			return v;
		}

		// scope values
		if ((scope = currentScope) != null) {
			do {
				if (scope.values.exists(id)) {
					return untyped scope.values.get(id);
				}
			} while ((scope = scope.parent) != null);
		}

		// global vars
		if (variables.exists(id)) {
			return variables.get(id);
		}

//		error(EUnknownVariable(id));
//		// unreachable since error() throws an exception
		return null;
	}

	override function get(o:Dynamic, f:String): Dynamic {
		var ret:Dynamic = null;
		if (Std.is(o,ValueScope) && untyped o.values.exists(f)) {
			ret = untyped o.values.get(f).get();
		} else {
			ret = super.get(o, f);
		}
		Ub1Log.valueInterp('get($f): $ret');
		return ret;
	}

	override function set(o:Dynamic, f:String, v:Dynamic): Dynamic {
		Ub1Log.valueInterp('set($f): $v');
		if (Std.is(o, ValueScope)) {
			untyped o.set(f, v);
			return v;
		}
		return super.set(o, f, v);
	}

}
