package pageamp.core;

import utest.Assert;
import pageamp.server.ServerLoader;
import pageamp.server.HtmlParser;
import utest.Test;

using pageamp.lib.DomTools;

class DatasourceTest extends Test {
	
	function testDatasourceBecomesScriptTypeJson() {
		var doc = HtmlParser.parse('<html><body><:datasource/></body></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals(
			'<html data-id="0"><body data-id="1">'
			+ '<script data-id="2" type="application/json"></script>'
			+ '</body></html>',
			doc.toString());
	}

	function testStaticDatasourceOutput() {
		var doc = HtmlParser.parse('<html><head>'
			+ '<:datasource>['
			+ '	{"name":"Ann", "role":"Admin"},'
			+ '	{"name":"Joe", "role":"Account"}'
			+ ']</:datasource>'
			+ '</head></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals(
			'<html data-id="0"><head data-id="1">'
			+ '<script data-id="2" type="application/json">['
			+ '	{"name":"Ann", "role":"Admin"},'
			+ '	{"name":"Joe", "role":"Account"}'
			+']</script>'
			+ '</head></html>',
			doc.toString());
	}

	function testStaticDatasourceArray() {
		var doc = HtmlParser.parse('<html><body>'
			+ '<:datasource :name="people">['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']</:datasource>'
			+ '<div :data=[[people.data]]>[[data.employee_name]]: [[data.employee_age]]</div>'
			+ '</body></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals('<html data-id="0"><body data-id="1">'
			+ '<script data-id="2" type="application/json">['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']</script>'
			+ '<div data-clone="0" data-id="3">Tiger Nixon: 61</div>'
			+ '<div data-id="3">Garrett Winters: 63</div>'
			+ '</body></html>', doc.toString());
	}

	function testStaticDatasourceObject1() {
		var doc = HtmlParser.parse('<html><body>'
			+ '<:datasource :name="people">{"list":['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']}</:datasource>'
			+ '<div :data=[[people.data.list]]>[[data.employee_name]]: [[data.employee_age]]</div>'
			+ '</body></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals('<html data-id="0"><body data-id="1">'
			+ '<script data-id="2" type="application/json">{"list":['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']}</script>'
			+ '<div data-clone="0" data-id="3">Tiger Nixon: 61</div>'
			+ '<div data-id="3">Garrett Winters: 63</div>'
			+ '</body></html>', doc.toString());
	}

	function testStaticDatasourceObject2() {
		// identical to testStaticDatasourceObject2(), but JSON's array is in field "data"
		var doc = HtmlParser.parse('<html><body>'
			+ '<:datasource :name="people">{"data":['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']}</:datasource>'
			+ '<div :data=[[people.data.data]]>'
			+ '[[data.employee_name]]: [[data.employee_age]]'
			+ '</div>'
			+ '</body></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals('<html data-id="0"><body data-id="1">'
			+ '<script data-id="2" type="application/json">{"data":['
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}'
			+ ']}</script>'
			+ '<div data-clone="0" data-id="3">Tiger Nixon: 61</div>'
			+ '<div data-id="3">Garrett Winters: 63</div>'
			+ '</body></html>', doc.toString());
	}

	function testDynamicDatasourceRestGet() {
		var url = "https://ubimate.com/.test/people.json";
		var doc = HtmlParser.parse('<html><body>'
			+ '<:datasource :name="people" :url="$url" :dataLength=[[2]]/>'
			+ '<div :data=[[people.data.data]]>'
			+ '[[data.employee_name]]: [[data.employee_age]]</div>'
			+ '</body></html>');
		var page = ServerLoader.loadRoot(doc);
		page.pageRefresh(null);
		Assert.equals('<html data-id="0"><body data-id="1">'
			+ '<script data-id="2" type="application/json">{"data":[\n'
			+ '	{"employee_name":"Tiger Nixon", "employee_age":61},\n'
			+ '	{"employee_name":"Garrett Winters", "employee_age":63}\n'
			+ ']}</script>'
			+ '<div data-clone="0" data-id="3">Tiger Nixon: 61</div>'
			+ '<div data-id="3">Garrett Winters: 63</div>'
			+ '</body></html>', doc.toString());
	}

}
