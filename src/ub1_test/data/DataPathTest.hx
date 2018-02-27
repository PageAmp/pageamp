package ub1_test.data;

import ub1.data.DataPath;
import ub1.data.DataProvider;
import ub1.util.Observable;
import ub1.util.Test;
import ub1.util.Url;

class DataPathTest extends Test {
	var doc: Xml;

	public function testCountLocalItems() {
		var str = '<root><item id="1"/><item id="2"/><item id="3"/></root>';
		var xml : Xml = Xml.parse(str).firstElement();
		var xpath = new DataPath('/root/item');
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assert(count, 3);
	}

	public function countAllItems() {
		var str = '<root><item id="1"/><item id="2"/><item id="3"/></root>';
		var xml : Xml = Xml.parse(str).firstElement();
		var xpath = new DataPath('//item');
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assert(count, 3);
	}

	public function attributeCompare() {
		var str = '<root><item id="1"/><item id="2"/><item id="21"/><item id="3"/></root>';
		var xml = Xml.parse(str).firstElement();
		var xpath = new DataPath("/root/item[@id<3]");
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assert(count, 2);
	}

	public function attributeNotEqualString() {
		var xpath = new DataPath("root/item[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 2, 'wrong results count');
		assert(nodes[0].get('id'), '1');
		assert(nodes[1].get('id'), '3');
	}

	public function attributeNotEqualNumber() {
		var xpath = new DataPath("root/item[@id!=2]");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 2, 'wrong results count');
		assert(nodes[0].get('id'), '1');
		assert(nodes[1].get('id'), '3');
	}

	public function attributeEqualString() {
		var xpath = new DataPath("root/item[@id='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 1, 'wrong results count');
		assert(nodes[0].get('id'), '2');
	}

	public function attributeEqualNumber() {
		var xpath = new DataPath("root/item[@id=2]");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 1, 'wrong results count');
		assert(nodes[0].get('id'), '2');
	}

	public function attributeValues() {
		var xpath = new DataPath('root/item/@id');
		var values = xpath.selectValues(doc);
		assert(values.length, 3, 'wrong results count');
		assert(values[0], '1');
		assert(values[1], '2');
		assert(values[2], '3');
	}

	public function textValues() {
		var xpath = new DataPath('root/item/text()');
		var values = xpath.selectValues(doc);
		assert(values.length, 3, 'wrong results count');
		assert(values[0], 'text 1');
		assert(values[1], 'text 2');
		assert(values[2], 'text 3');
	}

	public function trailingSlash() {
		var node = doc.firstElement();
		var values = new DataPath('root/item/@id').selectValues(node);
		assert(values.length, 0, 'wrong results count');
		var values = new DataPath('/root/item/@id').selectValues(node);
		assert(values.length, 3, 'wrong results count');
	}

	public function wildcard() {
		var xpath = new DataPath("root/*[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 3, 'wrong results count');
	}

	public function doubleSlash1() {
		var nodes = new DataPath("//item[@id!='2']").selectNodes(doc);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function doubleSlash2() {
		var nodes = new DataPath("/root//item[@id!='2']").selectNodes(doc);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function doubleSlash3() {
		var xpath = new DataPath("/root");
		var node = xpath.selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function doubleSlash4() {
		var node = new DataPath("//list").selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 2, 'wrong results count');
	}

	public function datasource1() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var nodes = new DataPath("source1:/dummy/item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assert(nodes.length, 3);
		assert(nodes.length, 3, 'wrong results count');
	}

	public function datasource2() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var nodes = new DataPath("source1://item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assert(nodes.length, 6);
		assert(nodes.length, 6, 'wrong results count');
	}

	public function datasource3() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var node = new DataPath("source1://list", function(id:String) {
			return sources.get(id);
		}).selectNode(null);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 2);
		assert(nodes.length, 2, 'wrong results count');
	}

	public function nullXpathNullNode() {
		var node = new DataPath(null).selectNode(null);
		assert(node == null, true);
	}

	public function nullXpathNonNullNode() {
		var node = new DataPath(null).selectNode(doc);
		assert(node == null, true);
	}

	public function emptyXpathNullNode() {
		var node = new DataPath('').selectNode(null);
		assert(node == null, true);
	}

	public function emptyXpathNonNullNode() {
		var node = new DataPath('').selectNode(doc);
		assert(node == doc, true);
	}

	public function nonEmptyXpathNullNode1() {
		var node = new DataPath('*').selectNode(null);
		assert(node == null, true);
	}

	public function nonEmptyXpathNullNode2() {
		var node = new DataPath('text()').selectValue(null);
		assert(node == null, true);
	}

}

class DummyDataSource extends Observable implements DataProvider {
	var xml:Xml;

	public function new() {
		super();
		xml = Xml.parse('<dummy>
			<item id="1">text 1</item>
			<item id="2">text 2</item>
			<item id="3">text 3</item>
			<list>
				<item id="1">list text 1</item>
				<item id="2">list text 2</item>
				<item id="3">list text 3</item>
			</list>
		</dummy>');
	}

	public function getData(?url:Url): Xml {
		return xml;
	}

	public function isRequesting(): Bool {
		return false;
	}

	public function abortRequest(): Void {}

}
