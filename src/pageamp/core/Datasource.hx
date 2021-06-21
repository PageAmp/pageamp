package pageamp.core;

import pageamp.reactivity.ReValue;
import pageamp.lib.Url;
import haxe.Http;
import haxe.Json;
import pageamp.core.Element;

using pageamp.lib.PropertyTools;

class Datasource extends Element {
	public static inline var URL_VALUE = 'url';
	
	public function new(parent:Element, props:ElementProps) {
		props == null ? props = {} : null;
		props.values == null ? props.values = {} : null;
		// ensure :data is not defined
		props.values.set(Element.DATA_VALUE, null);
		super(parent, props);
		new ReValue(this, Element.DATA_VALUE, null).valueFn = dataValueFn;
	}

	function dataValueFn() {
		var ret = null;
		if (values.exists(URL_VALUE)) {
			// dynamic datasource
			if (needsRequest()) {
				try {
					ret = doRequest();
				} catch (ignored:Dynamic) {}
			}
		} else {
			// static datasource
			try {
				ret = Json.parse(dom.innerHTML);
			} catch (ignored:Dynamic) {}
		}
		return ret;
	}

	// ===================================================================================
	// Dynamic datasource
	// ===================================================================================
	var http: Http = null;

	function needsRequest(): Bool {
		return true; //TODO
	}

	inline function isRequesting(): Bool {
		return (http != null);
	}

	function cancelRequest() {
		//TODO
	}

	//TODO: nodejs (and possibly client js) only supports async requests
	function doRequest() {
		var ret = null;
		cancelRequest();
		try {
			var url = new Url(get(URL_VALUE));
			var text = null;
			http = new Http(url.toString());
			http.onData = (data) -> {
				text = data.split('<').join('&lt;');
			};
			http.onError = (error) -> {
				throw error;
			}
			http.request();
			ret = Json.parse(text);
			dom.innerHTML = text;
		} catch (ex:Dynamic) {
			dom.innerHTML = '';
			//TODO
		}
		return ret;
	}

}
