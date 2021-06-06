package ub1.server;

import ub1.server.dom.HtmlText;
import ub1.server.dom.HtmlComment;
import ub1.server.dom.HtmlAttribute;
import ub1.server.dom.HtmlDocument;
import ub1.server.dom.HtmlElement;
import haxe.Exception;

using ub1.lib.PropertyTools;

class HtmlParser {
	static var SKIP_CONTENT_TAGS = {SCRIPT:true, STYLE:true};
	public var origins: Array<String>;
	
	public static function parse(s:String): HtmlDocument {
		return new HtmlParser().parseDoc(s);
	}

	public function new() {
		origins = [];
	}

	public function parseDoc(s:String, ?fname:String): HtmlDocument {
		fname == null ? fname = 'literal' : null;
		var origin = origins.length;
		origins.push(fname);
		var ret = new HtmlDocument(origin);
		var i = parseNodes(ret, s, 0, origin);
		if (i < s.length) {
			new HtmlText(ret, s.substr(i), i, s.length, origin);
		}
		return ret;
	}

	function parseNodes(p:HtmlElement, s:String, i1:Int, origin:Int) {
		var i2, closure, i3 = i1, i4, closetag = null;
		while ((i2 = s.indexOf('<', i1)) >= 0) {
			i4 = i2;
			i1 = i2 + 1;
			(closure = s.charCodeAt(i1) == '/'.code) ? i1++ : null;
			if ((i2 = skipName(s, i1)) > i1) {
				if (i4 > i3) {
					new HtmlText(p, s.substring(i3, i4), i3, i4, origin, false);
				}
				if (closure) {
					var name = s.substring(i1, i2).toUpperCase();
					if (s.charCodeAt(i2) == '>'.code) {
						if (name == p.name) {
							i1 = i2 + 1;
							closetag = name;
							break;
						} else {
							throw new HtmlException(
								'Found </$name> instead of </${p.name}>',
								origins[origin], i1, s
							);
						}
					} else {
						throw new HtmlException(
							'Unterminated close tag ' + name,
							origins[origin], i1, s
						);
					}
					i1 = i2;
				} else {
					i1 = parseElement(p, s, i1, i2, origin);
				}
				i3 = i1;
			} else if (!closure && (i2 = skipComment(s, i1, origin)) > i1) {
				if (i4 > i3) {
					new HtmlText(p, s.substring(i3, i4), i3, i4, origin, false);
				}
				if (s.charCodeAt(i1 + 3) != '-'.code) {
					// if it doesn't start with `<!---`, store the comment
					new HtmlComment(p, s.substring(i1 - 1, i2), i1 - 1, i2, origin);
				}
				i3 = i1 = i2;
			}
		}
		if (closetag != p.name) {
			throw new HtmlException('expected </${p.name}>', origins[origin], i1, s);
		}
		return i1;
	}

	function parseElement(p:HtmlElement, s:String, i1:Int, i2:Int, origin:Int): Int {
		var e = new HtmlElement(p, s.substring(i1, i2), i1, i2, origin);
		i1 = parseAttributes(e, s, i2, origin);
		i1 = skipBlanks(s, i1);
		var selfclose = false;
		if ((selfclose = (s.charCodeAt(i1) == '/'.code))) {
			i1++;
		}
		if (s.charCodeAt(i1) != '>'.code) {
			throw new HtmlException(
				'Unterminated tag ${e.name}',
				origins[origin], i1, s
			);
		}
		i1++;
		if (!selfclose && !HtmlElement.VOID_ELEMENTS.exists(e.name)) {
			if (SKIP_CONTENT_TAGS.exists(e.name)) {
				var res = skipContent(e.name, s, i1, origin);
				if (res == null) {
					throw new HtmlException(
						'Unterminated tag ${e.name}',
						origins[origin], i1, s
					);
				}
				new HtmlText(e, s.substring(i1, res.i0), i1, res.i0, origin, false);
				i1 = res.i2;
			} else {
				i1 = parseNodes(e, s, i1, origin);
			}
		}
		return i1;
	}

	function parseAttributes(e:HtmlElement, s:String, i2:Int, origin:Int) {
		var i1 = skipBlanks(s, i2);
		while ((i2 = skipName(s, i1)) > i1) {
			var name = s.substring(i1, i2);
			var a = e.setAttribute(name, '', null, i1, i2, origin);
			i1 = skipBlanks(s, i2);
			if (s.charCodeAt(i1) == '='.code) {
				i1 = skipBlanks(s, i1 + 1);
				var quote = s.charCodeAt(i1);
				if (quote == '"'.code || quote == "'".code) {
					i1 = parseValue(a, s, i1 + 1, quote, String.fromCharCode(quote), origin);
			#if (HTML_EXTENSIONS)
				} else if (quote == '['.code && s.charCodeAt(i1 + 1) == '['.code) {
					i1 = parseValue(a, s, i1 + 2, quote, ']]', origin);
			#end
				} else {
					throw new HtmlException(
						'Missing attribute value', origins[origin], i1, s
					);
				}
			}
			i1 = skipBlanks(s, i1);
		};
		return i1;
	}

	function parseValue(a:HtmlAttribute, s:String, i1:Int,
						quote:Int, term:String, origin:Int) {
		var i2 = s.indexOf(term, i1);
		if (i2 < 0) {
			throw new HtmlException(
				'Unterminated attribute value',
				origins[origin], i1, s
			);
		} else {
			a.quote = String.fromCharCode(quote);
			var i = i2 + term.length;
			while (i < s.length && s.charCodeAt(i) == term.charCodeAt(0)) {
				i2++; i++;
			}
			a.value = s.substring(i1, i2);
			i1 = i2 + term.length;
		}
		return i1;
	}

	function skipComment(s:String, i1:Int, origin:Int) {
		if (s.charCodeAt(i1) == '!'.code
			&& s.charCodeAt(i1 + 1) == '-'.code
			&& s.charCodeAt(i1 + 2) == '-'.code) {
			if ((i1 = s.indexOf('-->', i1 + 3)) < 0) {
				throw new HtmlException(
					'Unterminated comment',
					origins[origin], i1, s
				);
			}
			i1 += 3;
		}
		return i1;
	}

	function skipContent(tag:String, s:String, i1:Int, origin:Int) {
		var i2;
		while ((i2 = s.indexOf('</', i1)) >= 0) {
			var i0 = i2;
			i1 = i2 + 2;
			i2 = skipName(s, i1);
			if (i2 > i1) {
				if (s.substring(i1, i2).toUpperCase() == tag) {
					i2 = skipBlanks(s, i2);
					if (s.charCodeAt(i2) != '>'.code) {
						throw new HtmlException(
							'Unterminated close tag',
							origins[origin], i1, s
						);
					}
					i2++;
					// break;
					return {i0: i0, i2: i2};
				}
			}
			i1 = i2;
		}
		return null;
	}

	function skipBlanks(s:String, i:Int) {
		while (i < s.length) {
			if (s.charCodeAt(i) > 32) {
				break;
			}
			i++;
		}
		return i;
	}

	function skipName(s:String, i:Int) {
		while (i < s.length) {
			var code = s.charCodeAt(i);
			if ((code < 'a'.code || code > 'z'.code) &&
				(code < 'A'.code || code > 'Z'.code) &&
				(code < '0'.code || code > '9'.code) &&
				code != '-'.code && code != '_'.code && code != ':'.code) {
				break;
			}
			i++;
		}
		return i;
	}

}

class HtmlException extends Exception {
	public var msg: String;
	public var fname: String;
	public var row: Int;
	public var col: Int;

	public function new(msg:String, fname:String, pos:Int, s:String) {
		super(msg);
		this.msg = msg;
		this.fname = fname;
		row = col = 1;
		var i = 0, j;
		while ((j = s.indexOf('\n', i)) >= 0 && (j <= pos)) {
			i = j + 1;
			row++;
		}
		col += (pos - cast Math.max(0, i));
	}

	override public function toString() {
		return '$fname:$row col $col: $msg';
	}

}
