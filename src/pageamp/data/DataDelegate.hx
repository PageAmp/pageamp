package pageamp.data;

interface DataDelegate {

	public function dataAdd(node:Xml,
	                        parent:Xml,
	                        ?before:Xml,
	                        ?userData:Dynamic): Void;

	public function dataRemove(node:Xml,
	                           ?userData:Dynamic): Void;

	public function dataMove(node:Xml,
	                         parent:Xml,
	                         ?before:Xml,
	                         ?userData:Dynamic): Void;

	public function dataAssign(element:Xml,
	                           key:String,
	                           val:Null<String>,
	                           ?userData:Dynamic): Void;

	public function dataTrigger(): Void;

}
