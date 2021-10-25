package pageamp.core;

import pageamp.reactivity.ReConst;
import pageamp.lib.Util;
import pageamp.reactivity.ReParser;
import pageamp.reactivity.ReScope;
import pageamp.reactivity.ReValue;

using StringTools;
using pageamp.lib.DomTools;
using pageamp.lib.PropertyTools;

typedef ElementProps = {
	?dom: DomElement,
	?id: Int,
	?aka: String,
	?attr: Props,
	?values: Props,
	?texts: Array<ElementText>,
	?clone: CloneProps,
	// for client/server state transfer
	?_e: Element, ?_v: Props,
}

typedef ElementText = {
	index: Int,
	text: String,
}

typedef CloneProps = {
	source: Int,
	index: Int,
}

/**
 * Wraps a dynamic element in the DOM.
 */
class Element extends ReScope {
	public static inline var DOMATTR_PREFIX = 'a_';
	public static inline var CLASSATTR_PREFIX = 'class-';
	public static inline var CLASSATTR_PREFIXLEN = 6;
	public static inline var STYLEATTR_PREFIX = 'style-';
	public static inline var STYLEATTR_PREFIXLEN = 6;
	public static inline var EVENTATTR_PREFIX = 'event-';
	public static inline var EVENTATTR_PREFIXLEN = 6;
	public static inline var HANDLERATTR_PREFIX = 'on-';
	public static inline var HANDLERATTR_PREFIXLEN = 3;
	public static inline var ID_ATTR = 'data-id';
	public static inline var CLONE_ATTR = 'data-clone';
	public static inline var TEXT_PREFIX = '-tn';

	public var root(get,null): Page;
	public inline function get_root(): Page { return cast baseRoot; }
	public var parent(get,null): Element;
	public inline function get_parent(): Element { return cast baseParent; }
	public var id: Int;
	public var dom: DomElement;
	public var clone: CloneProps;
	
	public function new(parent:Element, props:ElementProps) {
		super(parent, (props.clone != null ? null : props.aka));
		this.id = props.id != null ? props.id : root.registerElement(props);
		this.dom = props.dom;
		props.set('dom', null);
		this.clone = props.clone;
		props.set('clone', null);
		for (k in props.attr.keys()) {
			var value = new ReValue(this, DOMATTR_PREFIX + k, props.attr.get(k));
			value.userData = k;
			value.callback = attrCallback;
		}
		for (k in props.values.keys()) {
			var v = props.values.get(k);
			if (k.startsWith(EVENTATTR_PREFIX)) {
				if (ReParser.isDynamic(v)) {
					addEventHandler(k, v);
				}
			} else if (k.startsWith(HANDLERATTR_PREFIX)) {
				if (ReParser.isDynamic(v)) {
					addValueHandler(k, v);
				}
			} else {
				var value = new ReValue(this, k, v);
				if (k.startsWith(CLASSATTR_PREFIX)) {
					// for class attributes with no value:
					v == '' ? value.setState(true) : null;
					value.userData = Util.makeHyphenName(k.substr(CLASSATTR_PREFIXLEN));
					value.callback = classCallback;
				} else if (k.startsWith(STYLEATTR_PREFIX)) {
					value.userData = Util.makeHyphenName(k.substr(STYLEATTR_PREFIXLEN));
					value.callback = styleCallback;
				}
			}
		}
		if (props.texts != null) {
			for (t in props.texts) {
				var value = new ReValue(this, TEXT_PREFIX + t.index, t.text);
				value.userData = dom.domGetNthChild(t.index);
				value.callback = textCallback;
			}
		}
		new ReConst(this, 'dom', dom);
		dom.domSet(ID_ATTR, '' + this.id);
		initData();
		props._e = this;
		if (props._v != null) {
			for (k in props._v.keys()) {
				var value = values.get(k);
				value != null ? value.setState(props._v.get(k)) : null;
			}
		}
	}

	// ===================================================================================
	// event handlers
	// ===================================================================================

	function addEventHandler(k:String, v:Dynamic) {
		var type = k.substr(EVENTATTR_PREFIXLEN);
		var value = new ReValue(this, k, null, v, false, false);
		dom.domAddEventHandler(type, (ev) -> {
			value.set(ev);
		});
	}

	// ===================================================================================
	// value handlers
	// ===================================================================================
	// build-in pseudo values you can listen to:
	static inline var IS_VISIBLE = 'isVisible';

	function addValueHandler(k:String, v:Dynamic) {
		var name = k.substr(HANDLERATTR_PREFIXLEN);
		new ReValue(this, null, '[[$name]]', v);
		var ref = name;
		switch (name) {
			case IS_VISIBLE:
				ref = IS_VISIBLE;
				if (!values.exists(ref)) {
					var value = new ReValue(this, ref, false);
#if client
					new js.html.IntersectionObserver((ee, _) -> {
						for (e in ee) {
							if (e.target == dom) {
								value.set((e.intersectionRatio > 0));
							}
						}
					}).observe(dom);
#end
				}
		}
		new ReValue(this, null, '[[$ref]]', v);
	}

	// ===================================================================================
	// value callbacks
	// ===================================================================================

	function attrCallback(v:Dynamic, k:String, attrName:String) {
		dom.domSet(attrName, v);
		return v;
	}

	function textCallback(v:Dynamic, k:String, n:DomTextNode) {
		n.domSetNodeText(v);
		return v;
	}

	function classCallback(v:Dynamic, k:String, className:String) {
#if client
		if (Util.isTrue(v)) {
			dom.classList.add(className);
		} else {
			dom.classList.remove(className);
		}
#else
		var s = dom.domGet('class');
		s == null ? s = '' : null;
		var classes = ~/\s+/g.split(s);
		var didChange = false;
		if (Util.isTrue(v)) {
			if (classes.indexOf(className) < 0) {
				classes.push(className);
				didChange = true;
			}
		} else {
			didChange = classes.remove(className);
		}
		if (didChange) {
			var v = classes.join(' ').trim();
			dom.domSet('class', v != '' ? v : null);
		}
#end
		return v;
	}

	function styleCallback(v:Dynamic, k:String, styleName:String) {
#if client
		if (Util.isTrue(v)) {
			dom.style.setProperty(styleName, '$v');
		} else {
			dom.style.removeProperty(styleName);
		}
#else
		var s = dom.domGet('style');
		s == null ? s = '' : null;
		var styles = ~/\s*;\s*/g.split(s);
		if (styles.length == 1 && styles[0] == '') {
			styles.pop();
		}
		var didChange = false;
		var ret = -1, i = 0;
		for (s in styles) {
			var p = ~/\s*:\s*/.split(s);
			if (p[0] == styleName) {
				ret = i;
				break;
			}
			i++;
		}
		if (ret < 0) {
			if (v != null) {
				styles.push(styleName + ':' + v);
				didChange = true;
			}
		} else {
			if (Util.isTrue(v)) {
				var s = styleName + ':' + v;
				if (styles[ret] != s) {
					styles[ret] = s;
					didChange = true;
				}
			} else {
				styles.splice(ret, 1);
				didChange = true;
			}
		}
		if (didChange) {
			var v = (styles.length > 0 ? styles.join(';') : null);
			dom.domSet('style', v);
		}
#end
		return v;
	}

	// ===================================================================================
	// data binding, replication
	// ===================================================================================
	public static inline var DATA_VALUE = 'data';
	public static inline var DATAOFFSET_VALUE = 'dataOffset';
	public static inline var DATALENGTH_VALUE = 'dataLength';
	var clones: Array<Element>;

	public inline function setClones(clones:Array<Element>) {
		this.clones = clones;
	}

	inline function initData() {
		if (values.exists(DATA_VALUE)) {
			values.get(DATA_VALUE).callback = dataCallback;
		}
	}

	//TODO: on-add-clone, on-remove-clone special handlers
	//TODO: auto-hide if data is null
	function dataCallback(v:Dynamic, k:String, userData:Dynamic): Dynamic {
		// dependencies
		var offset:Null<Int> = getLocal(DATAOFFSET_VALUE);
		var length:Null<Int> = getLocal(DATALENGTH_VALUE);

		if (Std.is(v, Array)) {
			var a:Array<Dynamic> = cast v;

			if (offset != null || length != null) {
				offset == null ? offset = 0 : null;
				length == null ? length = cast Math.max(0, a.length - offset) : null;
				a = a.slice(offset, offset + length);
			}

			if (clone != null) {
				// it's a clone
				var i = clone.index;
				return (i >= 0 && i < a.length ? a[i] : null);
			} else {
				var count:Int = cast Math.max(a.length - 1, 0);
				clones == null ? clones = [] : null;
				// create missing clones
				for (i in 0...count) {
					if (i >= clones.length) {
						var c = cloneSelf(i);
						clones.push(c);
						c.refresh();
					}
				}
				// remove exceeding clones
				while (clones.length > count) {
					var c = clones.pop();
					c.dom.domRemove();
					c.remove();
				}
				var ret = (a.length > 0 ? a[a.length - 1] : null);
				return ret;
			}
		} else {
			//TODO: remove possible clones
			//TODO: automatic hiding of element when v == null
			return v;
		}
	}

	function cloneSelf(cloneIndex:Int): Element {
		var html = dom.domOuterHTML();
		var wrapper = root.doc.domCreateElement('div');
		wrapper.domSetHtml(html);
		var e = wrapper.domFirstElementChild();
		e.domSet(CLONE_ATTR, '' + cloneIndex);
		dom.domParent().domAddChild(e, dom);
		var ret = root.load(parent, e, cloneIndex);
		return ret;
	}

}
