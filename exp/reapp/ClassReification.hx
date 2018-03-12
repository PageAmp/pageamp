package reapp;

import reapp.macro.REAPP;

class ClassReification {

	public static function main() {
		var n = REAPP.NODE({
			var x = 'foo';
			var child = NODE({
				var y = 'bar';
			});
		});
		trace(n.child.y);
	}

}
