package pageamp;

import pageamp.core.*;
import pageamp.reactivity.*;
import pageamp.roundtrip.*;
import pageamp.server.*;
import utest.Runner;
import utest.ui.Report;
import utest.ui.common.PackageResult;
import utest.ui.text.PlainTextReport;

// https://lib.haxe.org/p/utest/
class TestAll {

	static function addTests(runner:Runner) {
		// reactivity
		runner.addCase(new ReInterpTest());
		runner.addCase(new ReParserTest());
		runner.addCase(new ReScopeTest());
		runner.addCase(new ReValueTest());
		// core
		runner.addCase(new ElementTest());
		// server
		runner.addCase(new HtmlParserTest());
		runner.addCase(new ServerLoaderTest());
		runner.addCase(new PreprocessorTest());
		// roundtrip
		runner.addCase(new PlaygroundTest());
		// runner.addCase(new PagesTest());
	}

	public static function main() {
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}

	public static function test(?cb:PlainTextReport->Void): String {
		var runner = new Runner();
		addTests(runner);
		var report = new TestReport(runner, cb);
		runner.run();
		return report.getResults();
	}

}

class TestReport extends PlainTextReport {

	public function new(runner:Runner, ?outputHandler:PlainTextReport->Void) {
		super(runner, outputHandler);
		newline = '\n';
		indent = '\t';
	}

	override function complete(result:PackageResult) {
		this.result = result;
		if (handler != null) handler(this);
	}

}
