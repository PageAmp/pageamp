/*
 * Copyright (c) 2018-2019 Ubimate Technologies Ltd and Ub1 contributors.
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

package ub1_test.server;

import haxe.Http;
import ub1.util.Test;
import ub1_test.Ub1Suite.Server;
using StringTools;

class ServerTest2 extends Test {
	public static inline var BASEURL = Server.BASEURL + '2/';

	function test01() {
		var s = getPage('01_It-starts-with-HTML');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {
color: red;
font-family: sans-serif;
}
</style>
</head><body id="ub1_1">


A plain HTML page

</body></html>');
	}

	function test02() {
		var s = getPage('02_Includes');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">

<style>
body {
color: red;
font-family: sans-serif;
}
</style>

</head><body id="ub1_1">


A plain HTML page w/ include

</body></html>');
	}

	function test03() {
		var s = getPage('03_Styling');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style id="ub1_5">
body {
color: blue;
font-family: sans-serif;
}
</style>
</head><body id="ub1_8">
This text is blue
</body></html>');
	}

	function test04() {
		var s = getPage('04_Interaction');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style id="ub1_5">
body {
color: blue;
font-family: sans-serif;
user-select: none;
-moz-user-select: none;
-webkit-user-select: none;
-ms-user-select: none;
cursor: pointer;
}
</style>
</head><body id="ub1_8">
Click this blue text
</body></html>');
	}

	function test05() {
		var s = getPage('05_HTML-relaxation');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style id="ub1_5">
body {
color: blue;
font-family: sans-serif;
user-select: none;
-moz-user-select: none;
-webkit-user-select: none;
-ms-user-select: none;
cursor: pointer;
}
</style>
</head><body id="ub1_8">


Click this twice
<div style="width:100px;height:100px;background:blue" id="ub1_10"></div>

</body></html>');
	}

	function test06() {
		var s = getPage('06_Class-attributes');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
.list-item {
font-family: sans-serif;
color: blue;
cursor: pointer;
}
.list-item.selected {
font-weight: bold;
cursor: default;
}
</style>
</head><body id="ub1_1">


<ul>
<li class="list-item selected" id="ub1_13">First</li>
<li class="list-item" id="ub1_16">Second</li>
</ul>

</body></html>');
	}

	function test07() {
		var s = getPage('07_Style-attributes');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
.box {
width: 100px;
height: 100px;
background-color: blue;
margin-bottom: 10px;
cursor: pointer;
}
</style>
</head><body id="ub1_1">


<div class="box" style="background-color:red" id="ub1_11"></div>
<div class="box" id="ub1_13"></div>

</body></html>');
	}

	function test08() {
		var s = getPage('08_Animation');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
.box {
position: absolute;
width: 100px;
height: 100px;
background-color: blue;
margin-bottom: 10px;
cursor: pointer;
}
</style>
</head><body id="ub1_9">


<button id="ub1_11">
Animate
</button>
<div class="box" style="top:40px;left:0px" id="ub1_14"></div>
<div class="box" style="top:150px;left:0px" id="ub1_16"></div>

</body></html>');
	}

	function test09() {
		var s = getPage('09_Functions');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
.box {
position: absolute; box-sizing: border-box;
left: 25%; top: 25%; width: 50%; height: 50%;
background: #fff; border: 1px solid #aaa;
}
.sel {background: #eee}
</style>
</head><body id="ub1_1">


<div class="box" id="ub1_11">
<div class="box" id="ub1_13"></div>
</div>

</body></html>');
	}

	function test10() {
		var s = getPage('10_Handlers');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
body * {margin-bottom: 8px}
</style>
</head><body id="ub1_9">


<div id="ub1_11">-</div>
<div id="ub1_13">-</div>
<button id="ub1_15">
Click me
</button>

</body></html>');
	}

	function test11() {
		var s = getPage('11_Static-XML-data');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


<script type="text/xml" id="ub1_11">
<root phone="617-536-7855" name="John Smith"></root>
</script>
<span id="ub1_15">John Smith</span>
<span id="ub1_17">617-536-7855</span>

</body></html>');
	}

	function test12() {
		var s = getPage('12_Static-JSON-data');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


<script type="text/xml" id="ub1_11"><root name="John Smith" phone="617-536-7855"></root></script>
<span id="ub1_15">John Smith</span>
<span id="ub1_17">617-536-7855</span>

</body></html>');
	}

	function test13() {
		var s = getPage('13_Relative-data-paths');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_9">


<script type="text/xml" id="ub1_11"><root name="John Smith" phone="617-536-7855"></root></script>
<span id="ub1_15">John Smith</span>
<span id="ub1_17">617-536-7855</span>

</body></html>');
	}

	function test14() {
		var s = getPage('14_Replication');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


<script type="text/xml" id="ub1_11"><root><item name="John Smith" phone="617-536-7855"></item><item name="Dan Jackson" phone="636-517-5758"></item></root></script>
<table id="ub1_15">
<tr style="display:none" id="ub1_17">
<td id="ub1_19"></td>
<td id="ub1_21">&bull; tel: </td>
</tr>
<tr id="ub1_26">
<td id="ub1_28">John Smith</td>
<td id="ub1_30">&bull; tel: 617-536-7855</td>
</tr><tr id="ub1_32">
<td id="ub1_34">Dan Jackson</td>
<td id="ub1_36">&bull; tel: 636-517-5758</td>
</tr></table>

</body></html>');
	}

	function test15() {
		var s = getPage('15_External-data');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


<script type="text/xml" id="ub1_11"><root><item name="John Smith" phone="617-536-7855"></item><item name="Jack Brown" phone="536-617-5578"></item><item name="Dan Jackson" phone="636-517-5758"></item><item name="Dave Robin" phone="573-661-7558"></item></root></script>
<table id="ub1_13">
<tr style="display:none" id="ub1_15">
<td id="ub1_17"></td>
<td id="ub1_19">&bull; tel: </td>
</tr>
<tr id="ub1_24">
<td id="ub1_26">John Smith</td>
<td id="ub1_28">&bull; tel: 617-536-7855</td>
</tr><tr id="ub1_30">
<td id="ub1_32">Jack Brown</td>
<td id="ub1_34">&bull; tel: 536-617-5578</td>
</tr><tr id="ub1_36">
<td id="ub1_38">Dan Jackson</td>
<td id="ub1_40">&bull; tel: 636-517-5758</td>
</tr><tr id="ub1_42">
<td id="ub1_44">Dave Robin</td>
<td id="ub1_46">&bull; tel: 573-661-7558</td>
</tr></table>

</body></html>');
	}

	function test16() {
		var s = getPage('16_Local-services');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


<script type="text/xml" id="ub1_11"><root><item name="01_It-starts-with-HTML.html"></item><item name="02_Includes.html"></item><item name="03_Styling.html"></item><item name="04_Interaction.html"></item><item name="05_HTML-relaxation.html"></item><item name="06_Class-attributes.html"></item><item name="07_Style-attributes.html"></item><item name="08_Animation.html"></item><item name="09_Functions.html"></item><item name="10_Handlers.html"></item><item name="11_Static-XML-data.html"></item><item name="12_Static-JSON-data.html"></item><item name="13_Relative-data-paths.html"></item><item name="14_Replication.html"></item><item name="15_External-data.html"></item><item name="16_Local-services.html"></item><item name="17_Code-reuse-in-HTML.html"></item><item name="18_Custom-tags.html"></item><item name="19_HTML-components.html"></item><item name="20_HTML-libraries.html"></item></root></script>
<div style="display:none" id="ub1_13"></div>

<div id="ub1_16">01_It-starts-with-HTML.html</div><div id="ub1_17">02_Includes.html</div><div id="ub1_18">03_Styling.html</div><div id="ub1_19">04_Interaction.html</div><div id="ub1_20">05_HTML-relaxation.html</div><div id="ub1_21">06_Class-attributes.html</div><div id="ub1_22">07_Style-attributes.html</div><div id="ub1_23">08_Animation.html</div><div id="ub1_24">09_Functions.html</div><div id="ub1_25">10_Handlers.html</div><div id="ub1_26">11_Static-XML-data.html</div><div id="ub1_27">12_Static-JSON-data.html</div><div id="ub1_28">13_Relative-data-paths.html</div><div id="ub1_29">14_Replication.html</div><div id="ub1_30">15_External-data.html</div><div id="ub1_31">16_Local-services.html</div><div id="ub1_32">17_Code-reuse-in-HTML.html</div><div id="ub1_33">18_Custom-tags.html</div><div id="ub1_34">19_HTML-components.html</div><div id="ub1_35">20_HTML-libraries.html</div></body></html>');
	}

	function test17() {
		var s = getPage('17_Code-reuse-in-HTML');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
.product {
display: inline-block;
padding: 5px;
border: 1px solid #ddd;
margin: 3px;
}
</style>
</head><body id="ub1_1">


<div class="product">
<div><span>Name:</span> Thingy</div>
<div><span>Price:</span> 1€</div>
</div>
<div class="product">
<div><span>Name:</span> Widget</div>
<div><span>Price:</span> 2€</div>
</div>

</body></html>');
	}

	function test18() {
		var s = getPage('18_Custom-tags');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
.product {
display: inline-block;
padding: 5px;
border: 1px solid #ddd;
margin: 3px;
}
</style>
</head><body id="ub1_1">



<div class="product" id="ub1_24">
<div><span>Name:</span><b id="ub1_29"></b> Thingy</div>
<div><span>Price:</span><b id="ub1_35"></b> 1€</div>
</div>
<div class="product" id="ub1_39">
<div><span>Name:</span><b id="ub1_44"></b> Widget</div>
<div><span>Price:</span><b id="ub1_50"></b> 2€</div>
</div>

</body></html>');
	}

	function test19() {
		var s = getPage('19_HTML-components');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">



<div class="lib-product" id="ub1_27">
<style>
.lib-product {
display: inline-block;
padding: 5px;
border: 1px solid #ddd;
margin: 3px;
}
</style>
<div><span>Name:</span><b id="ub1_35"></b> Thingy</div>
<div><span>Price:</span><b id="ub1_41"></b> 1€</div>
</div>
<div class="lib-product" id="ub1_45">
<style>
.lib-product {
display: inline-block;
padding: 5px;
border: 1px solid #ddd;
margin: 3px;
}
</style>
<div><span>Name:</span><b id="ub1_53"></b> Widget</div>
<div><span>Price:</span><b id="ub1_59"></b> 2€</div>
</div>

</body></html>');
	}

	function test20() {
		var s = getPage('20_HTML-libraries');
		assert(s, '<!DOCTYPE html>
<html><head id="ub1_3">
<style>
body {font-family: sans-serif}
</style>
</head><body id="ub1_1">


Coming soon

</body></html>');
	}

	// =========================================================================
	// utilities
	// =========================================================================

	public static function getPage(name:String): String {
		var s = Http.requestUrl(BASEURL + name);
		s = ServerTest1.removeClient(s);
		return s;
	}

}
