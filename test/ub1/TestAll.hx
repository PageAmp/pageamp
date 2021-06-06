package ub1;

import ub1.core.*;
import ub1.reactivity.*;
import ub1.roundtrip.*;
import ub1.server.*;

// https://lib.haxe.org/p/utest/
class TestAll {

	public static function main() {
		utest.UTest.run([
			// reactivity
			new ReInterpTest(),
			new ReParserTest(),
			new ReScopeTest(),
			new ReValueTest(),
			// core
			new ElementTest(),
			// server
			new HtmlParserTest(),
			new ServerLoaderTest(),
			new PreprocessorTest(),
			// roundtrip
			new PlaygroundTest(),
		]);
	}

}
