package reapp1;

// https://github.com/andyli/hxAnonCls
@:build(hxAnonCls.Macros.build())
class ReApp2 {

	public static function main() new ReApp2();

	function new() {
		var app = (new Dummy():{
			var s = 'foo';
			public var child = (new Dummy():{
				public var print = function() {
					trace(s);
				}
			});
		});
		app.child.print();
	}

}

class Dummy {}