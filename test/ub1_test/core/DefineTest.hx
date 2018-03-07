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

package ub1_test.core;

import ub1.core.*;
import ub1.util.Test;
import ub1.web.DomTools;
using ub1.web.DomTools;
using StringTools;

class DefineTest extends Test {

	function testDefine1() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {n_def:'foo', n_ext:'span'}, function(p:Define) {
					new Element(p, {n_tag:'b', innerText:"title: ${title}"});
					new Element(p, {n_tag:'i', innerText:"text: ${text}"});
				});
				e = new Element(p, {n_tag:'foo'});
			});
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: </b><i>text: </i></span>'
			+ '</body></html>');
			e.set('title', 'Z');
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: </b><i>text: </i></span>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

	function testDefine2() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {n_def:'foo', n_ext:'span'}, function(p:Define) {
					new Element(p, {n_tag:'b', innerText:"title: ${title}"});
					new Element(p, {n_tag:'i', innerText:"text: ${text}"});
				});
				e = new Element(p, {n_tag:'foo', title:'X', text:'Y'});
			});
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: X</b><i>text: Y</i></span>'
			+ '</body></html>');
			e.set('title', 'Z');
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: Z</b><i>text: Y</i></span>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

	function testDefine3() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {
					n_def: 'foo',
					n_ext: 'span',
					title: 'A',
					text: 'B',
				}, function(p:Define) {
					new Element(p, {n_tag:'b', innerText:"title: ${title}"});
					new Element(p, {n_tag:'i', innerText:"text: ${text}"});
				});
				e = new Element(p, {n_tag:'foo'});
			});
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: A</b><i>text: B</i></span>'
			+ '</body></html>');
			e.set('title', 'Z');
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: Z</b><i>text: B</i></span>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

	function testDefine4() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {
					n_def: 'foo',
					n_ext: 'span',
					title: 'A',
					text: 'B',
				}, function(p:Define) {
					new Element(p, {n_tag:'b', innerText:"title: ${title}"});
					new Element(p, {n_tag:'i', innerText:"text: ${text}"});
				});
				e = new Element(p, {n_tag:'foo', title:'X', text:'Y'});
			});
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: X</b><i>text: Y</i></span>'
			+ '</body></html>');
			e.set('title', 'Z');
			assert(doc.domToString(), '<html>'
			+ '<head></head><body>'
			+ '<span><b>title: Z</b><i>text: Y</i></span>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

	function testSlot1() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {n_def:'item', n_ext:'li'}, function(p:Define) {
					new Element(p, {n_tag:'span', n_slot:'title'});
				});
				e = new Element(p, {n_tag:'item'}, function(p:Element) {
					new Element(p, {n_tag:'i', n_plug:'title', innerText:'x'});
				});
			});
			assert(doc.domToString(), '<html><head></head><body>'
			+ '<li><span><i>x</i></span></li>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

	function testSlot2() {
		willDelay();
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var e:Element = null;
			var page = new Page(doc, null, function(p:Page) {
				new Define(p, {n_def:'item', n_ext:'li'}, function(p:Define) {
					new Element(p, {n_tag:'span', n_slot:'title'});
				});
				new Define(p, {n_def:'bold', n_ext:'item'}, function(p:Define) {
					new Element(p, {n_tag:'b', n_plug:'title', n_slot:'title'});
				});
				e = new Element(p, {n_tag:'bold'}, function(p:Element) {
					new Element(p, {n_tag:'i', n_plug:'title', innerText:'x'});
				});
			});
			assert(doc.domToString(), '<html><head></head><body>'
			+ '<li><span><b><i>x</i></b></span></li>'
			+ '</body></html>');
			cleanup();
			didDelay();
		});
	}

}
