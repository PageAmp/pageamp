/*
 * Copyright (c) 2018-2020 Ubimate Technologies Ltd and PageAmp contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package pageamp_test.data;

import pageamp.data.DataPath;
import pageamp.data.DataProvider;
import pageamp.util.Observable;
import pageamp.util.Test;
import pageamp.util.Url;

//TODO: add test for '..' (parent operator)
class DataPathTest extends Test {
	var doc = Xml.parse('<root id="main">
		<item id="1">text 1</item>
		<item id="2">text 2</item>
		<item id="3">text 3</item>
		<list>
			<item id="1">list text 1</item>
			<item id="2">list text 2</item>
			<item id="3">list text 3</item>
		</list>
	</root>');

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

	public function testCountAllItems() {
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

	public function testAttributeCompare() {
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

	public function testAttributeNotEqualString() {
		var xpath = new DataPath("root/item[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 2, 'wrong results count');
		assert(nodes[0].get('id'), '1');
		assert(nodes[1].get('id'), '3');
	}

	public function testAttributeNotEqualNumber() {
		var xpath = new DataPath("root/item[@id!=2]");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 2, 'wrong results count');
		assert(nodes[0].get('id'), '1');
		assert(nodes[1].get('id'), '3');
	}

	public function testAttributeEqualString() {
		var xpath = new DataPath("root/item[@id='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 1, 'wrong results count');
		assert(nodes[0].get('id'), '2');
	}

	public function testAttributeEqualNumber() {
		var xpath = new DataPath("root/item[@id=2]");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 1, 'wrong results count');
		assert(nodes[0].get('id'), '2');
	}

	public function testAttributeValues() {
		var xpath = new DataPath('root/item/@id');
		var values = xpath.selectValues(doc);
		assert(values.length, 3, 'wrong results count');
		assert(values[0], '1');
		assert(values[1], '2');
		assert(values[2], '3');
	}

	public function testTextValues() {
		var xpath = new DataPath('root/item/text()');
		var values = xpath.selectValues(doc);
		assert(values.length, 3, 'wrong results count');
		assert(values[0], 'text 1');
		assert(values[1], 'text 2');
		assert(values[2], 'text 3');
	}

	public function testTrailingSlash() {
		var node = doc.firstElement();
		var values = new DataPath('root/item/@id').selectValues(node);
		assert(values.length, 0, 'wrong results count');
		var values = new DataPath('/root/item/@id').selectValues(node);
		assert(values.length, 3, 'wrong results count');
	}

	public function testWildcard() {
		var xpath = new DataPath("root/*[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assert(nodes.length, 3, 'wrong results count');
	}

	public function testDoubleSlash1() {
		var nodes = new DataPath("//item[@id!='2']").selectNodes(doc);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function testDoubleSlash2() {
		var nodes = new DataPath("/root//item[@id!='2']").selectNodes(doc);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function testDoubleSlash3() {
		var xpath = new DataPath("/root");
		var node = xpath.selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 4, 'wrong results count');
	}

	public function testDoubleSlash4() {
		var node = new DataPath("//list").selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 2, 'wrong results count');
	}

	public function testDatasource1() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var nodes = new DataPath("source1:/dummy/item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assert(nodes.length, 3);
		assert(nodes.length, 3, 'wrong results count');
	}

	public function testDatasource2() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var nodes = new DataPath("source1://item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assert(nodes.length, 6);
		assert(nodes.length, 6, 'wrong results count');
	}

	public function testDatasource3() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new DummyDataSource());
		var node = new DataPath("source1://list", function(id:String) {
			return sources.get(id);
		}).selectNode(null);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assert(nodes.length, 2);
		assert(nodes.length, 2, 'wrong results count');
	}

	public function testNullXpathNullNode() {
		var node = new DataPath(null).selectNode(null);
		assert(node == null, true);
	}

	public function testNullXpathNonNullNode() {
		var node = new DataPath(null).selectNode(doc);
		assert(node == null, true);
	}

	public function testEmptyXpathNullNode() {
		var node = new DataPath('').selectNode(null);
		assert(node == null, true);
	}

	public function testEmptyXpathNonNullNode() {
		var node = new DataPath('').selectNode(doc);
		assert(node == doc, true);
	}

	public function testNonEmptyXpathNullNode1() {
		var node = new DataPath('*').selectNode(null);
		assert(node == null, true);
	}

	public function testNonEmptyXpathNullNode2() {
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
