package pageamp.server;

import haxe.io.Path;
import pageamp.lib.Set;
import pageamp.server.HtmlParser.HtmlException;
import pageamp.server.dom.HtmlDocument;
import pageamp.server.dom.HtmlElement;
import pageamp.server.dom.HtmlNode;
import sys.io.File;

using StringTools;
using pageamp.lib.DomTools;

typedef Definition = {
	name1: String,
	name2: String,
	e: HtmlElement,
	ext: Definition,
}

class Preprocessor {
	var rootPath: String;
	var parser: HtmlParser;
	var sources: Array<String>;
	var macros: Map<String, Definition>;

	public function new(rootPath:String) {
		this.rootPath = Path.addTrailingSlash(Path.normalize(rootPath));
		parser = new HtmlParser();
		sources = [];
		macros = new Map();
	}

	public function read(fname:String): HtmlDocument {
		var ret = readFile(fname);
		processMacros(ret);
		return ret;
	}

	// ===================================================================================
	// includes
	// ===================================================================================
	public static inline var INCLUDE_TAG = ':INCLUDE';
	public static inline var IMPORT_TAG = ':IMPORT';
	public static inline var INCLUDE_ARG = 'src';

	function readFile(fname:String, ?currPath:String, once=false): HtmlDocument {
		var ret = null;
		fname.startsWith('/') ? currPath = null : null;
		currPath == null ? currPath = rootPath : null;
		var filePath = Path.normalize(Path.join([currPath, fname]));
		currPath = Path.directory(filePath);
		if (!filePath.startsWith(rootPath)) {
			throw new PreprocessorError('Forbidden file path "$fname"');
		}
		if (once && parser.origins.indexOf(filePath) >= 0) {
			return null;
		}
		var html;
		try {
			html = File.getContent(filePath);
		} catch (ex:Dynamic) {
			throw new PreprocessorError('Could not read file $fname');
		}
		try {
			sources.push(html);
			ret = parser.parseDoc(html, filePath);
			processIncludes(ret, currPath);
		} catch (ex:HtmlException) {
			throw new PreprocessorError(ex.msg, ex.fname, rootPath, ex.row, ex.col);
		} catch (ex:Dynamic) {
			throw new PreprocessorError('' + ex);
		}
		return ret;
	}

	function processIncludes(doc:HtmlDocument, currPath:String) {
		var tags = new Set<String>();
		tags.add(INCLUDE_TAG);
		tags.add(IMPORT_TAG);
		var includes = lookupTags(doc, tags);
		for (e in includes) {
			processInclude(e, e.domGet(INCLUDE_ARG), e.name == IMPORT_TAG, currPath);
		}
	}

	function processInclude(e:HtmlElement, src:String, once:Bool, currPath:String) {
		if (src == null || (src = src.trim()).length == 0) {
			throw new HtmlException(
				'Missing "src" attribute', parser.origins[e.origin],
				e.i1, sources[e.origin]
			);
		}
		var parent = e.domParent();
		var before = e.domNextSibling();
		e.remove();
		var doc = readFile(src, currPath, once);
		if (doc != null) {
			var root = doc.domGetRootElement();
			for (n in root.children.copy()) {
				parent.domAddChild(n.remove(), before);
			}
			// cascade root attributes
			for (k in root.attributes.keys()) {
				if (k.startsWith(ServerLoader.LOGIC_ATTR_PREFIX)
						&& !parent.attributes.exists(k)) {
					parent.attributes.set(k, root.attributes.get(k));
				}
			}
		}
	}

	// ===================================================================================
	// macros
	// ===================================================================================
	public static inline var DEFINE_TAG = ':DEFINE';
	public static inline var DEFINE_ARG = 'tag';
	public static inline var SLOT_TAG = ':SLOT';
	public static inline var SLOT_ARG = 'name';
	public static inline var SLOT_ATTR = ':slot';

	function processMacros(doc:HtmlDocument) {
		collectMacros(doc);
		expandMacros(doc);
	}

	// -----------------------------------------------------------------------------------
	// collect
	// -----------------------------------------------------------------------------------

	function collectMacros(p:HtmlElement) {
		var tags = new Set<String>();
		tags.add(DEFINE_TAG);
		var macros = lookupTags(p, tags);
		for (e in macros) {
			collectMacro(e);
		}
	}

	function collectMacro(e:HtmlElement) {
		var tag = e.domGet(DEFINE_ARG);
		if (tag == null || (tag = tag.trim()).length == 0) {
			throw new HtmlException(
				parser.origins[e.origin], 'Missing "tag" attribute',
				e.i1, sources[e.origin]
			);
		}
		var names = tag.split(':');
		names.length < 2 ? names.push('div') : null;
		if (!~/^[_a-zA-Z0-9]+-[-:_a-zA-Z0-9]+$/.match(names[0])
			|| !~/^[-_a-zA-Z0-9]+$/.match(names[1])) {
			throw new HtmlException(
				parser.origins[e.origin], 'Bad "tag" attribute',
				e.i1, sources[e.origin]
			);
		}
		names[0] = names[0].toUpperCase();
		names[1] = names[1].toUpperCase();
		e.remove();
		e.domSet(DEFINE_ARG, null);
		expandMacros(e);
		macros.set(names[0], {
			name1:names[0],
			name2:names[1],
			e:e,
			ext:macros.get(names[1])
		});
	}

	function collectSlots(p:HtmlElement) {
		var ret = new Map<String, HtmlElement>();
		var tags = new Set<String>();
		tags.add(SLOT_TAG);
		var slots = lookupTags(p, tags);
		for (e in slots) {
			var name = e.domGet(SLOT_ARG);
			if (name == null
				|| (name = name.trim()).length < 1
				|| ret.exists(name)) {
				throw new HtmlException(
					parser.origins[e.origin], 'Bad "name" attribute',
					e.i1, sources[e.origin]
				);
			}
			ret.set(name, e);
		}
		if (!ret.exists('default')) {
			var e = new HtmlElement(p, SLOT_TAG, p.i1, p.i2, p.origin);
			e.domSet(SLOT_ARG, 'default');
			ret.set('default', e);
		}
		return ret;
	}

	// -----------------------------------------------------------------------------------
	// expand
	// -----------------------------------------------------------------------------------

	function expandMacros(p:HtmlElement) {
		var f = null;
		f = function(p:HtmlElement) {
			for (n in p.children.copy()) {
				if (n.type == HtmlNode.ELEMENT_NODE) {
					var name = cast(n, HtmlElement).name;
					var def = macros.get(name);
					if (def != null) {
						var e = expandMacro(cast n, def);
						p.addChild(e, n);
						n.remove();
					} else {
						expandMacros(cast n);
					}
				}
			}
		}
		f(p);
	}

	function expandMacro(use:HtmlElement, def:Definition): HtmlElement {
		var ret = null;
		if (def.ext != null) {
			ret = expandMacro(def.e, def.ext);
		} else {
			ret = new HtmlElement(null, def.name2, use.i1, use.i2, use.origin);
			for (a in def.e.attributes) {
				ret.setAttribute(a.name, a.value, a.quote, a.i1, a.i2, a.origin);
			}
			ret.domSetHtml(def.e.getInnerHTML());
		}
		populateMacro(use, ret);
		return ret;
	}

	function populateMacro(src:HtmlElement, dst:HtmlElement) {
		for (a in src.attributes) {
			dst.setAttribute(a.name, a.value, a.quote, a.i1, a.i2, a.origin);
		}
		var slots = collectSlots(dst);
		for (n in src.children.copy()) {
			var slotName = 'default', s;
			if (n.type == HtmlNode.ELEMENT_NODE
				&& (s = cast(n, HtmlElement).domGet(SLOT_ATTR)) != null) {
				slotName = s;
			}
			var slot = slots.get(slotName);
			if (slot == null) {
				var err = new HtmlException(
					parser.origins[n.origin], null, n.i1, sources[n.origin]
				);
				throw new PreprocessorError(
					'unknown slot "$slotName"', err.fname, rootPath, err.row, err.col
				);
			}
			slot.parent.addChild(n, slot);
		}
		for (name in slots.keys()) {
			slots.get(name).remove();
		}
	}

	// ===================================================================================
	// util
	// ===================================================================================

	function lookupTags(p:HtmlElement, tags:Set<String>): Array<HtmlElement> {
		var ret = new Array<HtmlElement>();
		var f = null;
		f = function(p:HtmlElement) {
			for (n in p.children) {
				if (n.type == HtmlNode.ELEMENT_NODE) {
					if (tags.exists(cast(n, HtmlElement).name)) {
						ret.push(cast n);
					} else {
						f(cast n);
					}
				}
			}
		}
		f(p);
		return ret;
	}

}

class PreprocessorError {
	public var msg: String;
	public var fname: String;
	public var row: Int;
	public var col: Int;

	public function new(msg:String, ?fname:String, ?rootPath:String, ?row:Int, ?col:Int) {
		this.msg = msg;
		this.fname = (rootPath != null && fname != null && fname.startsWith(rootPath)
			? fname.substr(rootPath.length)
			: fname);
		this.row = row;
		this.col = col;	
	}

	public function toString() {
		return fname != null ? '$fname:$row col $col: $msg' : msg;
	}
}
