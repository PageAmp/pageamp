package ub1;

class Const {
    static inline var DEFAULT_FRAMEWORK_NAME = '__ub1';

    public static function getFrameworkName() {
        var name = getDefine('frameworkName');
        return (name != null ? name : DEFAULT_FRAMEWORK_NAME);
    }

    // https://code.haxe.org/category/macros/get-compiler-define-value.html
    static macro function getDefine(key : String): haxe.macro.Expr {
        return macro $v{haxe.macro.Context.definedValue(key)};
    }

}
