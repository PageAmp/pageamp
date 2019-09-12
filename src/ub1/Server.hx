/*
 * Copyright (c) 2018-2019 Ubimate Technologies Ltd and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package ub1;

import ub1.Ub1Log;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import htmlparser.HtmlDocument;
import ub1.core.*;
import ub1.server.Loader;
import php.Lib;
import php.Web;
import StringTools;
import ub1.server.Preprocessor;
import ub1.util.PropertyTool;
using ub1.util.PropertyTool;
using StringTools;

class Server {
	#if demo
		public static inline var SOURCEIN_ARG = 'ub1_source_in';
		public static inline var SOURCEOUT_ARG = 'ub1_source_out';
		public static inline var SOURCECOMPILE_ARG = 'ub1_source_compile';
	#end
	public static inline var DOMAINS_ROOT = '__ub1/domains/';
	public static inline var SITES_ROOT = '__ub1/sites/';
	public static inline var RESOURCES_ROOT = '__ub1/res/';

	public static function main() {
		var params = Web.getParams();
		var uri = Web.getURI();
		var domain = Web.getHostName();
		var root = DOMAINS_ROOT + domain;
		var re = ~/\.(\w+)$/;
		var ext = re.match(uri) ? re.matched(1) : null;
		Ub1Log.server('domain: $domain');
		Ub1Log.server('uri: $uri');
		Ub1Log.server('ext: $ext');
		// 'htm' files are never served (they're page fragments)
		if (ext != null && ext != 'html') {
			if (ext != 'htm') {
				outputFile(root, uri, ext);
			} else {
				outputResource(root, '404.html', 404);
			}
		} else {
			ext == 'html' ? uri = uri.split('.$ext')[0] : null;
			uri.endsWith('/') ? uri = uri + 'index' : null;
			#if demo
				if (params.get(SOURCEIN_ARG) == 'true') {
					outputSourceFile(root, uri);
				} else {
					outputPage(root, domain, uri, params);
				}
			#else
				outputPage(root, domain, uri, params);
			#end
		}
	}

	// =========================================================================
	// outputFile()
	// =========================================================================

	// http://en.wikipedia.org/wiki/Internet_media_type
	static function outputFile(root:String, uri:String, ext:String) {
		try {
			Web.setHeader('Content-type', switch (ext) {
				case 'js': 'application/javascript';
				case 'json': 'application/json';
				case 'xml': 'application/xml';
				case 'txt': 'text/plain';
				case 'css': 'text/css';
				case 'jpg': 'image/jpeg';
				case 'jpeg': 'image/jpeg';
				case 'png': 'image/png';
				case 'manifest': 'text/cache-manifest';
				case 'ico': 'image/x-icon';
				//TODO
				default: 'text/html';
			});
			Lib.printFile(root + uri);
		} catch (e:Dynamic) {
			outputResource(root, '404.html', 404);
		}
	}

	// =========================================================================
	// outputResource()
	// =========================================================================

	static function outputResource(root:String, fname:String, code=200) {
		Web.setReturnCode(code);
		try {
			// site-specific, if available
			Lib.printFile('$root/res/$fname');
		} catch (e:Dynamic) {
			// generic
			Lib.printFile(RESOURCES_ROOT + fname);
		}
	}

	// =========================================================================
	// outputPage()
	// =========================================================================

	static function outputPage(root:String,
	                           domain:String,
	                           uri:String,
	                           params:Map<String,String>) {
		var src:HtmlDocument = null;
		//uri = uri.replace('%20', ' ');
		Ub1Log.server('outputPage($root, $uri)');
		try {
			var p = new Preprocessor();
			#if demo
				if (params.exists(SOURCECOMPILE_ARG)) {
					src = p.loadText(root + uri + '.html',
									 root,
									 params.get(SOURCECOMPILE_ARG));
				} else {
					src = p.loadFile(root + uri, root);
				}
			#else
				src = p.loadFile(root + uri, root);
			#end
		} catch (e:Dynamic) {
			Ub1Log.server('outputPage(): ' + e);
			if (!uri.endsWith('/') &&
					FileSystem.exists(root + uri) &&
					FileSystem.isDirectory(root + uri)) {
				Web.redirect(uri + '/');
			} else {
			}
		}
		try {
			var path = new Path(root + uri);
			var u = Web.getURI();
			var q = Web.getParamsString();
			q != null ? u += ('?' + q) : null;
			var page = Loader.loadPage(src, null, path.dir, domain, u);
			#if !logServer
				#if demo
					if (params.get(SOURCEOUT_ARG) == 'true') {
						outputSourceText(root, page.toMarkup());
					} else {
						page.output();
					}
				#else
					page.output();
				#end
			#end
		} catch (e:Dynamic) {
			#if test
				Web.setHeader('Content-type', 'text/plain');
				Lib.println(e);
			#else
				outputResource(root, '404.html', 404);
			#end
		}
	}

	// =========================================================================
	// outputSourceFile()
	// =========================================================================

	static function outputSourceFile(root:String, uri:String) {
		try {
			var s = File.getContent(root + uri + '.html');
			outputSourceText(root, s);
		} catch (e:Dynamic) {
			outputResource(root, '404.html', 404);
		}
	}

	// =========================================================================
	// outputSourceText()
	// =========================================================================

	static function outputSourceText(root:String, s:String) {
		try {
			Web.setHeader('Content-type', 'text/html');
			Lib.print('<html><body><pre>');
			s = s.split("<").join("&lt;")
			.split(">").join("&gt;")
			.split("\t").join("    ");
			Lib.print(s);
			Lib.print('</pre></body></html>');
		} catch (e:Dynamic) {
			outputResource(root, '404.html', 404);
		}
	}

}
