package pageamp.server;

import pageamp.core.Body;
import pageamp.core.Element;
import pageamp.core.Head;
import pageamp.core.Page;
import pageamp.reactivity.ReParser;
import pageamp.server.dom.HtmlNode;

using StringTools;
using pageamp.lib.DomTools;
using pageamp.lib.PropertyTools;


class ServerLoader {
	public static inline var LOGIC_ATTR_PREFIX = ':';
	public static inline var LOGIC_NAME_ATTR = LOGIC_ATTR_PREFIX + 'name';
	
	public static function loadRoot(doc:DomDocument): Page {
		var root = doc.domGetRootElement();
		var ret = new Page(doc, getElementProps(root));
		loadChildren(ret, root, true);
		return ret;
	}

	public static function getElementProps(dom:DomElement): ElementProps {
		var ret:ElementProps = {dom:dom};
		for (a in dom.attributes) {
			if (a.quote == '[') {
				a.value = '[[' + a.value + ']]';
			}
		}
		for (k in dom.domAttributeNames()) {
			var v = dom.domGet(k);
			if (k.startsWith(LOGIC_ATTR_PREFIX)) {
				if (k == LOGIC_NAME_ATTR) {
					ret.name = v;
				} else {
					ret.values = ret.values.set(k.substr(1), v);
				}
				dom.domSet(k, null);
			} else if (ReParser.isDynamic(v)) {
				ret.attr = ret.attr.set(k, v);
				dom.domSet(k, '');
			}
		}
		var i = 0;
		for (n in dom.children) {
			if (n.type == HtmlNode.TEXT_NODE) {
				var v = cast(n, DomTextNode).domGetNodeText();
				if (ReParser.isDynamic(v)) {
					ret.texts == null ? ret.texts = [] : null;
					ret.texts.push({index: i, text: v});
					cast(n, DomTextNode).domSetNodeText(' ');
				}
			}
			i++;
		}
		return ret;
	}

	static function loadChildren(p:Element, dom:DomElement, firstLevel=false) {
		for (n in dom.children) {
			if (n.type == HtmlNode.ELEMENT_NODE) {
				var child:DomElement = cast n;
				var props = getElementProps(child);
				if (props.name != null
					|| props.values != null
					|| props.attr != null
					|| props.texts != null
					|| firstLevel) {
					var e = switch (child.name) {
						case 'HEAD': new Head(p, props);
						case 'BODY': new Body(p, props);
						default: new Element(p, props);
					};
					loadChildren(e, child);
				} else {
					loadChildren(p, child);
				}
			}
		}
	}

}
