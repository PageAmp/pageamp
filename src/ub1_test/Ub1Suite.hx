package ub1_test;

import ub1_test.data.DataPathTest;
import ub1.util.Test;

class Ub1Suite extends TestRoot {

	static public function main() {
		new Ub1Suite(function(p:Test) {
			new Core(p, function(p:Test) {
				new DataPathTest(p);
			});
		}, null, 'http://localhost/__ubr_test/php/index.php?rpc=');
	}

}

class Core extends Test {}
