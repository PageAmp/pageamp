package ub1;

class Const {
    public static inline var FRAMEWORK_NAME = 'pageamp';

    // https://code.haxe.org/category/macros/get-compiler-define-value.html
    static macro function getDefine(key : String): haxe.macro.Expr {
        return macro $v{haxe.macro.Context.definedValue(key)};
    }

}
