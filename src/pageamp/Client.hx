package pageamp;

import pageamp.core.Body;
import pageamp.core.Element;
import pageamp.core.Head;
import pageamp.core.Page;

using pageamp.lib.DomTools;


class Client {

	public static function load(doc:DomDocument, pageProps:Array<ElementProps>): Page {
		for (i in 0...pageProps.length) {
			pageProps[i].id = i;
		}
		pageProps[0].id = 0;
		pageProps[0].dom = doc.domGetRootElement();
		var ret = new Page(doc, pageProps[0], pageProps);
		loadChildren(pageProps, ret, ret.dom);
		ret.context.refresh();
		return ret;
	}

	static function loadChildren(pageProps:Array<ElementProps>,
				p:Element, dom:DomElement) {
		var s: String;
		var clones: Array<Element> = null;

		var child = dom.domFirstElementChild();
		while (child != null) {
			if ((s = child.domGet(Element.ID_ATTR)) != null) {
				var id = Std.parseInt(s);
				var props = pageProps[id];
				props.id = id;
				props.dom = child;
				var e:Element = switch (child.domGetTagname()) {
					case 'HEAD': new Head(p, props);
					case 'BODY': new Body(p, props);
					default: new Element(p, props);
				};
				loadChildren(pageProps, e, child);

				// handle clones
				if ((s = child.domGet(Element.CLONE_ATTR)) != null) {
					// this is a clone
					clones == null ? clones = [] : null;
					clones.push(e);
				} else if (clones != null) {
					// this is a clones origin
					e.setClones(clones);
					clones = null;
				}
			} else {
				loadChildren(pageProps, p, child);
			}
			child = child.domNextElementSibling();
		}
	}

}
