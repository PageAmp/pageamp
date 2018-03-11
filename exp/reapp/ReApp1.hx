package reapp;

import ub1.util.PropertyTool;
using ub1.util.PropertyTool;

// https://github.com/andyli/hxAnonCls
//@:build(hxAnonCls.Macros.build())
class ReApp1 {

	public static function main() {
		new ReApp1();
	}

	function new() {
		var print: Dynamic;
		var app = new Node(null, function(p:Node) {
			var s = 'cips';
			new Node(p, function(p:Node) {
				print = function() {
					trace(s);
				}
			});
		});
		print();
	}

}

class Node {
	var parent: Node;

	public function new(p:Node, cb:Dynamic->Void) {
		this.parent = p;
		cb(this);
	}

}