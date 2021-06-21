package pageamp.core;

import pageamp.lib.Url;
import pageamp.core.Element;
import pageamp.reactivity.ReConst;

using StringTools;
using pageamp.lib.DomTools;
using pageamp.lib.PropertyTools;


class Page extends Element {
	public var doc: DomDocument;
	public var refreshURL: Url;
	var propsRegistry: Array<ElementProps>;
	var refreshCB: Page->Void;

	public function new(doc:DomDocument, props:ElementProps, ?pageProps:Array<ElementProps>) {
		this.doc = doc;
		this.propsRegistry = (pageProps != null ? pageProps : []);
		props == null ? props = {} : null;
		props.name == null ? props.name = 'page' : null;
		super(null, props);
	}

	public function registerElement(props:ElementProps): Int {
		var ret = propsRegistry.length;
		props.id = ret;
		propsRegistry.push(props);
		return ret;
	}

	//TODO: use in Client, PhpServer, JavaServer and NodeServer
	public function pageRefresh(url:Url, ?cb:Page->Void) {
		//TODO: url must be a predeclared value in Page
		this.refreshURL = url;
		this.refreshCB = cb;
		context.refresh();
	}

	/**
	 * Must be used in the server only once, after page refresh,
	 * to transfer page state to the client.
	 * @return Array<ElementProps>
	 */
	public function getProps(): Array<ElementProps> {
		for (p in propsRegistry) {
			var e = p._e;
			for (k in e.values.keys()) {
				var v = e.values.get(k);
				if (!k.startsWith('-')
						&& !Std.isOfType(v, ReConst)
						&& !v.isFunction) {
					//TODO: values that weren't `set()` shouldn't need state entry
					p._v == null ? p._v = {} : null;
					p._v.set2(k, v.v);
				}
			}
			p.set('id', null); // removes property `id`
			p.set('_e', null); // removes property `_e`
		}
		return propsRegistry;
	}

	public function load(parent:Element, dom:DomElement, ?cloneIndex:Int) {
		var id = Std.parseInt(dom.domGet(Element.ID_ATTR));
		var props = propsRegistry[id];
		props.dom = dom;
		cloneIndex != null ? props.clone = {source:id, index:cloneIndex} : null;
		var ret = new Element(parent, props);
		var f = null;
		f = function(dom:DomElement) {
			var e = dom.domFirstElementChild();
			while (e != null) {
				if (e.domGet(Element.ID_ATTR) != null) {
					load(ret, e);
				}
				e = e.domNextElementSibling();
			}
		}
		f(dom);
		return ret;
	}

}
