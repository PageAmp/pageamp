package ub1.lib;

using StringTools;

class Url {
	// http://tools.ietf.org/html/rfc3986#page-50
	static var urlMatchRegex = ~/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/i;
	static var paramsSplitRegex = ~/[&;]/g;

	public var protocol:String;
	public var domain:String;
	public var path:String;
	public var query:String;
	public var fragment:String;
	public var params:Map<String, String>;

	var paramCount:Int;
	var pathSlices:Array<String>;

	// throws Dynamic
	public function new(url:String, params:Map<String, String> = null) {
		if (urlMatchRegex.match(url)) {
			try {
				var s:String;
				protocol = (isTrue((s = urlMatchRegex.matched(2))) ? s : null);
				domain = (isTrue((s = urlMatchRegex.matched(4))) ? s : null);
				path = (isTrue((s = urlMatchRegex.matched(5))) ? s : null);
				query = (isTrue((s = urlMatchRegex.matched(7))) ? s : null);
				fragment = (isTrue((s = urlMatchRegex.matched(8))) ? s.substr(1) : '');
				pathSlices = null;
				this.params = (params == null && query != null ? parseQueryString(query) : params);
				paramCount = -1;
			} catch (e:Dynamic) {
				throw('Url.new() - invalid URL: "$url"');
			}
		} else {
			throw('Url.new() - invalid URL: "$url"');
		}
	}

	public function getPathSlice(pos:Int, defval:String = null) {
		var ret = null;
		if (path != null) {
			if (pos > 0) {
				if (pathSlices == null) {
					pathSlices = path.split("/");
				}
				if (pos > 0 && pos <= pathSlices.length) {
					ret = pathSlices[pos - 1];
				}
			} else {
				ret = path;
			}
		}
		return (ret != null && ret.length > 0 ? ret : defval);
	}

	public function getLastPathSlice(defval:String = null) {
		getPathSlice(1);
		return (pathSlices != null && pathSlices.length > 0 ? pathSlices[pathSlices.length - 1] : defval);
	}

	public function getSuffix(defval:String = null) {
		var name:String = getLastPathSlice();
		var i = (name != null ? name.lastIndexOf('.') : -1);
		return (i >= 0 ? name.substr(i + 1) : null);
	}

	public function getParam(key:String, defval:String = null) {
		var ret = (params != null ? params.get(key) : null);
		return (ret != null ? ret : defval);
	}

	public function getParamCount() {
		if (paramCount < 0) {
			paramCount = (params != null ? MapTools.mapSize(params) : 0);
		}
		return paramCount;
	}

	public function setParam(key:String, val:String) {
		if (params == null) {
			params = new Map<String, String>();
		}
		params.set(key, val);
		paramCount = -1;
	}

	public function toString(okProtocol:Bool = true, okDomain:Bool = true, okPath:Bool = true, okQuery:Bool = true, okFragment:Bool = true) {
		var sb = new StringBuf();
		if (okProtocol && protocol != null) {
			sb.add(protocol);
			sb.add('://');
		}
		if (okDomain && domain != null) {
			sb.add(domain);
		}
		if (okPath && path != null) {
			sb.add(path);
		}
		if (okQuery && params != null) {
			sb.add(paramsToString(params));
		}
		if (okFragment && fragment != null && fragment.length > 0) {
			sb.add('#' + fragment);
		}
		return sb.toString();
	}

	public function mergeParams(query:String) {
		var p = parseQueryString(query);
		for (key in p.keys()) {
			setParam(key, p.get(key));
		}
	}

	public static function urlsAreEqual(a:Url, b:Url, fragment = true):Bool {
		if (a == null && b == null) {
			return true;
		} else if (a == null || b == null) {
			return false;
		} else {
			return (a.protocol == b.protocol
				&& a.domain == b.domain
				&& a.path == b.path
				&& MapTools.mapsAreEqual(a.params, b.params)
				&& (!fragment || a.fragment == b.fragment));
		}
	}

	public static function parseQueryString(query:String):Map<String, String> {
		var ret = null;
		var i = query.indexOf('?');
		if (i >= 0) {
			query = query.substr(i + 1);
		}
		var params = paramsSplitRegex.split(query);
		if (params.length > 1 || params[0].length > 0) {
			ret = new Map<String, String>();
			for (param in params) {
				var parts = param.split('=');
				var key = StringTools.urlDecode(StringTools.trim(parts[0]));
				var val = parts.length > 1 ? StringTools.urlDecode(StringTools.trim(parts[1])) : '';
				if (key != '') {
					ret.set(key, val);
				}
			}
		}
		return ret;
	}

	public static function paramsToString(params:Map<String, String>, nonempty:Bool = true):String {
		var ret = '';
		if (params != null) {
			var sb = new StringBuf();
			var sep = '?';
			if (nonempty) {
				sb.add(sep);
				sep = '';
			}
			for (key in params.keys()) {
				var val = params.get(key);
				sb.add(sep);
				sep = '&';
				sb.add(StringTools.urlEncode(key));
				sb.add('=');
				sb.add(StringTools.urlEncode(val));
			}
			ret = sb.toString();
		}
		return ret;
	}

	static function isTrue(s:String, defval = false):Bool {
		s = (s != null ? StringTools.trim(s) : null);
		return (s != null && s.length > 0 ? s != '0' && s != 'null' && s.toLowerCase() != 'false' : defval);
	}
}
