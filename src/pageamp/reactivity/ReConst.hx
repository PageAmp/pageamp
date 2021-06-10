package pageamp.reactivity;

class ReConst extends ReValue {

	public function new(scope:ReScope, k:String, v:Dynamic, ?handler:String,
						refreshable = false, handleFirst = true, parse = true) {
		super(scope, k, v, handler, refreshable, handleFirst, parse);
		unlink();
	}

	override public function set(v:Dynamic, push=false):Dynamic {
		return v;
	}

}
