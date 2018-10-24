/*
 * Copyright (c) 2018 Ubimate Technologies Ltd and Ub1 contributors.
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

#if server
	import htmlparser.*;
	typedef SrcDocument = HtmlDocument;
	typedef SrcElement = HtmlNodeElement;
	typedef SrcNode = HtmlNode;
#else
	import ub1.util.XmlTools;
	typedef SrcDocument = Xml;
	typedef SrcElement = Xml;
	typedef SrcNode = Xml;
#end

class SourceTools {

	public static inline function srcDocument(s:String): SrcDocument {
#if server
		return new HtmlDocument(s);
#else
		return Xml.parse(s);
#end
	}

	public static inline function srcString(doc:SrcDocument): String {
#if server
		return doc.toString();
#else
		return doc.toString();
#end
	}

	public static inline function srcRoot(doc:SrcDocument): SrcElement {
#if server
		return doc.children[0];
#else
		return XmlTools.root(doc);
#end
	}

	public static inline function srcName(e:SrcElement): String {
#if server
		return e.name;
#else
		return e.nodeName;
#end
	}

	public static inline function srcElements(e:SrcElement):
	Iterator<SrcElement> {
#if server
		return e.children.iterator();
#else
		return e.elements();
#end
	}

	public static inline function srcInnerHTML(e:SrcElement): String {
#if server
		return e.innerHTML;
#else
		var s = e.toString();
		s = new EReg('^<${e.nodeName}.*?>', '').replace(s, '');
		s = new EReg('</${e.nodeName}>$', '').replace(s, '');
		return s;
#end
	}

	public static inline function srcInnerText(e:SrcElement): String {
#if server
		return e.innerText;
#else
		return XmlTools.getElementText(e);
#end
	}

	public static inline function srcRemoveChild(e:SrcElement, n:SrcNode) {
#if server
		e.removeChild(n);
#else
		e.removeChild(n);
#end
	}

}
