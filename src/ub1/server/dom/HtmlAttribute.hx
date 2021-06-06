package ub1.server.dom;

class HtmlAttribute {
	public var name: String;
	public var value: String;
	public var quote: String;
	public var i1: Int;
	public var i2: Int;
	public var origin: Int;

	public function new(name:String, value:String, quote:String, i1:Int, i2:Int, origin:Int) {
		this.name = name;
		this.value = value;
		this.quote = quote;
		this.i1 = i1;
		this.i2 = i2;
		this.origin = origin;
	}
	
}
