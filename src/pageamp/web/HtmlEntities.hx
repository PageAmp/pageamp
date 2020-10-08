package pageamp.web;

class HtmlEntities {

	public static function decode(s:String): String {
#if entityDecoder
		return ~/(&\w{2,30};)/g.map(s, function(re:EReg) {
			//trace('map(): ${re.matched(1)}');
			// haxelib install html-entities
			var ret = html.Entities.all[re.matched(1)];
			//trace('map(): ${re.matched(1)} -> $ret');
			return ret != null ? ret : '';
		});
#else
		return s;
#end
	}

}
