package pageamp.server.dom;

class HtmlDocument extends HtmlElement {

	public function new(origin:Int) {
		super(null, null, 0, 0, origin);
	}

	override public inline function toString() {
		return getInnerHTML();
	}

}
