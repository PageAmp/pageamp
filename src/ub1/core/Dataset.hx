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

package ub1.core;

import ub1.Ub1Log;
import ub1.util.Observable;
import haxe.Timer;
import haxe.Http;
import ub1.test.UnblockedException;
import ub1.data.DataProvider;
import ub1.util.Url;
import ub1.util.Util;

// https://stackoverflow.com/questions/12712101/embedding-xml-in-html#12712221
// restrictions-for-contents-of-script-elements: https://tinyurl.com/yaaeg5rt
class Dataset extends Element implements DataProvider {
	public static inline var TAGNAME = 'ub1-dataset';
	// static data
	public static inline var XML_PROP = 'xml';
	public static inline var TEXT_PROP = 'text';
	public static inline var JSON_PROP = 'json';
	public static inline var JSONROOTNAME_PROP = 'jroot';
	public static inline var JSONARRAYITEMNAME_PROP = 'jitem';
	public static inline var DOC_VALUE = '__doc';
	// synthetic data
	public static inline var CLIENT_PROP = 'client';
	public static inline var SERVER_PROP = 'server';
	// remote data
	public static inline var SRC_PROP = 'src';
	public static inline var POST_PROP = 'post';
	public static inline var ASYNC_PROP = 'async';
	public static inline var CACHING_PROP = 'caching';
	public static inline var TIMEOUT_PROP = 'timeout';
	public static inline var ERROR_VALUE = 'error';
	public var observable = new Observable();

	// =========================================================================
	// as DataProvider
	// =========================================================================

	public function getData(?url:Url): Xml {
		return get(DOC_VALUE);
	}

	public function isRequesting(): Bool {
		return (http != null);
	}

	/**
	 * abort pending data request
	 */
	public function abortRequest(): Void {
		if (http != null) {
			clearHttp();
			observable.notifyObservers(this, DataNotification.REQUESTABORT);
		}
	}

	// =========================================================================
	// private
	// =========================================================================
	static inline var NO_CACHING = 0;
	static inline var CYCLE_CACHING = -1;
	static inline var URL_CACHING = -2;
	static inline var FORCED_CACHING = -3;
	static inline var DEFAULT_TIMEOUT = 30000;
	var lastSrc:String = null;
	var lastUrl:Url = null;
	var requestTime = -1.0;
	var requestUrl:Url = null;
	var http:Http = null;
#if !php
	var timer:Timer;
#end

	override function init() {
		makeScope();
		super.init();
		scope.setValueFn(DOC_VALUE, docValueFn);
	}

	override function makeDomElement() {
		e = page.createDomElement('script', {type:'text/xml'});
	}

	function docValueFn() {
		var ret:Xml = null;
		// ensure dependencies
		get(XML_PROP);
		get(XML_PROP);
		get(JSON_PROP);
		var src = get(SRC_PROP);
		var local = null;
#if client
		local = get(CLIENT_PROP);
#end
#if server
		local = get(SERVER_PROP);
#end
		if (local != null) {
			try {
				ret = Util.jsonToXml(local,
					get(JSONROOTNAME_PROP, false),
					get(JSONARRAYITEMNAME_PROP, false));
			} catch (ue:UnblockedException) {
				throw ue;
			} catch (error:Dynamic) {
				//TODO
			}
		} else {
			// parse data
			ret = parseData();
			// load if needed
			var url = needsReload(src);
			if (url != null) {
				loadData(url);
				// in case loadData() was synchronous
				ret = parseData();
			}
		}
		return ret;
	}

	function parseData(): Xml {
		var xml = get(XML_PROP, false);
		var text = get(TEXT_PROP, false);
		var json = get(JSON_PROP, false);
		var ret:Xml = get(DOC_VALUE, false);
		if (xml != null) {
			try {
				ret = Xml.parse(xml);
			} catch (ue:UnblockedException) {
				throw ue;
			} catch (error:Dynamic) {
				//TODO
			}
			set(XML_PROP, null, false);
		} else if (text != null) {
			ret = Xml.parse('<text/>');
			ret.firstElement().addChild(Xml.createCData(text));
			set(TEXT_PROP, null, false);
		} else if (json != null) {
			try {
				ret = Util.jsonTextToXml(json,
					get(JSONROOTNAME_PROP, false),
					get(JSONARRAYITEMNAME_PROP, false));
			} catch (ue:UnblockedException) {
				throw ue;
			} catch (error:Dynamic) {
				//TODO
			}
			set(JSON_PROP, null, false);
		}
		return ret;
	}

	inline function needsReload(src:String): Url {
		var caching = Util.toInt2(get(CACHING_PROP, false), URL_CACHING);
		var time = page.scope.context.cycleTime;
		var go = false;
		var ret:Url = null;
		if (src != null/* && (autoRequest || !selfRefreshing)*/) {
			try {
				ret = lastUrl = (src == lastSrc ? lastUrl : new Url(src));
				ret = (ret == null && src != null ? new Url(src) : ret);
			} catch (ue:UnblockedException) {
				throw ue;
			} catch (error:Dynamic) {
				//TODO
			}
			if (caching > 0) {
				go = (requestTime < 0 ? true : (requestTime + caching) < time);
			} else if (caching == NO_CACHING) {
				go = (time > requestTime);
			} else if (caching == URL_CACHING) {
				if (requestUrl == null) {
					go = true;
				} else {
					go = !Url.urlsAreEqual(ret, requestUrl);
				}
			} else if (caching == FORCED_CACHING) {
				go = (requestTime < 0);
			}
		}
		lastSrc = src;
		lastUrl = ret;
		return (go ? ret : null);
	}

	function loadData(url:Url) {
		var post = getBool(POST_PROP, false, false);
		var async = getBool(ASYNC_PROP, true, false);
		var timeout = getInt(TIMEOUT_PROP, DEFAULT_TIMEOUT, false);
		var time = page.scope.context.cycleTime;

		try {
			abortRequest();

			set(ERROR_VALUE, null);
			var s = url.toString(true, true, true, false);
			http = new Http(s);
			if (url.params != null) {
				for (key in url.params.keys()) {
					var val = url.params.get(key);
					http.setParameter(key, val);
				}
			}

			http.onData = function(text:String) {
				Ub1Log.data('$uid onData: $text');
				clearHttp();
				if (~/^\s*[\{\[]/.match(text)) {
					set(JSON_PROP, text, false);
					set(DOC_VALUE, parseData()).valueFn = docValueFn;
				} else if (~/^\s*</.match(text)) {
					set(XML_PROP, text, false);
					set(DOC_VALUE, parseData()).valueFn = docValueFn;
				} else {
					set(TEXT_PROP, text, false);
					set(DOC_VALUE, parseData()).valueFn = docValueFn;
				}
				observable.notifyObservers(this, DataNotification.REQUESTEND);
			}

			http.onError = function(error:String) {
				Ub1Log.data('$id onError: $error');
				clearHttp();
				set(ERROR_VALUE, error);
				observable.notifyObservers(this, DataNotification.REQUESTEND);
			}

#if logData
			http.onStatus = function(status:Int) {
				Log.data('$uid onStatus: $status');
			}
#end

			requestUrl = url;
			requestTime = time;
			observable.notifyObservers(this, DataNotification.REQUESTSTART);
#if js
			untyped http.async = async;
			if (async) {
				var t = new Timer(Std.int(timeout * 1000));
				t.run = function() {
					http.onError('TimeoutError');
				}
				timer = t;
			}
#else
			//TODO: il timeout in PHP non funge
			http.cnxTimeout = timeout;
#end
			http.request(post);
		} catch (ue:UnblockedException) {
			throw ue;
		} catch (error:Dynamic) {
			//TODO
		}
	}

	function clearHttp() {
		if (http != null) {
			http.onData = http.onError = function(s:String) {};
#if logData
			http.onStatus = function(i:Int) {};
#end
			http = null;
#if !php
			if (timer != null) {
				timer.stop();
				timer = null;
			}
#end
		}
	}

}
