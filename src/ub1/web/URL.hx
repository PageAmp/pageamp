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

package ub1.web;

using StringTools;

//http://old.haxe.org/doc/snip/uri_parser
class URL {
	public var source : String;
	public var protocol : String;
	public var authority : String;
	public var userInfo : String;
	public var user : String;
	public var password : String;
	public var host : String;
	public var port : String;
	public var relative : String;
	public var path : String;
	public var directory : String;
	public var file : String;
	public var query(get,null) : String;
	public var anchor : String;

	public function new(url:String) {
		// The almighty regexp (courtesy of http://blog.stevenlevithan.com/archives/parseuri)
		var r : EReg = ~/^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/;
		// Match the regexp to the url
		r.match(url);
		// Use reflection to set each part
		for (i in 0..._parts.length) {
			Reflect.setField(this, _parts[i],  r.matched(i));
		}
	}

	public function toString() : String {
		var sb = new StringBuf();
		protocol != null ? sb.add('$protocol://') : null;
		host != null ? sb.add(host) : null;
		path != null ? sb.add(path) : null;
		var q = query;
		q != null ? sb.add('?$q') : null;
		anchor != null ? sb.add('#$anchor') : null;
		return sb.toString();
	}

	public function getPathSlice(pos:Int, defval:String=null): String {
		var ret:String = null;
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

	public function get_query(): String {
		if (_query != null) {
			return _query;
		} else if (params != null) {
			var sb = new StringBuf();
			var sep = '';
			for (key in params.keys()) {
				sb.add(sep); sep = '&';
				sb.add(key); sb.add('=');
				sb.add(params.get(key).urlEncode());
			}
			return sb.toString();
		}
		return null;
	}

	public function getParam(key:String, defval='') {
		if (params == null && _query != null) {
			params = new Map<String,String>();
			var pp = _query.split('&');
			for (p in pp) {
				var kv:Array<String> = p.split('=');
				if (kv.length > 0) {
					var v = kv.length > 1 ? kv[1].urlDecode().trim() : null;
					params.set(kv[0].urlDecode().trim(), v);
				}
			}
			_query = null; // switch to params map rather than _query
		}
		var ret:String = params != null ? params.get(key) : null;
		return (ret != null ? ret : defval);
	}

	public function setParam(key:String, val:String) {
		if (params == null) {
			if (_query != null) {
				getParam(''); // parse _query into params map
			} else {
				params = new Map<String,String>();
			}
		}
		params.set(key, val);
	}

	public function getAnchor(defval='') {
		return (anchor != null ? anchor : defval);
	}

	// =========================================================================
	// private
	// =========================================================================
	static private var _parts : Array<String> = ["source","protocol","authority",
	"userInfo","user","password","host","port","relative","path","directory",
	"file","_query","anchor"];
	var pathSlices: Array<String>;
	var _query: String;
	var params: Map<String,String>;

}