package pageamp.reactivity;

import hscript.Expr;
import hscript.Interp;

// https://lib.haxe.org/p/hscript/
// https://github.com/HaxeFoundation/hscript
class ReInterp extends Interp {
    public static var ENABLE_UNKNOWN_VAR_EXCEPTION = false;

    // throws execution errors
    public function run(scope:ReScope, expr:Expr): Dynamic {
        var ret:Dynamic = null;
        var prev = variables;
        var error = null;
        variables = scope;
        try {
            ret = super.execute(expr);
        } catch (ex:Dynamic) {
            error = ex;
        }
        variables = prev;
        error != null ? throw error : null;
        return ret;
    }

    // =========================================================================
    // private
    // =========================================================================
    var scope: ReScope;

    override function execute(expr:Expr) return super.execute(expr);

    override function expr(expr:Expr) return super.expr(expr);

    override function get(o:Dynamic, f:String ): Dynamic {
        if (!ENABLE_UNKNOWN_VAR_EXCEPTION && o == null) return null;
        return Std.isOfType(o, ReScope) ? o.get(f) : super.get(o, f);
    }

    override function set(o:Dynamic, f:String, v:Dynamic): Dynamic {
        if (!ENABLE_UNKNOWN_VAR_EXCEPTION && o == null) return v;
        Std.isOfType(o, ReScope) ? o.set(f, v) : super.set(o, f, v);
        return v;
    }

}
