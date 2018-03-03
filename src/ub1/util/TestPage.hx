/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
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

package ub1.util;

import haxe.Timer;
import js.Browser;
import js.html.Element;
import js.html.Event;
import js.html.LIElement;
import js.html.UListElement;

class TestPage {

	public static function main() {
		var timer = new Timer(100);
		timer.run = function() {
			if (Browser.document.getElementsByTagName('LI').length > 0) {
				Timer.delay(apply, 100);
				timer.stop();
			}
		}
	}

	static function apply() {
		var items = Browser.document.getElementsByTagName('UL');
		items.length > 0 ? items.item(0).style.display = 'block' : null;
		var items = Browser.document.getElementsByTagName('LI');
		for (i in 0...items.length) {
			var item:LIElement = cast items.item(i);
			var sibling = item.nextElementSibling;
			if (Std.is(sibling, UListElement)) {
				if (i < 1 || hasElementClass('error', item)) {
					item.style.listStyleType = 'circle';
					sibling.style.display = 'block';
				} else {
					item.style.listStyleType = 'disc';
					sibling.style.display = 'none';
				}
			} else {
				item.style.listStyleType = 'circle';
			}
			if (i < 1) {
				item.style.listStyleType = 'none';
			} else {
				item.addEventListener('click', itemClickListener);
			}
		}
	}

	static function itemClickListener(ev:Event) {
		var li:Element = cast ev.target;
		var ul:Element = li.nextElementSibling;
		if (Std.is(ul, UListElement)) {
			if (ul.style.display == 'none') {
				li.style.listStyleType = 'circle';
				ul.style.display = 'block';
			} else {
				li.style.listStyleType = 'disc';
				ul.style.display = 'none';
			}
		}
	}

	static function hasElementClass(klass:String, e:Element): Bool {
		var val = e.getAttribute('class');
		val = (val != null ? val : '');
		var parts = val.split(' ');
		for (part in parts) {
			if (part == klass) {
				return true;
			}
		}
		return false;
	}

}
