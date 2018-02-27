/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.util;

using StringTools;

class Url {
	// http://tools.ietf.org/html/rfc3986#page-50
	static var urlMatchRegex = ~/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/i;
	static var paramsSplitRegex = ~/[&;]/;
	public var protocol: String;
	public var domain: String;
	public var path: String;
	public var query: String;
	public var params: Map<String,String>;
	var paramCount: Int;
	var pathSlices: Array<String>;

    // throws Dynamic
	public function new(url:String, params:Map<String,String> =null) {
		if (urlMatchRegex.match(url)) {
			try {
				var s;
				protocol = (isTrue((s = urlMatchRegex.matched(2))) ? s : null);
				domain = (isTrue((s = urlMatchRegex.matched(4))) ? s : null);
				path = (isTrue((s = urlMatchRegex.matched(5))) ? s : null);
				query = (isTrue((s = urlMatchRegex.matched(7))) ? s : null);
				pathSlices = null;
				this.params = (params == null && query != null
								? parseQueryString(query)
								: params);
				paramCount = -1;
			} catch (e:Dynamic) {
				throw('Url.new() - invalid URL: "$url"');
			}
		} else {
			throw('Url.new() - invalid URL: "$url"');
		}
	}

	public function getPathSlice(pos:Int, defval:String=null) {
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

	public function getLastPathSlice(defval:String=null) {
		getPathSlice(1);
		return (pathSlices != null && pathSlices.length > 0 ?
				pathSlices[pathSlices.length - 1] : defval);
	}

	public function getSuffix(defval:String=null) {
		var name:String = getLastPathSlice();
		var i = (name != null ? name.lastIndexOf('.') : -1);
		return (i >= 0 ? name.substr(i + 1) : null);
	}

	public function getParam(key:String, defval:String=null) {
		var ret = (params != null ? params.get(key) : null);
		return (ret != null ? ret : defval);
	}

	public function getParamCount() {
		if (paramCount < 0) {
			paramCount = (params != null ? MapTool.mapSize(params) : 0);
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

	public function toString(okProtocol:Bool=true, okDomain:Bool=true,
		okPath:Bool=true, okQuery:Bool=true) {
		var sb = new StringBuf();
		if (okProtocol && protocol != null) {
			sb.add(protocol); sb.add('://');
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
		return sb.toString();
	}

	public static function urlsAreEqual(a:Url, b:Url): Bool {
		if (a == null && b == null) {
			return true;
		} else if (a == null || b == null) {
			return false;
		} else {
			return (a.protocol == b.protocol &&
				a.domain == b.domain &&
				a.path == b.path &&
				MapTool.mapsAreEqual(a.params, b.params));
		}
	}

	public static function parseQueryString(query: String): Map<String,String> {
		var ret = null;
		var i = query.indexOf('?');
		if (i >= 0) {
			query = query.substr(i + 1);
		}
		var params = paramsSplitRegex.split(query);
		if (params.length > 1 || params[0].length > 0) {
			ret = new Map<String,String>();
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

	public static function paramsToString(params:Map<String,String>,
		nonempty:Bool=true): String {
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
				sb.add(sep); sep = '&';
				sb.add(StringTools.urlEncode(key));
				sb.add('=');
				sb.add(StringTools.urlEncode(val));
			}
			ret = sb.toString();
		}
		return ret;
	}

	static function isTrue(s:String, defval=false): Bool {
		s = (s != null ? StringTools.trim(s) : null);
		return (s != null && s.length > 0 ?
		s != '0' && s != 'null' && s.toLowerCase() != 'false' : defval
		);
	}

}
