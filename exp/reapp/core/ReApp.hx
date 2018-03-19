package reapp.core;

class ReApp extends ReNode {
	public var ctx: ReContext;

	public function new() {
		ctx = new ReContext();
		super();
	}

}